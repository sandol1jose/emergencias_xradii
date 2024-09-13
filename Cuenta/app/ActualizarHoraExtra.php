<?php
//Archivo actualizar el precio de la Hora Extra
session_start();
$ruta = dirname( __FILE__ ) . '/../../conexion.php';
include $ruta;

$Retorno = NULL;
$precio = $_POST['precio'];
$idDatos = $_POST['idDatos'];

try {
    $sql = "UPDATE datos SET precio = ".$precio." WHERE id = ".$idDatos.";";
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