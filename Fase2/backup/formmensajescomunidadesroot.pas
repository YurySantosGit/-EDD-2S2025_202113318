unit FormMensajesComunidadesRoot;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  app_state, bst_comunidades;

type

  { TFormVerMensajes }

  TFormVerMensajes = class(TForm)
    BtnRefrescar: TButton;
    BtnCerrar: TButton;
    MemoTodo: TMemo;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnRefrescarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure RenderAll;

  public

  end;

var
  FormVerMensajes: TFormVerMensajes;

implementation

{$R *.lfm}

{ TFormVerMensajes }

procedure TFormVerMensajes.FormShow(Sender: TObject);
begin
  RenderAll;
end;

procedure TFormVerMensajes.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormVerMensajes.BtnRefrescarClick(Sender: TObject);
begin
  RenderAll;
end;

procedure TFormVerMensajes.RenderAll;
  procedure DumpNode(N: PBSTC; SL: TStrings);
    var
      p: PMsg;
    begin
      if N = nil then Exit;

      DumpNode(N^.L, SL);

      SL.Add('==================================================');
      SL.Add(Format('Comunidad: %s', [N^.nombre]));
      SL.Add(Format('Fecha de creación: %s', [N^.fechaCreacion]));
      SL.Add(Format('Mensajes: %d', [N^.msgCount]));

      // Mensajes
      if N^.msgsHead = nil then
      begin
        SL.Add('— (sin mensajes) —');
      end
      else
      begin
        p := N^.msgsHead;
        while p <> nil do
        begin
          SL.Add(Format('%s | %s | %s', [p^.fecha, p^.correo, p^.mensaje]));
          p := p^.sig;
        end;
      end;
      SL.Add('');

      DumpNode(N^.R, SL);
    end;

  var
    SL: TStringList;
  begin
    MemoTodo.Lines.BeginUpdate;
    try
      MemoTodo.Clear;

      if ComunidadesBST = nil then
      begin
        MemoTodo.Lines.Add('No hay comunidades en el BST.');
        Exit;
      end;

      SL := TStringList.Create;
      try
        DumpNode(ComunidadesBST, SL);
        if SL.Count = 0 then
          SL.Add('No hay comunidades con mensajes.');
        MemoTodo.Lines.Assign(SL);
      finally
        SL.Free;
      end;
    finally
      MemoTodo.Lines.EndUpdate;
    end;
  end;

end.

