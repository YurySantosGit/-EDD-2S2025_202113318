unit form_papelera;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, pila_papelera;

type

  { TFormPapelera }

  TFormPapelera = class(TForm)
    BtnBuscar: TButton;
    BtnEliminar: TButton;
    BtnCerrar: TButton;
    EditBuscar: TEdit;
    Label1: TLabel;
    ListPapelera: TListBox;
    procedure BtnBuscarClick(Sender: TObject);
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnEliminarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

    procedure CargarTodo;

  public

  end;

var
  FormPapelera: TFormPapelera;

implementation

{$R *.lfm}

{ TFormPapelera }

procedure TFormPapelera.CargarTodo;
begin
  PapeleraALista(PapeleraGlobal, ListPapelera.Items);
end;

procedure TFormPapelera.BtnBuscarClick(Sender: TObject);
begin
  PapeleraAlistaFiltrada(PapeleraGlobal, EditBuscar.Text, ListPapelera.Items);
end;

procedure TFormPapelera.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormPapelera.BtnEliminarClick(Sender: TObject);
var
  info: TCorreoInfo;
begin
  if PopCorreo(PapeleraGlobal, info) then
  begin
    ShowMessage('Correo Eliminado - Asunto: ' + info.asunto);
    CargarTodo;
  end
  else
      ShowMessage('Papelera Vacia');
end;

procedure TFormPapelera.FormCreate(Sender: TObject);
begin
  CargarTodo;
end;

end.

