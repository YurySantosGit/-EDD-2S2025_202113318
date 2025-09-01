unit form_usuario;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormUsuario }

  TFormUsuario = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Label1: TLabel;
    procedure Button10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  FormUsuario: TFormUsuario;

implementation

{$R *.lfm}

{ TFormUsuario }

procedure TFormUsuario.Button1Click(Sender: TObject);
begin

end;

procedure TFormUsuario.Button10Click(Sender: TObject);
begin
  Form1.Show;   // Mostrar login de nuevo
  Self.Close;   // Cerrar menú usuario
end;

procedure TFormUsuario.Button2Click(Sender: TObject);
begin

end;

end.

