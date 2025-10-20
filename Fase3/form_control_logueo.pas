unit form_control_logueo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  app_state, FileUtil, reportes_usuario;

type

  { TFormControlLogueo }

  TFormControlLogueo = class(TForm)
    BtnExportar: TButton;
    BtnVisualizar: TButton;
    BtnCerrar: TButton;
    BtnGenerarReporte: TButton;
    MemoLog: TMemo;
    SaveDialog1: TSaveDialog;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnExportarClick(Sender: TObject);
    procedure BtnGenerarReporteClick(Sender: TObject);
    procedure BtnVisualizarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MemoLogChange(Sender: TObject);
    procedure MemoLogClick(Sender: TObject);
  private
    procedure RenderLogToMemo;
  public

  end;

var
  FormControlLogueo: TFormControlLogueo;

implementation

{$R *.lfm}

{ TFormControlLogueo }

procedure TFormControlLogueo.MemoLogChange(Sender: TObject);
begin

end;

procedure TFormControlLogueo.MemoLogClick(Sender: TObject);
begin

end;

procedure TFormControlLogueo.FormCreate(Sender: TObject);
begin

end;

procedure TFormControlLogueo.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormControlLogueo.BtnExportarClick(Sender: TObject);
var
  path: String;
begin
  SaveDialog1.Title := 'Exportar control de logueo (JSON)';
  SaveDialog1.Filter := 'JSON|*.json|Todos|*.*';
  SaveDialog1.FileName := 'control_logueo.json';

  if SaveDialog1.Execute then
  begin
    path := SaveDialog1.FileName;
    SaveLoginLogToJSON(path);
    ShowMessage('Exportado a: ' + path);
  end;
end;

procedure TFormControlLogueo.BtnGenerarReporteClick(Sender: TObject);
var carpeta: string;
begin
  carpeta := 'root-Reportes' + DirectorySeparator;
  ForceDirectories(carpeta);
  ReporteLogueos(carpeta);
  ShowMessage('Reporte generado en: ' + carpeta + 'control_logueo.png');
end;

procedure TFormControlLogueo.BtnVisualizarClick(Sender: TObject);
begin
  RenderLogToMemo;
end;

procedure TFormControlLogueo.FormShow(Sender: TObject);
begin
  RenderLogToMemo;
end;

procedure TFormControlLogueo.RenderLogToMemo;
var
  i, n: Integer;
  e: TLogEntry;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Clear;
    n := LoginLogCount;
    if n = 0 then
    begin
      MemoLog.Lines.Add('(sin registros de logueo)');
      Exit;
    end;

    for i := 0 to n-1 do
    begin
      e := GetLoginLog(i);
      MemoLog.Lines.Add(Format('%d) %s', [i+1, e.usuario]));
      MemoLog.Lines.Add('  Entrada: ' + e.entrada);
      MemoLog.Lines.Add('  Salida : ' + e.salida);
      MemoLog.Lines.Add('');
    end;
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

end.

