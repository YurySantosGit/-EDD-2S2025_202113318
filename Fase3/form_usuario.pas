unit form_usuario;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  form_bandeja, lista_doble, form_papelera, form_correosprogramados,
  form_programarcorreo, form_agregar_contacto, form_contactos, form_enviarcorreo,
  bandejas, form_perfil, reportes_usuario, form_borradores, app_state, avl_borradores,
  bst_contactos, btree_favoritos, form_favoritos, form_mensaje_comunidad,
  form_favoritos_merkle, merkle_favoritos;

type

  { TFormUsuario }

  TFormUsuario = class(TForm)
    BtnBandeja: TButton;
    BtnCerrarSesion: TButton;
    BtnEnviarCorreo: TButton;
    BtnPapelera: TButton;
    BtnProgramar: TButton;
    BtnBorradores: TButton;
    BtnFavoritos: TButton;
    BtnMensajeComunidad: TButton;
    BtnFavoritos_Merkle: TButton;
    Button5: TButton;
    Button6: TButton;
    BtnContactos: TButton;
    BtnActualizarPerfil: TButton;
    Button9: TButton;
    Label1: TLabel;
    procedure BtnActualizarPerfilClick(Sender: TObject);
    procedure BtnBorradoresClick(Sender: TObject);
    procedure BtnCerrarSesionClick(Sender: TObject);
    procedure BtnContactosClick(Sender: TObject);
    procedure BtnFavoritosClick(Sender: TObject);
    procedure BtnFavoritos_MerkleClick(Sender: TObject);
    procedure BtnMensajeComunidadClick(Sender: TObject);
    procedure BtnPapeleraClick(Sender: TObject);
    procedure BtnProgramarClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure BtnBandejaClick(Sender: TObject);
    procedure BtnEnviarCorreoClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  FormUsuario: TFormUsuario;

implementation

{$R *.lfm}

uses
  main, pila_papelera, cola_correos, contactos;

{ TFormUsuario }

procedure TFormUsuario.BtnBandejaClick(Sender: TObject);
var
  pB: ^TBandeja;
begin
  pB := ObtenerBandejaPtr(UsuarioActualEmail);
  FormBandeja := TFormBandeja.Create(Self);
  FormBandeja.CargarBandejaPtr(pB);
  FormBandeja.ShowModal;
end;

procedure TFormUsuario.Button10Click(Sender: TObject);
begin

end;

procedure TFormUsuario.BtnCerrarSesionClick(Sender: TObject);
begin
  Form1.Show;   // Mostrar login de nuevo
  Self.Close;   // Cerrar menú usuario
  RegistrarLogout(UsuarioActualEmail, FormatDateTime('dd/mm/yyyy hh:nn', Now));

end;

procedure TFormUsuario.BtnActualizarPerfilClick(Sender: TObject);
begin
  FormPerfil := TFormPerfil.Create(Self);
  FormPerfil.ShowModal;
end;

procedure TFormUsuario.BtnBorradoresClick(Sender: TObject);
begin
  if FormBorradores = nil then
    FormBorradores := TFormBorradores.Create(Self);
  FormBorradores.ShowModal;
end;

procedure TFormUsuario.BtnContactosClick(Sender: TObject);
begin
  FormContactos := TFormContactos.Create(Self);
  FormContactos.ShowModal;
end;

procedure TFormUsuario.BtnFavoritosClick(Sender: TObject);
begin
  if FormFavoritos = nil then
    FormFavoritos := TFormFavoritos.Create(Self);
  FormFavoritos.ShowModal;  // modal (recomendado)
end;

procedure TFormUsuario.BtnFavoritos_MerkleClick(Sender: TObject);
begin
  if FormFavoritosMerkle = nil then
    FormFavoritosMerkle := TFormFavoritosMerkle.Create(Self);
  FormFavoritosMerkle.ShowModal;
end;

procedure TFormUsuario.BtnMensajeComunidadClick(Sender: TObject);
begin
  if FormMensajeComunidad = nil then
    FormMensajeComunidad := TFormMensajeComunidad.Create(Self);
  FormMensajeComunidad.ShowModal;
end;

procedure TFormUsuario.BtnPapeleraClick(Sender: TObject);
begin
  FormPapelera := TFormPapelera.Create(Self);
  FormPapelera.ShowModal;
end;

procedure TFormUsuario.BtnProgramarClick(Sender: TObject);
begin
  FormProgramarCorreo := TFormProgramarCorreo.Create(Self);
  FormProgramarCorreo.ShowModal;
end;

procedure TFormUsuario.BtnEnviarCorreoClick(Sender: TObject);
begin
  FormEnviarCorreo := TFormEnviarCorreo.Create(Self);
  FormEnviarCorreo.ShowModal;
end;

procedure TFormUsuario.Button5Click(Sender: TObject);
begin
  FormCorreosProgramados := TFormCorreosProgramados.Create(Self);
  FormCorreosProgramados.ShowModal;
end;

procedure TFormUsuario.Button6Click(Sender: TObject);
begin
  FormAgregarContacto := TFormAgregarContacto.Create(Self);
  FormAgregarContacto.ShowModal;
end;

procedure TFormUsuario.Button9Click(Sender: TObject);
var usuarioCarp: string;
begin
  usuarioCarp := Copy(UsuarioActualEmail, 1, Pos('@', UsuarioActualEmail) - 1);
  if usuarioCarp = '' then usuarioCarp := 'usuario';

  GenerarReportesUsuarioPorEmail(UsuarioActualEmail);
  GenerarReporteBorradoresAVLPorEmail(UsuarioActualEmail);
  GenerarReporteContactosBSTPorEmail(UsuarioActualEmail);
  GenerarReporteFavoritosBTreePorEmail(UsuarioActualEmail);
  Merkle_RebuildAndReport(UsuarioActualEmail);

  ShowMessage('Reportes generados en "' + usuarioCarp + '-Reportes/".');
end;

procedure TFormUsuario.FormCreate(Sender: TObject);
begin

end;

end.

