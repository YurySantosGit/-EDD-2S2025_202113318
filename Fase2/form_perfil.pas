unit form_perfil;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormPerfil }

  TFormPerfil = class(TForm)
    BtnGuardar: TButton;
    BtnCerrar: TButton;
    EditUsuario: TEdit;
    EditTelefono: TEdit;
    LblTelefonoLbl: TLabel;
    LblUsuarioLbl: TLabel;
    LblEmail: TLabel;
    LblEmailLbl: TLabel;
    LblTitulo: TLabel;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnGuardarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LblEmailClick(Sender: TObject);
  private
    procedure CargarDatos;
    function  SoloDigitos(const s: String): Boolean;
  public

  end;

var
  FormPerfil: TFormPerfil;

implementation

{$R *.lfm}

uses
  main, usuarios;

{ TFormPerfil }


procedure TFormPerfil.LblEmailClick(Sender: TObject);
begin

end;

procedure TFormPerfil.BtnGuardarClick(Sender: TObject);
var
  u: PUsuario;
  nuevoUsuario, nuevoTelefono: String;
begin
  u := BuscarUsuarioPorEmailExacto(UsuarioActualEmail);
  if u = nil then Exit;

  nuevoUsuario  := Trim(EditUsuario.Text);
  nuevoTelefono := Trim(EditTelefono.Text);

  if nuevoUsuario = '' then
  begin
    ShowMessage('El nombre de usuario no puede estar vacío.');
    Exit;
  end;

  if not SameText(nuevoUsuario, u^.usuario) then
  begin
    if ExisteUsuarioExceptoEmail(nuevoUsuario, u^.email) then
    begin
      ShowMessage('El nombre de usuario ya está en uso por otro usuario.');
      Exit;
    end;
  end;

  if nuevoTelefono = '' then
  begin
    ShowMessage('El teléfono es obligatorio.');
    Exit;
  end;

  if (Length(nuevoTelefono) <> 8) or (not SoloDigitos(nuevoTelefono)) then
  begin
    ShowMessage('El teléfono debe tener exactamente 8 dígitos numéricos.');
    Exit;
  end;

  u^.usuario  := nuevoUsuario;
  u^.telefono := nuevoTelefono;

  GuardarUsuariosEnJSON('usuarios.json');
  ShowMessage('Datos actualizados correctamente.');
  Close;
end;

procedure TFormPerfil.FormCreate(Sender: TObject);
begin
  CargarDatos;
end;

procedure TFormPerfil.CargarDatos;
var
  u: PUsuario;
begin
  LblEmail.Caption := '-';
  EditUsuario.Text := '';
  EditTelefono.Text := '';

  u := BuscarUsuarioPorEmailExacto(UsuarioActualEmail);
  if u <> nil then
  begin
    LblEmail.Caption := u^.email;
    EditUsuario.Text := u^.usuario;
    EditTelefono.Text := u^.telefono;
  end
end;

function TFormPerfil.SoloDigitos(const s: String): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(s) do
    if not (s[i] in ['0'..'9']) then
      Exit(False);
end;

procedure TFormPerfil.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.

