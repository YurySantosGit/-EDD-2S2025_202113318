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
  pila_papelera, form_papelera, cola_correos, form_programarcorreo,
  form_correosprogramados, form_registro, contactos, form_contactos,
  form_agregar_contacto, form_enviarcorreo, bandejas, form_perfil,
  reportes_root, reportes_usuario, comunidades, form_comunidades,
  reportes_comunidades, avl_borradores, app_state, form_borradores,
  bst_contactos, btree_favoritos, form_favoritos, carga_masiva_correos,
  bst_comunidades, form_comunidades_bst, form_mensaje_comunidad,
  FormMensajesComunidadesRoot, reportes_comunidades_bst, form_control_logueo,
  merkle_favoritos, form_favoritos_merkle, form_mi_logueo, blockchain,
grafo_correos;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  AppStateInit;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormRoot, FormRoot);
  Application.CreateForm(TFormUsuario, FormUsuario);
  Application.CreateForm(TFormBandeja, FormBandeja);
  Application.CreateForm(TFormPapelera, FormPapelera);
  Application.CreateForm(TFormProgramarCorreo, FormProgramarCorreo);
  Application.CreateForm(TFormCorreosProgramados, FormCorreosProgramados);
  Application.CreateForm(TFormRegistro, FormRegistro);
  Application.CreateForm(TFormContactos, FormContactos);
  Application.CreateForm(TFormAgregarContacto, FormAgregarContacto);
  Application.CreateForm(TFormEnviarCorreo, FormEnviarCorreo);
  Application.CreateForm(TFormPerfil, FormPerfil);
  Application.CreateForm(TFormComunidades, FormComunidades);
  Application.CreateForm(TFormBorradores, FormBorradores);
  Application.CreateForm(TFormFavoritos, FormFavoritos);
  Application.CreateForm(TFormComunidadesBST, FormComunidadesBST);
  Application.CreateForm(TFormMensajeComunidad, FormMensajeComunidad);
  Application.CreateForm(TFormVerMensajes, FormVerMensajes);
  Application.CreateForm(TFormControlLogueo, FormControlLogueo);
  Application.CreateForm(TFormFavoritosMerkle, FormFavoritosMerkle);
  Application.CreateForm(TFormMiLogueo, FormMiLogueo);
  Application.Run;
end.

