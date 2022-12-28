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
$Cantidad_Campos = 8; //Para saber cuantos campos debe de llenar

$Inicio = $_POST["Inicio"];
$Fin = $_POST["Fin"];
$Direccion = $_POST["Direccion"];
$Precio = $_POST["Precio"];
$Honorarios = $_POST["Honorarios"];
$Paciente = $_POST["Paciente"];
$Edad = $_POST["Edad"];
$Estudios = $_POST["Estudios"];
$IDEmergencia = $_SESSION['IDEmergencia'];
$Rol = $_SESSION['Rol_Usuario_Emergencia'];//Variable de Session que almacena el Rol del usuario propietario de la Emergencia

//Para aprovar o revisar
$CheckBox = $_POST["CheckBox"];
$CheckBox_val = $_POST["CheckBox_val"];

//Para Mandar a revisión
$CheckBox2 = $_POST["CheckBox2"];
$CheckBox_val2 = $_POST["CheckBox_val2"];

if($CheckBox == 'true'){
    switch ($CheckBox_val) {
        case 'Revision':
            $Estado = 3;
            break;
        case 'Aprobada':
            $Estado = 4;
            break;
    }
}else if($CheckBox2 == 'true'){
    switch ($CheckBox_val2) {
        case 'Rechazar':
            $Estado = 2;
            break;
    }
}else{
    $Estado = NULL;
}

//Verificando si algunos parametros están vacios / y de ésta manera saber que estado tendrá la Emergencia
$Inicio = VerificarParametros($Inicio, true);
$Fin = VerificarParametros($Fin, true);
$Direccion = VerificarParametros($Direccion, true);
$Precio = VerificarParametros($Precio, true);
$Honorarios = VerificarParametros($Honorarios, true);
$Paciente = VerificarParametros($Paciente, true);
$Edad = VerificarParametros($Edad, true);
$Estudios = VerificarParametros($Estudios, true);

//Si el rol es (4) Piloto, entonces solo debe de llenar 4 campos
if($Rol == 4){
    $Cantidad_Campos = 5;
}

//Que al menos 8 parámetro esté lleno
if($Parametros_Llenos == $Cantidad_Campos){
    try {
        $sentencia = $base_de_datos->prepare("CALL UpdateEmergencia_Admin(?,?,?,?,?,?,?,?,?,?);");
        $resultado = $sentencia->execute([
                $Inicio, 
                $Fin, 
                $Direccion, 
                $Precio, 
                $Honorarios,
                $Paciente,
                $Edad,
                $Estudios, 
                $IDEmergencia,
                $Estado
        ]);

        if($resultado == true){
            //SE AGREGO CORRECTAMENTE LA EMERGENCIA
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