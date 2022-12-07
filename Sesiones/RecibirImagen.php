<?php

if (session_status() == PHP_SESSION_NONE) {
    session_start();//inicio de sesion
}

include_once "../app/RedimenionarImagen.php";

ImagenesProductos();

function ImagenesProductos(){
	$TipoImag = $_FILES['Imagen']['type'];
	if($TipoImag == "image/jpeg" || $TipoImag == "image/jpg" || $TipoImag == "image/gif" || $TipoImag == "image/png"){
		//Imagen aceptada
        $ArrayImagen = $_FILES['Imagen'];
        $nombreImagen = "U" . $_SESSION['Usuario']['IDUsuario'] . "_" . $ArrayImagen["name"];
        RedimencionarIMG($ArrayImagen, '../ImagenesDB/Radiografias/temp', $nombreImagen); //Imagen Comprimida con PHP
        $_SESSION['IMAGENES_PRODUCTO'][] = $nombreImagen;
	}else{
        //Imagen no aceptada
        $_SESSION["Alerta"] = "ImagenNo";
        header('Location: ../ingresoproducto.php');
	}
}
?>


<?php
function RedimencionarIMG($var, $path, $nombrearchivo){
    //return $var["type"];

    //$Imagen = NULL;

    //Parámetros optimización, resolución máxima permitida
    $max_ancho = 1280;
    $max_alto = 900;

    if($var['type']=='image/png' || $var['type']=='image/jpeg' || $var['type']=='image/gif'){
        $medidasimagen= getimagesize($var['tmp_name']);

        //$nombrearchivo = $var['name'];

        //Si las imagenes tienen una resolución y un peso aceptable se suben tal cual
        if($medidasimagen[0] < 1280 && $var['size'] < 100000){

            //$nombrearchivo = $var['name'];
            move_uploaded_file($var['tmp_name'], $path.'/'.$nombrearchivo);
            $img = $path."/".$nombrearchivo;
            //$dat = base64_encode(file_get_contents($img));
            //$Imagen = $dat;
        }else{//Si no, se generan nuevas imagenes optimizadas

            //$nombrearchivo = $var['name'];

            //Redimensionar
            $rtOriginal=$var['tmp_name'];

            if($var['type'] == 'image/jpeg'){
                $original = imagecreatefromjpeg($rtOriginal);
            }
            else if($var['type'] == 'image/png'){
                $original = imagecreatefrompng($rtOriginal);
            }
            else if($var['type'] == 'image/gif'){
                $original = imagecreatefromgif($rtOriginal);
            }

    
            list($ancho,$alto)=getimagesize($rtOriginal);

            $x_ratio = $max_ancho / $ancho;
            $y_ratio = $max_alto / $alto;


            if( ($ancho <= $max_ancho) && ($alto <= $max_alto) ){
                $ancho_final = $ancho;
                $alto_final = $alto;
            }
            elseif (($x_ratio * $alto) < $max_alto){
                $alto_final = ceil($x_ratio * $alto);
                $ancho_final = $max_ancho;
            }
            else{
                $ancho_final = ceil($y_ratio * $ancho);
                $alto_final = $max_alto;
            }

            $lienzo = imagecreatetruecolor($ancho_final,$alto_final); 

            imagecopyresampled($lienzo, $original, 0,0,0,0, $ancho_final, $alto_final, $ancho, $alto);
    
            //imagedestroy($original);

            //$cal=8;

            if($var['type']=='image/jpeg'){
                imagejpeg($lienzo, $path . "/" . $nombrearchivo);
                //$img = $path."/".$nombrearchivo;
                //$dat = base64_encode(file_get_contents($img));
                //$Imagen = $dat;
                //unlink($img); //Eliminamos la imagen en la carpeta
            }
            else if($var['type']=='image/png'){
                imagepng($lienzo, $path."/".$nombrearchivo);
                //$img = $path."/".$nombrearchivo;
                //$dat = base64_encode(file_get_contents($img));
                //$Imagen = $dat;
            }
            else if($var['type']=='image/gif'){
                imagegif($lienzo, $path."/".$nombrearchivo);
                //$img = $path."/".$nombrearchivo;
                //$dat = base64_encode(file_get_contents($img));
                //$Imagen = $dat;
            }
        }
    }else{
        echo 'fichero no soportado';
    }

    //return $Imagen;
}
?>