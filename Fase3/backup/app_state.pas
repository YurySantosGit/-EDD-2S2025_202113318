unit app_state;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  avl_borradores, bst_contactos, btree_favoritos, bst_comunidades,
  fpjson, jsonparser;

type
  TLogEntry = record
    usuario: string;
    entrada: string;
    salida:  string;
  end;

var
  BorradoresAVL: PAVL_Borr;
  DraftSeq: Integer;
  ContactosBST: PBST;
  FavoritosBTree: PBNode;
  ComunidadesBST: PBSTC;
  UsuarioActualEmail: String;
  LoginLog: array of TLogEntry;

procedure AppStateInit;
function  NextDraftId: Integer;

function LoginLogCount: Integer;
function GetLoginLog(i: Integer): TLogEntry;
function LoginLogToJSON: String;
procedure SaveLoginLogToJSON(const filePath: String);

procedure RegistrarLogin(const usuario, fechaHora: string);
procedure RegistrarLogout(const usuario, fechaHora: string);
function IsRootUser(const email: string): Boolean;

implementation

procedure AppStateInit;
begin
  BAVL_Init(BorradoresAVL);
  DraftSeq := 0;
  BST_Init(ContactosBST);
  BFav_Init(FavoritosBTree);
  BSTC_Init(ComunidadesBST);

  SetLength(LoginLog, 0);
end;

function NextDraftId: Integer;
begin
  Inc(DraftSeq);
  Result := DraftSeq;
end;

function LoginLogCount: Integer;
begin
  Result := Length(LoginLog);
end;

function GetLoginLog(i: Integer): TLogEntry;
begin
  if (i < 0) or (i >= Length(LoginLog)) then
  begin
    Result.usuario := '';
    Result.entrada := '';
    Result.salida  := '';
    Exit;
  end;
  Result := LoginLog[i];
end;

function LoginLogToJSON: String;
var
  root: TJSONObject;
  arr : TJSONArray;
  obj : TJSONObject;
  i   : Integer;
  e   : TLogEntry;
begin
  root := TJSONObject.Create;
  try
    arr := TJSONArray.Create;
    root.Add('logeos', arr);

    for i := 0 to Length(LoginLog)-1 do
    begin
      e := LoginLog[i];
      obj := TJSONObject.Create;
      obj.Add('usuario', e.usuario);
      obj.Add('entrada', e.entrada);
      obj.Add('salida',  e.salida);
      arr.Add(obj);
    end;

    Result := root.FormatJSON([], 2);
  finally
    root.Free;
  end;
end;

procedure SaveLoginLogToJSON(const filePath: String);
var
  s: TStringList;
begin
  s := TStringList.Create;
  try
    s.Text := LoginLogToJSON;
    s.SaveToFile(filePath);
  finally
    s.Free;
  end;
end;

function IsRootUser(const email: string): Boolean;
begin
  Result := SameText(Trim(email), 'root@edd.com');
end;

procedure RegistrarLogin(const usuario, fechaHora: string);
var
  e: TLogEntry;
  n: Integer;
begin
  if IsRootUser(usuario) then Exit;

  e.usuario := usuario;
  e.entrada := fechaHora;
  e.salida  := '';
  n := Length(LoginLog);
  SetLength(LoginLog, n + 1);
  LoginLog[n] := e;
end;

procedure RegistrarLogout(const usuario, fechaHora: string);
var
  i: Integer;
begin
  if IsRootUser(usuario) then Exit;

  for i := Length(LoginLog) - 1 downto 0 do
    if SameText(LoginLog[i].usuario, usuario) and (Trim(LoginLog[i].salida) = '') then
    begin
      LoginLog[i].salida := fechaHora;
      Exit;
    end;

  i := Length(LoginLog);
  SetLength(LoginLog, i + 1);
  LoginLog[i].usuario := usuario;
  LoginLog[i].entrada := '';
  LoginLog[i].salida  := fechaHora;
end;

end.
