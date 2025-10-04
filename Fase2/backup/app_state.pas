unit app_state;

{$mode ObjFPC}{$H+}

interface

uses
  avl_borradores, bst_contactos, btree_favoritos, bst_comunidades;

var
  BorradoresAVL: PAVL_Borr;
  DraftSeq: Integer;
  ContactosBST: PBST;
  FavoritosBTree: PBNode;
  ComunidadesBST: PBSTC;

procedure AppStateInit;
function  NextDraftId: Integer;

implementation

procedure AppStateInit;
begin
  BAVL_Init(BorradoresAVL);
  DraftSeq := 0;
  BST_Init(ContactosBST);
  BFav_Init(FavoritosBTree);
  BSTC_Init(ComunidadesBST);
end;

function NextDraftId: Integer;
begin
  Inc(DraftSeq);
  Result := DraftSeq;
end;

end.
