unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnLogin: TButton;
    BtnRegistrar: TButton;
    EditPassword: TEdit;
    EditEmail: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    LblMensaje: TLabel;
    procedure BtnLoginClick(Sender: TObject);
    procedure BtnRegistrarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public

  end;

var
  Form1: TForm1;
  UsuarioActualEmail: String;

implementation

{$R *.lfm}

uses
  usuarios, form_root, form_usuario, pila_papelera, cola_correos, form_bandeja,
  lista_doble, form_registro, contactos;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  InicializarUsuarios;
  AgregarUsuario(0, 'Administrador', 'root', 'root@edd.com', '00000000', 'root123'); // Crear root por defecto
  CargarUsuariosDesdeJSON('usuarios.json'); // Cargar usuarios desde JSON

  InicializarPapelera(PapeleraGlobal);
  InicializarCola(ColaGlobal);
  InicializarBandeja(BandejaActual);

  InicializarContactos(ListaContactos);
  CargarContactosDesdeJSON(ListaContactos, 'contactos.json');

end;

procedure TForm1.BtnLoginClick(Sender: TObject);
var
  user: PUsuario;
begin
  user := BuscarUsuarioPorEmail(EditEmail.Text, EditPassword.Text);

  if user <> nil then
  begin
    UsuarioActualEmail := user^.email;
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

procedure TForm1.BtnRegistrarClick(Sender: TObject);
begin
  FormRegistro := TFormRegistro.Create(Self);
  FormRegistro.ShowModal;
end;

end.

