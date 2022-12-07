<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();//inicio de sesion
}
//Buscamos el listado de imagenes en la carpeta temp
$arrFiles = scandir('../ImagenesDB/Radiografias/temp');
$IDUsuario = $_SESSION['Usuario']["IDUsuario"];
/*var_dump($arrFiles);
var_dump($IDUsuario);*/
foreach ($arrFiles as $value) {
    //Buscamos solo las del usuario en cuestion iniciando con la letra "U" como se guardan las imagenes
    if( str_contains($value, ("U".$IDUsuario)) ){
        $url = '../ImagenesDB/Radiografias/temp/' . $value;
        if(unlink($url)) { //Eliminamos la imagen
            //echo 1;
        } else {
            //echo 0;
        }
    }
}
?>