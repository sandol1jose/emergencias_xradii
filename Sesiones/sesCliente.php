<?php
//Archivo para crear la seseión de nuestro usuario
function CrearSesion($IDUsuario, $Nombre, $Correo, $Rol){
	if (session_status() == PHP_SESSION_NONE) {
		session_start();//inicio de sesion
	}
	
	$arrayUsuario = array(
			'IDUsuario'=>$IDUsuario,
			'Nombre'=>$Nombre,
			'Correo'=>$Correo,
			'Rol'=>$Rol
	);
	$_SESSION['Usuario'] = $arrayUsuario;
}
?>