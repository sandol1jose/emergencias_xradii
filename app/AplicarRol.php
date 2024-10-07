<?php
    session_start();
	include_once "../conexion.php";
	include_once "../Sesiones/sesCliente.php";

	$rol = $_POST["rol"];

    $IDUsuario = $_SESSION['Usuario']["IDUsuario"];
    $_SESSION['Usuario']["Rol"] = $rol;
    $_SESSION['Alerta'] = "inicioSesion";

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
?>