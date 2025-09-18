unit form_papelera;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, StrUtils,
  pila_papelera;

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
    function TryGetIDSeleccionado(out AID: Integer): Boolean;

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
  selID: Integer;
  info, auxInfo: TCorreoInfo;
  kept: array of TCorreoInfo;
  count, i: Integer;
  eliminado: Boolean;
begin
  if not TryGetIDSeleccionado(selID) then
  begin
    ShowMessage('Selecciona un elemento válido (debe contener (ID:...)).');
    Exit;
  end;

  eliminado := False;
  SetLength(kept, 0);
  count := 0;

  while PopCorreo(PapeleraGlobal, info) do
  begin
    if (not eliminado) and (info.id = selID) then
    begin
      eliminado := True;
      auxInfo := info;
      Continue;
    end;
    Inc(count);
    SetLength(kept, count);
    kept[count-1] := info;
  end;

  if not eliminado then
  begin
    ShowMessage('No se encontró el ID seleccionado en la pila.');
  end
  else
  begin
    ShowMessage('Correo eliminado - Asunto: ' + auxInfo.asunto);
  end;

  for i := High(kept) downto Low(kept) do
    PushCorreo(PapeleraGlobal, kept[i]);

  CargarTodo;
end;

procedure TFormPapelera.FormCreate(Sender: TObject);
begin
  CargarTodo;
end;

function TFormPapelera.TryGetIDSeleccionado(out AID: Integer): Boolean;
var
  s, numStr: String;
  pID, i, nstart: Integer;
begin
  Result := False;
  AID := -1;

  if ListPapelera.ItemIndex = -1 then Exit;

  s := ListPapelera.Items[ListPapelera.ItemIndex];

  pID := AnsiPos('ID:', UpperCase(s));
  if pID = 0 then Exit;

  nstart := pID + 3;

  while (nstart <= Length(s)) and (s[nstart] = ' ') do Inc(nstart);

  i := nstart;
  while (i <= Length(s)) and (s[i] in ['0'..'9']) do Inc(i);

  if i = nstart then Exit;

  numStr := Copy(s, nstart, i - nstart);

  Result := TryStrToInt(numStr, AID);
end;

end.

