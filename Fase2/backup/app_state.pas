unit app_state;

{$mode ObjFPC}{$H+}

interface

uses
  avl_borradores, bst_contactos;

var
  BorradoresAVL: PAVL_Borr;
  DraftSeq: Integer;
  ContactosBST: PBST;

procedure AppStateInit;
function  NextDraftId: Integer;

implementation

procedure AppStateInit;
begin
  BAVL_Init(BorradoresAVL);
  DraftSeq := 0;
  BST_Init(ContactosBST);
end;

function NextDraftId: Integer;
begin
  Inc(DraftSeq);
  Result := DraftSeq;
end;

end.
