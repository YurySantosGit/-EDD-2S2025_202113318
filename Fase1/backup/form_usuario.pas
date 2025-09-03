unit form_usuario;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, form_bandeja, lista_doble, form_papelera,
  form_correosprogramados, form_programarcorreo, form_agregar_contacto;

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
    procedure BtnProgramarClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure BtnBandejaClick(Sender: TObject);
    procedure BtnEnviarCorreoClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
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

procedure TFormUsuario.BtnProgramarClick(Sender: TObject);
begin
  FormProgramarCorreo := TFormProgramarCorreo.Create(Self);
  FormProgramarCorreo.ShowModal;
end;

procedure TFormUsuario.BtnEnviarCorreoClick(Sender: TObject);
begin

end;

procedure TFormUsuario.Button5Click(Sender: TObject);
begin
  FormCorreosProgramados := TFormCorreosProgramados.Create(Self);
  FormCorreosProgramados.ShowModal;
end;

procedure TFormUsuario.Button6Click(Sender: TObject);
begin
  FormAgregarContacto := TFormAgregarContacto.Create(Self);
  FormAgregarContacto.ShowModal;
end;

procedure TFormUsuario.FormCreate(Sender: TObject);
begin

end;

end.

