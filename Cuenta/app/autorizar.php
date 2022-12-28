<?php
//Archivo para actualizar el estado de un usuario
session_start();
$ruta = dirname( __FILE__ ) . '/../../conexion.php';
include $ruta;

$Retorno = NULL;
$id = $_POST["id"];
$Check = $_POST['Check'];

try {
    $sql = "UPDATE usuarios SET autorizacion = ".$Check." WHERE id = ".$id.";";
    $sentencia = $base_de_datos->prepare($sql);
    $sentencia->execute(); 
    if($sentencia){
        $Retorno = 1;
    }else{
        $Retorno = 0;
    }
} catch (Throwable $th) {
    $Retorno["Error"] = $th;
}
echo json_encode($Retorno);
?>