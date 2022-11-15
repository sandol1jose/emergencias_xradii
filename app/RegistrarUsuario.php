<?php
//REGISTRO DEL USUARIO EN LA BASE DE DATOS
    session_start();
	include '../conexion.php';
	//include 'EnviarCorreo.php';

	$Nombres = $_POST["nombres"];
    $Apellidos = $_POST["apellidos"];
    $Rol = $_POST["rol"];
    $Correo = $_POST["correo"];
	$Correo = strtolower($Correo);//Convirtiendo todo el correo a minusculas

	//VERIFICAMOS QUE EL CORREO NO EXISTA EN LA BASE DE DATOS
	$sql = "SELECT u.id FROM usuarios u WHERE u.correo = '".$Correo."';";
	$sentencia = $base_de_datos->prepare($sql);
	$sentencia->execute(); 
	$registros = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$contUsuarios = count($registros);
	if($contUsuarios == 0){ //El correo no existe en nuestra base de datos

		$Pass = $_POST["pass"];
		$PassCifrada = password_hash($Pass, PASSWORD_DEFAULT); //Encriptando contraseñas
		$sentencia = $base_de_datos->prepare("CALL NuevoUsuario(?,?,?,?,?);");
		$resultado = $sentencia->execute([$Nombres, $Apellidos, $Correo, $PassCifrada, $Rol]);
			
		if($resultado == true){
			//SE AGREGO CORRECTAMENTE AL CLIENTE
            $_SESSION["Alerta"] = "RegistroCorrecto";
			header('Location: ../Login'); //envia a la página de inicio.
		}else{
			echo "ocurrio un error";
		}
	}else{
		//El correo ya existe en la base de datos
		$_SESSION["Alerta"] = "CorreoYaExiste";
		header('Location: ../Login/registro.php'); //envia a la página de inicio.
	}
?>