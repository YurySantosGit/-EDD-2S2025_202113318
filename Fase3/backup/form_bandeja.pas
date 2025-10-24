unit form_bandeja;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, StrUtils,
  lista_doble, pila_papelera, btree_favoritos, app_state, lzw_comp;

type

  { TFormBandeja }

  TFormBandeja = class(TForm)
    BtnVerCorreo: TButton;
    BtnEliminarCorreo: TButton;
    BtnOrdenar: TButton;
    BtnCerrar: TButton;
    BtnFavorito: TButton;
    BtnDescargar: TButton;
    Label1: TLabel;
    LblNoLeidos: TLabel;
    ListCorreos: TListBox;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnDescargarClick(Sender: TObject);
    procedure BtnEliminarCorreoClick(Sender: TObject);
    procedure BtnFavoritoClick(Sender: TObject);
    procedure BtnOrdenarClick(Sender: TObject);
    procedure BtnVerCorreoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListCorreosClick(Sender: TObject);
  private
    BandejaPtr: PBandeja;
    function TryGetIDSeleccionado(out AID: Integer): Boolean;
  public
    procedure CargarBandejaPtr(p: PBandeja);

  end;

var
  FormBandeja: TFormBandeja;

implementation

{$R *.lfm}

{ TFormBandeja }

function TFormBandeja.TryGetIDSeleccionado(out AID: Integer): Boolean;
var
  s, numStr: String;
  pOpen, pClose: Integer;
begin
  Result := False;
  AID := -1;

  if ListCorreos.ItemIndex = -1 then Exit;

  s := ListCorreos.Items[ListCorreos.ItemIndex];

  pOpen := Pos('(ID:', s);
  if pOpen = 0 then Exit;

  pClose := PosEx(')', s, pOpen + 4);
  if (pClose = 0) or (pClose <= pOpen + 4) then Exit;

  numStr := Copy(s, pOpen + 4, pClose - (pOpen + 4));
  numStr := Trim(numStr);

  Result := TryStrToInt(numStr, AID);
end;

procedure TFormBandeja.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormBandeja.BtnDescargarClick(Sender: TObject);
var
  id: Integer;
  c: PCorreo;
  comp: TCompresorLZW;
  codes: TCodeArray;

  userDir, baseDir: string;
  resumenTxtPath, resumenBinPath, resumenLzwPath: string;

  resumenText: AnsiString;
  sl: TStringList;
  i: Integer;
  sCodes: string;
begin
  if not TryGetIDSeleccionado(id) then
  begin
    ShowMessage('Selecciona un correo.');
    Exit;
  end;

  c := BuscarCorreo(BandejaPtr^, id);
  if c = nil then
  begin
    ShowMessage('No se encontró el correo.');
    Exit;
  end;

  userDir := Copy(UsuarioActualEmail, 1, Pos('@', UsuarioActualEmail) - 1);
  if userDir = '' then userDir := 'usuario';
  baseDir := userDir + '-CorreoDescargado(' + IntToStr(id) + ')' + DirectorySeparator;
  ForceDirectories(baseDir);

  resumenTxtPath := baseDir + 'resumen.txt';
  resumenBinPath := baseDir + 'resumen.bin';
  resumenLzwPath := baseDir + 'resumen.lzw';

  resumenText :=
    'ID: '      + AnsiString(IntToStr(c^.id))        + sLineBreak +
    'De: '      + AnsiString(c^.remitente)           + sLineBreak +
    'Asunto: '  + AnsiString(c^.asunto)              + sLineBreak +
    'Fecha: '   + AnsiString(c^.fecha)               + sLineBreak +
    'Estado: '  + AnsiString(c^.estado)              + sLineBreak +
    'Mensaje:'  + sLineBreak +
    AnsiString(c^.mensaje);

  sl := TStringList.Create;
  try
    sl.Text := string(resumenText);
    sl.SaveToFile(resumenTxtPath);
  finally
    sl.Free;
  end;

  comp := TCompresorLZW.Create;
  try
    codes := comp.Comprimir(resumenText);
    LZW_SaveCodesAsBin(codes, resumenBinPath);

    sCodes := '';
    for i := 0 to High(codes) do
    begin
      if i > 0 then sCodes := sCodes + ',';
      sCodes := sCodes + IntToStr(codes[i]);
    end;

    sl := TStringList.Create;
    try
      sl.Text := sCodes;
      sl.SaveToFile(resumenLzwPath);
    finally
      sl.Free;
    end;
  finally
    comp.Free;
  end;

  ShowMessage(
    'Archivos guardados en:' + LineEnding + baseDir + LineEnding + LineEnding +
    'resumen.txt (original)'  + LineEnding +
    'resumen.bin (LZW binario)' + LineEnding +
    'resumen.lzw (LZW legible)'
  );
end;



procedure TFormBandeja.BtnEliminarCorreoClick(Sender: TObject);
var
  id: Integer;
  c: PCorreo;
  info: TCorreoInfo;
  wasFav: Boolean;

begin
  if not TryGetIDSeleccionado(id) then
  begin
    ShowMessage('No se pudo leer el ID del correo seleccionado.');
    Exit;
  end;

  c := BuscarCorreo(BandejaPtr^, id);
  if c <> nil then
  begin
    wasFav := c^.favorito;
    info := CorreoToInfo(c);
    PushCorreo(PapeleraGlobal, info);

    if EliminarCorreo(BandejaPtr^, id) then
    begin
      if wasFav then BFav_Delete(FavoritosBTree, id);
      ShowMessage('Correo enviado a la papelera');
      CargarBandejaPtr(BandejaPtr);
    end;
  end;
end;

procedure TFormBandeja.BtnFavoritoClick(Sender: TObject);
var
  id: Integer;
  c: PCorreo;
  F: TFavorito;

begin
  if (BandejaPtr = nil) then Exit;

  if not TryGetIDSeleccionado(id) then
  begin
    ShowMessage('Selecciona un correo.');
    Exit;
  end;

  c := BuscarCorreo(BandejaPtr^, id);
  if c = nil then
  begin
    ShowMessage('No se encontró el correo.');
    Exit;
  end;

  c^.favorito := not c^.favorito;

  if c^.favorito then
  begin
    F.id        := c^.id;
    F.remitente := c^.remitente;
    F.estado    := c^.estado;
    F.asunto    := c^.asunto;
    F.fecha     := c^.fecha;
    F.mensaje   := c^.mensaje;
    BFav_Insert(FavoritosBTree, F);
    ShowMessage('Correo marcado como favorito.');
  end
  else
  begin
    BFav_Delete(FavoritosBTree, c^.id);
    ShowMessage('Correo quitado de favoritos.');
  end;

  // Refresca lista y contador NL
  CargarBandejaPtr(BandejaPtr);
end;

procedure TFormBandeja.BtnOrdenarClick(Sender: TObject);
begin
  if BandejaPtr = nil then Exit;
  OrdenarPorAsunto(BandejaPtr^);
  CargarBandejaPtr(BandejaPtr);
end;

procedure TFormBandeja.BtnVerCorreoClick(Sender: TObject);
var
  id: Integer;
  correo: PCorreo;
  F: TFavorito;
begin
  if not TryGetIDSeleccionado(id) then
  begin
    ShowMessage('No se pudo leer el ID del correo seleccionado.');
    Exit;
  end;

  correo := BuscarCorreo(BandejaPtr^, id);
  if correo <> nil then
  begin
    ShowMessage('De: ' + correo^.remitente + LineEnding +
                'Asunto: ' + correo^.asunto + LineEnding +
                'Fecha: ' + correo^.fecha + LineEnding +
                'Mensaje:' + LineEnding + correo^.mensaje);

    correo^.estado := 'L';

    if correo^.favorito then
    begin
      F.id        := correo^.id;
      F.remitente := correo^.remitente;
      F.estado    := correo^.estado;
      F.asunto    := correo^.asunto;
      F.fecha     := correo^.fecha;
      F.mensaje   := correo^.mensaje;
      BFav_Insert(FavoritosBTree, F);
    end;

    CargarBandejaPtr(BandejaPtr);
  end;
end;

procedure TFormBandeja.FormCreate(Sender: TObject);
begin

end;

procedure TFormBandeja.ListCorreosClick(Sender: TObject);
begin

end;

procedure TFormBandeja.CargarBandejaPtr(p: PBandeja);
var
  actual: PCorreo;
  noLeidos: Integer;
  favMark: String;

begin
  BandejaPtr := p;
  ListCorreos.Clear;
  noLeidos := 0;

  if (BandejaPtr = nil) or (BandejaPtr^.cabeza = nil) then
  begin
    LblNoLeidos.Caption := 'No leídos: 0';
    Exit;
  end;

  actual := BandejaPtr^.cabeza;
  while actual <> nil do
  begin
    if actual^.estado = 'NL' then
      Inc(noLeidos);

    if actual^.favorito then favMark := '*** ' else favMark := '';

    ListCorreos.Items.Add(
      favMark + '[' + actual^.estado + '] ' +
      actual^.asunto + ' - ' + actual^.remitente +
      ' (ID:' + IntToStr(actual^.id) + ')'
    );

    actual := actual^.siguiente;
  end;

  LblNoLeidos.Caption := 'No leídos: ' + IntToStr(noLeidos);
end;


end.

