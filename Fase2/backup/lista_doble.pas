unit lista_doble;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  PCorreo = ^TCorreo;
  PBandeja = ^TBandeja;

  TCorreo = record
    id: Integer;
    remitente: String;
    estado: String;      // 'NL' = no leído, 'L' = leído
    programado: Boolean; // True = programado
    asunto: String;
    fecha: String;
    mensaje: String;
    anterior: PCorreo;
    siguiente: PCorreo;
  end;

  TBandeja = record
    cabeza: PCorreo;
    cola: PCorreo;
    tamano: Integer;
  end;

// Operaciones
procedure InicializarBandeja(var bandeja: TBandeja);
procedure InsertarCorreo(var bandeja: TBandeja; id: Integer; remitente, estado: String;
  programado: Boolean; asunto, fecha, mensaje: String);
procedure MostrarBandeja(bandeja: TBandeja);
function BuscarCorreo(bandeja: TBandeja; id: Integer): PCorreo;
function EliminarCorreo(var bandeja: TBandeja; id: Integer): Boolean;
procedure OrdenarPorAsunto(var bandeja: TBandeja);

implementation

procedure InicializarBandeja(var bandeja: TBandeja);
begin
  bandeja.cabeza := nil;
  bandeja.cola := nil;
  bandeja.tamano := 0;
end;

procedure InsertarCorreo(var bandeja: TBandeja; id: Integer; remitente, estado: String;
  programado: Boolean; asunto, fecha, mensaje: String);
var
  nuevo: PCorreo;
begin
  New(nuevo);
  nuevo^.id := id;
  nuevo^.remitente := remitente;
  nuevo^.estado := estado;
  nuevo^.programado := programado;
  nuevo^.asunto := asunto;
  nuevo^.fecha := fecha;
  nuevo^.mensaje := mensaje;
  nuevo^.anterior := bandeja.cola;
  nuevo^.siguiente := nil;

  if bandeja.cabeza = nil then
    bandeja.cabeza := nuevo
  else
    bandeja.cola^.siguiente := nuevo;

  bandeja.cola := nuevo;
  Inc(bandeja.tamano);
end;

procedure MostrarBandeja(bandeja: TBandeja);
var
  actual: PCorreo;
begin
  actual := bandeja.cabeza;
  while actual <> nil do
  begin
    WriteLn('ID: ', actual^.id, ' | Asunto: ', actual^.asunto, ' | Remitente: ', actual^.remitente);
    actual := actual^.siguiente;
  end;
end;

function BuscarCorreo(bandeja: TBandeja; id: Integer): PCorreo;
var
  actual: PCorreo;
begin
  actual := bandeja.cabeza;
  while actual <> nil do
  begin
    if actual^.id = id then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

function EliminarCorreo(var bandeja: TBandeja; id: Integer): Boolean;
var
  actual: PCorreo;
begin
  actual := BuscarCorreo(bandeja, id);
  if actual = nil then
    Exit(False);

  if actual^.anterior <> nil then
    actual^.anterior^.siguiente := actual^.siguiente
  else
    bandeja.cabeza := actual^.siguiente;

  if actual^.siguiente <> nil then
    actual^.siguiente^.anterior := actual^.anterior
  else
    bandeja.cola := actual^.anterior;

  Dispose(actual);
  Dec(bandeja.tamano);
  Result := True;
end;

procedure OrdenarPorAsunto(var bandeja: TBandeja);
var
  i, j: PCorreo;
  temp: TCorreo;
begin
  i := bandeja.cabeza;
  while (i <> nil) do
  begin
    j := i^.siguiente;
    while (j <> nil) do
    begin
      if CompareText(i^.asunto, j^.asunto) > 0 then
      begin
        // intercambio de valores (sin tocar punteros)
        temp.id := i^.id;
        temp.remitente := i^.remitente;
        temp.estado := i^.estado;
        temp.programado := i^.programado;
        temp.asunto := i^.asunto;
        temp.fecha := i^.fecha;
        temp.mensaje := i^.mensaje;

        i^.id := j^.id;
        i^.remitente := j^.remitente;
        i^.estado := j^.estado;
        i^.programado := j^.programado;
        i^.asunto := j^.asunto;
        i^.fecha := j^.fecha;
        i^.mensaje := j^.mensaje;

        j^.id := temp.id;
        j^.remitente := temp.remitente;
        j^.estado := temp.estado;
        j^.programado := temp.programado;
        j^.asunto := temp.asunto;
        j^.fecha := temp.fecha;
        j^.mensaje := temp.mensaje;
      end;
      j := j^.siguiente;
    end;
    i := i^.siguiente;
  end;
end;

end.
