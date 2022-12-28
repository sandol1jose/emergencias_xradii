<?php
//Archivo actualizar el precio de la Hora Extra
session_start();
$ruta = dirname( __FILE__ ) . '/../../conexion.php';
include $ruta;

$Retorno = NULL;
$precio = $_POST['precio'];

try {
    $sql = "UPDATE datos SET precio = ".$precio." WHERE dato = 'hora_extra';";
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