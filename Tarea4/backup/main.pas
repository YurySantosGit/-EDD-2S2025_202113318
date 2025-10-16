unit main;

program UndirectedGraphDemo;

{$mode objfpc}{$H+}

uses
  SysUtils, undirected_graph;

procedure Menu;
begin
  WriteLn('==================== Grafo No Dirigido ====================');
  WriteLn('1) Agregar ciudad');
  WriteLn('2) Agregar conexion');
  WriteLn('3) Mostrar lista de adyacencia');
  WriteLn('4) Exportar a DOT (Graphviz)');
  WriteLn('0) Salir');
  Write('Selecciona una opcion: ');
end;

var
  G: TUndirectedGraph;
  op: Integer;
  a, b, outDot: String;

begin
  G := TUndirectedGraph.Create;
  try
    repeat
      Menu;
      ReadLn(op);
      case op of
        1:
          begin
            Write('Nombre de la ciudad: ');
            ReadLn(a);
            G.AddCity(a);
            WriteLn('OK');
          end;
        2:
          begin
            Write('Ciudad A: '); ReadLn(a);
            Write('Ciudad B: '); ReadLn(b);
            G.AddConnection(a, b);
            WriteLn('OK');
          end;
        3:
          begin
            WriteLn;
            G.PrintAdjacency;
            WriteLn;
          end;
        4:
          begin
            Write('Nombre de archivo DOT: ');
            ReadLn(outDot);
            if Trim(outDot) = '' then outDot := 'grafo.dot';
            G.ExportDOT(outDot);
            WriteLn('DOT: ', outDot);
          end;
      end;
      WriteLn;
    until op = 0;
  finally
    G.Free;
  end;
end.
