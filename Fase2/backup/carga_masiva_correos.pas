unit carga_masiva_correos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser,
  usuarios, bandejas, lista_doble, pila_papelera;

procedure CargaMasivaCorreosDesdeJSON(const FileName: String; out agregados, rechazados: Integer; log: TStrings);

implementation

function EmailValido(const s: String): Boolean; inline;
begin
  Result := (Pos('@', s) > 1) and (Pos('.', s) > 3);
end;

function GetStrAny(J: TJSONObject; const Keys: array of String; const Default: String = ''): String;
var
  k: String;
begin
  for k in Keys do
    if J.IndexOfName(k) <> -1 then
      Exit(Trim(J.Get(k, Default)));
  Result := Default;
end;

function GetIntAny(J: TJSONObject; const Keys: array of String; const Default: Integer): Integer;
var
  k: String;
begin
  for k in Keys do
    if J.IndexOfName(k) <> -1 then
      Exit(J.Get(k, Default));
  Result := Default;
end;

function GetBoolAny(J: TJSONObject; const Keys: array of String; const Default: Boolean): Boolean;
var
  k: String;
begin
  for k in Keys do
    if J.IndexOfName(k) <> -1 then
      Exit(J.Get(k, Default));
  Result := Default;
end;

type
  TEstadoJSON = (ejNL, ejL, ejEliminado);

function ClasificaEstadoJSON(const s: String): TEstadoJSON;
var
  t: String;
begin
  t := UpperCase(Trim(s));
  if (t = 'L') or (t = 'LEIDO') or (t = 'LEÍDO') or (t = 'READ') then
    Exit(ejL);
  if (t = 'ELIMINADO') or (t = 'ELIM') or (t = 'DELETED') then
    Exit(ejEliminado);
  Result := ejNL;
end;

function FormatoFechaOK(const s: String): Boolean;
begin
  Result := (Length(s) >= 10) and ((Pos('/', s) > 0) or (Pos('-', s) > 0));
end;

function AFecha(const s: String): String;
var
  y, m, d, hh, nn: Word;
begin
  if (Length(s) >= 16) and (Pos('-', s) = 5) then
  begin
    try
      y  := StrToInt(Copy(s,1,4));
      m  := StrToInt(Copy(s,6,2));
      d  := StrToInt(Copy(s,9,2));
      hh := StrToIntDef(Copy(s,12,2), 0);
      nn := StrToIntDef(Copy(s,15,2), 0);
      Exit(Format('%.2d/%.2d/%.4d %.2d:%.2d', [d,m,y,hh,nn]));
    except
    end;
  end;
  if s <> '' then Result := s
  else Result := FormatDateTime('dd/mm/yyyy hh:nn', Now);
end;

procedure CargaMasivaCorreosDesdeJSON(const FileName: String; out agregados, rechazados: Integer; log: TStrings);
var
  FS: TFileStream;
  Parser: TJSONParser;
  Root: TJSONData;
  Arr: TJSONArray;
  Obj: TJSONObject;
  i, id: Integer;
  para, de, asunto, mensaje, fecha: String;
  estadoStr, estadoS: String;
  estadoJSON: TEstadoJSON;
  programado: Boolean;
  pb: PBandeja;
  pUser: PUsuario;
  c: PCorreo;
  info: TCorreoInfo;
begin
  agregados := 0; rechazados := 0;
  if Assigned(log) then log.Clear;

  if not FileExists(FileName) then
    raise Exception.Create('No existe el archivo: ' + FileName);

  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Parser := TJSONParser.Create(FS);
    try
      Root := Parser.Parse;
    finally
      Parser.Free;
    end;
  finally
    FS.Free;
  end;

  if Root.JSONType = jtArray then
    Arr := TJSONArray(Root)
  else if (Root.JSONType = jtObject) and (TJSONObject(Root).Find('correos') <> nil) then
    Arr := TJSONObject(Root).Arrays['correos']
  else
    raise Exception.Create('Formato JSON no reconocido');

  for i := 0 to Arr.Count - 1 do
  begin
    if Arr.Items[i].JSONType <> jtObject then
      Continue;
    Obj := Arr.Objects[i];

    para       := GetStrAny(Obj, ['para','destinatario','to']);
    de         := GetStrAny(Obj, ['de','remitente','from']);
    asunto     := GetStrAny(Obj, ['asunto','subject']);
    mensaje    := GetStrAny(Obj, ['mensaje','message','body']);
    fecha      := GetStrAny(Obj, ['fecha','date']);
    estadoStr  := GetStrAny(Obj, ['estado','status'], 'NL');
    programado := GetBoolAny(Obj, ['programado','scheduled'], False);
    id         := GetIntAny(Obj, ['id','ID'], Random(100000));

    if (para='') or (de='') or (asunto='') or (mensaje='') then
    begin
      Inc(rechazados);
      if Assigned(log) then log.Add(Format('Registro %d: campos obligatorios vacíos → rechazado.', [i+1]));
      Continue;
    end;

    if (not EmailValido(para)) or (not EmailValido(de)) then
    begin
      Inc(rechazados);
      if Assigned(log) then log.Add(Format('Registro %d: email inválido (para/de) → rechazado.', [i+1]));
      Continue;
    end;

    pUser := BuscarUsuarioPorCorreo(para);
    if pUser = nil then
    begin
      Inc(rechazados);
      if Assigned(log) then log.Add(Format('Registro %d: destinatario "%s" no existe → rechazado.', [i+1, para]));
      Continue;
    end;

    pb := ObtenerBandejaPtr(para);
    if (pb <> nil) and (BuscarCorreo(pb^, id) <> nil) then
    begin
      Inc(rechazados);
      if Assigned(log) then log.Add(Format('Registro %d: ID repetido (%d) → rechazado.', [i+1, id]));
      Continue;
    end;

    if not FormatoFechaOK(fecha) then
      fecha := '';

    estadoJSON := ClasificaEstadoJSON(estadoStr);

    case estadoJSON of
      ejNL, ejL:
      begin
        if estadoJSON = ejL then estadoS := 'L' else estadoS := 'NL';

        EntregarCorreoA(
          para,
          de,
          asunto,
          AFecha(fecha),
          mensaje,
          id,
          estadoS,
          programado
        );
        Inc(agregados);
        if Assigned(log) then
          log.Add(Format('Registro %d: entregado a %s (ID=%d, estado=%s).', [
            i+1, para, id, estadoS
          ]));
      end;

      ejEliminado:
      begin
        EntregarCorreoA(
          para,
          de,
          asunto,
          AFecha(fecha),
          mensaje,
          id,
          programado
        );

        pb := ObtenerBandejaPtr(para);
        c  := nil;
        if pb <> nil then c := BuscarCorreo(pb^, id);

        if c <> nil then
        begin
          info := CorreoToInfo(c);
          PushCorreo(PapeleraGlobal, info);
          EliminarCorreo(pb^, id);
          Inc(agregados);
          if Assigned(log) then
            log.Add(Format('Registro %d: enviado DIRECTO a Papelera (dest=%s, ID=%d).', [i+1, para, id]));
        end
        else
        begin
          Inc(rechazados);
          if Assigned(log) then
            log.Add(Format('Registro %d: no se pudo mover a Papelera (ID=%d).', [i+1, id]));
        end;
      end;
    end;
  end;

  Root.Free;
end;

end.

