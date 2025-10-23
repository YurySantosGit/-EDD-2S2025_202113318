unit grafo_correos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  PAdj = ^TAdj;
  TAdj = record
    toKey: string;
    next : PAdj;
  end;

  PVertex = ^TVertex;
  TVertex = record
    key  : string;
    adj  : PAdj;
    next : PVertex;
  end;

var
  GVertices: PVertex = nil;

procedure G_Init;
procedure G_AddVertex(const email: string);
procedure G_AddEdge(const fromEmail, toEmail: string);

procedure G_ClearUser(const ownerEmail: string);
procedure G_ListOutgoing(const ownerEmail: string; items: TStrings);

procedure G_RebuildFromContactList;
procedure G_ToDOT_All(const fileDot: string);
procedure G_SaveDOT_PNG_All(const outDir: string);

procedure G_ToDOT_User(const ownerEmail, fileDot: string);
procedure G_SaveDOT_PNG_User(const ownerEmail, outDir: string);

implementation

uses
  Process, FileUtil, contactos;

function NormKey(const s: string): string; inline;
begin
  Result := LowerCase(Trim(s));
end;

function V_Find(const key: string): PVertex;
var v: PVertex; k: string;
begin
  k := NormKey(key);
  v := GVertices;
  while v <> nil do
  begin
    if NormKey(v^.key) = k then Exit(v);
    v := v^.next;
  end;
  Result := nil;
end;

procedure G_Init;
var v, nx: PVertex; a, ax: PAdj;
begin
  v := GVertices;
  while v <> nil do
  begin
    a := v^.adj;
    while a <> nil do begin ax := a^.next; Dispose(a); a := ax; end;
    nx := v^.next;
    Dispose(v);
    v := nx;
  end;
  GVertices := nil;
end;

procedure G_AddVertex(const email: string);
var v: PVertex;
begin
  if Trim(email) = '' then Exit;
  if V_Find(email) <> nil then Exit;
  New(v);
  v^.key := email;
  v^.adj := nil;
  v^.next := GVertices;
  GVertices := v;
end;

procedure G_AddEdge(const fromEmail, toEmail: string);
var v: PVertex; a: PAdj; kTo: string;
begin
  if (Trim(fromEmail)='') or (Trim(toEmail)='') then Exit;
  G_AddVertex(fromEmail);
  G_AddVertex(toEmail);

  v := V_Find(fromEmail);
  if v = nil then Exit;

  kTo := NormKey(toEmail);
  a := v^.adj;
  while a <> nil do
  begin
    if NormKey(a^.toKey) = kTo then Exit;
    a := a^.next;
  end;

  New(a);
  a^.toKey := toEmail;
  a^.next := v^.adj;
  v^.adj := a;
end;

procedure G_ClearUser(const ownerEmail: string);
var v: PVertex; a, ax: PAdj;
begin
  v := V_Find(ownerEmail);
  if v = nil then Exit;
  a := v^.adj;
  while a <> nil do begin ax := a^.next; Dispose(a); a := ax; end;
  v^.adj := nil;
end;

procedure G_ListOutgoing(const ownerEmail: string; items: TStrings);
var v: PVertex; a: PAdj;
begin
  if items <> nil then items.Clear;
  v := V_Find(ownerEmail);
  if v = nil then Exit;
  a := v^.adj;
  while a <> nil do
  begin
    if items <> nil then items.Add(ownerEmail + ' -> ' + a^.toKey);
    a := a^.next;
  end;
end;

function Esc(const S: String): String;
var R: String;
begin
  R := StringReplace(S, '\', '\\', [rfReplaceAll]);
  R := StringReplace(R, '"', '\"', [rfReplaceAll]);
  R := StringReplace(R, #13#10, '\n', [rfReplaceAll]);
  R := StringReplace(R, #10, '\n', [rfReplaceAll]);
  R := StringReplace(R, #13, '\n', [rfReplaceAll]);
  Result := R;
end;

procedure G_RebuildFromContactList;
var
  it: PContacto;
  head: PContacto;
begin
  G_Init;

  if ListaContactos.cabeza = nil then Exit;

  head := ListaContactos.cabeza;
  it := head;
  repeat
    G_AddEdge(it^.ownerEmail, it^.email);
    it := it^.siguiente;
  until it = head;
end;

procedure G_ToDOT_All(const fileDot: string);
var
  f: Text;
  v: PVertex;
  a: PAdj;
begin
  Assign(f, fileDot); Rewrite(f);
  try
    Writeln(f, 'digraph GrafoGlobal {');
    Writeln(f, '  rankdir=LR;');
    Writeln(f, '  node [shape=ellipse, fontname="Helvetica"];');

    v := GVertices;
    if v = nil then
    begin
      Writeln(f, '  empty [label="(sin datos de grafo)"];');
      Writeln(f, '}');
      Exit;
    end;

    while v <> nil do
    begin
      a := v^.adj;
      if a = nil then
        Writeln(f, Format('  "%s";', [Esc(v^.key)]))
      else
      begin
        while a <> nil do
        begin
          Writeln(f, Format('  "%s" -> "%s";', [Esc(v^.key), Esc(a^.toKey)]));
          a := a^.next;
        end;
      end;
      v := v^.next;
    end;

    Writeln(f, '}');
  finally
    Close(f);
  end;
end;

procedure G_SaveDOT_PNG_All(const outDir: string);
var
  dirBase, dotFile, pngFile, dotExe: string;
  P: TProcess;
begin
  dirBase := IncludeTrailingPathDelimiter(outDir);
  if dirBase <> '' then ForceDirectories(dirBase);

  dotFile := dirBase + 'grafo_global.dot';
  pngFile := dirBase + 'grafo_global.png';

  G_ToDOT_All(dotFile);

  dotExe := FindDefaultExecutablePath({$IFDEF WINDOWS}'dot.exe'{$ELSE}'dot'{$ENDIF});
  if (dotExe = '') and FileExists('/usr/bin/dot') then dotExe := '/usr/bin/dot';
  if dotExe = '' then Exit;

  P := TProcess.Create(nil);
  try
    P.Executable := dotExe;
    P.Parameters.Add('-Tpng');
    P.Parameters.Add('-o'); P.Parameters.Add(pngFile);
    P.Parameters.Add(dotFile);
    P.Options := [poWaitOnExit];
    P.Execute;
  finally
    P.Free;
  end;
end;

procedure G_ToDOT_User(const ownerEmail, fileDot: string);
var
  f: Text;
  v: PVertex;
  a: PAdj;
begin
  Assign(f, fileDot); Rewrite(f);
  try
    Writeln(f, 'digraph GrafoUsuario {');
    Writeln(f, '  rankdir=LR;');
    Writeln(f, '  node [shape=ellipse, fontname="Helvetica"];');

    v := V_Find(ownerEmail);
    if v = nil then
    begin
      Writeln(f, '  empty [label="(sin grafo para el usuario)"];');
      Writeln(f, '}');
      Exit;
    end;

    Writeln(f, Format('  "%s" [shape=box, style="filled", fillcolor="#FFF9C4"];', [Esc(v^.key)]));

    a := v^.adj;
    if a = nil then
      Writeln(f, '  empty [label="(sin aristas)"]')
    else
      while a <> nil do
      begin
        Writeln(f, Format('  "%s" -> "%s";', [Esc(v^.key), Esc(a^.toKey)]));
        a := a^.next;
      end;

    Writeln(f, '}');
  finally
    Close(f);
  end;
end;

procedure G_SaveDOT_PNG_User(const ownerEmail, outDir: string);
var
  dirBase, dotFile, pngFile, dotExe: string;
  P: TProcess;
begin
  dirBase := IncludeTrailingPathDelimiter(outDir);
  if dirBase <> '' then ForceDirectories(dirBase);

  dotFile := dirBase + 'grafo_usuario.dot';
  pngFile := dirBase + 'grafo_usuario.png';

  G_ToDOT_User(ownerEmail, dotFile);

  dotExe := FindDefaultExecutablePath({$IFDEF WINDOWS}'dot.exe'{$ELSE}'dot'{$ENDIF});
  if (dotExe = '') and FileExists('/usr/bin/dot') then dotExe := '/usr/bin/dot';
  if dotExe = '' then Exit;

  P := TProcess.Create(nil);
  try
    P.Executable := dotExe;
    P.Parameters.Add('-Tpng');
    P.Parameters.Add('-o'); P.Parameters.Add(pngFile);
    P.Parameters.Add(dotFile);
    P.Options := [poWaitOnExit];
    P.Execute;
  finally
    P.Free;
  end;
end;

end.
