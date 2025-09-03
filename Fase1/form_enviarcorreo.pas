unit form_enviarcorreo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormEnviarCorreo }

  TFormEnviarCorreo = class(TForm)
    BtnEnviar: TButton;
    BtnCerrar: TButton;
    EditAsunto: TEdit;
    EditPara: TEdit;
    LblMensaje: TLabel;
    LblAsunto: TLabel;
    LblPara: TLabel;
    MemoMensaje: TMemo;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnEnviarClick(Sender: TObject);
  private
    function EmailValido(const s: String): Boolean;
  public

  end;

var
  FormEnviarCorreo: TFormEnviarCorreo;

implementation

{$R *.lfm}

{ TFormEnviarCorreo }

uses
  main, contactos, lista_doble, form_bandeja, bandejas;

function TFormEnviarCorreo.EmailValido(const s: String): Boolean;
begin
  Result := (Pos('@', s) > 1) and (Pos('.', s) > 3);
end;

procedure TFormEnviarCorreo.BtnEnviarClick(Sender: TObject);
var
  para, asunto, msg, fechaHora: String;
  nuevoId: Integer;
begin
  para   := Trim(EditPara.Text);
  asunto := Trim(EditAsunto.Text);
  msg    := Trim(MemoMensaje.Lines.Text);

  if (para = '') or (asunto = '') then
  begin
    ShowMessage('Para y Asunto son obligatorios.');
    Exit;
  end;

  if not EmailValido(para) then
  begin
    ShowMessage('Formato de correo invalido.');
    Exit;
  end;

  if not EsContacto(ListaContactos, UsuarioActualEmail, para) then
  begin
    ShowMessage('Envío fallido: el destinatario NO es tu contacto.');
    Exit;
  end;

  fechaHora := FormatDateTime('dd/mm/yyyy hh:nn', Now);
  nuevoId   := Random(100000);

  EntregarCorreoA(
    para,
    UsuarioActualEmail,
    asunto,
    fechaHora,
    msg,
    nuevoId,
    'NL',
    False
  );

  ShowMessage('Envío exitoso.');
  EditPara.Clear;
  EditAsunto.Clear;
  MemoMensaje.Clear;
  EditPara.SetFocus;
end;

procedure TFormEnviarCorreo.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.

