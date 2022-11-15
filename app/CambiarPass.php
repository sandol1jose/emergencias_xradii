<?php
//AGREGANDO NUEVA CUENTA BANCARIA
session_start();//inicio de sesion
	include '../conexion.php';

    if(!isset($_SESSION["Correo"])){
        $_SESSION["Alerta"] = "CodCaducate"; //Pass actualizada cprrectamente
        header('Location: ../Login/index.php'); //Agregamos el producto
        exit();
    }

    $Email = $_SESSION["Correo"];
    $Pass = $_POST["pass"];
    $codigo = $_POST["codigo"];
    $PassCifrada = password_hash($Pass, PASSWORD_DEFAULT); //Encriptando contraseñas

    $sql = "SELECT u.id IDUsuario, c.id IDCodigo FROM codigo_update_pass c 
        JOIN usuarios u ON c.F_idusuario = u.id WHERE u.correo = '".$Email."' 
        AND c.codigo = '".$codigo."' AND c.confirmado = 0;";
    $sentencia = $base_de_datos->prepare($sql);
    $sentencia->execute(); 
    $registros = $sentencia->fetchAll(PDO::FETCH_ASSOC);
    $Cont = count($registros);
    if($Cont > 0){
        //El codigo es correcto
        $sentencia2 = $base_de_datos->prepare("CALL UpdatePass(?,?,?);");
        $resultado2 = $sentencia2->execute([$codigo, $PassCifrada, $Email]);
        if($resultado2 == true){
            //SE AGREGO CORRECTAMENTE AL CLIENTE
            unset($_SESSION["Correo"]);//Borramos la sesion de correo
            $_SESSION["Alerta"] = "passUpdate"; //Pass actualizada correctamente
            header('Location: ../Login/index.php'); //Agregamos el producto
        }else{
            echo "ocurrio un error";
        }
    }else{
        //Codigo Incorrecto
        $_SESSION["Alerta"] = "CodPassIncorrect";
        header('Location: ../Login/CambiarPass.php'); //Agregamos el producto
    }
?>