<?php
    session_start();
	include_once "../conexion.php";
	include_once "../Sesiones/sesCliente.php";

	$usuario = strtolower($_POST["usuario"]);
	$password = $_POST["pass"];

	//verificando si el usuario no existe en la base de datos
	$BaseDatos = $base_de_datos;
	$sql = "SELECT u.id, CONCAT(u.nombres, ' ', u.apellidos) NombreCliente, u.pass password,
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
			#if($pass == $PassReal){ //Solo para pruebas
				//contrasenia correcta
				$Autorizacion = $registro["autorizacion"];
				if($Autorizacion == 1){//Si ha sido autorizado por un admin
					$IDUsuario = $registro["id"];
					$Nombre = $registro["NombreCliente"];
					//$rol = $registro["rol"];

					//Creando las cookies
					setcookie("COOKIE_USUARIO_EMAIL", $email, time() + (86400 * 30)); // 86400 = 1 day
					setcookie("COOKIE_USUARIO_PASS", $pass, time() + (86400 * 30)); // 86400 = 1 day
					$_SESSION['Alerta'] = "inicioSesion";

					//Revisamos los roles
					$rol = RevisarRoles($IDUsuario, $Nombre, $email);

					//Redirigiendo según el rol
					$ruta = NULL;
					switch ($rol) {
						case 1://Para el tecnico
						case 4://Para el piloto
							$ruta = "../Cuenta/index.php";
							break;

						case 2://Para el Administrador
						case 5://Para el admin
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



	function RevisarRoles($IDUsuario, $Nombre, $email) {
		// Conexión a la base de datos
		global $BaseDatos;
	
		// Consulta para obtener roles asignados al usuario
		$sql = "SELECT F_rol 
				FROM usuarios_rol 
				WHERE F_usuario = :idUsuario";
		
		$sentencia = $BaseDatos->prepare($sql);
		$sentencia->bindParam(':idUsuario', $IDUsuario, PDO::PARAM_INT);
		$sentencia->execute(); 

		// Obtener los roles en un array
		$roles = $sentencia->fetchAll(PDO::FETCH_COLUMN);
		$totalRoles = count($roles); // Contar el número de roles

		// Verificar la cantidad de roles
		if ($totalRoles === 1) {
			//Creando la sesion
			CrearSesion($IDUsuario, $Nombre, $email, $roles[0]);
			return $roles[0];
		} elseif ($totalRoles > 1) {
			CrearSesion($IDUsuario, $Nombre, $email, -1);// Se manda con rol -1 para que se redirija a una pagina para seleccionar el rol
			header("Location: ../Login/seleccionarRol.php"); // Cambia por la URL deseada
			exit(); // Asegúrate de usar exit() después de header()
		} else {
			// Redirigir si no tiene roles asignados
			header("Location: pagina_sin_roles.php"); // Cambia por la URL deseada
			exit(); // Asegúrate de usar exit() después de header()
		}
	}
?>