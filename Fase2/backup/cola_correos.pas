unit cola_correos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TCorreoProgramado = record
    id: Integer;
    remitente: String;
    destinatario: String;
    asunto: String;
    mensaje: String;
    fecha: String;   // formato DD/MM/AAAA
  end;

  PColaNodo = ^TColaNodo;
  TColaNodo = record
    dato: TCorreoProgramado;
    siguiente: PColaNodo;
  end;

  TColaCorreos = record
    frente, fin: PColaNodo;
    tamano: Integer;
  end;

procedure InicializarCola(var cola: TColaCorreos);
procedure Encolar(var cola: TColaCorreos; correo: TCorreoProgramado);
function  Desencolar(var cola: TColaCorreos; out correo: TCorreoProgramado): Boolean;
procedure ColaALista(const cola: TColaCorreos; items: TStrings);

var
  ColaGlobal: TColaCorreos;

implementation

procedure InicializarCola(var cola: TColaCorreos);
begin
  cola.frente := nil;
  cola.fin := nil;
  cola.tamano := 0;
end;

procedure Encolar(var cola: TColaCorreos; correo: TCorreoProgramado);
var
  nodo: PColaNodo;
begin
  New(nodo);
  nodo^.dato := correo;
  nodo^.siguiente := nil;

  if cola.fin = nil then
    cola.frente := nodo
  else
    cola.fin^.siguiente := nodo;

  cola.fin := nodo;
  Inc(cola.tamano);
end;

function Desencolar(var cola: TColaCorreos; out correo: TCorreoProgramado): Boolean;
var
  nodo: PColaNodo;
begin
  if cola.frente = nil then
    Exit(False);

  nodo := cola.frente;
  correo := nodo^.dato;
  cola.frente := nodo^.siguiente;

  if cola.frente = nil then
    cola.fin := nil;

  Dispose(nodo);
  Dec(cola.tamano);
  Result := True;
end;

procedure ColaALista(const cola: TColaCorreos; items: TStrings);
var
  actual: PColaNodo;
begin
  items.Clear;
  actual := cola.frente;
  while actual <> nil do
  begin
    items.Add(actual^.dato.fecha + ' ' +
              ' - ' + actual^.dato.asunto +
              ' -> ' + actual^.dato.destinatario);
    actual := actual^.siguiente;
  end;
end;

end.
