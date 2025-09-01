unit form_root;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormRoot }

  TFormRoot = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
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

procedure TFormRoot.Button3Click(Sender: TObject);
begin

end;

procedure TFormRoot.Button4Click(Sender: TObject);
begin
  Form1.Show;   // Mostrar login de nuevo
  Self.Close;   // Cerrar menú root
end;

end.

