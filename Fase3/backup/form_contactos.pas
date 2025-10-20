unit form_contactos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  contactos, app_state, bst_contactos;

type

  { TFormContactos }

  TFormContactos = class(TForm)
    BtnAnterior: TButton;
    BtnSiguiente: TButton;
    BtnCerrar: TButton;
    BtnEliminar: TButton;
    LblPos: TLabel;
    LblTelefono: TLabel;
    LblEmail: TLabel;
    LblNombre: TLabel;
    LblTitulo: TLabel;
    procedure BtnAnteriorClick(Sender: TObject);
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnEliminarClick(Sender: TObject);
    procedure BtnSiguienteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

    FInicio: PContacto;
    FActual: PContacto;
    FCount: Integer;
    procedure PrepararVista;
    procedure MostrarActual;
    function  SiguienteDelDueno(p: PContacto): PContacto;
    function  AnteriorDelDueno(p: PContacto): PContacto;
    function  EliminarContactoPropioDeLista(const ownerEmail, email: String): Boolean;
    function  PosicionActual: Integer;

  public

  end;

var
  FormContactos: TFormContactos;

implementation

{$R *.lfm}

{ TFormContactos }

uses
  main;

procedure TFormContactos.FormCreate(Sender: TObject);
begin
  PrepararVista;
  MostrarActual;
end;

procedure TFormContactos.PrepararVista;
var
  act: PContacto;
begin
  FInicio := nil;
  FActual := nil;
  FCount  := 0;

  if ListaContactos.cabeza = nil then Exit;


  act := ListaContactos.cabeza;
  repeat
    if SameText(act^.ownerEmail, UsuarioActualEmail) then
    begin
      if FInicio = nil then
        FInicio := act;
      Inc(FCount);
    end;
    act := act^.siguiente;
  until act = ListaContactos.cabeza;

  if FCount > 0 then
    FActual := FInicio;
end;

procedure TFormContactos.MostrarActual;
var
  pos: Integer;
begin
  if (FCount = 0) or (FActual = nil) then
  begin
    LblNombre.Caption   := 'Nombre: -';
    LblEmail.Caption    := 'Email: -';
    LblTelefono.Caption := 'Teléfono: -';
    LblPos.Caption      := '0 de 0';
    BtnAnterior.Enabled := False;
    BtnSiguiente.Enabled:= False;
    Exit;
  end;

  LblNombre.Caption   := 'Nombre: '   + FActual^.nombre;
  LblEmail.Caption    := 'Email: '    + FActual^.email;
  LblTelefono.Caption := 'Teléfono: ' + FActual^.telefono;

  pos := PosicionActual;
  LblPos.Caption := Format('%d de %d', [pos, FCount]);

  BtnAnterior.Enabled := FCount > 1;
  BtnSiguiente.Enabled:= FCount > 1;
end;

function TFormContactos.SiguienteDelDueno(p: PContacto): PContacto;
var
  q: PContacto;
begin
  if (p = nil) or (ListaContactos.cabeza = nil) then Exit(nil);

  q := p^.siguiente;
  while not SameText(q^.ownerEmail, UsuarioActualEmail) do
    q := q^.siguiente;

  Result := q;
end;

function TFormContactos.AnteriorDelDueno(p: PContacto): PContacto;
var
  q, ultimoValido: PContacto;
begin

  if (p = nil) or (ListaContactos.cabeza = nil) then Exit(nil);

  ultimoValido := p;
  q := p^.siguiente;
  repeat
    if SameText(q^.ownerEmail, UsuarioActualEmail) then
      ultimoValido := q;
    q := q^.siguiente;
  until q = p;

  Result := ultimoValido;
end;

function TFormContactos.PosicionActual: Integer;
var
  pos: Integer;
  q: PContacto;
begin
  if (FInicio = nil) or (FActual = nil) then Exit(0);

  pos := 1;
  q := FInicio;

  if q = FActual then Exit(pos);

  repeat
    q := SiguienteDelDueno(q);
    Inc(pos);
  until (q = FActual) or (pos > FCount);

  Result := pos;
end;

procedure TFormContactos.BtnAnteriorClick(Sender: TObject);
begin
  if FCount <= 1 then Exit;
  FActual := AnteriorDelDueno(FActual);
  MostrarActual;
end;

procedure TFormContactos.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormContactos.BtnEliminarClick(Sender: TObject);
var
  emailDel: String;
  okBST: Boolean;
begin
  if (FCount = 0) or (FActual = nil) then
  begin
    ShowMessage('No hay contacto seleccionado.');
    Exit;
  end;

  emailDel := Trim(FActual^.email);

  okBST := BST_Delete(ContactosBST, emailDel);

  if EliminarContactoPropioDeLista(UsuarioActualEmail, emailDel) then
  begin
    if okBST then
      ShowMessage('Contacto eliminado')
    else
      ShowMessage('Contacto eliminado de la lista');
  end
  else
  begin
    if okBST then
      ShowMessage('Contacto eliminado del BST.')
    else
      ShowMessage('No se encontró el contacto para eliminar.');
  end;

  if BST_Search(ContactosBST, emailDel) = nil then
    ShowMessage('Contacto ya no existe en el arbol.')
  else
    ShowMessage('Contacto no eliminado, revisar email');

  PrepararVista;
  MostrarActual;
end;

procedure TFormContactos.BtnSiguienteClick(Sender: TObject);
begin
  if FCount <= 1 then Exit;
  FActual := SiguienteDelDueno(FActual);
  MostrarActual;
end;

end.

