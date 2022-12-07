<?php
session_start();//inicio de sesion
if(!isset($_SESSION['Usuario'])){
    header('Location: ../Login/index.php');
}

$Titulo = "Historial";
?>

<?php include_once '../templates/encabezado.php'; ?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>

    <link href="css/historial.css" rel="stylesheet">
</head>
<body>

<?php include_once '../templates/estructura.php'; ?>

<div class="ContenedorBase">
    
    <div class="grid-Filtro">
        <div class="Filtro_item1"><span>Desde</span></div>
        <div class="Filtro_item2"><span>Hasta</span></div>
        <div class="Filtro_item3"></div>  
        <div class="Filtro_item4"><input type="date" id="desde"></div>
        <div class="Filtro_item5"><input type="date" name="" id="hasta"></div>
        <div class="Filtro_item6">
            <select name="estado" id="estado">
                <option value="0">Todas</option>
                <option value="2">Ingresada</option>
                <option value="3">Revisada</option>
                <option value="4">Aprovada</option>
            </select>
        </div>
        <div class="Filtro_item7"><button class="BotonGeneral" onclick="Filtrar();" >Buscar</button></div>
    </div>

</div>

<div class="ContenedorBase2">

    <div class="divTabla">
        <div class="divtabla2">
            <table>
                <thead>
                    <tr>
                        <th class="tdbtn_estado"></th>
                        <th class="tdfecha">Fecha</th>
                        <th class="tdfecha">Inicio</th>
                        <th class="tdfecha">Fin</th>
                        <th class="tdestudios">Estudios</th>
                        <th class="tdpaciente">Paciente</th>
                        <th class="tdprecio">Edad</th>
                        <th class="tdDireccion">Direccion</th>
                        <th class="tdprecio">H. Aprox.</th>
                        <th class="tdprecio">Precio</th>
                        <th class="tdprecio">Honorarios</th>
                        <th class="tdprecio">H.Extra</th>
                        <th class="tdprecio">Bonif.</th>
                        <th class="tdbtn_eliminar">Ver</th>
                        <th class="tdbtn_eliminar">Del.</th>
                    </tr>
                </thead>
                <tbody id="tbody_tabla" name="tbody_tabla">
                </tbody>
            </table>
        </div>
    </div>

    <div class="DivPie_tabla">
        <div class="DivPie_tabla2">
            <table>

                <thead class="theadPie_tabla">
                    <tr>
                    <th class="tdbtn_estado"></th>
                        <th class="tdfecha"></th>
                        <th class="tdfecha"></th>
                        <th class="tdfecha"></th>
                        <th class="tdestudios"></th>
                        <th class="tdpaciente"></th>
                        <th class="tdprecio"></th>
                        <th class="tdDireccion"></th>
                        <th class="tdprecio"></th>
                        <th class="tdprecio" id="precio"></th>
                        <th class="tdprecio" id="honorarios"></th>
                        <th class="tdprecio" id="hora_extra"></th>
                        <th class="tdprecio" id="bonificacion"></th>
                        <th class="tdbtn_eliminar"></th>
                        <th class="tdbtn_eliminar"></th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>

</div>

<?php include_once '../templates/estructura_abajo.php'; ?>
    
</body>
</html>

<script src="js/historial.js"></script>



<?php
//Consultamos las Emergencias "Incompletas"
include_once 'app/ConsultarEmergencias.php';


//Buscando el ultimo y primer dia del mes actual para traer los datos de éste mes
$month = date('m');
$year = date('Y');
$Desde = date('Y-m-d', mktime(0,0,0, $month, 1, $year));

$month = date('m');
$year = date('Y');
$day = date("d", mktime(0,0,0, $month+1, 0, $year));
$Hasta = date('Y-m-d', mktime(0,0,0, $month, $day, $year));

$Filtro = ["Desde" => $Desde, "Hasta" => $Hasta];

$Registros = ConsultarEmergencias($_SESSION['Usuario']['IDUsuario'], 2, $Filtro);
if($Registros != false){
    $Registros = json_encode($Registros);
    echo '<script>PintarTabla('.$Registros.');</script>';
}
?>