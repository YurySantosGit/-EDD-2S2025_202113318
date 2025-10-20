unit btree_favoritos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

const
  MAX_KEYS = 5;
  MIN_KEYS = 2;

type
  TFavorito = record
    id: Integer;
    remitente: String;
    estado: String;
    asunto: String;
    fecha: String;
    mensaje: String;
  end;

  PBNode = ^TBNode;
  TBNode = record
    n: Integer;
    key: array[1..MAX_KEYS] of Integer;
    data: array[1..MAX_KEYS] of TFavorito;
    child: array[0..MAX_KEYS] of PBNode;
    leaf: Boolean;
  end;

  TFavProc = procedure(const F: TFavorito);

procedure BFav_Init(var T: PBNode);
function  BFav_Search(T: PBNode; id: Integer): PBNode;
procedure BFav_Insert(var T: PBNode; const F: TFavorito);
function  BFav_Delete(var T: PBNode; id: Integer): Boolean;
procedure BFav_InOrder(T: PBNode; proc: TFavProc);
procedure BFav_ToDOT(T: PBNode; const fileDot: String);

implementation

function NewNode(leaf: Boolean): PBNode;
var
  i: Integer;
begin
  New(Result);
  Result^.n := 0;
  Result^.leaf := leaf;
  for i := 0 to MAX_KEYS do
    Result^.child[i] := nil;
end;

procedure BFav_Init(var T: PBNode);
begin
  T := nil;
end;

function BFav_Search(T: PBNode; id: Integer): PBNode;
var
  i: Integer;
begin
  while T <> nil do
  begin
    i := 1;
    while (i <= T^.n) and (id > T^.key[i]) do Inc(i);
    if (i <= T^.n) and (id = T^.key[i]) then Exit(T);
    if T^.leaf then Exit(nil) else T := T^.child[i-1];
  end;
  Result := nil;
end;

procedure SplitChild(parent: PBNode; i: Integer; y: PBNode);
var
  z: PBNode;
  j: Integer;
begin
  z := NewNode(y^.leaf);

  z^.n := MAX_KEYS - (MIN_KEYS + 1);

  for j := 1 to z^.n do
  begin
    z^.key[j]  := y^.key[MIN_KEYS + 1 + j];
    z^.data[j] := y^.data[MIN_KEYS + 1 + j];
  end;

  if not y^.leaf then
    for j := 0 to z^.n do
      z^.child[j] := y^.child[MIN_KEYS + 1 + j];

  y^.n := MIN_KEYS;

  for j := parent^.n downto i + 1 do
    parent^.child[j + 1] := parent^.child[j];
  parent^.child[i + 1] := z;

  for j := parent^.n downto i + 1 do
  begin
    parent^.key[j + 1]  := parent^.key[j];
    parent^.data[j + 1] := parent^.data[j];
  end;

  parent^.key[i + 1]  := y^.key[MIN_KEYS + 1];
  parent^.data[i + 1] := y^.data[MIN_KEYS + 1];
  Inc(parent^.n);
end;

procedure InsertNonFull(x: PBNode; const F: TFavorito);
var
  i: Integer;
begin
  if x^.leaf then
  begin
    i := x^.n;
    while (i >= 1) and (F.id < x^.key[i]) do
    begin
      x^.key[i + 1]  := x^.key[i];
      x^.data[i + 1] := x^.data[i];
      Dec(i);
    end;
    x^.key[i + 1]  := F.id;
    x^.data[i + 1] := F;
    Inc(x^.n);
  end
  else
  begin
    i := x^.n;
    while (i >= 1) and (F.id < x^.key[i]) do Dec(i);
    Inc(i);

    if x^.child[i - 1]^.n = MAX_KEYS then
    begin
      SplitChild(x, i - 1, x^.child[i - 1]);
      if F.id > x^.key[i] then Inc(i);
    end;

    InsertNonFull(x^.child[i - 1], F);
  end;
end;

procedure BFav_Insert(var T: PBNode; const F: TFavorito);
var
  r, s: PBNode;
  i: Integer;
begin
  r := BFav_Search(T, F.id);
  if r <> nil then
  begin
    for i := 1 to r^.n do
      if r^.key[i] = F.id then
      begin
        r^.data[i] := F;
        Exit;
      end;
  end;

  if T = nil then
  begin
    T := NewNode(True);
    T^.n := 1;
    T^.key[1]  := F.id;
    T^.data[1] := F;
    Exit;
  end;

  if T^.n = MAX_KEYS then
  begin
    s := NewNode(False);
    s^.child[0] := T;
    s^.n := 0;
    SplitChild(s, 0, T);
    if F.id > s^.key[1] then
      InsertNonFull(s^.child[1], F)
    else
      InsertNonFull(s^.child[0], F);
    T := s;
  end
  else
    InsertNonFull(T, F);
end;

//Eliminar

function GetPred(n: PBNode; idx: Integer): TFavorito;
var
  cur: PBNode;
begin
  cur := n^.child[idx - 1];
  while not cur^.leaf do cur := cur^.child[cur^.n];
  Result := cur^.data[cur^.n];
end;

function GetSucc(n: PBNode; idx: Integer): TFavorito;
var
  cur: PBNode;
begin
  cur := n^.child[idx];
  while not cur^.leaf do cur := cur^.child[0];
  Result := cur^.data[1];
end;

procedure BorrowFromPrev(n: PBNode; idx: Integer);
var
  c, s: PBNode;
  j: Integer;
begin
  c := n^.child[idx - 1];
  s := n^.child[idx - 2];

  for j := c^.n downto 1 do
  begin
    c^.key[j + 1]  := c^.key[j];
    c^.data[j + 1] := c^.data[j];
  end;
  if not c^.leaf then
    for j := c^.n downto 0 do
      c^.child[j + 1] := c^.child[j];

  c^.key[1]  := n^.key[idx - 1];
  c^.data[1] := n^.data[idx - 1];
  if not c^.leaf then c^.child[0] := s^.child[s^.n];
  Inc(c^.n);

  n^.key[idx - 1]  := s^.key[s^.n];
  n^.data[idx - 1] := s^.data[s^.n];

  if not s^.leaf then s^.child[s^.n] := nil;
  Dec(s^.n);
end;

procedure BorrowFromNext(n: PBNode; idx: Integer);
var
  c, s: PBNode;
  j: Integer;
begin
  c := n^.child[idx - 1];
  s := n^.child[idx];

  c^.key[c^.n + 1]  := n^.key[idx];
  c^.data[c^.n + 1] := n^.data[idx];
  if not c^.leaf then c^.child[c^.n + 1] := s^.child[0];
  Inc(c^.n);

  n^.key[idx]  := s^.key[1];
  n^.data[idx] := s^.data[1];

  for j := 1 to s^.n - 1 do
  begin
    s^.key[j]  := s^.key[j + 1];
    s^.data[j] := s^.data[j + 1];
  end;

  if not s^.leaf then
  begin
    for j := 0 to s^.n - 1 do
      s^.child[j] := s^.child[j + 1];
    s^.child[s^.n] := nil;
  end;

  Dec(s^.n);
end;

procedure Merge(n: PBNode; idx: Integer);
var
  c, s: PBNode;
  i: Integer;
begin
  c := n^.child[idx - 1];
  s := n^.child[idx];

  c^.key[MIN_KEYS + 1]  := n^.key[idx];
  c^.data[MIN_KEYS + 1] := n^.data[idx];

  for i := 1 to s^.n do
  begin
    c^.key[MIN_KEYS + 1 + i]  := s^.key[i];
    c^.data[MIN_KEYS + 1 + i] := s^.data[i];
  end;

  if not c^.leaf then
    for i := 0 to s^.n do
      c^.child[MIN_KEYS + 1 + i] := s^.child[i];

  c^.n := c^.n + 1 + s^.n;

  for i := idx to n^.n - 1 do
  begin
    n^.key[i]   := n^.key[i + 1];
    n^.data[i]  := n^.data[i + 1];
    n^.child[i] := n^.child[i + 1];
  end;
  n^.child[n^.n]   := n^.child[n^.n + 1];
  n^.child[n^.n+1] := nil;
  Dec(n^.n);

  Dispose(s);
end;

function RemoveInternal(var n: PBNode; id: Integer): Boolean; forward;

function RemoveFromNode(n: PBNode; idx, id: Integer): Boolean;
var
  k: Integer;
  pred, succ: TFavorito;
begin
  if n^.leaf then
  begin
    for k := idx to n^.n - 1 do
    begin
      n^.key[k]  := n^.key[k + 1];
      n^.data[k] := n^.data[k + 1];
    end;
    Dec(n^.n);
    Exit(True);
  end;

  if n^.child[idx - 1]^.n >= MIN_KEYS + 1 then
  begin
    pred := GetPred(n, idx);
    n^.key[idx]  := pred.id;
    n^.data[idx] := pred;
    Exit(RemoveInternal(n^.child[idx - 1], pred.id));
  end
  else if n^.child[idx]^.n >= MIN_KEYS + 1 then
  begin
    succ := GetSucc(n, idx);
    n^.key[idx]  := succ.id;
    n^.data[idx] := succ;
    Exit(RemoveInternal(n^.child[idx], succ.id));
  end
  else
  begin
    Merge(n, idx);
    Exit(RemoveInternal(n^.child[idx - 1], id));
  end;
end;

function RemoveInternal(var n: PBNode; id: Integer): Boolean;
var
  idx: Integer;
  childPtr: PBNode;
begin
  idx := 1;
  while (idx <= n^.n) and (id > n^.key[idx]) do Inc(idx);

  if (idx <= n^.n) and (n^.key[idx] = id) then
    Exit(RemoveFromNode(n, idx, id));

  if n^.leaf then Exit(False);

  childPtr := n^.child[idx - 1];
  if childPtr^.n = MIN_KEYS then
  begin
    if (idx > 1) and (n^.child[idx - 2]^.n >= MIN_KEYS + 1) then
      BorrowFromPrev(n, idx)
    else if (idx <= n^.n) and (n^.child[idx]^.n >= MIN_KEYS + 1) then
      BorrowFromNext(n, idx)
    else
    begin
      if idx <= n^.n then
        Merge(n, idx)
      else
      begin
        Merge(n, idx - 1);
        Dec(idx);
      end;
      childPtr := n^.child[idx - 1];
    end;
  end;

  Result := RemoveInternal(childPtr, id);
end;

function BFav_Delete(var T: PBNode; id: Integer): Boolean;
var
  oldRoot: PBNode;
begin
  if T = nil then Exit(False);
  Result := RemoveInternal(T, id);

  if (T^.n = 0) and (not T^.leaf) then
  begin
    oldRoot := T;
    T := T^.child[0];
    Dispose(oldRoot);
  end;
end;

//Recorrido y reporte

procedure BFav_InOrder(T: PBNode; proc: TFavProc);
var
  i: Integer;
begin
  if T = nil then Exit;
  for i := 1 to T^.n do
  begin
    BFav_InOrder(T^.child[i - 1], proc);
    if Assigned(proc) then proc(T^.data[i]);
  end;
  BFav_InOrder(T^.child[T^.n], proc);
end;

procedure BFav_ToDOT(T: PBNode; const fileDot: String);

  function Esc(const S: String): String;
  var
    R: String;
  begin
    R := StringReplace(S, '\', '\\', [rfReplaceAll]);
    R := StringReplace(R, '"', '\"', [rfReplaceAll]);
    R := StringReplace(R, #13#10, '\n', [rfReplaceAll]);
    R := StringReplace(R, #10, '\n', [rfReplaceAll]);
    R := StringReplace(R, #13, '\n', [rfReplaceAll]);
    Result := R;
  end;

  function TruncEllipsis(const S: String; MaxLen: Integer): String;
  begin
    if (MaxLen > 0) and (Length(S) > MaxLen) then
      Result := Copy(S, 1, MaxLen) + '…'
    else
      Result := S;
  end;

  function BuildLabel(N: PBNode): String;
  var
    i: Integer;
    s: String;
  begin
    s := '';
    for i := 1 to N^.n do
    begin
      if s <> '' then s += '\n---\n';
      s += 'ID: '        + IntToStr(N^.key[i])           + '\n' +
           'Remitente: ' + Esc(N^.data[i].remitente)     + '\n' +
           'Estado: '    + Esc(N^.data[i].estado)        + '\n' +
           'Asunto: '    + Esc(N^.data[i].asunto)        + '\n' +
           'Fecha: '     + Esc(N^.data[i].fecha)         + '\n' +
           'Mensaje: '   + Esc(TruncEllipsis(N^.data[i].mensaje, 120));
    end;
    Result := s;
  end;

  procedure Emit(var f: Text; N: PBNode);
  var
    i: Integer;
    nodeId, labelStr: String;
  begin
    if N = nil then Exit;

    nodeId   := 'n' + IntToStr(PtrUInt(N));
    labelStr := BuildLabel(N);

    WriteLn(f, '  ', nodeId, ' [shape=box, fontname="Helvetica", label="', labelStr, '"];');

    for i := 0 to N^.n do
      if N^.child[i] <> nil then
        WriteLn(f, '  ', nodeId, ' -> ', 'n', PtrUInt(N^.child[i]), ';');

    for i := 0 to N^.n do
      Emit(f, N^.child[i]);
  end;

var
  f: Text;
begin
  Assign(f, fileDot); Rewrite(f);
  try
    WriteLn(f, 'digraph BTree_Favoritos {');
    WriteLn(f, '  rankdir=TB;');
    Emit(f, T);
    WriteLn(f, '}');
  finally
    Close(f);
  end;
end;

end.
