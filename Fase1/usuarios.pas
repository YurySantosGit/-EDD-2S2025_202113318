unit usuarios;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, fpjson, jsonparser;

type
  PUsuario = ^TUsuario;
  TUsuario = record
    id: Integer;
    nombre: String;
    usuario: String;
    email: String;
    telefono: String;
    password: String;
    siguiente: PUsuario;
  end;

// Variable global: cabeza de la lista
var
  ListaUsuarios: PUsuario;

// Operaciones principales
procedure InicializarUsuarios;
procedure AgregarUsuario(id: Integer; nombre, usuario, email, telefono, password: String);
function BuscarUsuarioPorEmail(email, password: String): PUsuario;
procedure MostrarUsuarios;
procedure CargarUsuariosDesdeJSON(const archivo: String);

implementation

// Inicializar lista
procedure InicializarUsuarios;
begin
  ListaUsuarios := nil;
end;

// Insertar usuario al final
procedure AgregarUsuario(id: Integer; nombre, usuario, email, telefono, password: String);
var
  nuevo, actual: PUsuario;
begin
  New(nuevo);
  nuevo^.id := id;
  nuevo^.nombre := nombre;
  nuevo^.usuario := usuario;
  nuevo^.email := email;
  nuevo^.telefono := telefono;
  nuevo^.password := password;
  nuevo^.siguiente := nil;

  if ListaUsuarios = nil then
    ListaUsuarios := nuevo
  else
  begin
    actual := ListaUsuarios;
    while actual^.siguiente <> nil do
      actual := actual^.siguiente;
    actual^.siguiente := nuevo;
  end;
end;

// Buscar usuario por email y password
function BuscarUsuarioPorEmail(email, password: String): PUsuario;
var
  actual: PUsuario;
begin
  actual := ListaUsuarios;
  while actual <> nil do
  begin
    if (actual^.email = email) and (actual^.password = password) then
    begin
      BuscarUsuarioPorEmail := actual;
      Exit;
    end;
    actual := actual^.siguiente;
  end;
  BuscarUsuarioPorEmail := nil;
end;

// Mostrar usuarios en consola
procedure MostrarUsuarios;
var
  actual: PUsuario;
begin
  actual := ListaUsuarios;
  writeln('--- Usuarios registrados ---');
  while actual <> nil do
  begin
    writeln('ID: ', actual^.id, ' | Nombre: ', actual^.nombre, ' | Email: ', actual^.email);
    actual := actual^.siguiente;
  end;
end;

// Cargar usuarios desde archivo JSON
procedure CargarUsuariosDesdeJSON(const archivo: String);
var
  JSONData: TJSONData;
  JSONObject, user: TJSONObject;
  JSONArray: TJSONArray;
  contenido: TStringList;
  i: Integer;
begin
  if not FileExists(archivo) then
  begin
    writeln('Archivo JSON no encontrado: ', archivo);
    Exit;
  end;

  contenido := TStringList.Create;
  try
    contenido.LoadFromFile(archivo);
    JSONData := GetJSON(contenido.Text);
    JSONObject := TJSONObject(JSONData);
    JSONArray := JSONObject.Arrays['usuarios'];

    for i := 0 to JSONArray.Count - 1 do
    begin
      user := JSONArray.Objects[i];
      AgregarUsuario(
        user.Integers['id'],
        user.Strings['nombre'],
        user.Strings['usuario'],
        user.Strings['email'],
        user.Strings['telefono'],
        user.Strings['password']
      );
    end;
  finally
    contenido.Free;
  end;
end;

end.
