unit avl_borradores;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TBorrador = record
    id: Integer;
    remitente, destinatario: String;
    asunto, mensaje: String;
  end;

  PAVL_Borr = ^TAVL_Borr;
  TAVL_Borr = record
    key: Integer;
    h: Integer;
    data: TBorrador;
    L, R: PAVL_Borr;
  end;

procedure BAVL_Init(var T: PAVL_Borr);
procedure BAVL_Insert(var T: PAVL_Borr; const B: TBorrador);
function  BAVL_Find(T: PAVL_Borr; id: Integer): PAVL_Borr;
function BAVL_Delete(var T: PAVL_Borr; id: Integer): Boolean;


procedure BAVL_ToStrings_PreOrder(T: PAVL_Borr; outList: TStrings);
procedure BAVL_ToStrings_InOrder(T: PAVL_Borr; outList: TStrings);
procedure BAVL_ToStrings_PostOrder(T: PAVL_Borr; outList: TStrings);

procedure BAVL_ToDOT(T: PAVL_Borr; const fileDot: String);

implementation

function Height(N: PAVL_Borr): Integer; inline;
begin
  if N = nil then Exit(0) else Exit(N^.h);
end;

function MaxI(a,b: Integer): Integer; inline;
begin if a>b then Exit(a) else Exit(b) end;

function NewNode(const B: TBorrador): PAVL_Borr;
begin
  New(Result);
  Result^.key := B.id;
  Result^.data := B;
  Result^.h := 1;
  Result^.L := nil;
  Result^.R := nil;
end;

function RotR(y: PAVL_Borr): PAVL_Borr;
var x: PAVL_Borr;
begin
  x := y^.L;
  y^.L := x^.R;
  x^.R := y;
  y^.h := MaxI(Height(y^.L), Height(y^.R)) + 1;
  x^.h := MaxI(Height(x^.L), Height(x^.R)) + 1;
  Exit(x);
end;

function RotL(x: PAVL_Borr): PAVL_Borr;
var y: PAVL_Borr;
begin
  y := x^.R;
  x^.R := y^.L;
  y^.L := x;
  x^.h := MaxI(Height(x^.L), Height(x^.R)) + 1;
  y^.h := MaxI(Height(y^.L), Height(y^.R)) + 1;
  Exit(y);
end;

function Balance(N: PAVL_Borr): Integer; inline;
begin
  Exit(Height(N^.L) - Height(N^.R));
end;

function MinNode(N: PAVL_Borr): PAVL_Borr;
begin
  if N=nil then Exit(nil);
  while N^.L<>nil do N := N^.L;
  Exit(N);
end;

procedure RecalcHeight(N: PAVL_Borr);
begin
  N^.h := 1 + MaxI(Height(N^.L), Height(N^.R));
end;

function _Delete(var N: PAVL_Borr; id: Integer): Boolean;
var
  tmp, succ: PAVL_Borr;
  bf: Integer;
begin
  if N=nil then Exit(False);

  if id < N^.key then
    Result := _Delete(N^.L, id)
  else if id > N^.key then
    Result := _Delete(N^.R, id)
  else
  begin
    Result := True;
    if (N^.L=nil) or (N^.R=nil) then
    begin
      if N^.L<>nil then tmp := N^.L else tmp := N^.R;
      Dispose(N);
      N := tmp;
      Exit;
    end
    else
    begin
      succ := MinNode(N^.R);
      N^.key  := succ^.key;
      N^.data := succ^.data;
      Result := _Delete(N^.R, succ^.key);
    end;
  end;

  if N=nil then Exit(Result);

  RecalcHeight(N);
  bf := Balance(N);

  if (bf > 1) and (Balance(N^.L) >= 0) then begin N := RotR(N); Exit(Result) end;
  if (bf > 1) and (Balance(N^.L) < 0)  then begin N^.L := RotL(N^.L); N := RotR(N); Exit(Result) end;
  if (bf < -1) and (Balance(N^.R) <= 0) then begin N := RotL(N); Exit(Result) end;
  if (bf < -1) and (Balance(N^.R) > 0)  then begin N^.R := RotR(N^.R); N := RotL(N); Exit(Result) end;
end;

function BAVL_Delete(var T: PAVL_Borr; id: Integer): Boolean;
begin
  Result := _Delete(T, id);
end;


procedure _Insert(var N: PAVL_Borr; const B: TBorrador);
var bf: Integer;
begin
  if N = nil then begin N := NewNode(B); Exit end;

  if B.id < N^.key then _Insert(N^.L, B)
  else if B.id > N^.key then _Insert(N^.R, B)
  else begin
    N^.data := B; Exit;
  end;

  N^.h := 1 + MaxI(Height(N^.L), Height(N^.R));
  bf := Balance(N);

  if (bf > 1) and (B.id < N^.L^.key) then begin N := RotR(N); Exit end;
  if (bf < -1) and (B.id > N^.R^.key) then begin N := RotL(N); Exit end;
  if (bf > 1) and (B.id > N^.L^.key) then begin N^.L := RotL(N^.L); N := RotR(N); Exit end;
  if (bf < -1) and (B.id < N^.R^.key) then begin N^.R := RotR(N^.R); N := RotL(N); Exit end;
end;

procedure BAVL_Init(var T: PAVL_Borr); begin T := nil end;
procedure BAVL_Insert(var T: PAVL_Borr; const B: TBorrador); begin _Insert(T, B) end;

function  BAVL_Find(T: PAVL_Borr; id: Integer): PAVL_Borr;
begin
  while (T<>nil) and (T^.key<>id) do
    if id < T^.key then T := T^.L else T := T^.R;
  Exit(T);
end;

procedure _Pre(T: PAVL_Borr; outList: TStrings);
begin
  if T=nil then Exit;
  outList.Add(Format('%d | %s -> %s | %s',
    [T^.data.id, T^.data.remitente, T^.data.destinatario, T^.data.asunto]));
  _Pre(T^.L, outList); _Pre(T^.R, outList);
end;

procedure _In(T: PAVL_Borr; outList: TStrings);
begin
  if T=nil then Exit;
  _In(T^.L, outList);
  outList.Add(Format('%d | %s -> %s | %s',
    [T^.data.id, T^.data.remitente, T^.data.destinatario, T^.data.asunto]));
  _In(T^.R, outList);
end;

procedure _Post(T: PAVL_Borr; outList: TStrings);
begin
  if T=nil then Exit;
  _Post(T^.L, outList); _Post(T^.R, outList);
  outList.Add(Format('%d | %s -> %s | %s',
    [T^.data.id, T^.data.remitente, T^.data.destinatario, T^.data.asunto]));
end;

procedure BAVL_ToStrings_PreOrder(T: PAVL_Borr; outList: TStrings); begin _Pre(T, outList) end;
procedure BAVL_ToStrings_InOrder (T: PAVL_Borr; outList: TStrings); begin _In (T, outList) end;
procedure BAVL_ToStrings_PostOrder(T: PAVL_Borr; outList: TStrings); begin _Post(T, outList) end;

procedure BAVL_ToDOT(T: PAVL_Borr; const fileDot: String);
  procedure EmitNode(var f: Text; N: PAVL_Borr);
  begin
    if N=nil then Exit;
    WriteLn(f, '  "', N^.key, '" [label="', StringReplace(N^.data.asunto,'"','\"',[rfReplaceAll]),
            '\nID:', N^.key, '"];');
    if N^.L<>nil then WriteLn(f, '  "', N^.key, '" -> "', N^.L^.key, '";');
    if N^.R<>nil then WriteLn(f, '  "', N^.key, '" -> "', N^.R^.key, '";');
    EmitNode(f, N^.L); EmitNode(f, N^.R);
  end;
var f: Text;
begin
  Assign(f, fileDot); Rewrite(f);
  WriteLn(f, 'digraph AVL {');
  WriteLn(f, '  node [shape=box, fontname="Helvetica"];');
  EmitNode(f, T);
  WriteLn(f, '}');
  Close(f);
end;

end.
