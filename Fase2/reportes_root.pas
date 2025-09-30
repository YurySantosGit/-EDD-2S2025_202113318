unit reportes_root;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Process, StrUtils,
  usuarios, bandejas, lista_doble;

procedure GenerarReporteUsuarios(const BaseDir: string = '');
procedure GenerarReporteRelaciones(const BaseDir: string = '');
procedure GenerarReportesRoot(const BaseDir: string = '');

implementation

function AppDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

function ReportDir(const BaseDir: string): string;
var dir: string;
begin
  if BaseDir <> '' then dir := IncludeTrailingPathDelimiter(BaseDir)
                   else dir := AppDir;
  dir := IncludeTrailingPathDelimiter(dir) + 'Root-Reportes';
  ForceDirectories(dir);
  Result := dir;
end;

procedure GuardarTexto(const Ruta, Contenido: string);
var sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Text := Contenido;
    sl.SaveToFile(Ruta);
  finally
    sl.Free;
  end;
end;

function Esc(const s: string): string;
begin
  Result := StringReplace(s, '"', '\"', [rfReplaceAll]);
end;

function RunGraphviz(const DotPath, OutPngPath: string): boolean;
var
  P: TProcess;
begin
  Result := False;
  if not FileExists(DotPath) then Exit;
  P := TProcess.Create(nil);
  try
    P.Executable := 'dot';
    P.Parameters.Add('-Tpng');
    P.Parameters.Add('-o');
    P.Parameters.Add(OutPngPath);
    P.Parameters.Add(DotPath);
    P.Options := [poWaitOnExit, poUsePipes];
    try
      P.Execute;
      Result := (P.ExitStatus = 0) and FileExists(OutPngPath);
    except
      Result := False;
    end;
  finally
    P.Free;
  end;
end;

//Reporte Usuarios
procedure GenerarReporteUsuarios(const BaseDir: string);
var rutaDir, rutaDot, rutaPng: string; dot: TStringList;
    actual: PUsuario; idx: Integer; prevId, nowId: string;
begin
  rutaDir := ReportDir(BaseDir);
  rutaDot := IncludeTrailingPathDelimiter(rutaDir)+'usuarios.dot';
  rutaPng := IncludeTrailingPathDelimiter(rutaDir)+'usuarios.png';

  dot := TStringList.Create;
  try
    dot.Add('digraph Usuarios {');
    dot.Add('  graph [splines=ortho, bgcolor="white"];');
    dot.Add('  rankdir=LR;');
    dot.Add('  node [shape=record, style="rounded,filled", fillcolor="#C9DFEC", color="#6B7B8C", penwidth=1.2, fontname="Helvetica"];');
    dot.Add('  edge [color="#2E2E2E", arrowsize=0.8];');
    dot.Add('  subgraph cluster_lista { label="Lista Enlazada"; labelloc=top; fontsize=22; fontname="Helvetica"; color="#C0C0C0"; style="rounded";');
    actual := ListaUsuarios; idx := 0; prevId := '';
    while actual <> nil do
    begin
      nowId := 'u'+IntToStr(idx);
      dot.Add(Format('    %s [label="{ID: %d|Nombre: %s|Usuario: %s|Email: %s|Teléfono: %s}"];',
        [nowId, actual^.id, Esc(actual^.nombre), Esc(actual^.usuario), Esc(actual^.email), Esc(actual^.telefono)]));
      if prevId <> '' then dot.Add(Format('    %s -> %s;', [prevId, nowId]));
      prevId := nowId; actual := actual^.siguiente; Inc(idx);
    end;
    if idx = 0 then dot.Add('    empty [label="(sin usuarios)"];');
    dot.Add('  }'); dot.Add('}');
    GuardarTexto(rutaDot, dot.Text);
  finally dot.Free; end;
  RunGraphviz(rutaDot, rutaPng);
end;

//Reporte de relaciones
procedure GenerarReporteRelaciones(const BaseDir: string);
var rutaDir, rutaDot, rutaPng: string; dot: TStringList;
    filas, cols, celdas: TStringList;

  function KeyRC(const r, c: string): string; inline; begin Result := r+'|'+c; end;
  function GetIndex(sl: TStringList; const s: string): Integer;
  begin if sl.IndexOf(s) < 0 then sl.Add(s); Result := sl.IndexOf(s); end;
  procedure IncCelda(const r, c: string);
  var k: string; p: Integer; v: PtrInt;
  begin
    k := KeyRC(r,c); p := celdas.IndexOf(k);
    if p < 0 then celdas.AddObject(k, TObject(PtrInt(1))) else
    begin v := PtrInt(celdas.Objects[p]); Inc(v); celdas.Objects[p] := TObject(v); end;
  end;

  procedure RecolectarDatos;
  var nB: PBandejaNodo; c: PCorreo;
  begin
    nB := ListaBandejas;
    while nB <> nil do
    begin
      c := nB^.bandeja.cabeza;
      while c <> nil do
      begin
        GetIndex(filas, c^.remitente);
        GetIndex(cols,  nB^.ownerEmail);
        IncCelda(c^.remitente, nB^.ownerEmail);
        c := c^.siguiente;
      end;
      nB := nB^.siguiente;
    end;
  end;

  function SafeId(const prefix, raw: string): string;
  var s: string;
  begin
    s := raw;
    s := StringReplace(s,'@','_at_',[rfReplaceAll]);
    s := StringReplace(s,'.','_',[rfReplaceAll]);
    s := StringReplace(s,'-','_',[rfReplaceAll]);
    s := StringReplace(s,'+','_',[rfReplaceAll]);
    s := StringReplace(s,' ','_',[rfReplaceAll]);
    Result := prefix+s;
  end;


  function Q(const id: string): string; inline;
  begin
    Result := '"' + id + '"';
  end;

var i: Integer; r,c,k,nodo, rowId, colId: string; count: PtrInt;
begin
  rutaDir := ReportDir(BaseDir);
  rutaDot := IncludeTrailingPathDelimiter(rutaDir)+'relaciones.dot';
  rutaPng := IncludeTrailingPathDelimiter(rutaDir)+'relaciones.png';

  filas := TStringList.Create; cols := TStringList.Create; celdas := TStringList.Create;
  try
    filas.Sorted := True; filas.Duplicates := dupIgnore;
    cols.Sorted  := True; cols.Duplicates  := dupIgnore;

    RecolectarDatos;

    dot := TStringList.Create;
    try
      dot.Add('digraph Relaciones {');
      dot.Add('  graph [splines=ortho, bgcolor="white"]; rankdir=TB;');
      dot.Add('  node [shape=box, fontname="Helvetica"]; edge [arrowhead=vee, color="black"];');
      dot.Add('  subgraph cluster_matriz { label="Matriz Dispersa"; labelloc=top; fontsize=22; style="rounded"; color="#C0C0C0";');

      dot.Add('    ' + Q('rootCorner') + ' [shape=box, style="filled", fillcolor="#9E9E9E", width=0.8, height=0.6, label=""];');


      for i:=0 to cols.Count-1 do
      begin
        colId := SafeId('col_', cols[i]);
        dot.Add(Format('    %s [label="%s", style="filled", fillcolor="#C9DFEC"];',
          [Q(colId), Esc(cols[i])]));
      end;

      for i:=0 to filas.Count-1 do
      begin
        rowId := SafeId('row_', filas[i]);
        dot.Add(Format('    %s [label="%s", style="filled", fillcolor="#CDECC9"];',
          [Q(rowId), Esc(filas[i])]));
      end;

      if cols.Count>0 then
      begin
        colId := SafeId('col_', cols[0]);
        dot.Add(Format('    %s -> %s;', [Q('rootCorner'), Q(colId)]));
        dot.Add(Format('    %s -> %s;', [Q(colId), Q('rootCorner')]));
      end;
      if filas.Count>0 then
      begin
        rowId := SafeId('row_', filas[0]);
        dot.Add(Format('    %s -> %s;', [Q('rootCorner'), Q(rowId)]));
        dot.Add(Format('    %s -> %s;', [Q(rowId), Q('rootCorner')]));
      end;

      for i:=0 to cols.Count-2 do
      begin
        dot.Add(Format('    %s -> %s;', [Q(SafeId('col_', cols[i])), Q(SafeId('col_', cols[i+1]))]));
        dot.Add(Format('    %s -> %s;', [Q(SafeId('col_', cols[i+1])), Q(SafeId('col_', cols[i]))]));
      end;
      for i:=0 to filas.Count-2 do
      begin
        dot.Add(Format('    %s -> %s;', [Q(SafeId('row_', filas[i])), Q(SafeId('row_', filas[i+1]))]));
        dot.Add(Format('    %s -> %s;', [Q(SafeId('row_', filas[i+1])), Q(SafeId('row_', filas[i]))]));
      end;

      for i:=0 to celdas.Count-1 do
      begin
        k := celdas[i];
        r := Copy(k, 1, Pos('|', k)-1);
        c := Copy(k, Pos('|', k)+1, Length(k));
        count := PtrInt(celdas.Objects[i]);

        nodo := SafeId('f_'+r+'_c_', c);
        rowId := SafeId('row_', r);
        colId := SafeId('col_', c);

        dot.Add(Format('    %s [label="%d", style="filled", fillcolor="#FFB74D"];', [Q(nodo), count]));
        dot.Add(Format('    %s -> %s; %s -> %s;', [Q(rowId), Q(nodo), Q(nodo), Q(rowId)]));
        dot.Add(Format('    %s -> %s; %s -> %s;', [Q(colId), Q(nodo), Q(nodo), Q(colId)]));
      end;

      dot.Add('  }');
      dot.Add('}');
      GuardarTexto(rutaDot, dot.Text);
    finally
      dot.Free;
    end;

  finally
    filas.Free; cols.Free; celdas.Free;
  end;

  RunGraphviz(rutaDot, rutaPng);
end;


{ --------------------- WRAPPER --------------------- }
procedure GenerarReportesRoot(const BaseDir: string);
begin
  GenerarReporteUsuarios(BaseDir);
  GenerarReporteRelaciones(BaseDir);
end;

end.
