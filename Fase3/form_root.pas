unit form_root;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  usuarios, comunidades, carga_masiva_correos, form_comunidades_bst,
  FormMensajesComunidadesRoot, reportes_comunidades_bst, app_state,
  form_control_logueo;

type

  { TFormRoot }

  TFormRoot = class(TForm)
    BtnCargaMasiva: TButton;
    BtnReporteUsuarios: TButton;
    BtnReporteRelaciones: TButton;
    BtnCerrarSesion: TButton;
    BtnCrearComunidadBST: TButton;
    BtnVerMensajesComunidades: TButton;
    BtnReporteComunidadesBST: TButton;
    BtnControlLogueo: TButton;
    CargaMasivaCorreos: TButton;
    ReporteComunidades: TButton;
    Comunidad: TButton;
    Label1: TLabel;
    Label2: TLabel;
    MemoLog: TMemo;
    OpenDialog1: TOpenDialog;
    procedure BtnCargaMasivaClick(Sender: TObject);
    procedure BtnControlLogueoClick(Sender: TObject);
    procedure BtnReporteComunidadesBSTClick(Sender: TObject);
    procedure BtnReporteRelacionesClick(Sender: TObject);
    procedure BtnCerrarSesionClick(Sender: TObject);
    procedure BtnReporteUsuariosClick(Sender: TObject);
    procedure BtnVerMensajesComunidadesClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CargaMasivaCorreosClick(Sender: TObject);
    procedure ComunidadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MemoLogChange(Sender: TObject);
    procedure ReporteComunidadesClick(Sender: TObject);
    procedure BtnCrearComunidadBSTClick(Sender: TObject);

  private

  public

  end;

var
  FormRoot: TFormRoot;

implementation

{$R *.lfm}

uses
  main, reportes_root, bandejas, reportes_comunidades, form_comunidades;

{ TFormRoot }

procedure TFormRoot.BtnReporteRelacionesClick(Sender: TObject);
begin
  GenerarReporteRelaciones;
  ShowMessage('Reporte de Relaciones creado en "Root-Reportes/relaciones.dot".');
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

procedure TFormRoot.BtnControlLogueoClick(Sender: TObject);
begin
  if FormControlLogueo = nil then
    FormControlLogueo := TFormControlLogueo.Create(Self);
  FormControlLogueo.ShowModal;
end;

procedure TFormRoot.BtnReporteComunidadesBSTClick(Sender: TObject);
var
  usuarioCarp: string;
begin
  usuarioCarp := Copy(UsuarioActualEmail, 1, Pos('@', UsuarioActualEmail) - 1);
  if usuarioCarp = '' then usuarioCarp := 'usuario';

  GenerarReporteComunidadesBSTPorEmail(UsuarioActualEmail);
  ShowMessage('Reporte de Comunidades BST generado en "' +
              usuarioCarp + '-Reportes/comunidades_bst.png".');
end;

procedure TFormRoot.BtnCerrarSesionClick(Sender: TObject);
begin
  Form1.Show;
  Self.Close;
end;

procedure TFormRoot.BtnReporteUsuariosClick(Sender: TObject);
begin
  GenerarReporteUsuarios;
  ShowMessage('Reporte de Usuarios creado en "Root-Reportes/usuarios.dot".');
end;

procedure TFormRoot.BtnVerMensajesComunidadesClick(Sender: TObject);
begin
  if FormVerMensajes = nil then
    FormVerMensajes := TFormVerMensajes.Create(Self);
  FormVerMensajes.ShowModal;
end;

procedure TFormRoot.Button1Click(Sender: TObject);
var
  agregados, rechazados: Integer;
  log: TStringList;
begin
  if not Assigned(OpenDialog1) then
  begin
    ShowMessage('No se encontró OpenDialog1 en el formulario.');
    Exit;
  end;

  OpenDialog1.Title  := 'Selecciona el archivo JSON de correos';
  OpenDialog1.Filter := 'Archivos JSON|*.json|Todos|*.*';
  if not OpenDialog1.Execute then Exit;

  log := TStringList.Create;
  try
    CargaMasivaCorreosDesdeJSON(OpenDialog1.FileName, agregados, rechazados, log);

    ShowMessage(Format('Carga masiva de correos finalizada.' + LineEnding +
                       'Agregados: %d' + LineEnding +
                       'Rechazados: %d',
                       [agregados, rechazados]));

    if Assigned(MemoLog) then
    begin
      MemoLog.Lines.Clear;
      MemoLog.Lines.AddStrings(log);
    end;
  finally
    log.Free;
  end;
end;

procedure TFormRoot.CargaMasivaCorreosClick(Sender: TObject);
var
  agregados, rechazados: Integer;
  log: TStringList;
begin
  if not Assigned(OpenDialog1) then
  begin
    ShowMessage('No se encontró OpenDialog1 en el formulario.');
    Exit;
  end;

  OpenDialog1.Title  := 'Selecciona el archivo JSON de correos';
  OpenDialog1.Filter := 'Archivos JSON|*.json|Todos|*.*';
  if not OpenDialog1.Execute then Exit;

  log := TStringList.Create;
  try
    CargaMasivaCorreosDesdeJSON(OpenDialog1.FileName, agregados, rechazados, log);

    ShowMessage(Format('Carga masiva de correos finalizada.' + LineEnding +
                       'Agregados: %d' + LineEnding +
                       'Rechazados: %d',
                       [agregados, rechazados]));

    if Assigned(MemoLog) then
    begin
      MemoLog.Lines.Clear;
      MemoLog.Lines.AddStrings(log);
    end;
  finally
    log.Free;
  end;
end;

procedure TFormRoot.ComunidadClick(Sender: TObject);
begin
  FormComunidades := TFormComunidades.Create(Self);
  FormComunidades.ShowModal;
end;

procedure TFormRoot.FormCreate(Sender: TObject);
begin

end;

procedure TFormRoot.MemoLogChange(Sender: TObject);
begin

end;

procedure TFormRoot.ReporteComunidadesClick(Sender: TObject);
begin
  GenerarReporteComunidades;
  ShowMessage('Reporte de comunidades generado.');
end;

procedure TFormRoot.BtnCrearComunidadBSTClick(Sender: TObject);
begin
  if FormComunidadesBST = nil then
    FormComunidadesBST := TFormComunidadesBST.Create(Self);
  FormComunidadesBST.ShowModal;
end;

end.

