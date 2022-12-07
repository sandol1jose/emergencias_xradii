<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();//inicio de sesion
}

$Retorno = 0;

if(isset($_SESSION['IMAGENES_PRODUCTO'])){
    $ArrayImagenes["SinAgregar"] = $_SESSION['IMAGENES_PRODUCTO'];//Imagenes sin agregar al DB
    $Retorno = 1;
}

if(isset($_SESSION['IMAGENES_PRODUCTO_ENDB'])){
    $ArrayImagenes["EnDB"] = $_SESSION['IMAGENES_PRODUCTO_ENDB'];//Imagenes que ya estan en la DB
    $Retorno = 1;
}

if($Retorno == 1){
    echo json_encode($ArrayImagenes);
}else{
    echo $Retorno;
}


?>