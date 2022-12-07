<?php
    session_start();
	include_once "../conexion.php";
	include_once "../Sesiones/sesCliente.php";

	$correo = $_POST["correo"];
	$password = $_POST["pass"];

	//verificando si el usuario no existe en la base de datos
	$BaseDatos = $base_de_datos;
	$sql = "SELECT u.id, CONCAT(u.nombres, ' ', u.apellidos) NombreCliente, u.pass password, u.F_rol rol
	FROM usuarios u WHERE u.correo = '".$correo."'";
	$sentencia = $BaseDatos->prepare($sql);
	$sentencia->execute(); 
	$registros = $sentencia->fetchAll(PDO::FETCH_ASSOC);
	$contar = count($registros);
	
	if($contar == 1){
		RecorrerRegistros($registros, $password, $correo);
	}else{
        //correo no existe
        $_SESSION['Alerta'] = "MailNoExist";
        header('Location: ../Login/index.php');
	}

	function RecorrerRegistros($Reg, $pass, $email){
		foreach ($Reg as $registro) {
			$PassReal = $registro["password"];
			if(password_verify($pass, $PassReal)){
				//contrasenia correcta
                $IDUsuario = $registro["id"];
                $Nombre = $registro["NombreCliente"];
                $rol = $registro["rol"];

                //Creando la sesion
                CrearSesion($IDUsuario, $Nombre, $email, $rol);

                //Creando las cookies
                setcookie("COOKIE_USUARIO_EMAIL", $email, time() + (86400 * 30)); // 86400 = 1 day
                setcookie("COOKIE_USUARIO_PASS", $pass, time() + (86400 * 30)); // 86400 = 1 day
                $_SESSION['Alerta'] = "inicioSesion";
                header('Location: ../Cuenta/index.php');
			}else{
				//contraseña incorrecta
				$_SESSION['Alerta'] = "passIncorrect";
				header('Location: ../Login/index.php');
			}
		}
	}



	function CargarEstadosTransacciones($IdClie){
		/*Cargamos los estados actuales de las transacciones
		Servira para comparar con firebese cuando cambie de estado y no me notifique de todas las transacciones
		si no solo de la que cambio*/
		include "../conexion.php";
		
		$sql2 = "SELECT t.id, t.f_estado FROM transaccion t
		WHERE t.f_comprador = '".$IdClie."' OR t.f_vendedor = '".$IdClie."';";
		$sentencia2 = $base_de_datos->prepare($sql2);
		$sentencia2->execute();
		$registros2 = $sentencia2->fetchAll(PDO::FETCH_ASSOC);
		$contar2 = count($registros2);
		if($contar2 > 0){
			foreach($registros2 as $reg){
				$IDtrans = $reg['id'];
				$estado = $reg['f_estado'];
				$_SESSION['ESTADO_TRANSACCIONES'][$IDtrans] = $estado;
			}
		}
	}
?>