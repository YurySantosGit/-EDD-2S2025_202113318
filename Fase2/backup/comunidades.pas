unit comunidades;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, usuarios;

type
  PMiembro = ^TMiembro;
  TMiembro = record
    email: string;
    sig: PMiembro;
  end;

  TListaMiembros = record
    cabeza: PMiembro;
    tam: Integer;
  end;

  PComunidad = ^TComunidad;
  TComunidad = record
    nombre: string;
    miembros: TListaMiembros;
    sig: PComunidad;
  end;

  TListaComunidades = record
    cabeza: PComunidad;
    tam: Integer;
  end;

var
  ListaComunidades: TListaComunidades;

procedure InicializarComunidades(var L: TListaComunidades);
function CrearComunidad(const nombre: string): Boolean;
function BuscarComunidad(const nombre: string): PComunidad;
function UsuarioExisteEnSistema(const email: string): Boolean;
function AgregarMiembro(const comunidad, email: string): Integer;
procedure ListarComunidades(const L: TListaComunidades; items: TStrings);
procedure ListarMiembros(const comunidad: string; items: TStrings);

procedure SembrarComunidadesDemo;

implementation

function TL(const s: string): string; inline; begin Result := LowerCase(Trim(s)); end;

procedure InicializarListaMiembros(var L: TListaMiembros);
begin L.cabeza := nil; L.tam := 0; end;

procedure InicializarComunidades(var L: TListaComunidades);
begin L.cabeza := nil; L.tam := 0; end;

function BuscarComunidad(const nombre: string): PComunidad;
var it: PComunidad; k: string;
begin
  k := TL(nombre); it := ListaComunidades.cabeza;
  while it <> nil do
  begin
    if TL(it^.nombre) = k then exit(it);
    it := it^.sig;
  end;
  Result := nil;
end;

function CrearComunidad(const nombre: string): Boolean;
var nuevo: PComunidad;
begin
  if (Trim(nombre)='') or (BuscarComunidad(nombre)<>nil) then Exit(False);
  New(nuevo);
  nuevo^.nombre := Trim(nombre);
  InicializarListaMiembros(nuevo^.miembros);
  nuevo^.sig := ListaComunidades.cabeza;
  ListaComunidades.cabeza := nuevo;
  Inc(ListaComunidades.tam);
  Result := True;
end;

function UsuarioExisteEnSistema(const email: string): Boolean;
var u: PUsuario; k: string;
begin
  k := TL(email); u := ListaUsuarios;
  while u <> nil do
  begin
    if TL(u^.email) = k then exit(True);
    u := u^.siguiente;
  end;
  Result := False;
end;

function MiembroDuplicado(const L: TListaMiembros; const email: string): Boolean;
var it: PMiembro; k: string;
begin
  k := TL(email); it := L.cabeza;
  while it <> nil do
  begin
    if TL(it^.email) = k then exit(True);
    it := it^.sig;
  end;
  Result := False;
end;

function AgregarMiembro(const comunidad, email: string): Integer;
var c: PComunidad; m: PMiembro;
begin
  c := BuscarComunidad(comunidad);
  if c = nil then Exit(1);
  if not UsuarioExisteEnSistema(email) then Exit(2);
  if MiembroDuplicado(c^.miembros, email) then Exit(3);

  New(m); m^.email := Trim(email); m^.sig := c^.miembros.cabeza;
  c^.miembros.cabeza := m; Inc(c^.miembros.tam);
  Result := 0;
end;

procedure ListarComunidades(const L: TListaComunidades; items: TStrings);
var it: PComunidad;
begin
  items.Clear; it := L.cabeza;
  while it <> nil do begin items.Add(it^.nombre); it := it^.sig; end;
end;

procedure ListarMiembros(const comunidad: string; items: TStrings);
var c: PComunidad; it: PMiembro;
begin
  items.Clear; c := BuscarComunidad(comunidad);
  if c = nil then Exit;
  it := c^.miembros.cabeza;
  while it <> nil do begin items.Add(it^.email); it := it^.sig; end;
end;

procedure SembrarComunidadesDemo;
begin
  CrearComunidad('Comunidad 1');
  CrearComunidad('Comunidad 2');
  CrearComunidad('Comunidad 3');
  AgregarMiembro('Comunidad 1','aux-marcos@edd.com');
  AgregarMiembro('Comunidad 1','aux-facundo1@edd.com');
  AgregarMiembro('Comunidad 2','aux-luis@edd.com');
  AgregarMiembro('Comunidad 3','aux-luis@edd.com');
  AgregarMiembro('Comunidad 3','aux-marcos@edd.com');
  AgregarMiembro('Comunidad 3','aux-facundo@edd.com');
end;

end.
