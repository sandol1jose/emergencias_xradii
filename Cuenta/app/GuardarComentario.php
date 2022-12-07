<?php
//Archivo para consultar una emergencia en particular
session_start();
date_default_timezone_set('America/Guatemala');
$ruta = dirname( __FILE__ ) . '/../../conexion.php';
include $ruta;

$Retorno = NULL;
$motivo = $_POST["motivo"];
$comentario = $_POST["comentario"];

$IDUsuario_Modif = $_SESSION["IDUsuario_Modif"];
$IDEmergencia = $_SESSION["IDEmergencia"];
$fechaActual = date('Y-m-d H:i:s');

try {
    $sentencia = $base_de_datos->prepare("CALL NuevoComentario(?,?,?,?,?);");
    $resultado = $sentencia->execute([
            $fechaActual, 
            $comentario, 
            $motivo, 
            $IDUsuario_Modif, 
            $IDEmergencia
    ]);

    if($resultado == true){
        //Se registro el comentario
        $Retorno["Retorno"] = 1;
    }else{
        $Retorno["Retorno"] = 0;
    }
} catch (Throwable $th) {
    $Retorno["Error"] = $th;
}

echo json_encode($Retorno);
?>