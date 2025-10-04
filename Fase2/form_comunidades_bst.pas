unit form_comunidades_bst;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  comunidades, bst_comunidades, app_state;

type

  { TFormComunidadesBST }

  TFormComunidadesBST = class(TForm)
    BtnCrear: TButton;
    BtnAgregar: TButton;
    BtnCerrar: TButton;
    ComboComunidades: TComboBox;
    EditCorreo: TEdit;
    EditNombre: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MemoLog: TMemo;
    procedure BtnAgregarClick(Sender: TObject);
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnCrearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure RefrescarCombo;
    procedure EnsureBST(const NombreComunidad: String);

  public

  end;

var
  FormComunidadesBST: TFormComunidadesBST;

implementation

{$R *.lfm}

procedure TFormComunidadesBST.FormShow(Sender: TObject);
begin
  RefrescarCombo;
end;

procedure TFormComunidadesBST.BtnCrearClick(Sender: TObject);
  var
  nom: String;
begin
  nom := Trim(EditNombre.Text);
  if nom = '' then
  begin
    MemoLog.Lines.Add('Nombre de comunidad vacio');
    Exit;
  end;

  if CrearComunidad(nom) then
  begin
    MemoLog.Lines.Add('Comunidad creada: ' + nom);
    EditNombre.Clear;
    RefrescarCombo;
  end
  else
  begin
    MemoLog.Lines.Add('Ya existe comunidad');
  end;
  EnsureBST(nom);
end;

procedure TFormComunidadesBST.BtnAgregarClick(Sender: TObject);
  var
    cod: Integer;
    nom, correo: String;
  begin
    if ComboComunidades.ItemIndex < 0 then
    begin
      MemoLog.Lines.Add('Selecciona una comunidad');
      Exit;
    end;

    nom    := ComboComunidades.Text;
    correo := Trim(EditCorreo.Text);

    if correo = '' then
    begin
      MemoLog.Lines.Add('Ingrese el correo del usuario a agregar');
      Exit;
    end;

    cod := AgregarMiembro(nom, correo);
    case cod of
      0: MemoLog.Lines.Add('Agregado a "' + nom + '": ' + correo);
      1: MemoLog.Lines.Add('No existe la comunidad.');
      2: MemoLog.Lines.Add('El usuario NO existe en el sistema.');
      3: MemoLog.Lines.Add('Usuario duplicado en esa comunidad.');
    end;

    EnsureBST(nom);
  end;

procedure TFormComunidadesBST.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormComunidadesBST.RefrescarCombo;
begin
  ListarComunidades(ListaComunidades, ComboComunidades.Items);
  if ComboComunidades.Items.Count > 0 then
    ComboComunidades.ItemIndex := 0;
end;

procedure TFormComunidadesBST.EnsureBST(const NombreComunidad: String);
var
  hoy: String;
begin
  hoy := FormatDateTime('dd/mm/yyyy', Now);
  BSTC_EnsureCommunity(ComunidadesBST, Trim(NombreComunidad), hoy);
end;

end.

