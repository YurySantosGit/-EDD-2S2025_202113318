unit reportes_comunidades_bst;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Process, FileUtil,
  bst_comunidades, app_state;

procedure GenerarReporteComunidadesBSTPorEmail(const UsuarioEmail: String);

implementation

procedure GenerarReporteComunidadesBSTPorEmail(const UsuarioEmail: String);
var
  usuarioCarp, dirU, dotFile, pngFile, dotPath: String;
  P: TProcess;
begin
  if Trim(UsuarioEmail) = '' then Exit;

  usuarioCarp := Copy(UsuarioEmail, 1, Pos('@', UsuarioEmail) - 1);
  if usuarioCarp = '' then usuarioCarp := 'usuario';
  dirU := usuarioCarp + '-Reportes' + DirectorySeparator;
  ForceDirectories(dirU);

  dotFile := dirU + 'comunidades_bst.dot';
  pngFile := dirU + 'comunidades_bst.png';

  BSTC_ToDOT(ComunidadesBST, dotFile);

  dotPath := FindDefaultExecutablePath({$IFDEF WINDOWS}'dot.exe'{$ELSE}'dot'{$ENDIF});
  if (dotPath = '') and FileExists('/usr/bin/dot') then dotPath := '/usr/bin/dot';
  if (dotPath = '') or (not FileExists(dotPath)) then Exit;

  P := TProcess.Create(nil);
  try
    P.Executable := dotPath;
    P.Parameters.Add('-Tpng');
    P.Parameters.Add(dotFile);
    P.Parameters.Add('-o');
    P.Parameters.Add(pngFile);
    P.Options := [poWaitOnExit];
    P.Execute;
  finally
    P.Free;
  end;
end;

end.
