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
    Label3: TLabel;
    LblMensaje: TLabel;
    procedure BtnLoginClick(Sender: TObject);
    procedure EditEmailChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

// <<< IMPORTA TU UNIT AQUÍ, NO DENTRO DEL PROCEDIMIENTO >>>
uses
  usuarios;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InicializarUsuarios;

  AgregarUsuario(0, 'Administrador', 'root', 'root@edd.com', '00000000', 'root123'); //Inicializacion usuario root

  CargarUsuariosDesdeJSON('usuarios.json'); //Cargar usuarios desde JSON

  // Si quieres confirmar visualmente:
  // ShowMessage('Usuarios cargados');
end;

procedure TForm1.EditEmailChange(Sender: TObject);
begin

end;

procedure TForm1.BtnLoginClick(Sender: TObject);
var
  user: PUsuario;
begin
  user := BuscarUsuarioPorEmail(EditEmail.Text, EditPassword.Text);

  if user <> nil then
  begin
    LblMensaje.Caption := 'Bienvenido, ' + user^.nombre;
    LblMensaje.Font.Color := clGreen; // Éxito en verde
  end
  else
  begin
    LblMensaje.Caption := 'Credenciales inválidas';
    LblMensaje.Font.Color := clRed;   // Error en rojo
  end;
end;

<<<<<<< Updated upstream
end.
=======

>>>>>>> Stashed changes
