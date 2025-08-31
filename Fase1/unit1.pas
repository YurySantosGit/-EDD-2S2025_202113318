unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnSaludar: TButton;
    EditNombre: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    LblResultado: TLabel;
    procedure BtnSaludarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label3Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.BtnSaludarClick(Sender: TObject);
begin
  if EditNombre.Text <> '' then
     lblResultado.Caption := 'Hola, ' + EditNombre.Text + '!'
  else
     LblResultado.Caption := 'Por favor, ingrese un nombre.';

end;

procedure TForm1.Label3Click(Sender: TObject);
begin

end;

end.

