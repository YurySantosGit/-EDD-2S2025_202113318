unit form_agregar_contacto;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  contactos, usuarios;

type

  { TFormAgregarContacto }

  TFormAgregarContacto = class(TForm)
    BtnAgregar: TButton;
    BtnCerrar: TButton;
    EditCorreo: TEdit;
    Label1: TLabel;
    procedure BtnAgregarClick(Sender: TObject);
    procedure BtnCerrarClick(Sender: TObject);
  private
    function EmailValido(const s: String): Boolean;
  public

  end;

var
  FormAgregarContacto: TFormAgregarContacto;

implementation

{$R *.lfm}

{ TFormAgregarContacto }

uses
  main;

function TFormAgregarContacto.EmailValido(const s: String): Boolean;
begin
  Result := (Pos('@', s) > 1) and (Pos('.', s) > 3);
end;

procedure TFormAgregarContacto.BtnAgregarClick(Sender: TObject);
var
  email: String;
  u: PUsuario;
  idNuevo: Integer;
begin
  email := Trim(EditCorreo.Text);

  if email = '' then
  begin
    ShowMessage('Ingrese el correo del contacto.');
    Exit;
  end;

  if not EmailValido(email) then
  begin
    ShowMessage('Formato de correo no válido.');
    Exit;
  end;

  if ExisteContactoEmail(ListaContactos, UsuarioActualEmail, email) then
  begin
    ShowMessage('Este contacto ya existe para tu cuenta.');
    Exit;
  end;

  u := BuscarUsuarioPorCorreo(email);
  if u = nil then
  begin
    ShowMessage('El correo no corresponde a ningún usuario del sistema.');
    Exit;
  end;

  idNuevo := ObtenerSiguienteIDContacto(ListaContactos);

  AgregarContacto(
    ListaContactos,
    idNuevo,
    UsuarioActualEmail,
    u^.nombre,
    u^.email,
    u^.telefono
  );

  GuardarContactosEnJSON(ListaContactos, 'contactos.json');

  ShowMessage('Contacto agregado.');
  EditCorreo.Clear;
  EditCorreo.SetFocus;
end;

procedure TFormAgregarContacto.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.

