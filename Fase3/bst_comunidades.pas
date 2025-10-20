unit bst_comunidades;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  PMsg = ^TMsg;
  TMsg = record
    correo:  String;
    mensaje: String;
    fecha:   String;
    sig:     PMsg;
  end;

  PBSTC = ^TBSTC;
  TBSTC = record
    key:            String;
    nombre:         String;
    fechaCreacion:  String;
    msgsHead:       PMsg;
    msgCount:       Integer;
    L, R:           PBSTC;
  end;


procedure BSTC_Init(var T: PBSTC);
function  BSTC_Find(T: PBSTC; const nombreGrupo: String): PBSTC;
function  BSTC_Insert(var T: PBSTC; const nombreGrupo, fechaCreacion: String): PBSTC;
function  BSTC_EnsureCommunity(var T: PBSTC; const nombreGrupo, fechaCreacion: String): PBSTC;
function  BSTC_AddMessage(var T: PBSTC; const nombreGrupo, correo, mensaje, fechaPub: String): Boolean;
function  BSTC_ListMessages(T: PBSTC; const nombreGrupo: String; out SL: TStringList): Boolean;
procedure BSTC_ToDOT(T: PBSTC; const fileDot: String);
procedure BSTC_ListCommunities(T: PBSTC; items: TStrings);
function  BSTC_GetCommunityInfo(T: PBSTC; const groupName: String; out fechaCreacion: String; out count: Integer): Boolean;
procedure BSTC_ListMessages(T: PBSTC; const groupName: String; lines: TStrings);

implementation

function NormKey(const s: String): String; inline;
begin
  Result := LowerCase(Trim(s));
end;

function NewMsg(const correo, mensaje, fecha: String): PMsg;
var p: PMsg;
begin
  New(p);
  p^.correo  := correo;
  p^.mensaje := mensaje;
  p^.fecha   := fecha;
  p^.sig     := nil;
  Result := p;
end;

function NewNode(const nombre, fechaC: String): PBSTC;
var n: PBSTC;
begin
  New(n);
  n^.key           := NormKey(nombre);
  n^.nombre        := nombre;
  n^.fechaCreacion := fechaC;
  n^.msgsHead      := nil;
  n^.msgCount      := 0;
  n^.L := nil; n^.R := nil;
  Result := n;
end;

procedure BSTC_Init(var T: PBSTC);
begin
  T := nil;
end;

function  BSTC_Find(T: PBSTC; const nombreGrupo: String): PBSTC;
var k: String;
begin
  k := NormKey(nombreGrupo);
  while (T<>nil) and (k<>T^.key) do
    if k < T^.key then T := T^.L else T := T^.R;
  Result := T;
end;

function  BSTC_Insert(var T: PBSTC; const nombreGrupo, fechaCreacion: String): PBSTC;
var k: String;
begin
  k := NormKey(nombreGrupo);
  if T=nil then
  begin
    T := NewNode(nombreGrupo, fechaCreacion);
    Exit(T);
  end;

  if k < T^.key then
    Result := BSTC_Insert(T^.L, nombreGrupo, fechaCreacion)
  else if k > T^.key then
    Result := BSTC_Insert(T^.R, nombreGrupo, fechaCreacion)
  else
  begin
    if Trim(T^.fechaCreacion) = '' then
      T^.fechaCreacion := fechaCreacion;
    Result := T;
  end;
end;

function BSTC_EnsureCommunity(var T: PBSTC; const nombreGrupo, fechaCreacion: String): PBSTC;
begin
  Result := BSTC_Find(T, nombreGrupo);
  if Result=nil then
    Result := BSTC_Insert(T, nombreGrupo, fechaCreacion);
end;

function  BSTC_AddMessage(var T: PBSTC; const nombreGrupo, correo, mensaje, fechaPub: String): Boolean;
var g: PBSTC; m: PMsg;
begin
  Result := False;
  g := BSTC_Find(T, nombreGrupo);
  if g = nil then Exit;

  m := NewMsg(correo, mensaje, fechaPub);
  m^.sig := g^.msgsHead;
  g^.msgsHead := m;
  Inc(g^.msgCount);
  Result := True;
end;

function  BSTC_ListMessages(T: PBSTC; const nombreGrupo: String; out SL: TStringList): Boolean;
var g: PBSTC; p: PMsg;
begin
  Result := False;
  SL := TStringList.Create;
  g := BSTC_Find(T, nombreGrupo);
  if g = nil then Exit;

  p := g^.msgsHead;
  while p<>nil do
  begin
    SL.Add(Format('%s | %s | %s', [p^.fecha, p^.correo, p^.mensaje]));
    p := p^.sig;
  end;
  Result := True;
end;

procedure BSTC_ToDOT(T: PBSTC; const fileDot: String);

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

  procedure Emit(var f: Text; N: PBSTC);
  var
    nodeId, labelStr: String;
  begin
    if N=nil then Exit;

    nodeId := 'n' + IntToStr(NativeInt(N));
    labelStr :=
      'Grupo: ' + Esc(N^.nombre) + '\n' +
      'Creado: ' + Esc(N^.fechaCreacion) + '\n' +
      'Mensajes: ' + IntToStr(N^.msgCount);

    WriteLn(f, '  ', nodeId, ' [shape=box, fontname="Helvetica", label="', labelStr, '"];');
    if N^.L<>nil then
      WriteLn(f, '  ', nodeId, ' -> ', 'n', NativeInt(N^.L), ';');
    if N^.R<>nil then
      WriteLn(f, '  ', nodeId, ' -> ', 'n', NativeInt(N^.R), ';');

    Emit(f, N^.L);
    Emit(f, N^.R);
  end;

var f: Text;
begin
  Assign(f, fileDot); Rewrite(f);
  try
    WriteLn(f, 'digraph ComunidadesBST {');
    WriteLn(f, '  rankdir=TB;');
    WriteLn(f, '  node [style="rounded"];');
    Emit(f, T);
    WriteLn(f, '}');
  finally
    Close(f);
  end;
end;

procedure BSTC_ListCommunities(T: PBSTC; items: TStrings);
  procedure InOrder(N: PBSTC);
  begin
    if N = nil then Exit;
    InOrder(N^.L);
    items.Add(N^.nombre);
    InOrder(N^.R);
  end;
begin
  if items <> nil then items.Clear;
  InOrder(T);
end;

function BSTC_GetCommunityInfo(T: PBSTC; const groupName: String; out fechaCreacion: String; out count: Integer): Boolean;
var
  N: PBSTC;
  M: PMsg;
begin
  fechaCreacion := '';
  count := 0;

  N := BSTC_Find(T, groupName);
  Result := (N <> nil);
  if not Result then Exit;

  fechaCreacion := N^.fechaCreacion;

  M := N^.msgsHead;
  while M <> nil do
  begin
    Inc(count);
    M := M^.sig;
  end;
end;

procedure BSTC_ListMessages(T: PBSTC; const groupName: String; lines: TStrings);
var
  N: PBSTC;
  M: PMsg;
begin
  if lines <> nil then lines.Clear;

  N := BSTC_Find(T, groupName);
  if N = nil then Exit;

  M := N^.msgsHead;
  while M <> nil do
  begin
    lines.Add(Format('%s | %s | %s', [M^.fecha, M^.correo, M^.mensaje]));
    M := M^.sig;
  end;
end;


end.
