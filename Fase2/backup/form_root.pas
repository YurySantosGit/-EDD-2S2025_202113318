unit form_root;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  usuarios, comunidades;

type

  { TFormRoot }

  TFormRoot = class(TForm)
    BtnCargaMasiva: TButton;
    BtnReporteUsuarios: TButton;
    BtnReporteRelaciones: TButton;
    BtnCerrarSesion: TButton;
    ReporteComunidades: TButton;
    Comunidad: TButton;
    Label1: TLabel;
    Label2: TLabel;
    MemoLog: TMemo;
    OpenDialog1: TOpenDialog;
    procedure BtnCargaMasivaClick(Sender: TObject);
    procedure BtnReporteRelacionesClick(Sender: TObject);
    procedure BtnCerrarSesionClick(Sender: TObject);
    procedure BtnReporteUsuariosClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComunidadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MemoLogChange(Sender: TObject);
    procedure ReporteComunidadesClick(Sender: TObject);
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

procedure TFormRoot.Button1Click(Sender: TObject);
begin

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

end.

