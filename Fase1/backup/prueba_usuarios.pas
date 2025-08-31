unit prueba_usuarios;

{$mode objfpc}{$H+}

uses
  SysUtils, usuarios;

begin
  // Inicializar lista vacía
  InicializarUsuarios;

  // Crear usuario root
  AgregarUsuario(0, 'Administrador', 'root', 'root@edd.com', '00000000', 'root123');

  // Cargar desde archivo JSON
  CargarUsuariosDesdeJSON('usuarios.json');

  // Mostrar todos los usuarios cargados
  MostrarUsuarios;

  writeln;
  writeln('Prueba de login:');

  // Probar búsqueda de root
  if BuscarUsuarioPorEmail('root@edd.com', 'root123') <> nil then
    writeln('Login root correcto ✅')
  else
    writeln('Login root falló ❌');

  // Probar búsqueda de un usuario del JSON
  if BuscarUsuarioPorEmail('lgarcia@edd.com', 'lgarcia123') <> nil then
    writeln('Login Luis Garcia correcto ✅')
  else
    writeln('Login Luis Garcia falló ❌');

  readln; // Pausa antes de cerrar
end.
