unit form_usuario;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

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
  ShowMessage('Abrir Bandeja de Entrada');
end;

procedure TFormUsuario.Button10Click(Sender: TObject);
begin

end;

procedure TFormUsuario.BtnCerrarSesionClick(Sender: TObject);
begin
  Form1.Show;   // Mostrar login de nuevo
  Self.Close;   // Cerrar menú usuario
end;

procedure TFormUsuario.BtnEnviarCorreoClick(Sender: TObject);
begin

end;

procedure TFormUsuario.FormCreate(Sender: TObject);
begin

end;

end.

