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

