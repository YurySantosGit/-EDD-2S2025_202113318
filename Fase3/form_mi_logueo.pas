unit form_mi_logueo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  app_state;

type

  { TFormMiLogueo }

  TFormMiLogueo = class(TForm)
    BtnRefrescar: TButton;
    BtnCerrar: TButton;
    MemoLog: TMemo;
    procedure BtnCerrarClick(Sender: TObject);
    procedure BtnRefrescarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure RenderMyLog;
  public
  end;

var
  FormMiLogueo: TFormMiLogueo;

implementation

{$R *.lfm}

uses
  StrUtils;

{ TFormMiLogueo }

procedure TFormMiLogueo.BtnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMiLogueo.BtnRefrescarClick(Sender: TObject);
begin
  RenderMyLog;
end;

procedure TFormMiLogueo.FormShow(Sender: TObject);
begin
  RenderMyLog;
end;

procedure TFormMiLogueo.RenderMyLog;
var
  i, n, shown: Integer;
  e: TLogEntry;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Clear;
    n := LoginLogCount;
    shown := 0;

    for i := 0 to n - 1 do
    begin
      e := GetLoginLog(i);
      if SameText(Trim(e.usuario), Trim(UsuarioActualEmail)) then
      begin
        Inc(shown);
        MemoLog.Lines.Add(Format('%d) %s', [shown, e.usuario]));
        MemoLog.Lines.Add('  Entrada: ' + e.entrada);
        MemoLog.Lines.Add('  Salida : ' + e.salida);
        MemoLog.Lines.Add('');
      end;
    end;

    if shown = 0 then
      MemoLog.Lines.Add('(sin registros de logueo para tu usuario)');
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

end.
