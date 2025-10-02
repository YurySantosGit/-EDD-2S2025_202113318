unit form_bandeja;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, StrUtils,
  lista_doble, pila_papelera;

type

  { TFormBandeja }

  TFormBandeja = class(TForm)
    BtnVerCorreo: TButton;
    BtnEliminarCorreo: TButton;
    BtnOrdenar: TButton;
    BtnCerrar: TButton;
    BtnFavorito: TButton;
    Label1: TLabel;
    LblNoLeidos: TLabel;
    ListCorreos: TListBox;
    procedure BtnCerrarClick(Sender: TObject);
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

procedure TFormBandeja.BtnEliminarCorreoClick(Sender: TObject);
var
  id: Integer;
  c: PCorreo;
  info: TCorreoInfo;
begin
  if not TryGetIDSeleccionado(id) then
  begin
    ShowMessage('No se pudo leer el ID del correo seleccionado.');
    Exit;
  end;

  c := BuscarCorreo(BandejaPtr^, id);
  if c <> nil then
  begin
    info := CorreoToInfo(c);
    PushCorreo(PapeleraGlobal, info);

    if EliminarCorreo(BandejaPtr^, id) then
    begin
      ShowMessage('Correo enviado a la papelera');
      CargarBandejaPtr(BandejaPtr);
    end;
  end;
end;

procedure TFormBandeja.BtnFavoritoClick(Sender: TObject);
var
  id: Integer;
  c: PCorreo;
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
    ShowMessage('Correo marcado como favorito.')
  else
    ShowMessage('Correo quitado de favoritos.');

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

