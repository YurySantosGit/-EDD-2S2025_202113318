unit bandejas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, lista_doble;

type
  PBandejaNodo = ^TBandejaNodo;
  TBandejaNodo = record
    ownerEmail: String;
    bandeja: TBandeja;
    siguiente: PBandejaNodo;
  end;

var
  ListaBandejas: PBandejaNodo = nil;

procedure InicializarBandejas;
function  ObtenerBandejaPtr(const ownerEmail: String): ^TBandeja;
procedure EntregarCorreoA(const destinatario, remitente, asunto, fecha, mensaje: String;
  id: Integer; estado: String = 'NL'; programado: Boolean = False);

implementation

procedure InicializarBandejas;
begin
  ListaBandejas := nil;
end;

function BuscarNodo(const ownerEmail: String): PBandejaNodo;
var
  act: PBandejaNodo;
begin
  act := ListaBandejas;
  while act <> nil do
  begin
    if SameText(act^.ownerEmail, ownerEmail) then Exit(act);
    act := act^.siguiente;
  end;
  Result := nil;
end;

function  ObtenerBandejaPtr(const ownerEmail: String): PBandeja;
var
  nodo, nuevo: PBandejaNodo;
begin
  nodo := BuscarNodo(ownerEmail);
  if nodo = nil then
  begin
    New(nuevo);
    nuevo^.ownerEmail := ownerEmail;
    InicializarBandeja(nuevo^.bandeja);
    nuevo^.siguiente := ListaBandejas;
    ListaBandejas := nuevo;
    Result := @nuevo^.bandeja;
  end
  else
    Result := @nodo^.bandeja;
end;

procedure EntregarCorreoA(const destinatario, remitente, asunto, fecha, mensaje: String;
  id: Integer; estado: String; programado: Boolean);
var
  pB: PBandeja;
begin
  pB := ObtenerBandejaPtr(destinatario);
  InsertarCorreo(pB^, id, remitente, estado, programado, asunto, fecha, mensaje);
end;

end.

