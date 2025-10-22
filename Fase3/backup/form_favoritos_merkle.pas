unit form_favoritos_merkle;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  md5, btree_favoritos, app_state, lista_doble, bandejas;

type

  { TFormFavoritosMerkle }

  TFormFavoritosMerkle = class(TForm)
    BtnCerrar: TButton;
    BtnEliminarPorID: TButton;
    BtnRefrescar: TButton;
    BtnVerPorID: TButton;
    EditID: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    LblRoot: TLabel;
    LblCount: TLabel;
    MemoMerkle: TMemo;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnEliminarPorIDClick(Sender: TObject);
    procedure BtnRefrescarClick(Sender: TObject);
    procedure BtnVerPorIDClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure ListarFavoritosYMerkle;
    function  ParseID(out AID: Integer): Boolean;
    procedure RefreshInboxIfOpen;
    function  MD5Hex(const S: AnsiString): AnsiString;
    function  HashFavorito(const F: TFavorito): string;
    procedure FavoritosToHashes(out hashes: TStringList; out countFav: Integer);
    function  MerkleRootFromLeaves(const leaves: TStrings): string;

  public

  end;

var
  FormFavoritosMerkle: TFormFavoritosMerkle;

implementation

{$R *.lfm}

uses
  form_bandeja;

var
  gFavSL   : TStringList = nil;
  gFavCount: Integer     = 0;

procedure AddLineGlobal(const F: TFavorito);
begin
  Inc(gFavCount);
  if Assigned(gFavSL) then
    gFavSL.Add(Format('%d | %s | %s | %s | %s', [
      F.id, F.remitente, F.estado, F.asunto, F.fecha
    ]));
end;

procedure TFormFavoritosMerkle.FormCreate(Sender: TObject);
begin
end;

procedure TFormFavoritosMerkle.FormShow(Sender: TObject);
begin
  ListarFavoritosYMerkle;
end;

procedure TFormFavoritosMerkle.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormFavoritosMerkle.BtnEliminarPorIDClick(Sender: TObject);
var
  id: Integer;
  pB: PBandeja;
  C: PCorreo;
begin
  if not ParseID(id) then Exit;

  if not BFav_Delete(FavoritosBTree, id) then
  begin
    ShowMessage('El ID no estaba en Favoritos.');
    Exit;
  end;

  pB := ObtenerBandejaPtr(UsuarioActualEmail);
  C := BuscarCorreo(pB^, id);
  if C <> nil then
    C^.favorito := False;

  ShowMessage('Eliminado de Favoritos.');
  RefreshInboxIfOpen;
  ListarFavoritosYMerkle;
end;

procedure TFormFavoritosMerkle.BtnRefrescarClick(Sender: TObject);
begin
  ListarFavoritosYMerkle;
end;

procedure TFormFavoritosMerkle.BtnVerPorIDClick(Sender: TObject);
var
  id: Integer;
  pB: PBandeja;
  C: PCorreo;
  F: TFavorito;
begin
  if not ParseID(id) then Exit;

  if BFav_Search(FavoritosBTree, id) = nil then
  begin
    ShowMessage('El ID no está en Favoritos.');
    Exit;
  end;

  pB := ObtenerBandejaPtr(UsuarioActualEmail);
  C := BuscarCorreo(pB^, id);
  if C = nil then
  begin
    ShowMessage('No se encontró el correo en tu bandeja.');
    Exit;
  end;

  ShowMessage('De: ' + C^.remitente + LineEnding +
              'Asunto: ' + C^.asunto + LineEnding +
              'Fecha: ' + C^.fecha + LineEnding +
              'Mensaje:' + LineEnding + C^.mensaje);

  C^.estado := 'L';

  F.id        := C^.id;
  F.remitente := C^.remitente;
  F.estado    := C^.estado;
  F.asunto    := C^.asunto;
  F.fecha     := C^.fecha;
  F.mensaje   := C^.mensaje;
  BFav_Insert(FavoritosBTree, F);

  RefreshInboxIfOpen;
  ListarFavoritosYMerkle;
end;

function TFormFavoritosMerkle.ParseID(out AID: Integer): Boolean;
begin
  Result := TryStrToInt(Trim(EditID.Text), AID);
  if not Result then
    ShowMessage('Ingresa un ID válido.');
end;

procedure TFormFavoritosMerkle.RefreshInboxIfOpen;
var
  pB: PBandeja;
begin
  if Assigned(FormBandeja) then
  begin
    pB := ObtenerBandejaPtr(UsuarioActualEmail);
    FormBandeja.CargarBandejaPtr(pB);
  end;
end;

function TFormFavoritosMerkle.MD5Hex(const S: AnsiString): AnsiString;
var
  d: TMD5Digest;
begin
  d := MD5String(S);
  Result := MD5Print(d);
end;

function TFormFavoritosMerkle.HashFavorito(const F: TFavorito): string;
var
  data: AnsiString;
begin
  data :=
    IntToStr(F.id) + '|' +
    F.remitente    + '|' +
    F.estado       + '|' +
    F.asunto       + '|' +
    F.fecha        + '|' +
    F.mensaje;
  Result := MD5Hex(data);
end;

function HashFavoritoG(const F: TFavorito): string;
var
  s: AnsiString;
  d: TMD5Digest;
begin
  s := IntToStr(F.id) + '|' + F.remitente + '|' + F.estado + '|' +
       F.asunto + '|' + F.fecha + '|' + F.mensaje;
  d := MD5String(s);
  Result := MD5Print(d);
end;

var
  gHashSL  : TStrings = nil;
  gHashCnt : Integer  = 0;

procedure AddHashGlobal(const F: TFavorito);
begin
  if Assigned(gHashSL) then
  begin
    gHashSL.Add(HashFavoritoG(F));
    Inc(gHashCnt);
  end;
end;

procedure TFormFavoritosMerkle.FavoritosToHashes(out hashes: TStringList; out countFav: Integer);
begin
  hashes   := TStringList.Create;
  countFav := 0;
  gHashSL  := hashes;
  gHashCnt := 0;
  try
    BFav_InOrder(FavoritosBTree, @AddHashGlobal);
    countFav := gHashCnt;
  finally
    gHashSL := nil;
  end;
end;

function TFormFavoritosMerkle.MerkleRootFromLeaves(const leaves: TStrings): string;
var
  cur, nxt: TStringList;
  i: Integer;
  leftH, rightH: string;
begin
  Result := '';
  if (leaves = nil) or (leaves.Count = 0) then Exit;

  cur := TStringList.Create;
  try
    cur.Assign(leaves);

    while cur.Count > 1 do
    begin
      nxt := TStringList.Create;
      try
        i := 0;
        while i < cur.Count do
        begin
          leftH := cur[i];
          if i+1 < cur.Count then
            rightH := cur[i+1]
          else
            rightH := leftH;
          nxt.Add(MD5Hex(leftH + rightH));
          Inc(i, 2);
        end;
      finally
        cur.Assign(nxt);
        nxt.Free;
      end;
    end;

    Result := cur[0];
  finally
    cur.Free;
  end;
end;

procedure TFormFavoritosMerkle.ListarFavoritosYMerkle;
var
  hashes, detalles: TStringList;
  countFav, i: Integer;
  root: string;
begin
  FavoritosToHashesAndDetails(hashes, detalles, countFav);
  try
    MemoMerkle.Lines.BeginUpdate;
    try
      MemoMerkle.Clear;

      MemoMerkle.Lines.Add('Hojas (favoritos): ' + IntToStr(countFav));
      MemoMerkle.Lines.Add('--------------------------------------------------');
      for i := 0 to detalles.Count - 1 do
        MemoMerkle.Lines.Add(detalles[i]);

      root := MerkleRootFromLeaves(hashes);
      MemoMerkle.Lines.Add('');
      MemoMerkle.Lines.Add('Merkle Root:');
      MemoMerkle.Lines.Add(root);

      LblCount.Caption := 'Favoritos: ' + IntToStr(countFav);
      LblRoot.Caption  := 'Merkle Root: ' + root;
    finally
      MemoMerkle.Lines.EndUpdate;
    end;
  finally
    hashes.Free;
    detalles.Free;
  end;
end;

procedure FavoritosToHashesAndDetails(out hashes, detalles: TStringList; out countFav: Integer);

  function San(const s: string): string;
  begin
    Result := StringReplace(s, #13#10, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  end;

  procedure Collect(const F: TFavorito);
  var
    h: string;
  begin
    h := HashFavorito(F);
    hashes.Add(h);
    detalles.Add(Format('ID:%d | De:%s | Asunto:%s | Fecha:%s | Hash:%s',
               [F.id, San(F.remitente), San(F.asunto), San(F.fecha), h]));
    Inc(countFav);
  end;

begin
  hashes   := TStringList.Create;
  detalles := TStringList.Create;
  countFav := 0;
  BFav_InOrder(FavoritosBTree, @Collect);
end;


end.
