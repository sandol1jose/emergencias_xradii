<?php
    session_start();
	include_once "../conexion.php";
	include_once "../Sesiones/sesCliente.php";

	$usuario = strtolower($_POST["usuario"]);
	$password = $_POST["pass"];

	//verificando si el usuario no existe en la base de datos
	$BaseDatos = $base_de_datos;
	$sql = "SELECT u.id, CONCAT(u.nombres, ' ', u.apellidos) NombreCliente, u.pass password, u.F_rol rol, 
	u.autorizacion, u.correo
	FROM usuarios u WHERE u.correo = '".$usuario."' OR u.username = '".$usuario."'";
	$sentencia = $BaseDatos->prepare($sql);
	$sentencia->execute(); 
	$registros = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$contar = count($registros);
	
	if($contar == 1){
		$Correo = $registros[0]["correo"];
		RecorrerRegistros($registros, $password, $Correo);
	}else{
        //correo no existe probamos con el username
        $_SESSION['Alerta'] = "MailNoExist";
        header('Location: ../Login/index.php');
	}

	function RecorrerRegistros($Reg, $pass, $email){
		foreach ($Reg as $registro) {
			$PassReal = $registro["password"];
			if(password_verify($pass, $PassReal)){
				//contrasenia correcta
				$Autorizacion = $registro["autorizacion"];
				if($Autorizacion == 1){//Si ha sido autorizado por un admin
					$IDUsuario = $registro["id"];
					$Nombre = $registro["NombreCliente"];
					$rol = $registro["rol"];

					//Creando la sesion
					CrearSesion($IDUsuario, $Nombre, $email, $rol);

					//Creando las cookies
					setcookie("COOKIE_USUARIO_EMAIL", $email, time() + (86400 * 30)); // 86400 = 1 day
					setcookie("COOKIE_USUARIO_PASS", $pass, time() + (86400 * 30)); // 86400 = 1 day
					$_SESSION['Alerta'] = "inicioSesion";


					//Redirigiendo según el rol
					$ruta = NULL;
					switch ($rol) {
						case 1://Técnico de Rayos X nivel I
						case 3://Radiólogo
						case 4://Laborante de mantenimiento
						case 8://Asistente de radiología
						case 9://Asistente Administrativo II
						case 10://Técnico de Rayos X nivel II
						case 11://Secretaria recepcionista
						case 12://Conserje
						case 13://Asistente de Técnico de Rayos X
						case 14://Coordinadora de Recursos Humanos
						case 15://Contador General 
						case 16://Supervisor Operativo y Soporte Técnico
							$ruta = "../Cuenta/index.php";
							break;

						case 2://Para el Administrador
						case 5://Para el admin
						case 6://Gerente General
						case 7://Director General
							$ruta = "../Cuenta/Tecnicos.php";
							break;
					}
					header('Location: ' . $ruta);
				}else{
					//No está autorizado para iniciar
					$_SESSION['Alerta'] = "NoAutorizado";
					header('Location: ../Login/index.php');
				}
			}else{
				//contraseña incorrecta
				$_SESSION['Alerta'] = "passIncorrect";
				header('Location: ../Login/index.php');
			}
		}
	}
?>