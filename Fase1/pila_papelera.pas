unit pila_papelera;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, lista_doble; // usamos PCorreo/TCorreo de la bandeja

type
  TCorreoInfo = record   // Versión simple del correo para la pila (para este proceso no se utilizaron punteros)
    id: Integer;
    remitente: String;
    estado: String;
    programado: Boolean;
    asunto: String;
    fecha: String;
    mensaje: String;
  end;

  PPilaNodo = ^TPilaNodo;
  TPilaNodo = record
    dato: TCorreoInfo;
    siguiente: PPilaNodo;
  end;

  TPilaCorreo = record
    tope: PPilaNodo;
    tamano: Integer;
  end;

procedure InicializarPapelera(var pila: TPilaCorreo);
procedure PushCorreo(var pila: TPilaCorreo; const info: TCorreoInfo);
function  PopCorreo(var pila: TPilaCorreo; out info: TCorreoInfo): Boolean;

function  CorreoToInfo(const c: PCorreo): TCorreoInfo;
procedure PapeleraALista(const pila: TPilaCorreo; items: TStrings);
procedure PapeleraAListaFiltrada(const pila: TPilaCorreo; const palabra: String; items: TStrings);

var
  PapeleraGlobal: TPilaCorreo;

implementation

procedure InicializarPapelera(var pila: TPilaCorreo);
begin
  pila.tope := nil;
  pila.tamano := 0;
end;

procedure PushCorreo(var pila: TPilaCorreo; const info: TCorreoInfo);
var
  nodo: PPilaNodo;
begin
  New(nodo);
  nodo^.dato := info;
  nodo^.siguiente := pila.tope;
  pila.tope := nodo;
  Inc(pila.tamano);
end;

function PopCorreo(var pila: TPilaCorreo; out info: TCorreoInfo): Boolean;
var
  tmp: PPilaNodo;
begin
  if pila.tope = nil then
    Exit(False);
  info := pila.tope^.dato;
  tmp := pila.tope;
  pila.tope := pila.tope^.siguiente;
  Dispose(tmp);
  Dec(pila.tamano);
  Result := True;
end;

function CorreoToInfo(const c: PCorreo): TCorreoInfo;
begin
  Result.id := c^.id;
  Result.remitente := c^.remitente;
  Result.estado := c^.estado;
  Result.programado := c^.programado;
  Result.asunto := c^.asunto;
  Result.fecha := c^.fecha;
  Result.mensaje := c^.mensaje;
end;

procedure PapeleraALista(const pila: TPilaCorreo; items: TStrings);
var
  it: PPilaNodo;
begin
  items.Clear;
  it := pila.tope;
  while it <> nil do
  begin
    items.Add('[' + it^.dato.estado + '] ' + it^.dato.asunto +
              ' - ' + it^.dato.remitente + ' (ID:' + IntToStr(it^.dato.id) + ')');
    it := it^.siguiente;
  end;
end;

procedure PapeleraAListaFiltrada(const pila: TPilaCorreo; const palabra: String; items: TStrings);
var
  it: PPilaNodo;
  pUp, asuntoUp: String;
begin
  items.Clear;
  pUp := UpperCase(Trim(palabra));
  it := pila.tope;
  while it <> nil do
  begin
    asuntoUp := UpperCase(it^.dato.asunto);
    if (pUp = '') or (Pos(pUp, asuntoUp) > 0) then
      items.Add('[' + it^.dato.estado + '] ' + it^.dato.asunto +
                ' - ' + it^.dato.remitente + ' (ID:' + IntToStr(it^.dato.id) + ')');
    it := it^.siguiente;
  end;
end;

function EliminarPorID(var pila: TPilaCorreo; id: Integer): Boolean;
var
  prev, curr: PPilaNodo;
begin
  Result := False;
  prev := nil;
  curr := pila.tope;
  while curr <> nil do
  begin
    if curr^.dato.id = id then
    begin
      if prev = nil then
        pila.tope := curr^.siguiente
      else
        prev^.siguiente := curr^.siguiente;
      Dispose(curr);
      Dec(pila.tamano);
      Exit(True);
    end;
    prev := curr;
    curr := curr^.siguiente;
  end;
end;

end.
