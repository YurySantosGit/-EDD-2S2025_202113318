unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnLogin: TButton;
    EditPassword: TEdit;
    EditEmail: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    LblMensaje: TLabel;
    procedure BtnLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  usuarios, form_root, form_usuario;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  InicializarUsuarios;

  // Crear root por defecto
  AgregarUsuario(0, 'Administrador', 'root', 'root@edd.com', '00000000', 'root123');

  // Cargar usuarios desde JSON
  CargarUsuariosDesdeJSON('usuarios.json');
end;

procedure TForm1.BtnLoginClick(Sender: TObject);
var
  user: PUsuario;
begin
  user := BuscarUsuarioPorEmail(EditEmail.Text, EditPassword.Text);

  if user <> nil then
  begin
    //Usuario Root
    if user^.email = 'root@edd.com' then
    begin
      FormRoot := TFormRoot.Create(Self);
      FormRoot.Show;
      Self.Hide;
    end
    else
    begin
      //Usuario Estandar
      FormUsuario := TFormUsuario.Create(Self);
      FormUsuario.Show;
      Self.Hide;
    end;
  end
  else
  begin
    LblMensaje.Caption := 'Credenciales inválidas';
    LblMensaje.Font.Color := clRed;   // Error en rojo
  end;
end;

end.

