<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();//inicio de sesion
}

$Modo = $_POST["Modo"];
$Imagen = $_POST["Imagen"];
$Retorno = -1;

if($Modo == 0){
    //Eliminando la imagen de la variable de sesión IMAGENES_PRODUCTO
    if(isset($_SESSION['IMAGENES_PRODUCTO'])){
        foreach ($_SESSION['IMAGENES_PRODUCTO'] as $key => $value) {
            if($value == $Imagen){
                unset($_SESSION['IMAGENES_PRODUCTO'][$key]);
                $url = '../../ImagenesDB/Radiografias/temp/' . $Imagen;
                if(file_exists($url)) {
                    unlink($url);
                }
                $Retorno = 1;
            }
        }
    }
}else if($Modo == 1){
    //Eliminando la imagen de la variable de sesión IMAGENES_PRODUCTO_ENDB
    if(isset($_SESSION['IMAGENES_PRODUCTO_ENDB'])){
        foreach ($_SESSION['IMAGENES_PRODUCTO_ENDB'] as $key => $value) {
            if($value == $Imagen){
                $_SESSION['IMAGENES_AELIMINAR'][$key] = $value;
                unset($_SESSION['IMAGENES_PRODUCTO_ENDB'][$key]);
                /*$url = '../../ImagenesDB/Radiografias/' . $Imagen;
                if(file_exists($url)) {
                    unlink($url);
                }*/
                $Retorno = 1;
            }
        }
    }
}
//echo $Retorno;
echo json_encode($_SESSION['IMAGENES_AELIMINAR']);
?>