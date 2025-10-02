unit contactos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser;

type
  PContacto = ^TContacto;

  TContacto = record
    id: Integer;
    ownerEmail: String;
    nombre: String;
    email: String;
    telefono: String;
    siguiente: PContacto;
  end;

  TListaContactos = record
    cabeza: PContacto;
    tamano: Integer;
  end;

var
  ListaContactos: TListaContactos;


procedure InicializarContactos(var lista: TListaContactos);
procedure LiberarContactos(var lista: TListaContactos);

procedure AgregarContacto(var lista: TListaContactos; id: Integer;
  const ownerEmail, nombre, email, telefono: String);

function ExisteContactoEmail(const lista: TListaContactos;
  const ownerEmail, email: String): Boolean;

function EsContacto(const lista: TListaContactos;
  const ownerEmail, email: String): Boolean;

procedure ListarContactos(const lista: TListaContactos; items: TStrings;
  const ownerEmail: String);

function EliminarContacto(var lista: TListaContactos; const ownerEmail: String;
  id: Integer): Boolean;

function ObtenerSiguienteIDContacto(const lista: TListaContactos): Integer;

procedure CargarContactosDesdeJSON(var lista: TListaContactos; const archivo: String);
procedure GuardarContactosEnJSON(const lista: TListaContactos; const archivo: String);

implementation

procedure InicializarContactos(var lista: TListaContactos);
begin
  lista.cabeza := nil;
  lista.tamano := 0;
end;

procedure LiberarContactos(var lista: TListaContactos);
var
  act, sig: PContacto;
begin
  if lista.cabeza = nil then Exit;

  act := lista.cabeza^.siguiente;
  while act <> lista.cabeza do
  begin
    sig := act^.siguiente;
    Dispose(act);
    act := sig;
  end;
  Dispose(lista.cabeza);

  lista.cabeza := nil;
  lista.tamano := 0;
end;

procedure AgregarContacto(var lista: TListaContactos; id: Integer;
  const ownerEmail, nombre, email, telefono: String);
var
  nuevo, cola: PContacto;
begin
  New(nuevo);
  nuevo^.id         := id;
  nuevo^.ownerEmail := ownerEmail;
  nuevo^.nombre     := nombre;
  nuevo^.email      := email;
  nuevo^.telefono   := telefono;

  if lista.cabeza = nil then
  begin
    lista.cabeza := nuevo;
    nuevo^.siguiente := nuevo;
  end
  else
  begin
    cola := lista.cabeza;
    while cola^.siguiente <> lista.cabeza do
      cola := cola^.siguiente;

    cola^.siguiente := nuevo;
    nuevo^.siguiente := lista.cabeza;
  end;

  Inc(lista.tamano);
end;

function ExisteContactoEmail(const lista: TListaContactos;
  const ownerEmail, email: String): Boolean;
var
  act: PContacto;
begin
  Result := False;
  if lista.cabeza = nil then Exit;

  act := lista.cabeza;
  repeat
    if SameText(act^.ownerEmail, ownerEmail) and SameText(act^.email, email) then
      Exit(True);
    act := act^.siguiente;
  until act = lista.cabeza;
end;

function EsContacto(const lista: TListaContactos;
  const ownerEmail, email: String): Boolean;
begin
  Result := ExisteContactoEmail(lista, ownerEmail, email);
end;

procedure ListarContactos(const lista: TListaContactos; items: TStrings;
  const ownerEmail: String);
var
  act: PContacto;
begin
  if items <> nil then items.Clear;
  if lista.cabeza = nil then Exit;

  act := lista.cabeza;
  repeat
    if SameText(act^.ownerEmail, ownerEmail) then
      if items <> nil then
        items.Add(Format('%s (%s) - %s [ID:%d]',
                  [act^.nombre, act^.email, act^.telefono, act^.id]));
    act := act^.siguiente;
  until act = lista.cabeza;
end;

function EliminarContacto(var lista: TListaContactos; const ownerEmail: String;
  id: Integer): Boolean;
var
  act, ant, cola: PContacto;
  found: Boolean;
begin
  Result := False;
  if lista.cabeza = nil then Exit;

  ant := nil;
  act := lista.cabeza;
  found := False;

  repeat
    if (act^.id = id) and SameText(act^.ownerEmail, ownerEmail) then
    begin
      found := True;
      Break;
    end;
    ant := act;
    act := act^.siguiente;
  until act = lista.cabeza;

  if not found then Exit(False);


  if (act = lista.cabeza) and (act^.siguiente = act) then
  begin
    Dispose(act);
    lista.cabeza := nil;
    Dec(lista.tamano);
    Exit(True);
  end;

  if act = lista.cabeza then
  begin

    cola := lista.cabeza;
    while cola^.siguiente <> lista.cabeza do
      cola := cola^.siguiente;


    lista.cabeza := act^.siguiente;
    cola^.siguiente := lista.cabeza;
    Dispose(act);
  end
  else
  begin

    ant^.siguiente := act^.siguiente;
    Dispose(act);
  end;

  Dec(lista.tamano);
  Result := True;
end;

function ObtenerSiguienteIDContacto(const lista: TListaContactos): Integer;
var
  act: PContacto;
  maxId: Integer;
begin
  if lista.cabeza = nil then
    Exit(1);

  maxId := 0;
  act := lista.cabeza;
  repeat
    if act^.id > maxId then
      maxId := act^.id;
    act := act^.siguiente;
  until act = lista.cabeza;

  Result := maxId + 1;
end;

procedure CargarContactosDesdeJSON(var lista: TListaContactos; const archivo: String);
var
  JSONData: TJSONData;
  root, item: TJSONObject;
  arr: TJSONArray;
  sl: TStringList;
  i, id: Integer;
  ownerEmail, nombre, email, telefono: String;
begin
  if not FileExists(archivo) then Exit;

  sl := TStringList.Create;
  JSONData := nil;
  try
    sl.LoadFromFile(archivo);
    JSONData := GetJSON(sl.Text);
    root := TJSONObject(JSONData);

    if not root.Find('contactos', arr) then Exit;

    for i := 0 to arr.Count - 1 do
    begin
      item       := arr.Objects[i];
      id         := item.Get('id', -1);
      ownerEmail := item.Get('ownerEmail', '');
      nombre     := item.Get('nombre', '');
      email      := item.Get('email', '');
      telefono   := item.Get('telefono', '');

      if (id >= 0) and (ownerEmail <> '') and (email <> '') then
        AgregarContacto(lista, id, ownerEmail, nombre, email, telefono);
    end;
  finally
    if Assigned(JSONData) then JSONData.Free;
    sl.Free;
  end;
end;

procedure GuardarContactosEnJSON(const lista: TListaContactos; const archivo: String);
var
  arr: TJSONArray;
  root, obj: TJSONObject;
  act: PContacto;
  sl: TStringList;
begin
  arr := TJSONArray.Create;
  try
    if lista.cabeza <> nil then
    begin
      act := lista.cabeza;
      repeat
        obj := TJSONObject.Create;
        obj.Add('id',         act^.id);
        obj.Add('ownerEmail', act^.ownerEmail);
        obj.Add('nombre',     act^.nombre);
        obj.Add('email',      act^.email);
        obj.Add('telefono',   act^.telefono);
        arr.Add(obj);

        act := act^.siguiente;
      until act = lista.cabeza;
    end;

    root := TJSONObject.Create;
    try
      root.Add('contactos', arr); // root toma propiedad de arr
      sl := TStringList.Create;
      try
        sl.Text := root.AsJSON;
        sl.SaveToFile(archivo);
      finally
        sl.Free;
      end;
    finally
      root.Free;
    end;

  except
    on E: Exception do
      WriteLn('Error al guardar contactos: ', E.Message);
  end;
end;

end.

