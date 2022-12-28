<?php
//Archivo para consultar una emergencia en particular
session_start();
$ruta = dirname( __FILE__ ) . '/../../conexion.php';
include $ruta;

$Retorno = NULL;

if(!isset($_POST["id"])){
    //Se está buscando en view.php
    $IDUsuario = $_SESSION["IDUsuario"];
    $id = $_SESSION["IDEmergencia"];
    $Rol = $_SESSION['Usuario']["Rol"];
}else{
    $IDUsuario = $_SESSION['Usuario']['IDUsuario'];
    $id = $_POST["id"];
}


//Limpiamos la variable de sesion Imagenes en base de datos
unset($_SESSION['IMAGENES_PRODUCTO']);
unset($_SESSION['IMAGENES_PRODUCTO_ENDB']); 

try {
    $sql = "SELECT  e.*, c.comentario, e2.nombre_estado, e2.id idEstado FROM emergencia e
    LEFT JOIN comentario c ON e.id = c.f_emergencia
    JOIN estado e2 ON e2.id = e.f_estado 
    WHERE e.id = ".$id." AND e.f_usuario = ".$IDUsuario." ORDER BY c.id ASC LIMIT 1";
    $sentencia = $base_de_datos->prepare($sql);
    $sentencia->execute(); 
    $registro = $sentencia->fetchAll(PDO::FETCH_ASSOC);
    if(count($registro) == 1){
        //Se encontro la emergencia
        
        /*if(!isset($_POST["id"])){
            //Se está buscando en view.php
            $_SESSION['EMERGENCIA'] = $registro[0];
        }*/

        //Buscamos las imagenes
        $sql = "SELECT id, ruta FROM imagen i WHERE i.f_emergencia = ".$id."";
        $sentencia2 = $base_de_datos->prepare($sql);
        $sentencia2->execute();
        $Imagenes = $sentencia2->fetchAll(PDO::FETCH_ASSOC);
        if(count($Imagenes) > 0){
            foreach ($Imagenes as $key => $value) {
                $Ruta = $value["ruta"];
                $id = $value["id"];
                $_SESSION['IMAGENES_PRODUCTO_ENDB'][$id] = $Ruta;
            }
            $Retorno["Imagenes"] = true;
            $Retorno["Imagenes2"] = $_SESSION['IMAGENES_PRODUCTO_ENDB'];
        }else{
            $Retorno["Imagenes"] = false;
        }
        if(!isset($_POST["id"])){
            //Se está buscando en view.php
            $Retorno["RolUsuario"] = $Rol;
        }
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