unit reportes_usuario;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Process, StrUtils,
  usuarios, bandejas, lista_doble, cola_correos, pila_papelera, contactos;

procedure GenerarReportesUsuario(const usuarioSistema: string; const BaseDir: string = '');

procedure ReporteCorreosRecibidos(const userEmail, carpeta: string);
procedure ReportePapelera(const userEmail, carpeta: string);
procedure ReporteProgramados(const userEmail, carpeta: string);
procedure ReporteContactos(const userEmail, carpeta: string);

implementation


function AppDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

function MkUserFolder(const usuarioSistema, BaseDir: string): string;
var dirBase, folder: string;
begin
  if BaseDir <> '' then dirBase := IncludeTrailingPathDelimiter(BaseDir)
                   else dirBase := AppDir;
  folder := IncludeTrailingPathDelimiter(dirBase) + usuarioSistema + '-Reportes';
  ForceDirectories(folder);
  Result := folder;
end;

procedure SaveText(const Path, TextOut: string);
var sl: TStringList;
begin
  sl := TStringList.Create;
  try sl.Text := TextOut; sl.SaveToFile(Path);
  finally sl.Free; end;
end;

function Esc(const s: string): string;
begin
  Result := StringReplace(s, '"', '\"', [rfReplaceAll]);
end;

function Id(const prefix, raw: string): string;
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
    P.Executable := 'dot';
    P.Parameters.Add('-Tpng');
    P.Parameters.Add('-o'); P.Parameters.Add(pngPath);
    P.Parameters.Add(dotPath);
    P.Options := [poWaitOnExit, poUsePipes];
    try
      P.Execute;
      Result := (P.ExitStatus = 0) and FileExists(pngPath);
    except
      Result := False;
    end;
  finally
    P.Free;
  end;
end;

function BuscarEmailPorUsuario(const usuarioSistema: string): string;
var it: PUsuario;
begin
  Result := '';
  it := ListaUsuarios;
  while it <> nil do
  begin
    if SameText(it^.usuario, usuarioSistema) then
    begin
      Result := it^.email;
      Exit;
    end;
    it := it^.siguiente;
  end;
end;

//Correos Recibidos
procedure ReporteCorreosRecibidos(const userEmail, carpeta: string);
var
  dot: TStringList; rutaDot, rutaPng: string;
  pb: PBandeja; cur: PCorreo; i: Integer; prevId, nowId: string;
begin
  rutaDot := IncludeTrailingPathDelimiter(carpeta) + 'correos_recibidos.dot';
  rutaPng := IncludeTrailingPathDelimiter(carpeta) + 'correos_recibidos.png';

  dot := TStringList.Create;
  try
    dot.Add('digraph CorreosRecibidos {');
    dot.Add('  graph [splines=ortho, bgcolor="white"];');
    dot.Add('  rankdir=LR;');
    dot.Add('  node [shape=record, style="rounded,filled", fillcolor="#C9DFEC", fontname="Helvetica"];');
    dot.Add('  edge [color="#2E2E2E", arrowsize=0.8];');
    dot.Add('  subgraph cluster_lista { label="Correos Recibidos ('+Esc(userEmail)+')"; labelloc=top; fontsize=22; style="rounded"; color="#C0C0C0";');

    pb := ObtenerBandejaPtr(userEmail);
    if pb = nil then
    begin
      dot.Add('    empty [label="(sin bandeja para el usuario)"];');
    end
    else
    begin
      cur := pb^.cabeza; i := 0; prevId := '';
      while cur <> nil do
      begin
        nowId := 'n'+IntToStr(i);
        dot.Add(Format('    %s [label="{ID: %d|Remitente: %s|Asunto: %s|Fecha: %s|Estado: %s}"];',
          [nowId, cur^.id, Esc(cur^.remitente), Esc(cur^.asunto), Esc(cur^.fecha), Esc(cur^.estado)]));
        if prevId <> '' then
        begin
          dot.Add(Format('    %s -> %s;', [prevId, nowId]));
          dot.Add(Format('    %s -> %s;', [nowId, prevId]));
        end;
        prevId := nowId; cur := cur^.siguiente; Inc(i);
      end;
      if i = 0 then dot.Add('    empty [label="(sin correos)"];');
    end;

    dot.Add('  }'); dot.Add('}');
    SaveText(rutaDot, dot.Text);
  finally
    dot.Free;
  end;

  RunDot(rutaDot, rutaPng);
end;

//Papelera
procedure ReportePapelera(const userEmail, carpeta: string);
var
  dot: TStringList; rutaDot, rutaPng: string;
  it: PPilaNodo; idx: Integer; nowId, prevId: string;
begin
  rutaDot := IncludeTrailingPathDelimiter(carpeta) + 'papelera.dot';
  rutaPng := IncludeTrailingPathDelimiter(carpeta) + 'papelera.png';

  dot := TStringList.Create;
  try
    dot.Add('digraph Papelera {');
    dot.Add('  graph [splines=ortho, bgcolor="white"];');
    dot.Add('  rankdir=TB;');
    dot.Add('  node [shape=box, style="filled", fillcolor="#FFECB3", fontname="Helvetica"];');
    dot.Add('  edge [arrowhead=vee];');
    dot.Add('  subgraph cluster_pila { label="Papelera ('+Esc(userEmail)+')"; labelloc=top; fontsize=22; style="rounded"; color="#C0C0C0";');

    it := PapeleraGlobal.tope; idx := 0; prevId := '';
    while it <> nil do
    begin
      nowId := 'p'+IntToStr(idx);
      dot.Add(Format('    %s [label="[%s] %s"];',
        [nowId, Esc(it^.dato.estado), Esc(it^.dato.asunto)]));
      if prevId <> '' then
        dot.Add(Format('    %s -> %s;', [prevId, nowId]));
      prevId := nowId;
      it := it^.siguiente; Inc(idx);
    end;
    if idx = 0 then dot.Add('    empty [label="(papelera vacía)"];');

    dot.Add('  }'); dot.Add('}');
    SaveText(rutaDot, dot.Text);
  finally
    dot.Free;
  end;

  RunDot(rutaDot, rutaPng);
end;

//Correos Programados
procedure ReporteProgramados(const userEmail, carpeta: string);
var
  dot: TStringList; rutaDot, rutaPng: string;
  it: PColaNodo; idx: Integer; prevId, nowId: string;
begin
  rutaDot := IncludeTrailingPathDelimiter(carpeta) + 'programados.dot';
  rutaPng := IncludeTrailingPathDelimiter(carpeta) + 'programados.png';

  dot := TStringList.Create;
  try
    dot.Add('digraph Programados {');
    dot.Add('  graph [splines=ortho, bgcolor="white"];');
    dot.Add('  rankdir=LR;');
    dot.Add('  node [shape=record, style="rounded,filled", fillcolor="#D1C4E9", fontname="Helvetica"];');
    dot.Add('  edge [arrowhead=vee];');
    dot.Add('  subgraph cluster_cola { label="Correos Programados ('+Esc(userEmail)+')"; labelloc=top; fontsize=22; style="rounded"; color="#C0C0C0";');

    it := ColaGlobal.frente; idx := 0; prevId := '';
    while it <> nil do
    begin
      if SameText(it^.dato.remitente, userEmail) then
      begin
        nowId := 'c'+IntToStr(idx);
        dot.Add(Format('    %s [label="{%s %s|Asunto: %s|Para: %s}"];',
          [nowId, Esc(it^.dato.fecha), Esc(it^.dato.hora),
           Esc(it^.dato.asunto), Esc(it^.dato.destinatario)]));
        if prevId <> '' then dot.Add(Format('    %s -> %s;', [prevId, nowId]));
        prevId := nowId;
      end;
      it := it^.siguiente; Inc(idx);
    end;
    if prevId = '' then dot.Add('    empty [label="(sin programados del usuario)"];');

    dot.Add('  }'); dot.Add('}');
    SaveText(rutaDot, dot.Text);
  finally
    dot.Free;
  end;

  RunDot(rutaDot, rutaPng);
end;

//Contactos
procedure ReporteContactos(const userEmail, carpeta: string);
var
  dot: TStringList; rutaDot, rutaPng: string;
  head, it: PContacto; idx: Integer; firstId, prevId, nowId: string;
begin
  rutaDot := IncludeTrailingPathDelimiter(carpeta) + 'contactos.dot';
  rutaPng := IncludeTrailingPathDelimiter(carpeta) + 'contactos.png';

  dot := TStringList.Create;
  try
    dot.Add('digraph Contactos {');
    dot.Add('  graph [splines=ortho, bgcolor="white"];');
    dot.Add('  rankdir=LR;');
    dot.Add('  node [shape=box, style="rounded,filled", fillcolor="#B2DFDB", fontname="Helvetica"];');
    dot.Add('  edge [arrowhead=vee];');
    dot.Add('  subgraph cluster_circular { label="Contactos ('+Esc(userEmail)+')"; labelloc=top; fontsize=22; style="rounded"; color="#C0C0C0";');


    head := nil; it := ListaContactos.cabeza;
    if it <> nil then
    begin
      repeat
        if SameText(it^.ownerEmail, userEmail) then
        begin head := it; Break; end;
        it := it^.siguiente;
      until it = ListaContactos.cabeza;
    end;

    if head = nil then
      dot.Add('    empty [label="(sin contactos del usuario)"]')
    else
    begin
      idx := 0; prevId := ''; firstId := '';
      it := head;
      repeat
        nowId := 'k'+IntToStr(idx);
        dot.Add(Format('    %s [label="%s\n(%s)"];', [nowId, Esc(it^.nombre), Esc(it^.email)]));
        if prevId <> '' then dot.Add(Format('    %s -> %s;', [prevId, nowId]));
        if firstId = '' then firstId := nowId;
        prevId := nowId;
        it := it^.siguiente; Inc(idx);
      until (it = head) or (idx > 10000);
      if (firstId <> '') and (firstId <> prevId) then
        dot.Add(Format('    %s -> %s;', [prevId, firstId]));
    end;

    dot.Add('  }'); dot.Add('}');
    SaveText(rutaDot, dot.Text);
  finally
    dot.Free;
  end;

  RunDot(rutaDot, rutaPng);
end;

procedure GenerarReportesUsuario(const usuarioSistema: string; const BaseDir: string);
var email, carpeta: string;
begin
  email := BuscarEmailPorUsuario(usuarioSistema);
  if Trim(email) = '' then
    raise Exception.Create('No se encontró email para el usuario: ' + usuarioSistema);

  carpeta := MkUserFolder(usuarioSistema, BaseDir);

  ReporteCorreosRecibidos(email, carpeta);
  ReportePapelera(email, carpeta);
  ReporteProgramados(email, carpeta);
  ReporteContactos(email, carpeta);
end;

end.

