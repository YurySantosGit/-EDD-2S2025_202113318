unit merkle_favoritos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure Merkle_RebuildAndReport(const usuarioEmail: string; const outDir: string = '');

implementation

uses
  md5, Process, FileUtil, btree_favoritos, app_state;

type
  TStringListArray = array[0..64] of TStringList;

function MD5Hex(const S: AnsiString): AnsiString;
var
  d: TMD5Digest;
begin
  d := MD5String(S);
  Result := MD5Print(d);
end;

function HashFavorito(const F: TFavorito): string;
var
  s: AnsiString;
  d: TMD5Digest;
begin
  s := IntToStr(F.id) + '|' + F.remitente + '|' + F.estado + '|' +
       F.asunto + '|' + F.fecha + '|' + F.mensaje;
  d := MD5String(s);
  Result := MD5Print(d);
end;

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

function San(const s: string): string;
begin
  Result := StringReplace(s, #13#10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
end;

var
  gHashes  : TStringList = nil;
  gDetails : TStringList = nil;

procedure CollectBoth(const F: TFavorito);
var
  h: string;
  line: string;
begin
  h := HashFavorito(F);
  if Assigned(gHashes) then gHashes.Add(h);
  if Assigned(gDetails) then
  begin
    line := Format('ID:%d | De:%s | Asunto:%s | Fecha:%s | Hash:%s',
                   [F.id, San(F.remitente), San(F.asunto), San(F.fecha), h]);
    gDetails.Add(line);
  end;
end;

procedure FavoritosToHashesAndDetails(out hashes, details: TStringList);
begin
  hashes  := TStringList.Create;
  details := TStringList.Create;
  gHashes  := hashes;
  gDetails := details;
  try
    BFav_InOrder(FavoritosBTree, @CollectBoth);
  finally
    gHashes := nil;
    gDetails := nil;
  end;
end;

procedure BuildLevels(const leaves: TStrings; var levels: TStringListArray);
var
  lvl, i, n: Integer;
  cur, nxt: TStringList;
  leftH, rightH: string;
begin
  for i := Low(levels) to High(levels) do levels[i] := nil;

  levels[0] := TStringList.Create;
  levels[0].Assign(leaves);

  lvl := 0;
  while (levels[lvl] <> nil) and (levels[lvl].Count > 1) do
  begin
    cur := levels[lvl];
    nxt := TStringList.Create;
    levels[lvl+1] := nxt;

    n := cur.Count;
    i := 0;
    while i < n do
    begin
      leftH := cur[i];
      if (i+1 < n) then rightH := cur[i+1] else rightH := leftH;
      nxt.Add(MD5Hex(leftH + rightH));
      Inc(i, 2);
    end;

    Inc(lvl);
  end;
end;

function MerkleRootFromLevels(const levels: TStringListArray): string;
var
  top: TStringList;
  i: Integer;
begin
  Result := '';
  if levels[0] = nil then Exit;
  top := nil;
  i := 0;
  while (i <= High(levels)) and (levels[i] <> nil) do
  begin
    if (levels[i].Count > 0) then top := levels[i];
    Inc(i);
  end;
  if (top <> nil) and (top.Count > 0) then
    Result := top[0];
end;

procedure Merkle_ToDOT_FromLeaves(const leafHashes, leafDetails: TStrings; const dotPath, pngPath: string);
var
  f: Text;
  lvlLists: TStringListArray;
  lvl, i: Integer;
  dotExe: string;
  P: TProcess;

  function IdOf(l, idx: Integer): string;
  begin
    Result := Format('L%d_N%d', [l, idx]);
  end;

  function RootFromLevels: string;
  begin
    Result := MerkleRootFromLevels(lvlLists);
  end;

var
  nodeId, labelStr, root: string;
begin
  BuildLevels(leafHashes, lvlLists);

  Assign(f, dotPath);
  Rewrite(f);
  try
    Writeln(f, 'digraph MerkleFavoritos {');
    Writeln(f, '  rankdir=TB;');
    Writeln(f, '  node [shape=box, fontname="Helvetica"];');

    lvl := 0;
    while (lvl <= High(lvlLists)) and (lvlLists[lvl] <> nil) do
    begin
      Writeln(f, '  { rank=same;');
      for i := 0 to lvlLists[lvl].Count - 1 do
      begin
        nodeId := IdOf(lvl, i);
        if lvl = 0 then
          labelStr := Esc(leafDetails[i])
        else
          labelStr := Esc(lvlLists[lvl][i]);
        Writeln(f, Format('    %s [label="%s"];', [nodeId, labelStr]));
      end;
      Writeln(f, '  }');
      Inc(lvl);
    end;

    lvl := 0;
    while (lvlLists[lvl] <> nil) and (lvlLists[lvl+1] <> nil) do
    begin
      for i := 0 to lvlLists[lvl].Count - 1 do
        Writeln(f, Format('  %s -> %s;', [IdOf(lvl, i), IdOf(lvl+1, i div 2)]));
      Inc(lvl);
    end;

    root := RootFromLevels;
    if root <> '' then
      Writeln(f, '  { rank=sink; root [shape=ellipse, style="filled", fillcolor="#C8E6C9", label="Merkle Root\l', root, '"]; }');

    Writeln(f, '}');
  finally
    Close(f);
  end;

  for i := Low(lvlLists) to High(lvlLists) do
    if lvlLists[i] <> nil then lvlLists[i].Free;

  dotExe := FindDefaultExecutablePath({$IFDEF WINDOWS}'dot.exe'{$ELSE}'dot'{$ENDIF});
  if (dotExe = '') and FileExists('/usr/bin/dot') then dotExe := '/usr/bin/dot';
  if (dotExe = '') then Exit;

  P := TProcess.Create(nil);
  try
    P.Executable := dotExe;
    P.Parameters.Add('-Tpng');
    P.Parameters.Add('-o'); P.Parameters.Add(pngPath);
    P.Parameters.Add(dotPath);
    P.Options := [poWaitOnExit];
    P.Execute;
  finally
    P.Free;
  end;
end;

procedure Merkle_RebuildAndReport(const usuarioEmail: string; const outDir: string);
var
  baseDir, userCarp: string;
  dotFile, pngFile: string;
  hashes, details: TStringList;
begin
  if outDir <> '' then
    baseDir := IncludeTrailingPathDelimiter(outDir)
  else
  begin
    userCarp := Copy(usuarioEmail, 1, Pos('@', usuarioEmail) - 1);
    if userCarp = '' then userCarp := 'usuario';
    baseDir := userCarp + '-Reportes' + DirectorySeparator;
  end;
  ForceDirectories(baseDir);

  dotFile := baseDir + 'favoritos_merkle.dot';
  pngFile := baseDir + 'favoritos_merkle.png';

  FavoritosToHashesAndDetails(hashes, details);
  try
    if hashes.Count = 0 then
    begin
      with TStringList.Create do
      try
        Text := 'digraph MerkleFavoritos { label="(sin favoritos)"; }';
        SaveToFile(dotFile);
      finally
        Free;
      end;
      Exit;
    end;

    Merkle_ToDOT_FromLeaves(hashes, details, dotFile, pngFile);
  finally
    hashes.Free;
    details.Free;
  end;
end;

end.
