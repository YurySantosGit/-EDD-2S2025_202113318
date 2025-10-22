unit blockchain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TCorreoData = class
  public
    Id: Integer;
    Remitente: string;
    Asunto: string;
    Mensaje: string;
    Fecha: string;
    constructor Create(AId: Integer; const ARemitente, AAsunto, AMensaje, AFecha: string);
  end;

  TBloque = class
  public
    Index: Integer;
    Timestamp: TDateTime;
    Data: TCorreoData;
    PreviousHash: string;
    Nonce: Integer;
    Hash: string;

    constructor Create(AIndex: Integer; AData: TCorreoData; const APrevHash: string);
    function  CalcularHash: string;
    procedure Minar(Dificultad: Integer);
  end;

  TBlockchain = class
  private
    FChain: TList;
    function  GetUltimoBloque: TBloque;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AgregarBloque(AData: TCorreoData; Dificultad: Integer = 4);
    procedure MostrarCadena(aLines: TStrings);
    function  GenerarDOT: string;
    procedure GuardarDOT(const FileDot: string);
    procedure GuardarPNG(const FileDot, FilePng: string);
    function  Count: Integer;
    function ValidarCadena(out motivo: string; Dificultad: Integer = 4): Boolean;

  end;

function HashStringSHA1(const Texto: string): string;

procedure GenerarReporteBlockchain_Global(const outDir: string = '');
procedure GenerarReporteBlockchain_DeUsuario(const usuarioEmail: string; const outDir: string = '');

implementation

uses
  fpjson, sha1, Process, FileUtil,
  usuarios, bandejas, lista_doble;

function HashStringSHA1(const Texto: string): string;
var
  JSON: TJSONObject;
  Digest: TSHA1Digest;
  i: Integer;
begin
  JSON := TJSONObject.Create;
  try
    JSON.Add('Data', Texto);
    Digest := SHA1String(JSON.AsJSON);
    Result := '';
    for i := 0 to High(Digest) do
      Result := Result + LowerCase(IntToHex(Digest[i], 2));
  finally
    JSON.Free;
  end;
end;

constructor TCorreoData.Create(AId: Integer; const ARemitente, AAsunto, AMensaje, AFecha: string);
begin
  Id        := AId;
  Remitente := ARemitente;
  Asunto    := AAsunto;
  Mensaje   := AMensaje;
  Fecha     := AFecha;
end;

constructor TBloque.Create(AIndex: Integer; AData: TCorreoData; const APrevHash: string);
begin
  Index        := AIndex;
  Timestamp    := Now;
  Data         := AData;
  PreviousHash := APrevHash;
  Nonce        := 0;
  Hash         := CalcularHash;
end;

function TBloque.CalcularHash: string;
var
  InputStr: string;
begin
  InputStr :=
    IntToStr(Index) +
    DateTimeToStr(Timestamp) +
    IntToStr(Data.Id) +
    Data.Remitente +
    Data.Asunto +
    Data.Mensaje +
    Data.Fecha +
    IntToStr(Nonce) +
    PreviousHash;
  Result := HashStringSHA1(InputStr);
end;

procedure TBloque.Minar(Dificultad: Integer);
var
  Prefijo: string;
begin
  if Dificultad < 0 then Dificultad := 0;
  Prefijo := StringOfChar('0', Dificultad);

  Nonce := 0;
  Hash  := CalcularHash;

  while Copy(Hash, 1, Dificultad) <> Prefijo do
  begin
    Inc(Nonce);
    Hash := CalcularHash;
  end;
end;

constructor TBlockchain.Create;
var
  GenesisCorreo: TCorreoData;
  GenesisBlock : TBloque;
begin
  FChain := TList.Create;

  GenesisCorreo := TCorreoData.Create(0, 'system', 'Genesis Block', '', DateTimeToStr(Now));
  GenesisBlock  := TBloque.Create(0, GenesisCorreo, '0');
  FChain.Add(GenesisBlock);
end;

destructor TBlockchain.Destroy;
var
  i: Integer;
  B: TBloque;
begin
  for i := 0 to FChain.Count - 1 do
  begin
    B := TBloque(FChain[i]);
    if Assigned(B) then
    begin
      B.Data.Free;
      B.Free;
    end;
  end;
  FChain.Free;
  inherited;
end;

function TBlockchain.GetUltimoBloque: TBloque;
begin
  Result := TBloque(FChain[FChain.Count - 1]);
end;

procedure TBlockchain.AgregarBloque(AData: TCorreoData; Dificultad: Integer);
var
  Ultimo: TBloque;
  Nuevo : TBloque;
begin
  Ultimo := GetUltimoBloque;
  Nuevo  := TBloque.Create(FChain.Count, AData, Ultimo.Hash);
  Nuevo.Minar(Dificultad);
  FChain.Add(Nuevo);
end;

procedure TBlockchain.MostrarCadena(aLines: TStrings);
var
  i: Integer;
  B: TBloque;
begin
  if aLines <> nil then aLines.Clear;

  for i := 0 to FChain.Count - 1 do
  begin
    B := TBloque(FChain[i]);
    if aLines <> nil then
    begin
      aLines.Add('------- BLOQUE -------');
      aLines.Add('Index: ' + IntToStr(B.Index));
      aLines.Add('Timestamp: ' + DateTimeToStr(B.Timestamp));
      aLines.Add('Id Correo: ' + IntToStr(B.Data.Id));
      aLines.Add('Remitente: ' + B.Data.Remitente);
      aLines.Add('Asunto: ' + B.Data.Asunto);
      aLines.Add('Fecha: ' + B.Data.Fecha);
      aLines.Add('Nonce: ' + IntToStr(B.Nonce));
      aLines.Add('Hash: ' + B.Hash);
      aLines.Add('PrevHash: ' + B.PreviousHash);
      aLines.Add('');
    end;
  end;
end;

function TBlockchain.Count: Integer;
begin
  Result := FChain.Count;
end;

function TBlockchain.ValidarCadena(out motivo: string; Dificultad: Integer): Boolean;
var
  i: Integer;
  cur, prev: TBloque;
  prefijo: string;
begin
  Result := True;
  motivo := '';

  if FChain.Count <= 1 then Exit;

  if Dificultad < 0 then Dificultad := 0;
  prefijo := StringOfChar('0', Dificultad);

  for i := 1 to FChain.Count - 1 do
  begin
    cur  := TBloque(FChain[i]);
    prev := TBloque(FChain[i-1]);

    if cur.PreviousHash <> prev.Hash then
    begin
      Result := False;
      motivo := Format('Enlace roto en bloque %d: PreviousHash != Hash anterior.', [cur.Index]);
      Exit;
    end;

    if cur.CalcularHash <> cur.Hash then
    begin
      Result := False;
      motivo := Format('Hash alterado en bloque %d: CalcularHash <> Hash almacenado.', [cur.Index]);
      Exit;
    end;

    if (Dificultad > 0) and (Copy(cur.Hash, 1, Dificultad) <> prefijo) then
    begin
      Result := False;
      motivo := Format('PoW inválido en bloque %d: hash no cumple %d ceros.', [cur.Index, Dificultad]);
      Exit;
    end;
  end;
end;

function TBlockchain.GenerarDOT: string;
var
  i: Integer;
  B: TBloque;
  DOT: TStringList;
  HashShort, PrevHashShort: string;

  function TruncHash(const H: string): string;
  begin
    if Length(H) <= 15 then Exit(H);
    Result := Copy(H, 1, 15) + '...';
  end;

  function San(const S: string): string;
  var T: string;
  begin
    T := StringReplace(S, #13#10, ' ', [rfReplaceAll]);
    T := StringReplace(T, #10,    ' ', [rfReplaceAll]);
    T := StringReplace(T, #13,    ' ', [rfReplaceAll]);
    T := StringReplace(T, '"', '\"', [rfReplaceAll]);
    Result := T;
  end;

  function TruncText(const S: string; MaxLen: Integer): string;
  begin
    if Length(S) <= MaxLen then Exit(S);
    Result := Copy(S, 1, MaxLen) + '...';
  end;

var
  MsgSan: string;
begin
  DOT := TStringList.Create;
  try
    DOT.Add('digraph Blockchain {');
    DOT.Add('  rankdir=TB;');
    DOT.Add('  ranksep=0.7; nodesep=0.4;');
    DOT.Add('  node [shape=box, style=filled, color=lightblue, fontname="Helvetica"];');
    DOT.Add('  edge [dir=forward];');

    for i := 0 to FChain.Count - 1 do
    begin
      B := TBloque(FChain[i]);
      HashShort     := TruncHash(B.Hash);
      PrevHashShort := TruncHash(B.PreviousHash);
      MsgSan        := TruncText(San(B.Data.Mensaje), 80);

      DOT.Add(Format(
        '  Block%d [label="Index: %d\nTimestamp: %s\nId: %d\nDe: %s\nAsunto: %s\nMensaje: %s\nFecha: %s\nNonce: %d\nHash: %s\nPrevHash: %s"];',
        [B.Index,
         B.Index,
         DateTimeToStr(B.Timestamp),
         B.Data.Id,
         San(B.Data.Remitente),
         San(B.Data.Asunto),
         MsgSan,
         San(B.Data.Fecha),
         B.Nonce,
         HashShort,
         PrevHashShort]
      ));
    end;

    for i := 1 to FChain.Count - 1 do
      DOT.Add(Format('  Block%d -> Block%d;', [i-1, i]));

    DOT.Add('}');
    Result := DOT.Text;
  finally
    DOT.Free;
  end;
end;

procedure TBlockchain.GuardarDOT(const FileDot: string);
var
  s: TStringList;
begin
  s := TStringList.Create;
  try
    s.Text := GenerarDOT;
    s.SaveToFile(FileDot);
  finally
    s.Free;
  end;
end;

procedure TBlockchain.GuardarPNG(const FileDot, FilePng: string);
var
  P: TProcess;
  dotExe: string;
begin
  dotExe := FindDefaultExecutablePath({$IFDEF WINDOWS}'dot.exe'{$ELSE}'dot'{$ENDIF});
  if (dotExe = '') and FileExists('/usr/bin/dot') then dotExe := '/usr/bin/dot';
  if dotExe = '' then Exit;

  P := TProcess.Create(nil);
  try
    P.Executable := dotExe;
    P.Parameters.Add('-Tpng');
    P.Parameters.Add(FileDot);
    P.Parameters.Add('-o');
    P.Parameters.Add(FilePng);
    P.Options := [poWaitOnExit];
    P.Execute;
  finally
    P.Free;
  end;
end;

procedure GenerarReporteBlockchain_Global(const outDir: string);
var
  baseDir: string;
  dotFile, pngFile: string;
  bc: TBlockchain;
  u: PUsuario;
  pb: PBandeja;
  c: PCorreo;
begin
  if outDir <> '' then
    baseDir := IncludeTrailingPathDelimiter(outDir)
  else
    baseDir := 'root-Reportes' + DirectorySeparator;
  ForceDirectories(baseDir);

  dotFile := baseDir + 'blockchain.dot';
  pngFile := baseDir + 'blockchain.png';

  bc := TBlockchain.Create;
  try
    u := ListaUsuarios;
    while u <> nil do
    begin
      pb := ObtenerBandejaPtr(u^.email);
      if (pb <> nil) then
      begin
        c := pb^.cabeza;
        while c <> nil do
        begin
          bc.AgregarBloque(
            TCorreoData.Create(c^.id, c^.remitente, c^.asunto, c^.mensaje, c^.fecha),
            4
          );
          c := c^.siguiente;
        end;
      end;
      u := u^.siguiente;
    end;

    bc.GuardarDOT(dotFile);
    bc.GuardarPNG(dotFile, pngFile);
  finally
    bc.Free;
  end;
end;

procedure GenerarReporteBlockchain_DeUsuario(const usuarioEmail: string; const outDir: string);
var
  baseDir, userCarp: string;
  dotFile, pngFile: string;
  bc: TBlockchain;
  pb: PBandeja;
  c: PCorreo;
begin
  if outDir <> '' then
    baseDir := IncludeTrailingPathDelimiter(outDir)
  else
  begin
    userCarp := Copy(usuarioEmail, 1, Pos('@', usuarioEmail) - 1);
    if userCarp = '' then userCarp := 'usuario';
    baseDir := userCarp + '-Reportes' + DirectorySeparator;
  end;
  ForceDirectories(baseDir);

  dotFile := baseDir + 'blockchain_usuario.dot';
  pngFile := baseDir + 'blockchain_usuario.png';

  bc := TBlockchain.Create;
  try
    pb := ObtenerBandejaPtr(usuarioEmail);
    if (pb <> nil) then
    begin
      c := pb^.cabeza;
      while c <> nil do
      begin
        bc.AgregarBloque(
          TCorreoData.Create(c^.id, c^.remitente, c^.asunto, c^.mensaje, c^.fecha),
          4
        );
        c := c^.siguiente;
      end;
    end;

    bc.GuardarDOT(dotFile);
    bc.GuardarPNG(dotFile, pngFile);
  finally
    bc.Free;
  end;
end;

end.
