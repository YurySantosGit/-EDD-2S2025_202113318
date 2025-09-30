unit form_contactos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormContactos }

  TFormContactos = class(TForm)
    LblPos: TLabel;
    LblTelefono: TLabel;
    LblEmail: TLabel;
    LblNombre: TLabel;
    LblTitulo: TLabel;
  private

  public

  end;

var
  FormContactos: TFormContactos;

implementation

{$R *.lfm}

end.

