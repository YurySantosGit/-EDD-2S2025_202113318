unit form_correosprogramados;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  cola_correos, lista_doble;

type

  { TFormCorreosProgramados }

  TFormCorreosProgramados = class(TForm)
    BtnActualizar: TButton;
    BtnProcesar: TButton;
    BtnCerrar: TButton;
    LblPendientes: TLabel;
    LblTitulo: TLabel;
    ListProgramados: TListBox;
    procedure BtnActualizarClick(Sender: TObject);
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnProcesarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure ActualizarLista;
    function  ParseFechaHora(const f, h: String; out dt: TDateTime): Boolean;
    procedure EntregarCorreo(const c: TCorreoProgramado);

  public

  end;

var
  FormCorreosProgramados: TFormCorreosProgramados;

implementation

{$R *.lfm}

uses
  form_bandeja, bandejas, main;

{ TFormCorreosProgramados }

procedure TFormCorreosProgramados.FormCreate(Sender: TObject);
begin
  ActualizarLista;
end;

procedure TFormCorreosProgramados.BtnActualizarClick(Sender: TObject);
begin
  ActualizarLista;
end;

procedure TFormCorreosProgramados.ActualizarLista;
begin
  ColaALista(ColaGlobal, ListProgramados.Items);
  LblPendientes.Caption := 'Pendientes: ' + IntToStr(ColaGlobal.tamano);
end;

function TFormCorreosProgramados.ParseFechaHora(const f, h: String; out dt: TDateTime): Boolean;
var
  FS: TFormatSettings;
begin
  FS := DefaultFormatSettings;
  FS.DateSeparator := '/';
  FS.TimeSeparator := ':';
  FS.ShortDateFormat := 'dd/mm/yyyy';
  FS.ShortTimeFormat := 'hh:nn';
  Result := TryStrToDateTime(f + ' ' + h, dt, FS);
end;

procedure TFormCorreosProgramados.EntregarCorreo(const c: TCorreoProgramado);
begin
  EntregarCorreoA(
    c.destinatario,
    c.remitente,
    c.asunto,
    c.fecha + ' ' + c.hora,
    c.mensaje,
    c.id,
    'NL',
    False
  );
end;

procedure TFormCorreosProgramados.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCorreosProgramados.BtnProcesarClick(Sender: TObject);
var
  dtProgramado, ahora: TDateTime;
  correo: TCorreoProgramado;
  enviados: Integer;
begin
  enviados := 0;
  ahora := Now;

  while (ColaGlobal.frente <> nil) do
  begin
    if not ParseFechaHora(ColaGlobal.frente^.dato.fecha, ColaGlobal.frente^.dato.hora, dtProgramado) then
    begin
      Desencolar(ColaGlobal, correo);
      EntregarCorreo(correo);
      Inc(enviados);
      Continue;
    end;

    if dtProgramado <= ahora then
    begin
      Desencolar(ColaGlobal, correo);
      EntregarCorreo(correo);
      Inc(enviados);
    end
    else
      Break;
  end;

  if enviados > 0 then
    ShowMessage('Se enviaron automáticamente ' + IntToStr(enviados) + ' correo(s).')
  else
    ShowMessage('No hay correos vencidos para enviar.');

  ActualizarLista;

  if Assigned(FormBandeja) and FormBandeja.Visible then
    FormBandeja.CargarBandejaPtr(ObtenerBandejaPtr(UsuarioActualEmail));

end;

end.

