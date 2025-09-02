unit form_registro;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, usuarios;

type

  { TFormRegistro }

  TFormRegistro = class(TForm)
    BtnGuardar: TButton;
    BtnCancelar: TButton;
    EditPassword: TEdit;
    EditTelefono: TEdit;
    EditCorreo: TEdit;
    EditUsuario: TEdit;
    EditNombre: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnGuardarClick(Sender: TObject);
  private

  public

  end;

var
  FormRegistro: TFormRegistro;

implementation

{$R *.lfm}

{ TFormRegistro }

procedure TFormRegistro.BtnGuardarClick(Sender: TObject);
var
  nuevoId: Integer;
begin
  if (Trim(EditCorreo.Text) = '') or (Trim(EditPassword.Text) = '') then
  begin
    ShowMessage('Correo y contraseña son obligatorios');
    Exit;
  end;

  if ExisteEmail(EditCorreo.Text) then
  begin
    ShowMessage('Ya existe un usuario con este correo.');
    Exit;
  end;

  if ExisteUsuario(EditUsuario.Text) then
  begin
    ShowMessage('Ya existe un usuario con este nombre de usuario.');
    Exit;
  end;

  nuevoId := ObtenerSiguienteID;

  AgregarUsuario(nuevoId, EditNombre.Text, EditUsuario.Text,
    EditCorreo.Text, EditTelefono.Text, EditPassword.Text);

  GuardarUsuariosEnJSON('usuarios.json');

  ShowMessage('Usuario registrado con éxito.');
  Close;
end;

end.

