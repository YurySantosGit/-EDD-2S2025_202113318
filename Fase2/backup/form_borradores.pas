unit form_borradores;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  app_state, avl_borradores, form_enviarcorreo;

type

  { TFormBorradores }

  TFormBorradores = class(TForm)
    BtnPre: TButton;
    BtnIn: TButton;
    BtnPost: TButton;
    BtnCargarPorID: TButton;
    EditID: TEdit;
    MemoRecorridos: TMemo;
    procedure BtnCargarPorIDClick(Sender: TObject);
    procedure BtnInClick(Sender: TObject);
    procedure BtnPostClick(Sender: TObject);
    procedure BtnPreClick(Sender: TObject);
    procedure BtnReporteAVLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MemoRecorridosChange(Sender: TObject);
  private
    procedure ExportarReporteBorradoresAVL(const UsuarioEmail: String);
  public

  end;

var
  FormBorradores: TFormBorradores;

implementation

{$R *.lfm}

uses
  Process, FileUtil,
  main;

{ TFormBorradores }

procedure TFormBorradores.MemoRecorridosChange(Sender: TObject);
begin


end;

procedure TFormBorradores.FormCreate(Sender: TObject);
begin

end;

procedure TFormBorradores.BtnPreClick(Sender: TObject);
begin
  MemoRecorridos.Clear;
  BAVL_ToStrings_PreOrder(BorradoresAVL, MemoRecorridos.Lines);
end;

procedure TFormBorradores.BtnInClick(Sender: TObject);
begin
  MemoRecorridos.Clear;
  BAVL_ToStrings_InOrder(BorradoresAVL, MemoRecorridos.Lines);
end;

procedure TFormBorradores.BtnCargarPorIDClick(Sender: TObject);
var
  id: Integer;
  N: PAVL_Borr;
begin
  id := StrToIntDef(Trim(EditID.Text), -1);
  if id < 0 then
  begin
    ShowMessage('Ingresa un ID válido.');
    Exit;
  end;

  N := BAVL_Find(BorradoresAVL, id);
  if N = nil then
  begin
    ShowMessage('No existe un borrador con ID=' + IntToStr(id));
    Exit;
  end;

  if FormEnviarCorreo = nil then
    FormEnviarCorreo := TFormEnviarCorreo.Create(Self);

  FormEnviarCorreo.EditPara.Text   := N^.data.destinatario;
  FormEnviarCorreo.EditAsunto.Text := N^.data.asunto;
  FormEnviarCorreo.MemoMensaje.Text:= N^.data.mensaje;

  FormEnviarCorreo.DraftIdLoaded := N^.data.id;

  FormEnviarCorreo.ShowModal;

  MemoRecorridos.Clear;
  BAVL_ToStrings_InOrder(BorradoresAVL, MemoRecorridos.Lines);

end;

procedure TFormBorradores.BtnPostClick(Sender: TObject);
begin
  MemoRecorridos.Clear;
  BAVL_ToStrings_PostOrder(BorradoresAVL, MemoRecorridos.Lines);
end;

procedure TFormBorradores.FormShow(Sender: TObject);
begin
  MemoRecorridos.Clear;
end;

procedure TFormBorradores.ExportarReporteBorradoresAVL(const UsuarioEmail: String);
var
  dirU, dotPath, dotFile, pngFile: String;
  P: TProcess;
begin
  dirU := UsuarioEmail + '-Reportes' + DirectorySeparator;
  ForceDirectories(dirU);

  dotFile := dirU + 'borradores_avl.dot';
  pngFile := dirU + 'borradores_avl.png';

  BAVL_ToDOT(BorradoresAVL, dotFile);

  dotPath := '/usr/bin/dot';
  if not FileExists(dotPath) then
  begin
    ShowMessage('No se encontró Graphviz (dot).');
    Exit;
  end;

  P := TProcess.Create(nil);
  try
    P.Executable := dotPath;
    P.Parameters.Add('-Tpng');
    P.Parameters.Add(dotFile);
    P.Parameters.Add('-o');
    P.Parameters.Add(pngFile);
    P.Options := [poWaitOnExit];
    P.Execute;
  finally
    P.Free;
  end;

  if FileExists(pngFile) then
    ShowMessage('Reporte generado: ' + pngFile)
  else
    ShowMessage('No se pudo generar el PNG.');
end;

end.

