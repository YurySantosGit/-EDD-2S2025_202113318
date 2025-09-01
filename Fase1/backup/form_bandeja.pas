unit form_bandeja;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, lista_doble, pila_papelera;

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

  public
    procedure CargarBandeja(var bandeja: TBandeja);

  end;

var
  FormBandeja: TFormBandeja;
  BandejaActual: TBandeja;

implementation

{$R *.lfm}

{ TFormBandeja }

procedure TFormBandeja.BtnCerrarClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFormBandeja.BtnEliminarCorreoClick(Sender: TObject);
var
  id, p: Integer;
  s: String;
  c: PCorreo;
  info: TCorreoInfo;

begin
  if ListCorreos.ItemIndex = -1 then Exit;

  s := ListCorreos.Items[ListCorreos.ItemIndex];
  p := Pos('(ID:', s);
  id := StrToInt(Copy(s, p+4, Length(s)-p-4));
  c := BuscarCorreo(BandejaActual, id);

  if c <> nil then
  begin
    info := CorreoToInfo(c); //Enviar a pila (papelera)
    PushCorreo(PapeleraGlobal, info; //Quitar de la bandeja

    if EliminarCorreo(BandejaActual, id) then
    begin
      Showmessage('Correo enviado a la papelera');
      CargarBandeja(BandejaActual);
    end;

  end;

end;

procedure TFormBandeja.BtnOrdenarClick(Sender: TObject);
begin
  OrdenarPorAsunto(BandejaActual);
  CargarBandeja(BandejaActual);
end;

procedure TFormBandeja.BtnVerCorreoClick(Sender: TObject);
var
  correo: PCorreo;
  id: Integer;
  s: String;
  p: Integer;
begin
  if ListCorreos.ItemIndex = -1 then Exit;

  // Extraer ID desde la cadena
  s := ListCorreos.Items[ListCorreos.ItemIndex];
  p := Pos('(ID:', s);
  id := StrToInt(Copy(s, p+4, Length(s)-p-4));

  correo := BuscarCorreo(BandejaActual, id);
  if correo <> nil then
  begin
    ShowMessage('De: ' + correo^.remitente + LineEnding +
                'Asunto: ' + correo^.asunto + LineEnding +
                'Fecha: ' + correo^.fecha + LineEnding +
                'Mensaje:' + LineEnding + correo^.mensaje);

    // Marcar como leído
    correo^.estado := 'L';
    CargarBandeja(BandejaActual);
  end;
end;

procedure TFormBandeja.FormCreate(Sender: TObject);
begin
  InicializarBandeja(BandejaActual);

  InsertarCorreo(BandejaActual, 1, 'root@edd.com', 'NL', False,
    'Bienvenido', '31/08/2025', 'Este es tu primer correo en el sistema.');

  InsertarCorreo(BandejaActual, 2, 'soporte@edd.com', 'NL', False,
    'Aviso importante', '31/08/2025', 'Recuerda cambiar tu contraseña.');

  InsertarCorreo(BandejaActual, 3, 'admin@edd.com', 'L', False,
    'Prueba interna', '31/08/2025', 'Este correo ya está leído.');

  CargarBandeja(BandejaActual);

end;

procedure TFormBandeja.CargarBandeja(var bandeja: TBandeja);
var
  actual: PCorreo;
  noLeidos: Integer;
begin
  ListCorreos.Clear;
  BandejaActual := bandeja;
  actual := bandeja.cabeza;
  noLeidos := 0;

  while actual <> nil do
  begin
    if actual^.estado = 'NL' then
      Inc(noLeidos);

    ListCorreos.Items.Add('[' + actual^.estado + '] ' +
                          actual^.asunto + ' - ' + actual^.remitente +
                          ' (ID:' + IntToStr(actual^.id) + ')');
    actual := actual^.siguiente;
  end;

  LblNoLeidos.Caption := 'No leídos: ' + IntToStr(noLeidos);
end;

end.

