unit app_state;

{$mode ObjFPC}{$H+}

interface

uses
  avl_borradores;

var
  BorradoresAVL: PAVL_Borr;
  DraftSeq: Integer;

procedure AppStateInit;
function  NextDraftId: Integer;

implementation

procedure AppStateInit;
begin
  BAVL_Init(BorradoresAVL);
  DraftSeq := 0;
end;

function NextDraftId: Integer;
begin
  Inc(DraftSeq);
  Result := DraftSeq;
end;

end.
