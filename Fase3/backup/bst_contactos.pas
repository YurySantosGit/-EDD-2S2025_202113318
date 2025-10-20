unit bst_contactos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TBSTContacto = record
    email:   String;
    nombre:  String;
    telefono:String;
  end;

  PBST = ^TBST;
  TBST = record
    key:  String;
    data: TBSTContacto;
    L, R: PBST;
  end;

  TContactoProc = procedure(const C: TBSTContacto);

procedure BST_Init(var T: PBST);
procedure BST_Insert(var T: PBST; const C: TBSTContacto);
function  BST_Search(T: PBST; const EmailLookup: String): PBST;
function  BST_Delete(var T: PBST; const EmailToDelete: String): Boolean;
procedure BST_InOrder(T: PBST; proc: TContactoProc);
procedure BST_ToDOT(T: PBST; const fileDot: String);

implementation

function NormEmail(const S: String): String; inline;
begin
  Result := LowerCase(Trim(S));
end;

function NewNode(const C: TBSTContacto): PBST;
begin
  New(Result);
  Result^.key  := NormEmail(C.email);
  Result^.data := C;
  Result^.L := nil; Result^.R := nil;
end;

procedure BST_Init(var T: PBST);
begin
  T := nil;
end;

procedure BST_Insert(var T: PBST; const C: TBSTContacto);
var k: String;
begin
  k := NormEmail(C.email);
  if T=nil then begin
    T := NewNode(C); Exit;
  end;

  if k < T^.key then BST_Insert(T^.L, C)
  else if k > T^.key then BST_Insert(T^.R, C)
  else T^.data := C;
end;

function  BST_Search(T: PBST; const EmailLookup: String): PBST;
var k: String;
begin
  k := NormEmail(EmailLookup);
  while (T<>nil) and (k<>T^.key) do
    if k < T^.key then T := T^.L else T := T^.R;
  Exit(T);
end;

function MinNode(N: PBST): PBST; inline;
begin
  while (N<>nil) and (N^.L<>nil) do N := N^.L;
  Result := N;
end;

function  BST_Delete(var T: PBST; const EmailToDelete: String): Boolean;
var k: String; tmp, succ: PBST;
begin
  Result := False;
  if T=nil then Exit;
  k := NormEmail(EmailToDelete);

  if k < T^.key then Exit(BST_Delete(T^.L, k))
  else if k > T^.key then Exit(BST_Delete(T^.R, k))
  else begin
    Result := True;
    // 0 o 1 hijo
    if (T^.L=nil) or (T^.R=nil) then
    begin
      if T^.L<>nil then tmp := T^.L else tmp := T^.R;
      Dispose(T); T := tmp;
      Exit;
    end;
    // 2 hijos: sucesor in-order
    succ := MinNode(T^.R);
    T^.key  := succ^.key;
    T^.data := succ^.data;
    Exit(BST_Delete(T^.R, succ^.key));
  end;
end;

procedure BST_InOrder(T: PBST; proc: TContactoProc);
begin
  if T=nil then Exit;
  BST_InOrder(T^.L, proc);
  if Assigned(proc) then proc(T^.data);
  BST_InOrder(T^.R, proc);
end;

procedure BST_ToDOT(T: PBST; const fileDot: String);

  function Esc(const S: String): String;
  var tmp: String;
  begin
    tmp := StringReplace(S, '\', '\\', [rfReplaceAll]);
    tmp := StringReplace(tmp, '"', '\"', [rfReplaceAll]);
    tmp := StringReplace(tmp, #13#10, '\n', [rfReplaceAll]);
    tmp := StringReplace(tmp, #10, '\n', [rfReplaceAll]);
    tmp := StringReplace(tmp, #13, '\n', [rfReplaceAll]);
    Result := tmp;
  end;

  procedure Emit(var f: Text; N: PBST);
  var labelStr: String;
  begin
    if N=nil then Exit;
    labelStr := 'Email: ' + Esc(N^.data.email) + '\n'
              + 'Nombre: ' + Esc(N^.data.nombre) + '\n'
              + 'Tel: ' + Esc(N^.data.telefono);
    WriteLn(f, '  "',N^.key,'" [shape=ellipse, label="',labelStr,'"];');
    if N^.L<>nil then WriteLn(f, '  "',N^.key,'" -> "',N^.L^.key,'";');
    if N^.R<>nil then WriteLn(f, '  "',N^.key,'" -> "',N^.R^.key,'";');
    Emit(f, N^.L); Emit(f, N^.R);
  end;

var f: Text;
begin
  Assign(f, fileDot); Rewrite(f);
  WriteLn(f, 'digraph BST_Contactos {');
  WriteLn(f, '  node [fontname="Helvetica"];');
  Emit(f, T);
  WriteLn(f, '}');
  Close(f);
end;

end.
