unit form_comunidades;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  comunidades;

type

  { TFormComunidades }

  TFormComunidades = class(TForm)
    BtnCrear: TButton;
    BtnAgregar: TButton;
    Cerrar: TButton;
    ComboComunidades: TComboBox;
    EditCorreo: TEdit;
    EditNombre: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MemoLog: TMemo;
    procedure BtnAgregarClick(Sender: TObject);
    procedure BtnCrearClick(Sender: TObject);
    procedure CerrarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    procedure RefrescarCombo;
  public

  end;

var
  FormComunidades: TFormComunidades;

implementation

{$R *.lfm}

{ TFormComunidades }

procedure TFormComunidades.RefrescarCombo;
begin
  ListarComunidades(ListaComunidades, ComboComunidades.Items);
  if ComboComunidades.Items.Count>0 then ComboComunidades.ItemIndex := 0;
end;

procedure TFormComunidades.Label1Click(Sender: TObject);
begin

end;

procedure TFormComunidades.BtnCrearClick(Sender: TObject);
begin
  if CrearComunidad(EditNombre.Text) then
  begin
    MemoLog.Lines.Add('Comunidad creada: ' + EditNombre.Text);
    EditNombre.Clear;
    RefrescarCombo;
  end
  else
    MemoLog.Lines.Add('Ya existe o nombre inválido.');
end;

procedure TFormComunidades.CerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormComunidades.FormCreate(Sender: TObject);
begin

end;

procedure TFormComunidades.FormShow(Sender: TObject);
begin
  RefrescarCombo;
end;

procedure TFormComunidades.BtnAgregarClick(Sender: TObject);
var cod: Integer;
begin
  if ComboComunidades.ItemIndex < 0 then
  begin
    MemoLog.Lines.Add('Selecciona una comunidad.');
    Exit;
  end;

  cod := AgregarMiembro(ComboComunidades.Text, EditCorreo.Text);
  case cod of
    0: MemoLog.Lines.Add('Agregado a "'+ComboComunidades.Text+'": '+EditCorreo.Text);
    1: MemoLog.Lines.Add('No existe la comunidad.');
    2: MemoLog.Lines.Add('El usuario NO existe en el sistema.');
    3: MemoLog.Lines.Add('Usuario duplicado en esa comunidad.');
  end;
end;

procedure TFormComunidades.Label2Click(Sender: TObject);
begin

end;

end.

