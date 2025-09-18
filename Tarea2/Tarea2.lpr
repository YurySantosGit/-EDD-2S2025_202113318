program Tarea2;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, crt, fpjson, jsonparser;

type
  // Nodo
  PTnode = ^Tnode;
  Tnode = record
    ID: Integer;
    right: PTnode;
    left: PTnode;
  end;

  // Árbol
  Tree = class
  private
    procedure recursive(curr: PTnode; newNode: PTnode);
    procedure inOrderRecursive(curr: PTnode);
    procedure preOrderRecursive(curr: PTnode);
    procedure postOrderRecursive(curr: PTnode);
    procedure dotRecursive(curr: PTnode; var sl: TStringList);
  public
    root: PTnode;

    constructor Create;
    destructor Destroy; override;

    procedure Agregar(id: Integer);
    function Buscar(id: Integer): Boolean;

    // Recorridos
    procedure RecorridoInOrder;
    procedure RecorridoPreOrder;
    procedure RecorridoPostOrder;

    // Liberación
    procedure LiberarArbol(nodo: PTnode);

    // Graphviz
    procedure GuardarDOT(const FileName: string);
  end;

// ============== Implementación Tree ==============

constructor Tree.Create;
begin
  root := nil;
end;

destructor Tree.Destroy;
begin
  LiberarArbol(root);
  inherited Destroy;
end;

procedure Tree.LiberarArbol(nodo: PTnode);
begin
  if nodo <> nil then
  begin
    LiberarArbol(nodo^.left);
    LiberarArbol(nodo^.right);
    Dispose(nodo);
  end;
end;

procedure Tree.Agregar(id: Integer);
var
  node: PTnode;
begin
  New(node);
  node^.ID := id;
  node^.right := nil;
  node^.left := nil;

  if root = nil then
    root := node
  else
    recursive(root, node);
end;

procedure Tree.recursive(curr: PTnode; newNode: PTnode);
begin
  if newNode^.ID < curr^.ID then
  begin
    if curr^.left <> nil then
      recursive(curr^.left, newNode)
    else
      curr^.left := newNode;
  end
  else if newNode^.ID > curr^.ID then
  begin
    if curr^.right <> nil then
      recursive(curr^.right, newNode)
    else
      curr^.right := newNode;
  end
  else
  begin
    Writeln('El valor ', newNode^.ID, ' ya esta en el arbol (duplicado). Se ignora.');
    Dispose(newNode);
  end;
end;

function Tree.Buscar(id: Integer): Boolean;
var
  actual: PTnode;
begin
  actual := root;
  while actual <> nil do
  begin
    if id = actual^.ID then Exit(True)
    else if id < actual^.ID then actual := actual^.left
    else actual := actual^.right;
  end;
  Result := False;
end;

procedure Tree.RecorridoInOrder;
begin
  inOrderRecursive(root);
end;

procedure Tree.inOrderRecursive(curr: PTnode);
begin
  if curr = nil then Exit;
  inOrderRecursive(curr^.left);
  Writeln('Nodo: ', curr^.ID);
  inOrderRecursive(curr^.right);
end;

procedure Tree.RecorridoPreOrder;
begin
  preOrderRecursive(root);
end;

procedure Tree.preOrderRecursive(curr: PTnode);
begin
  if curr = nil then Exit;
  Writeln('Nodo: ', curr^.ID);
  preOrderRecursive(curr^.left);
  preOrderRecursive(curr^.right);
end;

procedure Tree.RecorridoPostOrder;
begin
  postOrderRecursive(root);
end;

procedure Tree.postOrderRecursive(curr: PTnode);
begin
  if curr = nil then Exit;
  postOrderRecursive(curr^.left);
  postOrderRecursive(curr^.right);
  Writeln('Nodo: ', curr^.ID);
end;

// ---- Graphviz ----
// Crea líneas "  ID;" para nodos y "  ID -> hijo;" para conexiones
procedure Tree.dotRecursive(curr: PTnode; var sl: TStringList);
begin
  if curr = nil then Exit;

  // Asegurar declaración de nodo
  sl.Add('  ' + IntToStr(curr^.ID) + ';');

  // Conexión izquierda
  if curr^.left <> nil then
    sl.Add(Format('  %d -> %d;', [curr^.ID, curr^.left^.ID]));

  // Conexión derecha
  if curr^.right <> nil then
    sl.Add(Format('  %d -> %d;', [curr^.ID, curr^.right^.ID]));

  dotRecursive(curr^.left, sl);
  dotRecursive(curr^.right, sl);
end;

procedure Tree.GuardarDOT(const FileName: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Add('digraph BST {');
    sl.Add('  node [shape=circle];');
    sl.Add('  rankdir=TB;'); // de arriba hacia abajo

    if root <> nil then
      dotRecursive(root, sl)
    else
      sl.Add('  // Arbol vacio');

    sl.Add('}');
    sl.SaveToFile(FileName);
  finally
    sl.Free;
  end;
end;

// ============== Utilidades JSON ==============

procedure CargarDesdeJSONYInsertar(const JSONPath: string; ATree: Tree);
var
  JSONStr: TStringList;
  Data: TJSONData;
  Arr: TJSONArray;
  i: Integer;
  obj: TJSONObject;
  idValue: TJSONData;
begin
  if not FileExists(JSONPath) then
    raise Exception.Create('No se encontro el archivo: ' + JSONPath);

  JSONStr := TStringList.Create;
  try
    JSONStr.LoadFromFile(JSONPath);
    Data := GetJSON(JSONStr.Text);
    try
      if not (Data.JSONType = jtArray) then
        raise Exception.Create('El JSON debe ser un arreglo de objetos');

      Arr := TJSONArray(Data);
      for i := 0 to Arr.Count - 1 do
      begin
        if Arr.Items[i].JSONType = jtObject then
        begin
          obj := TJSONObject(Arr.Items[i]);
          // Busca la clave 'id' (en minúsculas, como en tu archivo)
          idValue := obj.Find('id');
          if (idValue <> nil) and (idValue.JSONType = jtNumber) then
            ATree.Agregar(idValue.AsInteger)
          else
            Writeln('Objeto #', i, ' no contiene "id" numerico. Se omite.');
        end
        else
          Writeln('Elemento #', i, ' no es objeto. Se omite.');
      end;
    finally
      Data.Free;
    end;
  finally
    JSONStr.Free;
  end;
end;

// ============== Programa principal ==============

var
  miArbol: Tree;
  rutaJSON: string;
  rutaDOT: string;
begin
  miArbol := Tree.Create;
  try
    // Ajusta la ruta si es necesario. Si el JSON está junto al .exe, basta 'datos.json'
    rutaJSON := 'datos.json';   // <- cambia si lo ejecutas desde otra carpeta
    rutaDOT  := 'bst.dot';

    // Cargar JSON e insertar por ID
    Writeln('Cargando: ', rutaJSON);
    CargarDesdeJSONYInsertar(rutaJSON, miArbol);

    // Mostrar recorridos (opcional)
    Writeln(#10, 'Recorrido InOrder:');
    miArbol.RecorridoInOrder;

    Writeln(#10, 'Recorrido PreOrder:');
    miArbol.RecorridoPreOrder;

    Writeln(#10, 'Recorrido PostOrder:');
    miArbol.RecorridoPostOrder;

    // Guardar Graphviz DOT
    miArbol.GuardarDOT(rutaDOT);
    Writeln(#10, 'Archivo DOT generado: ', rutaDOT);
    Writeln('Para generar PNG: dot -Tpng bst.dot -o bst.png');

    Writeln(#10, 'Presiona una tecla para finalizar...');
    ReadKey;
  finally
    miArbol.Free;
  end;
end.

