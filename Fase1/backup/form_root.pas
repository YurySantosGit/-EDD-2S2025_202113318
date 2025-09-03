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
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    MemoLog: TMemo;
    OpenDialog1: TOpenDialog;
    procedure BtnCargaMasivaClick(Sender: TObject);
    procedure BtnReporteRelacionesClick(Sender: TObject);
    procedure BtnCerrarSesionClick(Sender: TObject);
    procedure BtnReporteUsuariosClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
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
  main, reportes_root, bandejas;

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
  begin
  // Inicializa estructura de bandejas (si ya las inicializas en otro lado, no pasa nada)
  InicializarBandejas;

  // Semilla de relaciones: remitente -> destinatario
  // id, estado='NL', programado=False
  EntregarCorreoA('aux-luis@edd.com',   'aux-marcos@edd.com', 'Hola 1', '2025-09-03', '...', 1, 'NL', False);
  EntregarCorreoA('aux-marcos@edd.com', 'aux-luis@edd.com',   'Re: 1',  '2025-09-03', '...', 2, 'NL', False);
  EntregarCorreoA('teacher@edd.com',    'aux-marcos@edd.com', 'Aviso',  '2025-09-03', '...', 3, 'NL', False);

  // Repite para crear conteo > 1 en una celda específica:
  EntregarCorreoA('teacher@edd.com',    'aux-marcos@edd.com', 'Aviso 2','2025-09-03', '...', 4, 'NL', False);

  ShowMessage('Datos de demo sembrados en bandejas. Ahora genera el reporte de Relaciones.');
end;
end;

procedure TFormRoot.FormCreate(Sender: TObject);
begin

end;

procedure TFormRoot.MemoLogChange(Sender: TObject);
begin

end;

end.

