unit form_enviarcorreo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  app_state, avl_borradores;

type

  { TFormEnviarCorreo }

  TFormEnviarCorreo = class(TForm)
    BtnEnviar: TButton;
    BtnCerrar: TButton;
    Borrador: TButton;
    EditAsunto: TEdit;
    EditPara: TEdit;
    LblMensaje: TLabel;
    LblAsunto: TLabel;
    LblPara: TLabel;
    MemoMensaje: TMemo;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnEnviarClick(Sender: TObject);
    procedure BorradorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function EmailValido(const s: String): Boolean;
  public
    DraftIdLoaded: Integer;
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

  if DraftIdLoaded >= 0 then
  begin
    if BAVL_Delete(BorradoresAVL, DraftIdLoaded) then
      ShowMessage('Envío exitoso. Borrador eliminado.')
    else
      ShowMessage('Envío exitoso');
    DraftIdLoaded := -1;
  end
  else
    ShowMessage('Envío exitoso.');

  EditPara.Clear;
  EditAsunto.Clear;
  MemoMensaje.Clear;
  EditPara.SetFocus;
end;

procedure TFormEnviarCorreo.BorradorClick(Sender: TObject);
var
  B: TBorrador;
begin
  if Trim(EditAsunto.Text) = '' then
  begin
    ShowMessage('El asunto no puede estar vacío para guardar como borrador.');
    Exit;
  end;

  B.id           := NextDraftId;
  B.remitente    := UsuarioActualEmail;
  B.destinatario := Trim(EditPara.Text);
  B.asunto       := Trim(EditAsunto.Text);
  B.mensaje      := MemoMensaje.Lines.Text;

  BAVL_Insert(BorradoresAVL, B);
  ShowMessage('Borrador guardado');
end;

procedure TFormEnviarCorreo.FormCreate(Sender: TObject);
begin
  DraftIdLoaded := -1;
end;

procedure TFormEnviarCorreo.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.

