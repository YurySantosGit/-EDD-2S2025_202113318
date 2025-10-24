unit lzw_comp;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TCode = Word;
  TCodeArray = array of TCode;

  TDictionary = array of AnsiString;

  TCompresorLZW = class
  public
    procedure Inicializar(var dict: TDictionary);
    function  Buscar(const dict: TDictionary; const cadena: AnsiString): Integer;
    procedure Agregar(var dict: TDictionary; const cadena: AnsiString);
    function  Comprimir(const texto: AnsiString): TCodeArray;
    function  Descomprimir(const codigos: TCodeArray): AnsiString;
  end;

procedure LZW_SaveCodesAsBin(const codes: TCodeArray; const filePath: string);

implementation

procedure TCompresorLZW.Inicializar(var dict: TDictionary);
var
  i: Integer;
begin
  SetLength(dict, 256);
  for i := 0 to 255 do
    dict[i] := AnsiChar(i);
end;

function TCompresorLZW.Buscar(const dict: TDictionary; const cadena: AnsiString): Integer;
var
  i: Integer;
begin
  for i := 0 to High(dict) do
    if dict[i] = cadena then Exit(i);
  Result := -1;
end;

procedure TCompresorLZW.Agregar(var dict: TDictionary; const cadena: AnsiString);
begin
  SetLength(dict, Length(dict) + 1);
  dict[High(dict)] := cadena;
end;

function TCompresorLZW.Comprimir(const texto: AnsiString): TCodeArray;
var
  dict: TDictionary;
  entrada: AnsiString;
  c: AnsiChar;
  codigo, i: Integer;
  nextCode: Integer;
begin
  Inicializar(dict);
  nextCode := 256;
  SetLength(Result, 0);
  entrada := '';

  for i := 1 to Length(texto) do
  begin
    c := texto[i];
    codigo := Buscar(dict, entrada + c);
    if codigo <> -1 then
      entrada := entrada + c
    else
    begin
      codigo := Buscar(dict, entrada);
      if codigo <> -1 then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := codigo;
        if nextCode < 65536 then
        begin
          Agregar(dict, entrada + c);
          Inc(nextCode);
        end;
      end;
      entrada := c;
    end;
  end;

  if entrada <> '' then
  begin
    codigo := Buscar(dict, entrada);
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := codigo;
  end;
end;

function TCompresorLZW.Descomprimir(const codigos: TCodeArray): AnsiString;
var
  dict: TDictionary;
  anterior, actual: AnsiString;
  i: Integer;
  nextCode: Integer;
  code: TCode;
begin
  Result := '';
  if Length(codigos) = 0 then Exit;

  Inicializar(dict);
  nextCode := 256;

  anterior := dict[codigos[0]];
  Result := anterior;

  for i := 1 to High(codigos) do
  begin
    code := codigos[i];
    if code < Length(dict) then
      actual := dict[code]
    else if code = nextCode then
      actual := anterior + anterior[1]
    else
      raise Exception.Create('Código inválido en descompresión');

    Result := Result + actual;

    if nextCode < 65536 then
    begin
      Agregar(dict, anterior + actual[1]);
      Inc(nextCode);
    end;

    anterior := actual;
  end;
end;

procedure LZW_SaveCodesAsBin(const codes: TCodeArray; const filePath: string);
var
  f: File of Word;
  i: Integer;
begin
  AssignFile(f, filePath);
  Rewrite(f);
  try
    for i := 0 to High(codes) do
      Write(f, codes[i]);
  finally
    CloseFile(f);
  end;
end;

end.
