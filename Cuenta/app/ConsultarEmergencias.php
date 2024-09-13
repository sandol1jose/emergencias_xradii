<?php
//Esto es para usarla con AJAX
if (session_status() == PHP_SESSION_NONE) {
    session_start();//inicio de sesion
}
if(isset($_POST["desde"]) && isset($_POST["hasta"]) && isset($_POST["estado"])){
    if($_POST["desde"] != "" && $_POST["hasta"] != ""){
        $Filtro = ["Desde" => $_POST["desde"], "Hasta" => $_POST["hasta"], "estado" => $_POST["estado"]];

        if(!isset($_SESSION['UsuarioConsulta'])){
            $UsuarioConsulta = $_SESSION['Usuario']['IDUsuario'];
        }else{
            $UsuarioConsulta = $_SESSION['UsuarioConsulta'];
        }
	$_SESSION["Filtro_Historial"] = $Filtro;
        echo json_encode(ConsultarEmergencias($UsuarioConsulta, 2, $Filtro));
    }else{
        echo "0"; //Campo de fechas vacios
    }
}






//Archivo para consultar las Emergencias que estan en estado: "Incompleta"
//Tipo: 1 = trae las incompletas, 2 = trae las que no estan incompletas
//Filtro es un parametro opcional y sirve para filtrar las consultas por fecha y estado
function ConsultarEmergencias($IDUsuario, $tipo, $Filtro = NULL){
    $ruta = dirname( __FILE__ ) . '/../../conexion.php';
    include $ruta;
    $sql = NULL;
    if($tipo == 1){
        $sql = "SELECT * FROM emergencia WHERE f_estado = 1 AND f_usuario = '".$IDUsuario."'";
    }else{
        if(isset($Filtro["estado"])){
            $Desde = $Filtro["Desde"];
            $Hasta = $Filtro["Hasta"];
            $estado = $Filtro["estado"];

            if($Filtro["estado"] == 0){
                $sql = "SELECT * FROM emergencia WHERE f_estado <> 1 AND f_usuario = '".$IDUsuario."' 
                AND (fecha BETWEEN '".$Desde."' AND '".$Hasta."');";
            }else{
                $sql = "SELECT * FROM emergencia WHERE f_estado = ".$estado." AND f_usuario = '".$IDUsuario."' 
                AND (fecha BETWEEN '".$Desde."' AND '".$Hasta."');";
            }
        }else{
            $Desde = $Filtro["Desde"];
            $Hasta = $Filtro["Hasta"];
            $sql = "SELECT * FROM emergencia WHERE f_estado <> 1 AND f_usuario = '".$IDUsuario."' 
            AND (fecha BETWEEN '".$Desde."' AND '".$Hasta."');";
        }
    }
    
    $sentencia = $base_de_datos->prepare($sql);
    $sentencia->execute(); 
    $registros = $sentencia->fetchAll(PDO::FETCH_ASSOC);
    if(count($registros) > 0){
        //Se encontraron registros
        return $registros;
    }else{
        return false;
    }
}
?>