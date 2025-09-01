unit form_root;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormRoot }

  TFormRoot = class(TForm)
    BtnCargarJSON: TButton;
    BtnReporteUsuarios: TButton;
    BtnReporteRelaciones: TButton;
    BtnCerrarSesion: TButton;
    Label1: TLabel;
    procedure BtnReporteRelacionesClick(Sender: TObject);
    procedure BtnCerrarSesionClick(Sender: TObject);
  private

  public

  end;

var
  FormRoot: TFormRoot;

implementation

{$R *.lfm}

uses
  main;

{ TFormRoot }

procedure TFormRoot.BtnReporteRelacionesClick(Sender: TObject);
begin

end;

procedure TFormRoot.BtnCerrarSesionClick(Sender: TObject);
begin
  Form1.Show;   // Mostrar login de nuevo
  Self.Close;   // Cerrar menú root
end;

end.

