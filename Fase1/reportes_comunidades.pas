unit reportes_comunidades;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, StrUtils, comunidades;

procedure GenerarReporteComunidades(const BaseDir: string = '');

implementation

function AppDir: string; begin Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))); end;

function ReportDir(const BaseDir: string): string;
var d: string;
begin
  if BaseDir <> '' then d := IncludeTrailingPathDelimiter(BaseDir) else d := AppDir;
  d := IncludeTrailingPathDelimiter(d) + 'Root-Reportes';
  ForceDirectories(d); Result := d;
end;

procedure SaveText(const Path, S: string);
var sl: TStringList; begin sl := TStringList.Create; try sl.Text := S; sl.SaveToFile(Path); finally sl.Free; end; end;

function SanId(const prefix, raw: string): string;
var s: string;
begin
  s := raw;
  s := StringReplace(s,'@','_at_',[rfReplaceAll]);
  s := StringReplace(s,'.','_',[rfReplaceAll]);
  s := StringReplace(s,'-','_',[rfReplaceAll]);
  s := StringReplace(s,'+','_',[rfReplaceAll]);
  s := StringReplace(s,' ','_',[rfReplaceAll]);
  Result := prefix + s;
end;
function Q(const s: string): string; inline; begin Result := '"' + s + '"'; end;

function RunDot(const dotPath, pngPath: string): boolean;
var P: TProcess;
begin
  Result := False;
  if not FileExists(dotPath) then Exit;
  P := TProcess.Create(nil);
  try
    P.Executable := 'dot'; P.Parameters.Add('-Tpng');
    P.Parameters.Add('-o'); P.Parameters.Add(pngPath);
    P.Parameters.Add(dotPath);
    P.Options := [poWaitOnExit, poUsePipes];
    try P.Execute; Result := (P.ExitStatus = 0) and FileExists(pngPath);
    except Result := False; end;
  finally P.Free; end;
end;

procedure GenerarReporteComunidades(const BaseDir: string);
var
  dir, dotPath, pngPath: string;
  dot: TStringList;
  c: PComunidad; m: PMiembro;
  prevC, idC, idPrevM, idM: string;
begin
  dir := ReportDir(BaseDir);
  dotPath := IncludeTrailingPathDelimiter(dir) + 'comunidades.dot';
  pngPath := IncludeTrailingPathDelimiter(dir) + 'comunidades.png';

  dot := TStringList.Create;
  try
    dot.Add('digraph Comunidades {');
    dot.Add('  graph [splines=ortho, bgcolor="white"]; rankdir=LR;');
    dot.Add('  node [fontname="Helvetica"]; edge [arrowhead=vee];');
    dot.Add('  subgraph cluster_all { label="Comunidades"; labelloc=top; fontsize=22; style="rounded"; color="#C0C0C0";');

    c := ListaComunidades.cabeza; prevC := '';
    while c <> nil do
    begin
      idC := SanId('com_', c^.nombre);
      dot.Add(Format('    %s [label="%s", shape=box, style="filled,rounded", fillcolor="#B3D9EA"];',
        [Q(idC), StringReplace(c^.nombre,'"','\"',[rfReplaceAll])]));

      if prevC <> '' then
      begin
        dot.Add(Format('    %s -> %s;', [Q(prevC), Q(idC)]));
        dot.Add(Format('    %s -> %s;', [Q(idC), Q(prevC)]));
      end;
      prevC := idC;

      idPrevM := '';
      m := c^.miembros.cabeza;
      while m <> nil do
      begin
        idM := SanId('m_', m^.email);
        dot.Add(Format('    %s [label="%s", shape=box, style="filled", fillcolor="#FFF9C4"];',
          [Q(idM), StringReplace(m^.email,'"','\"',[rfReplaceAll])]));
        if idPrevM = '' then
          dot.Add(Format('    %s -> %s;', [Q(idC), Q(idM)]))
        else
          dot.Add(Format('    %s -> %s;', [Q(idPrevM), Q(idM)]));
        idPrevM := idM;
        m := m^.sig;
      end;

      c := c^.sig;
    end;

    dot.Add('  }'); dot.Add('}');
    SaveText(dotPath, dot.Text);
  finally
    dot.Free;
  end;

  RunDot(dotPath, pngPath);
end;

end.

