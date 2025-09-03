unit form_root;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  usuarios;

type

  { TFormRoot }

  TFormRoot = class(TForm)
    BtnCargaMasiva: TButton;
    BtnReporteUsuarios: TButton;
    BtnReporteRelaciones: TButton;
    BtnCerrarSesion: TButton;
    Label1: TLabel;
    Label2: TLabel;
    MemoLog: TMemo;
    OpenDialog1: TOpenDialog;
    procedure BtnCargaMasivaClick(Sender: TObject);
    procedure BtnReporteRelacionesClick(Sender: TObject);
    procedure BtnCerrarSesionClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MemoLogChange(Sender: TObject);
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

procedure TFormRoot.BtnCargaMasivaClick(Sender: TObject);
var
  agregados, rechazados: Integer;
  log: TStringList;
begin
  if not Assigned(OpenDialog1) then
  begin
    ShowMessage('No se encontró el componente OpenDialog1 en el formulario.');
    Exit;
  end;

  OpenDialog1.Title := 'Selecciona el archivo JSON de usuarios';
  OpenDialog1.Filter := 'Archivos JSON|*.json|Todos|*.*';
  if not OpenDialog1.Execute then Exit;

  log := TStringList.Create;
  try
    CargaMasivaDesdeJSON(OpenDialog1.FileName, agregados, rechazados, log);
    ShowMessage(Format('Carga masiva finalizada.' + LineEnding +
                       'Agregados: %d' + LineEnding +
                       'Rechazados: %d',
                       [agregados, rechazados]));

    MemoLog.Lines.Clear;
    MemoLog.Lines.AddStrings(log);
  finally
    log.Free;
  end;
end;

procedure TFormRoot.BtnCerrarSesionClick(Sender: TObject);
begin
  Form1.Show;
  Self.Close;
end;

procedure TFormRoot.FormCreate(Sender: TObject);
begin

end;

procedure TFormRoot.MemoLogChange(Sender: TObject);
begin

end;

end.

