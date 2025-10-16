unit grafo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs;

type
  TEdge = class
  public
    Neighbor: Integer;
  end;

  TUndirectedGraph = class
  private
    FCities: TStringList;
    FAdj: array of TObjectList;
    function GetCityIndex(const Name: string): Integer;
    function EnsureCity(const Name: string): Integer;
    function FindEdgeIdx(const FromIdx, ToIdx: Integer): Integer;
    procedure EnsureAdjSize(NewSize: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function AddCity(const Name: string): Integer;
    procedure AddConnection(const CityA, CityB: string);
    procedure PrintAdjacency;
    procedure ExportDOT(const FileName: string);
    function CityCount: Integer;
    function CityName(Index: Integer): string;
  end;

implementation

constructor TUndirectedGraph.Create;
begin
  inherited Create;
  FCities := TStringList.Create;
  FCities.Sorted := True;
  FCities.Duplicates := dupIgnore;
  SetLength(FAdj, 0);
end;

destructor TUndirectedGraph.Destroy;
var
  i: Integer;
begin
  for i := Low(FAdj) to High(FAdj) do
    if Assigned(FAdj[i]) then
      FAdj[i].Free;
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
    FAdj[i] := TObjectList.Create(True);
end;

function TUndirectedGraph.GetCityIndex(const Name: string): Integer;
begin
  if not FCities.Find(Name, Result) then
    Result := -1;
end;

function TUndirectedGraph.EnsureCity(const Name: string): Integer;
begin
  Result := GetCityIndex(Name);
  if Result = -1 then
  begin
    FCities.Add(Name);
    FCities.Find(Name, Result);
    EnsureAdjSize(FCities.Count);
  end;
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
var
  aIdx, bIdx: Integer;
  posAB, posBA: Integer;
  e: TEdge;
begin
  aIdx := EnsureCity(CityA);
  bIdx := EnsureCity(CityB);
  if aIdx = bIdx then Exit;

  posAB := FindEdgeIdx(aIdx, bIdx);
  if posAB = -1 then
  begin
    e := TEdge.Create;
    e.Neighbor := bIdx;
    FAdj[aIdx].Add(e);
  end;

  posBA := FindEdgeIdx(bIdx, aIdx);
  if posBA = -1 then
  begin
    e := TEdge.Create;
    e.Neighbor := aIdx;
    FAdj[bIdx].Add(e);
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

    for i := 0 to FCities.Count - 1 do
      sl.Add(Format('  "%s";', [FCities[i]]));

    for i := 0 to FCities.Count - 1 do
    begin
      aName := FCities[i];
      for j := 0 to FAdj[i].Count - 1 do
      begin
        e := TEdge(FAdj[i][j]);
        if i < e.Neighbor then
          key := IntToStr(i) + '#' + IntToStr(e.Neighbor)
        else
          key := IntToStr(e.Neighbor) + '#' + IntToStr(i);
        if printed.IndexOf(key) = -1 then
        begin
          printed.Add(key);
          bName := FCities[e.Neighbor];
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
