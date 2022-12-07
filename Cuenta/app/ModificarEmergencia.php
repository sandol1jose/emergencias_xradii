<?php
//REGISTRO DE LA EMERGENCIA EN LA BASE DE DATOS
session_start();
include_once '../../conexion.php';
include_once 'ConsultarEmergencias.php';
/*include_once '../../templates/encabezado.php';*/

if(!isset($_SESSION['Usuario'])){
    header('Location: ../index.php');
    exit();
}

$Estado = NULL;
$Parametros_Llenos = 0;
$Retorno = NULL;

$Inicio = $_POST["Inicio"];
$Fin = $_POST["Fin"];
$Direccion = $_POST["Direccion"];
$Precio = $_POST["Precio"];
$Honorarios = $_POST["Honorarios"];
$Paciente = $_POST["Paciente"];
$Edad = $_POST["Edad"];
$Estudios = $_POST["Estudios"];
$Comentarios = $_POST["Comentarios"];
$IDEmergencia = $_POST["IDEmergencia"];
$fechaActual = date('Y-m-d');
$IDUsuario = $_SESSION['Usuario']['IDUsuario'];

//Verificando si algunos parametros están vacios / y de ésta manera saber que estado tendrá la Emergencia
$Inicio = VerificarParametros($Inicio, true);
$Fin = VerificarParametros($Fin, true);
$Direccion = VerificarParametros($Direccion, true);
$Precio = VerificarParametros($Precio, true);
$Honorarios = VerificarParametros($Honorarios, true);
$Paciente = VerificarParametros($Paciente, true);
$Edad = VerificarParametros($Edad, true);
$Estudios = VerificarParametros($Estudios, true);
$Comentarios = VerificarParametros($Comentarios, false);

if($Parametros_Llenos === 8){
    $Estado = 2;
}else{
    $Estado = 1;
}


//Que al menos un parámetro esté lleno
if($Parametros_Llenos > 0){
    try {
        $sentencia = $base_de_datos->prepare("CALL UpdateEmergencia(?,?,?,?,?,?,?,?,?,?,?,?,?);");
        $resultado = $sentencia->execute([
                $fechaActual, 
                $Inicio, 
                $Fin, 
                $Direccion, 
                $Precio, 
                $Honorarios,
                $Paciente,
                $Edad,
                $Estudios, 
                $Comentarios,
                $IDEmergencia,
                $Estado,
                $IDUsuario
        ]);
    
        //Guardando las imagenes (Si hubieran)
        if(isset($_SESSION["IMAGENES_PRODUCTO"])){
            $Array_Imagenes = $_SESSION["IMAGENES_PRODUCTO"];
            foreach ($Array_Imagenes as $value) {
                $Ruta = $value;
                $Ruta_Renombrada = "E" . $IDEmergencia . "_" . $value;
                $sentencia = $base_de_datos->prepare("CALL NuevaImagen(?,?);");
                $resultado = $sentencia->execute([$Ruta_Renombrada, $IDEmergencia]);
    
                //Moviendo la imagen a la carpeta
                $currentLocation = '../../ImagenesDB/Radiografias/temp/' . $Ruta;
                $newLocation = '../../ImagenesDB/Radiografias/' . $Ruta_Renombrada;
                if(is_file($currentLocation)){
                    rename($currentLocation, $newLocation);
                }
            }
            //Eliminamos las imagenes de la variable Sesion
            unset($_SESSION["IMAGENES_PRODUCTO"]);
        }

        if(isset($_SESSION["IMAGENES_PRODUCTO_ENDB"])){
            unset($_SESSION["IMAGENES_PRODUCTO_ENDB"]);
        }

        //Si hay imagenes por eliminar, las eliminamos de la base de datos y del directorio
        if(isset($_SESSION["IMAGENES_AELIMINAR"])){
            foreach ($_SESSION['IMAGENES_AELIMINAR'] as $id => $name_image) {
                //La eliminamos de la base de datos
                $sql = "DELETE FROM imagen WHERE id = '".$id."' AND f_emergencia = '".$IDEmergencia."';";
                $sentencia = $base_de_datos->prepare($sql);
                $resultado2 = $sentencia->execute(); 
                if($resultado2 == true){
                    //La eliminamos de la carpeta
                    $url = '../../ImagenesDB/Radiografias/' . $name_image;
                    if(file_exists($url)) {
                        unlink($url);
                    }
                }
            }
        }
    
        if($resultado == true){
            //SE AGREGO CORRECTAMENTE LA EMERGENCIA
    
            //Consultamos las emergencias en estado "Incompleta"
            $registros = ConsultarEmergencias($IDUsuario, 1);
            if($registros != false){
                $Arrar_Retorno["Registros"] = $registros;
            }
    
            $Retorno = '1';
        }else{
            //Ocurrio un error al almacenar en la base de datos
            $Retorno = '0';
        }
    } catch (Throwable $th) {
        $Arrar_Retorno["Error"] = $th;
    }
}else{
    //No se llenó ningún parametro
    $Retorno = '-1';
}

//Retornamos el array con los datos en formato Json
$Arrar_Retorno["Retorno"] = $Retorno;
echo json_encode($Arrar_Retorno);
?>
<?php
function VerificarParametros($Parametro, $importancia){
    global $Parametros_Llenos;
    if($Parametro == ""){
        $Parametro = NULL;
    }else{
        if($importancia == true){
            $Parametros_Llenos++;
        }
    }
    return $Parametro;
}
?>