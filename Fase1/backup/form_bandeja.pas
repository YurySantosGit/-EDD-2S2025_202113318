unit form_bandeja;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  lista_doble, pila_papelera;

type

  { TFormBandeja }

  TFormBandeja = class(TForm)
    BtnVerCorreo: TButton;
    BtnEliminarCorreo: TButton;
    BtnOrdenar: TButton;
    BtnCerrar: TButton;
    Label1: TLabel;
    LblNoLeidos: TLabel;
    ListCorreos: TListBox;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnEliminarCorreoClick(Sender: TObject);
    procedure BtnOrdenarClick(Sender: TObject);
    procedure BtnVerCorreoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    BandejaPtr: PBandeja;
  public
    procedure CargarBandejaPtr(p: PBandeja);

  end;

var
  FormBandeja: TFormBandeja;

implementation

{$R *.lfm}

{ TFormBandeja }

procedure TFormBandeja.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormBandeja.BtnEliminarCorreoClick(Sender: TObject);
var
  id, posId: Integer;
  s: String;
  c: PCorreo;
  info: TCorreoInfo;
begin
  if ListCorreos.ItemIndex = -1 then Exit;

  s := ListCorreos.Items[ListCorreos.ItemIndex];
  posId := Pos('(ID:', s);
  id := StrToInt(Copy(s, posId+4, Length(s) - (posId+4) + 1));

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

procedure TFormBandeja.BtnOrdenarClick(Sender: TObject);
begin
  if BandejaPtr = nil then Exit;
  OrdenarPorAsunto(BandejaPtr^);
  CargarBandejaPtr(BandejaPtr);
end;

procedure TFormBandeja.BtnVerCorreoClick(Sender: TObject);
var
  id, posId: Integer;
  s: String;
  correo: PCorreo;
begin
  if ListCorreos.ItemIndex = -1 then Exit;

  s := ListCorreos.Items[ListCorreos.ItemIndex];
  posId := Pos('(ID:', s);
  id := StrToInt(Copy(s, posId+4, Length(s) - (posId+4) + 1));

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

procedure TFormBandeja.CargarBandejaPtr(p: PBandeja);
var
  actual: PCorreo;
  noLeidos: Integer;
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

    ListCorreos.Items.Add(
      '[' + actual^.estado + '] ' +
      actual^.asunto + ' - ' + actual^.remitente +
      ' (ID:' + IntToStr(actual^.id) + ')'
    );

    actual := actual^.siguiente;
  end;

  LblNoLeidos.Caption := 'No leídos: ' + IntToStr(noLeidos);
end;


end.

