unit form_mensaje_comunidad;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  comunidades, app_state, bst_comunidades;

type

  { TFormMensajeComunidad }

  TFormMensajeComunidad = class(TForm)
    BtnPublicar: TButton;
    BtnCerrar: TButton;
    ComboComunidades: TComboBox;
    EditMensaje: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnPublicarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure CargarComunidadesDelUsuario;

  public

  end;

var
  FormMensajeComunidad: TFormMensajeComunidad;

implementation

{$R *.lfm}

procedure TFormMensajeComunidad.FormShow(Sender: TObject);
begin
  CargarComunidadesDelUsuario;
  if ComboComunidades.Items.Count = 0 then
    ShowMessage('No perteneces a ninguna comunidad.');
end;

procedure TFormMensajeComunidad.BtnPublicarClick(Sender: TObject);
var
  grupo, texto, fecha: String;
begin
  if ComboComunidades.ItemIndex < 0 then
  begin
    ShowMessage('Selecciona una comunidad.');
    Exit;
  end;

  grupo := ComboComunidades.Text;
  texto := Trim(EditMensaje.Text);
  if texto = '' then
  begin
    ShowMessage('Escribe un mensaje.');
    Exit;
  end;

  if BSTC_Find(ComunidadesBST, grupo) = nil then
  begin
    ShowMessage('La comunidad no existe en el BST');
    Exit;
  end;

  fecha := FormatDateTime('dd/mm/yyyy hh:nn', Now);
  if BSTC_AddMessage(ComunidadesBST, grupo, UsuarioActualEmail, texto, fecha) then
  begin
    ShowMessage('Mensaje publicado en "'+grupo+'".');
    EditMensaje.Clear;
    EditMensaje.SetFocus;
  end
  else
    ShowMessage('No fue posible publicar el mensaje.');
end;

procedure TFormMensajeComunidad.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMensajeComunidad.CargarComunidadesDelUsuario;
begin
  ComboComunidades.Items.BeginUpdate;
  try
    ComboComunidades.Items.Clear;
    ListarComunidadesDeUsuario(UsuarioActualEmail, ComboComunidades.Items);
    if ComboComunidades.Items.Count > 0 then
      ComboComunidades.ItemIndex := 0;
  finally
    ComboComunidades.Items.EndUpdate;
  end;
end;

end.

