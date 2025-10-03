unit form_favoritos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  btree_favoritos, app_state, lista_doble, bandejas;

type
  { TFormFavoritos }
  TFormFavoritos = class(TForm)
    BtnCerrar: TButton;
    BtnEliminarPorID: TButton;
    BtnVerPorID: TButton;
    BtnRefrescar: TButton;
    EditID: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    LblCount: TLabel;
    MemoFav: TMemo;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnEliminarPorIDClick(Sender: TObject);
    procedure BtnRefrescarClick(Sender: TObject);
    procedure BtnVerPorIDClick(Sender: TObject);
    procedure EditIDChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    procedure ListarFavoritos;
    function  ParseID(out AID: Integer): Boolean;
    procedure RefreshInboxIfOpen;
  public
  end;

var
  FormFavoritos: TFormFavoritos;

implementation

{$R *.lfm}

uses
  reportes_usuario, form_bandeja, main;

var
  gFavSL: TStringList = nil;
  gFavCount: Integer = 0;

procedure AddLineGlobal(const F: TFavorito);
begin
  Inc(gFavCount);
  if Assigned(gFavSL) then
    gFavSL.Add(Format('%d | %s | %s | %s | %s', [
      F.id, F.remitente, F.estado, F.asunto, F.fecha
    ]));
end;

{ TFormFavoritos }

procedure TFormFavoritos.FormShow(Sender: TObject);
begin
  ListarFavoritos;
end;

procedure TFormFavoritos.BtnRefrescarClick(Sender: TObject);
begin
  ListarFavoritos;
end;

procedure TFormFavoritos.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormFavoritos.BtnVerPorIDClick(Sender: TObject);
var
  id: Integer;
  pB: PBandeja;
  C: PCorreo;
  F: TFavorito;
begin
  if not ParseID(id) then Exit;

  if BFav_Search(FavoritosBTree, id) = nil then
  begin
    ShowMessage('El ID no está en Favoritos.');
    Exit;
  end;

  pB := ObtenerBandejaPtr(UsuarioActualEmail);
  C := BuscarCorreo(pB^, id);
  if C = nil then
  begin
    ShowMessage('No se encontró el correo en tu bandeja.');
    Exit;
  end;

  ShowMessage('De: ' + C^.remitente + LineEnding +
              'Asunto: ' + C^.asunto + LineEnding +
              'Fecha: ' + C^.fecha + LineEnding +
              'Mensaje:' + LineEnding + C^.mensaje);

  C^.estado := 'L';

  F.id        := C^.id;
  F.remitente := C^.remitente;
  F.estado    := C^.estado;
  F.asunto    := C^.asunto;
  F.fecha     := C^.fecha;
  F.mensaje   := C^.mensaje;
  BFav_Insert(FavoritosBTree, F);

  RefreshInboxIfOpen;
  ListarFavoritos;
end;

procedure TFormFavoritos.BtnEliminarPorIDClick(Sender: TObject);
var
  id: Integer;
  pB: PBandeja;
  C: PCorreo;
begin
  if not ParseID(id) then Exit;

  if not BFav_Delete(FavoritosBTree, id) then
  begin
    ShowMessage('El ID no estaba en Favoritos.');
    Exit;
  end;

  pB := ObtenerBandejaPtr(UsuarioActualEmail);
  C := BuscarCorreo(pB^, id);
  if C <> nil then
    C^.favorito := False;

  ShowMessage('Eliminado de Favoritos.');

  RefreshInboxIfOpen;
  ListarFavoritos;
end;

function TFormFavoritos.ParseID(out AID: Integer): Boolean;
begin
  Result := TryStrToInt(Trim(EditID.Text), AID);
  if not Result then
    ShowMessage('Ingresa un ID válido.');
end;

procedure TFormFavoritos.RefreshInboxIfOpen;
var
  pB: PBandeja;
begin
  if Assigned(FormBandeja) then
  begin
    pB := ObtenerBandejaPtr(UsuarioActualEmail);
    FormBandeja.CargarBandejaPtr(pB);
  end;
end;

procedure TFormFavoritos.ListarFavoritos;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    gFavSL := SL;
    gFavCount := 0;

    BFav_InOrder(FavoritosBTree, @AddLineGlobal);
    MemoFav.Lines.Assign(SL);
    LblCount.Caption := 'Favoritos: ' + IntToStr(gFavCount);
  finally
    gFavSL := nil;
    SL.Free;
  end;
end;

procedure TFormFavoritos.EditIDChange(Sender: TObject);
begin
end;

procedure TFormFavoritos.FormCreate(Sender: TObject);
begin
end;

procedure TFormFavoritos.Label1Click(Sender: TObject);
begin
end;

end.
