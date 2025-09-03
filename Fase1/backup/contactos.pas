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
  act := lista.cabeza;
  while act <> nil do
  begin
    sig := act^.siguiente;
    Dispose(act);
    act := sig;
  end;
  lista.cabeza := nil;
  lista.tamano := 0;
end;

procedure AgregarContacto(var lista: TListaContactos; id: Integer;
  const ownerEmail, nombre, email, telefono: String);
var
  nuevo, act: PContacto;
begin
  New(nuevo);
  nuevo^.id := id;
  nuevo^.ownerEmail := ownerEmail;
  nuevo^.nombre := nombre;
  nuevo^.email := email;
  nuevo^.telefono := telefono;
  nuevo^.siguiente := nil;

  if lista.cabeza = nil then
  begin
    lista.cabeza := nuevo;
  end
  else
  begin
    act := lista.cabeza;
    while act^.siguiente <> nil do
      act := act^.siguiente;
    act^.siguiente := nuevo;
  end;
  Inc(lista.tamano);
end;

function ExisteContactoEmail(const lista: TListaContactos;
  const ownerEmail, email: String): Boolean;
var
  act: PContacto;
begin
  Result := False;
  act := lista.cabeza;
  while act <> nil do
  begin
    if SameText(act^.ownerEmail, ownerEmail) and SameText(act^.email, email) then
      Exit(True);
    act := act^.siguiente;
  end;
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
  act := lista.cabeza;
  while act <> nil do
  begin
    if SameText(act^.ownerEmail, ownerEmail) then
      if items <> nil then
        items.Add(Format('%s (%s) - %s [ID:%d]', [act^.nombre, act^.email, act^.telefono, act^.id]));
    act := act^.siguiente;
  end;
end;

function EliminarContacto(var lista: TListaContactos; const ownerEmail: String;
  id: Integer): Boolean;
var
  act, ant: PContacto;
begin
  Result := False;
  act := lista.cabeza;
  ant := nil;

  while act <> nil do
  begin
    if (act^.id = id) and SameText(act^.ownerEmail, ownerEmail) then
    begin
      if ant = nil then
        lista.cabeza := act^.siguiente
      else
        ant^.siguiente := act^.siguiente;

      Dispose(act);
      Dec(lista.tamano);
      Exit(True);
    end;
    ant := act;
    act := act^.siguiente;
  end;
end;

function ObtenerSiguienteIDContacto(const lista: TListaContactos): Integer;
var
  act: PContacto;
  maxId: Integer;
begin
  maxId := 0;
  act := lista.cabeza;
  while act <> nil do
  begin
    if act^.id > maxId then
      maxId := act^.id;
    act := act^.siguiente;
  end;
  Result := maxId + 1;
end;

procedure CargarContactosDesdeJSON(var lista: TListaContactos; const archivo: String);
var
  JSONData: TJSONData;
  root, item: TJSONObject;
  arr: TJSONArray;
  sl: TStringList;
  i: Integer;
  id: Integer;
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
    act := lista.cabeza;
    while act <> nil do
    begin
      obj := TJSONObject.Create;
      obj.Add('id',         act^.id);
      obj.Add('ownerEmail', act^.ownerEmail);
      obj.Add('nombre',     act^.nombre);
      obj.Add('email',      act^.email);
      obj.Add('telefono',   act^.telefono);
      arr.Add(obj);
      act := act^.siguiente;
    end;

    root := TJSONObject.Create;
    try
      root.Add('contactos', arr);
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
