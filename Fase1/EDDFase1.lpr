program EDDFase1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, usuarios, form_root, form_usuario, lista_doble, form_bandeja,
  pila_papelera, form_papelera
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormRoot, FormRoot);
  Application.CreateForm(TFormUsuario, FormUsuario);
  Application.CreateForm(TFormBandeja, FormBandeja);
  Application.CreateForm(TFormPapelera, FormPapelera);
  Application.Run;
end.

