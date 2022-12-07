<?php
//Archivo para consultar una emergencia en particular
session_start();
$ruta = dirname( __FILE__ ) . '/../../conexion.php';
include $ruta;

$Retorno = NULL;

$IDUsuario = $_SESSION["IDUsuario"];
$IDEmergencia = $_SESSION["IDEmergencia"];

try {
    $sql = "SELECT c.*, u.nombres usuario, e.f_usuario FROM comentario c
    JOIN usuarios u ON c.f_usuario = u.id
    JOIN emergencia e ON e.id = c.f_emergencia
    WHERE c.f_emergencia = ".$IDEmergencia." AND e.f_usuario = ".$IDUsuario." ORDER BY c.fecha DESC";
    $sentencia = $base_de_datos->prepare($sql);
    $sentencia->execute(); 
    $registro = $sentencia->fetchAll(PDO::FETCH_ASSOC);
    if(count($registro) > 0){
        //Se encontraron los comentarios
        $Retorno["Registros"] = $registro;
        $Retorno["Retorno"] = 1;
    }else{
        $Retorno["Retorno"] = 0;
    }
} catch (Throwable $th) {
    $Retorno["Error"] = $th;
}

echo json_encode($Retorno);
?>