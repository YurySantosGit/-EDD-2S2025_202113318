unit grafo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs;

type
  { TEdge: arista hacia un vecino, con peso opcional }
  TEdge = class
  public
    Neighbor: Integer;     // índice de la ciudad vecina en FCities
    HasWeight: Boolean;    // true si hay peso
    Weight: Integer;       // valor del peso (p. ej. distancia)
  end;

  { TUndirectedGraph: grafo no dirigido con lista de adyacencia }
  TUndirectedGraph = class
  private
    FCities: TStringList;           // nombres de ciudades
    FAdj: array of TObjectList;     // por cada ciudad, lista de TEdge
    function GetCityIndex(const Name: string): Integer;
    function EnsureCity(const Name: string): Integer;
    function FindEdgeIdx(const FromIdx, ToIdx: Integer): Integer;
    procedure EnsureAdjSize(NewSize: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    function AddCity(const Name: string): Integer;
    procedure AddConnection(const CityA, CityB: string); overload; // sin peso
    procedure AddConnection(const CityA, CityB: string; const Weight: Integer); overload; // con peso
    procedure PrintAdjacency;
    procedure ExportDOT(const FileName: string);

    // utilidades
    function CityCount: Integer;
    function CityName(Index: Integer): string;
  end;

implementation

{ TUndirectedGraph }

constructor TUndirectedGraph.Create;
begin
  inherited Create;
  FCities := TStringList.Create;
  FCities.Sorted := True;           // para búsquedas rápidas
  FCities.Duplicates := dupIgnore;  // no permitir nombres duplicados
  SetLength(FAdj, 0);
end;

destructor TUndirectedGraph.Destroy;
var
  i: Integer;
begin
  for i := Low(FAdj) to High(FAdj) do
  begin
    if Assigned(FAdj[i]) then
    begin
      FAdj[i].Free; // TObjectList OwnsObjects = True por defecto en FPC? -> Aseguramos nosotros:
    end;
  end;
  FCities.Free;
  inherited Destroy;
end;

procedure TUndirectedGraph.EnsureAdjSize(NewSize: Integer);
var
  OldSize, i: Integer;
begin
  OldSize := Length(FAdj);
  if NewSize <= OldSize then Exit;
  SetLength(FAdj, NewSize);
  for i := OldSize to NewSize - 1 do
  begin
    FAdj[i] := TObjectList.Create(True); // OwnsObjects = True -> libera TEdge automáticamente
  end;
end;

function TUndirectedGraph.GetCityIndex(const Name: string): Integer;
begin
  if not FCities.Find(Name, Result) then
    Result := -1;
end;

function TUndirectedGraph.EnsureCity(const Name: string): Integer;
var
  idx: Integer;
begin
  idx := GetCityIndex(Name);
  if idx = -1 then
  begin
    FCities.Add(Name);
    // OJO: al estar Sorted=True, el índice final puede no ser al final; volvemos a buscar
    FCities.Find(Name, idx);
    EnsureAdjSize(FCities.Count);
  end;
  Result := idx;
end;

function TUndirectedGraph.FindEdgeIdx(const FromIdx, ToIdx: Integer): Integer;
var
  i: Integer;
  e: TEdge;
begin
  Result := -1;
  if (FromIdx < 0) or (FromIdx >= Length(FAdj)) then Exit;
  for i := 0 to FAdj[FromIdx].Count - 1 do
  begin
    e := TEdge(FAdj[FromIdx][i]);
    if e.Neighbor = ToIdx then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TUndirectedGraph.AddCity(const Name: string): Integer;
begin
  Result := EnsureCity(Name);
end;

procedure TUndirectedGraph.AddConnection(const CityA, CityB: string);
begin
  AddConnection(CityA, CityB, 0);
  // dentro usamos HasWeight := False si se invoca sin peso
end;

procedure TUndirectedGraph.AddConnection(const CityA, CityB: string; const Weight: Integer);
var
  aIdx, bIdx, posAB, posBA: Integer;
  e: TEdge;
begin
  aIdx := EnsureCity(CityA);
  bIdx := EnsureCity(CityB);

  if aIdx = bIdx then Exit; // opcional: ignorar lazos A--A si no se desean

  // A -> B
  posAB := FindEdgeIdx(aIdx, bIdx);
  if posAB = -1 then
  begin
    e := TEdge.Create;
    e.Neighbor := bIdx;
    if Weight = 0 then
      e.HasWeight := False
    else
    begin
      e.HasWeight := True;
      e.Weight := Weight;
    end;
    FAdj[aIdx].Add(e);
  end
  else
  begin
    // si ya existe, actualizamos peso si viene con peso
    e := TEdge(FAdj[aIdx][posAB]);
    if Weight <> 0 then
    begin
      e.HasWeight := True;
      e.Weight := Weight;
    end;
  end;

  // B -> A (no dirigido -> duplicamos)
  posBA := FindEdgeIdx(bIdx, aIdx);
  if posBA = -1 then
  begin
    e := TEdge.Create;
    e.Neighbor := aIdx;
    if Weight = 0 then
      e.HasWeight := False
    else
    begin
      e.HasWeight := True;
      e.Weight := Weight;
    end;
    FAdj[bIdx].Add(e);
  end
  else
  begin
    e := TEdge(FAdj[bIdx][posBA]);
    if Weight <> 0 then
    begin
      e.HasWeight := True;
      e.Weight := Weight;
    end;
  end;
end;

procedure TUndirectedGraph.PrintAdjacency;
var
  i, j: Integer;
  e: TEdge;
  line: String;
begin
  for i := 0 to FCities.Count - 1 do
  begin
    line := FCities[i] + ': ';
    for j := 0 to FAdj[i].Count - 1 do
    begin
      e := TEdge(FAdj[i][j]);
      if j > 0 then line += ', ';
      line += FCities[e.Neighbor];
      if e.HasWeight then
        line += Format('(%d)', [e.Weight]);
    end;
    WriteLn(line);
  end;
end;

procedure TUndirectedGraph.ExportDOT(const FileName: string);
var
  sl, printed: TStringList;
  i, j: Integer;
  e: TEdge;
  aName, bName, key: string;
begin
  sl := TStringList.Create;
  printed := TStringList.Create;
  try
    printed.Sorted := True;
    printed.Duplicates := dupIgnore;

    sl.Add('graph G {');
    sl.Add('  node [shape=circle];');

    // Aseguramos que todos los nodos aparezcan aunque no tengan aristas
    for i := 0 to FCities.Count - 1 do
      sl.Add(Format('  "%s";', [FCities[i]]));

    // Para no duplicar aristas en DOT, imprimimos solo cuando (minIdx, maxIdx) no se haya impreso
    for i := 0 to FCities.Count - 1 do
    begin
      aName := FCities[i];
      for j := 0 to FAdj[i].Count - 1 do
      begin
        e := TEdge(FAdj[i][j]);
        // clave ordenada por índice
        if i < e.Neighbor then
          key := IntToStr(i) + '#' + IntToStr(e.Neighbor)
        else
          key := IntToStr(e.Neighbor) + '#' + IntToStr(i);

        if printed.IndexOf(key) = -1 then
        begin
          printed.Add(key);
          bName := FCities[e.Neighbor];
          if e.HasWeight then
            sl.Add(Format('  "%s" -- "%s" [label="%d"];', [aName, bName, e.Weight]))
          else
            sl.Add(Format('  "%s" -- "%s";', [aName, bName]));
        end;
      end;
    end;

    sl.Add('}');
    sl.SaveToFile(FileName);
  finally
    printed.Free;
    sl.Free;
  end;
end;

function TUndirectedGraph.CityCount: Integer;
begin
  Result := FCities.Count;
end;

function TUndirectedGraph.CityName(Index: Integer): string;
begin
  Result := FCities[Index];
end;

end.
