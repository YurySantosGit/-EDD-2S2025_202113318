unit form_usuario;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, form_bandeja, lista_doble, form_papelera;

type

  { TFormUsuario }

  TFormUsuario = class(TForm)
    BtnBandeja: TButton;
    BtnCerrarSesion: TButton;
    BtnEnviarCorreo: TButton;
    BtnPapelera: TButton;
    BtnProgramar: TButton;
    Button5: TButton;
    Button6: TButton;
    BtnContactos: TButton;
    BtnActualizarPerfil: TButton;
    Button9: TButton;
    Label1: TLabel;
    procedure BtnCerrarSesionClick(Sender: TObject);
    procedure BtnPapeleraClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure BtnBandejaClick(Sender: TObject);
    procedure BtnEnviarCorreoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  FormUsuario: TFormUsuario;

implementation

{$R *.lfm}

uses
  main;

{ TFormUsuario }

procedure TFormUsuario.BtnBandejaClick(Sender: TObject);
begin
  // Simulación de correos recibidos
  InicializarBandeja(BandejaActual);
  InsertarCorreo(BandejaActual, 1, 'root@edd.com', 'NL', False,
    'Bienvenido', '31/08/2025', 'Este es tu primer correo.');
  InsertarCorreo(BandejaActual, 2, 'soporte@edd.com', 'NL', False,
    'Aviso', '31/08/2025', 'Tu cuenta fue creada con éxito.');
  InsertarCorreo(BandejaActual, 3, 'admin@edd.com', 'L', False,
    'Prueba', '31/08/2025', 'Este correo ya está leído.');

  FormBandeja := TFormBandeja.Create(Self);
  FormBandeja.CargarBandeja(BandejaActual);
  FormBandeja.ShowModal;
end;

procedure TFormUsuario.Button10Click(Sender: TObject);
begin

end;

procedure TFormUsuario.BtnCerrarSesionClick(Sender: TObject);
begin
  Form1.Show;   // Mostrar login de nuevo
  Self.Close;   // Cerrar menú usuario
end;

procedure TFormUsuario.BtnPapeleraClick(Sender: TObject);
begin
  FormPapelera := TFormPapelera.Create(Self);
  FormPapelera.ShowModal;
end;

procedure TFormUsuario.BtnEnviarCorreoClick(Sender: TObject);
begin

end;

procedure TFormUsuario.FormCreate(Sender: TObject);
begin

end;

end.

