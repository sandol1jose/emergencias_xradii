<?php
session_start();
$ruta = dirname( __FILE__ ) . '/../../conexion.php';
include $ruta;
include_once 'ConsultarEmergencias.php';


if(!isset($_SESSION['UsuarioConsulta'])){//El propietario quiere eliminar su Emergencia

    $idEmergencia = $_POST["id"];
    $IDUsuario = $_SESSION['Usuario']['IDUsuario'];
    $estado = $_POST["estado"];
    $tipo = $_POST["tipo"];


    //Consultando las imagenes de la emergencia
    $sql = "SELECT ruta FROM imagen WHERE f_emergencia = '".$idEmergencia."'";
    $sentencia = $base_de_datos->prepare($sql);
    $Result = $sentencia->execute();
    $Imagenes = $sentencia->fetchAll(PDO::FETCH_ASSOC); 


    //Eliminamos la emergencia de la base de datos
    $sql = "DELETE FROM emergencia WHERE f_estado = ".$estado." AND id = '".$idEmergencia."'";
    $sentencia = $base_de_datos->prepare($sql);
    $Result = $sentencia->execute();
    if($Result == true){
        //Se elimino la emergencia

        //Eliminamos las imagenes de la carpeta
        if(count($Imagenes) > 0){
            //Si hay imagenes para borrar
            foreach ($Imagenes as $ruta) {
                $url = dirname( __FILE__ ) . '/../../ImagenesDB/Radiografias/' . $ruta["ruta"];
                unlink($url);
            }
        }

        //Consultamos si hay emergencias solo si tipo es igual a 1
        if($tipo == 1){
            $Emergencias = ConsultarEmergencias($IDUsuario, $tipo);
            $Arrar_Retorno["Registros"] = $Emergencias;
        }

        $Arrar_Retorno["Retorno"] = 1;
    }else{
        //Ocurrio un error
        $Arrar_Retorno["Retorno"] = 0;
    }
}else{
    //Se quiere eliminar desde el administrador esto no es posible
    $UsuarioConsulta = $_SESSION['UsuarioConsulta'];
    $Arrar_Retorno["Retorno"] = 2;
}

echo json_encode($Arrar_Retorno);
?>