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
function ExisteEmail(const email: String): Boolean;
function ExisteUsuario(const usuario: String): Boolean;
function ObtenerSiguienteID: Integer;
procedure GuardarUsuariosEnJSON(const archivo: String);
procedure CargaMasivaDesdeJSON(const archivo: String; out agregados, rechazados: Integer; log: TStrings);
function BuscarUsuarioPorCorreo(const email: String): PUsuario;

function BuscarUsuarioPorEmailExacto(const email: String): PUsuario;
function ExisteUsuarioExceptoEmail(const usuario, emailActual: String): Boolean;

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

function BuscarUsuarioPorCorreo(const email: String): PUsuario;
var
  actual: PUsuario;
begin
  actual := ListaUsuarios;
  while actual <> nil do
  begin
    if SameText(actual^.email, email) then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

function ExisteEmail(const email: String): Boolean;
var
  actual: PUsuario;
begin
  Result := False;
  actual := ListaUsuarios;
  while actual <> nil do
  begin
    if SameText(actual^.email, email) then
      Exit(True);
    actual := actual^.siguiente;
  end;
end;

function ExisteUsuario(const usuario: String): Boolean;
var
  actual: PUsuario;
begin
  Result := False;
  actual := ListaUsuarios;
  while actual <> nil do
  begin
    if SameText(actual^.usuario, usuario) then
      Exit(True);
    actual := actual^.siguiente;
  end;
end;

function ObtenerSiguienteID: Integer;
var
  actual: PUsuario;
  maxId: Integer;
begin
  maxId := 0;
  actual := ListaUsuarios;
  while actual <> nil do
  begin
    if actual^.id > maxId then
      maxId := actual^.id;
    actual := actual^.siguiente;
  end;
  Result := maxId + 1;
end;

function ExisteID(id: Integer): Boolean;
var
  actual: PUsuario;
begin
  Result := False;
  actual := ListaUsuarios;
  while actual <> nil do
  begin
    if actual^.id = id then Exit(True);
    actual := actual^.siguiente;
  end;
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

function BuscarUsuarioPorEmailExacto(const email: String): PUsuario;
var
  actual: PUsuario;
begin
  actual := ListaUsuarios;
  while actual <> nil do
  begin
    if SameText(actual^.email, email) then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

function ExisteUsuarioExceptoEmail(const usuario, emailActual: String): Boolean;
var
  actual: PUsuario;
begin
  Result := False;
  actual := ListaUsuarios;
  while actual <> nil do
  begin
    if SameText(actual^.usuario, usuario) and (not SameText(actual^.email, emailActual)) then
      Exit(True);
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
  JSONData := nil;

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
    if Assigned(JSONData) then JSONData.Free;
    contenido.Free;
  end;
end;


procedure GuardarUsuariosEnJSON(const archivo: String);
var
  arr: TJSONArray;
  root: TJSONObject;
  obj: TJSONObject;
  actual: PUsuario;
  sl: TStringList;
begin
  arr := TJSONArray.Create;
  try
    actual := ListaUsuarios;
    while actual <> nil do
    begin
      obj := TJSONObject.Create;
      obj.Add('id',        actual^.id);
      obj.Add('nombre',    actual^.nombre);
      obj.Add('usuario',   actual^.usuario);
      obj.Add('password',  actual^.password);
      obj.Add('email',     actual^.email);
      obj.Add('telefono',  actual^.telefono);
      arr.Add(obj);
      actual := actual^.siguiente;
    end;

    root := TJSONObject.Create;
    try
      root.Add('usuarios', arr);   // root es dueño de arr a partir de aquí
      sl := TStringList.Create;
      try
        sl.Text := root.AsJSON;
        sl.SaveToFile(archivo);
      finally
        sl.Free;
      end;
    finally
      root.Free; // libera root y también arr y sus hijos
    end;

  except
    on E: Exception do
      WriteLn('Error al guardar usuarios: ', E.Message);
  end;
end;

procedure CargaMasivaDesdeJSON(const archivo: String; out agregados, rechazados: Integer; log: TStrings);
var
  JSONData: TJSONData;
  JSONObject, user: TJSONObject;
  JSONArray: TJSONArray;
  contenido: TStringList;
  i, id: Integer;
  nombre, usuarioStr, email, telefono, password: String;
begin
  agregados := 0;
  rechazados := 0;

  if not FileExists(archivo) then
  begin
    if Assigned(log) then log.Add('Archivo no encontrado: ' + archivo);
    Exit;
  end;

  contenido := TStringList.Create;
  JSONData := nil;
  try
    contenido.LoadFromFile(archivo);
    JSONData := GetJSON(contenido.Text);
    JSONObject := TJSONObject(JSONData);

    if not JSONObject.Find('usuarios', JSONArray) then
    begin
      if Assigned(log) then log.Add('Formato inválido: falta clave "usuarios".');
      Exit;
    end;

    for i := 0 to JSONArray.Count - 1 do
    begin
      user := JSONArray.Objects[i];

      // leer con defaults seguro
      id         := user.Get('id', -1);
      nombre     := user.Get('nombre', '');
      usuarioStr := user.Get('usuario', '');
      email      := user.Get('email', '');
      telefono   := user.Get('telefono', '');
      password   := user.Get('password', '');

      // validaciones mínimas
      if (id < 0) or (Trim(email) = '') or (Trim(usuarioStr) = '') then
      begin
        Inc(rechazados);
        if Assigned(log) then
          log.Add(Format('Registro %d inválido (id/email/usuario requeridos).', [i+1]));
        Continue;
      end;

      // unicidad
      if ExisteID(id) then
      begin
        Inc(rechazados);
        if Assigned(log) then log.Add(Format('ID repetido (%d) → rechazado.', [id]));
        Continue;
      end;

      if ExisteEmail(email) then
      begin
        Inc(rechazados);
        if Assigned(log) then log.Add(Format('Email repetido (%s) → rechazado.', [email]));
        Continue;
      end;

      // pasa validaciones → agregar
      AgregarUsuario(id, nombre, usuarioStr, email, telefono, password);
      Inc(agregados);
    end;

    // persistir cambios
    GuardarUsuariosEnJSON('usuarios.json');

    if Assigned(log) then
      log.Add(Format('Resumen → agregados: %d, rechazados: %d', [agregados, rechazados]));

  finally
    if Assigned(JSONData) then JSONData.Free;
    contenido.Free;
  end;
end;


end.
