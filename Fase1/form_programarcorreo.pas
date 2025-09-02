unit form_programarcorreo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  EditBtn, Spin, lista_doble, cola_correos;

type

  { TFormProgramarCorreo }

  TFormProgramarCorreo = class(TForm)
    BtnProgramar: TButton;
    DateProgramada: TDateEdit;
    EditDestinatario: TEdit;
    EditAsunto: TEdit;
    LblHora: TLabel;
    LblEstado: TLabel;
    LblFecha: TLabel;
    LblMensaje: TLabel;
    LblDestinatario: TLabel;
    LblAsunto: TLabel;
    MemoMensaje: TMemo;
    TimeProgramada: TTimeEdit;
    procedure BtnProgramarClick(Sender: TObject);
    procedure DateProgramadaChange(Sender: TObject);
    procedure MemoMensajeChange(Sender: TObject);
    procedure TimeProgramadaChange(Sender: TObject);
  private

    function FormatFecha(const d: TDateTime): String;
    function FormatHora(const t: TDateTime): String;

  public

  end;

var
  FormProgramarCorreo: TFormProgramarCorreo;

implementation

{$R *.lfm}

uses
  usuarios;

{ TFormProgramarCorreo }

function TFormProgramarCorreo.FormatFecha(const d: TDateTime): String;
var FS: TFormatSettings;
begin
  FS := DefaultFormatSettings;
  FS.DateSeparator := '/';
  FS.ShortDateFormat := 'dd/mm/yyyy';
  Result := DateToStr(d, FS);
end;

function TFormProgramarCorreo.FormatHora(const t: TDateTime): String;
var FS: TFormatSettings;
begin
  FS := DefaultFormatSettings;
  FS.TimeSeparator := ':';
  FS.ShortTimeFormat := 'hh:nn';
  Result := TimeToStr(t, FS);
end;

procedure TFormProgramarCorreo.MemoMensajeChange(Sender: TObject);
begin

end;

procedure TFormProgramarCorreo.TimeProgramadaChange(Sender: TObject);
begin

end;

procedure TFormProgramarCorreo.BtnProgramarClick(Sender: TObject);
var
  correo: TCorreoProgramado;
begin
  if (Trim(EditDestinatario.Text) = '') or (Trim(EditAsunto.Text) = '') then
  begin
    ShowMessage('Debe llenar al menos el destinatario y el asunto.');
    Exit;
  end;

  correo.id := Random(100000);             // ID simple
  correo.remitente := 'root@edd.com';      // luego: usuario logueado
  correo.destinatario := EditDestinatario.Text;
  correo.asunto := EditAsunto.Text;
  correo.mensaje := MemoMensaje.Text;
  correo.fecha := FormatFecha(DateProgramada.Date);
  correo.hora  := FormatHora(TimeProgramada.Time);

  Encolar(ColaGlobal, correo);

  LblEstado.Caption := 'Correo programado: ' + correo.fecha + ' ' + correo.hora;
  LblEstado.Font.Color := clGreen;

  EditDestinatario.Clear;
  EditAsunto.Clear;
  MemoMensaje.Clear;
end;

procedure TFormProgramarCorreo.DateProgramadaChange(Sender: TObject);
begin

end;

end.

