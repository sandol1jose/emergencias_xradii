<?php
session_start();//inicio de sesion
//echo $_SESSION['Usuario']["Rol"];
/*if(!isset($_SESSION['Usuario']) || ($_SESSION['Usuario']["Rol"] != 2 || $_SESSION['Usuario']["Rol"] != 5 ) ){
    header('Location: ../Login/index.php');
}*/

$Rol = $_SESSION['Usuario']['Rol'];
if($Rol == 1 || $Rol == 4){
    header('Location: ../Login/index.php');
}

unset($_SESSION['UsuarioConsulta']);

$Titulo = "Listado de técnicos";
?>

<?php
//Consultado los usuarios
$ruta = dirname( __FILE__ ) . '/../conexion.php';
include $ruta;

$sql = "SELECT u.id, u.nombres, u.apellidos, u.correo, c.nombre_cargo FROM usuarios u 
JOIN cargo c ON u.F_cargo = c.id 
WHERE u.activo != 0 AND u.apellidos != 'Prueba';";
$sentencia = $base_de_datos->prepare($sql);
$sentencia->execute(); 
$registro = $sentencia->fetchAll(PDO::FETCH_ASSOC);
?>



<?php include_once '../templates/encabezado.php'; ?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tecnicos</title>

    <link href="css/tecnicos.css" rel="stylesheet">
</head>
<body>

<?php include_once '../templates/estructura.php'; ?>

<div class="ContenedorBase">
    <h1>Seleccione un técnico para ver su información</h1>
</div>

<div class="ContenedorBase2">

    <div class="divTabla_tec">
        <div class="divtabla2_tec">
            <table>
                <thead>
                    <tr>
                        <th class="">Nombres</th>
                        <th class="">Apellidos</th>
                        <th class="">Correo</th>
                        <th class="tdfecha">Cargo</th>
                        <th class="tdfecha">ver</th>
                    </tr>
                </thead>
                <tbody id="tbody_tabla" name="tbody_tabla">
                    <?php if(count($registro) > 0){ ?>
                        <?php foreach($registro as $valor){ ?>
                            <tr>
                                <td>
                                    <?php echo $valor["nombres"]; ?>
                                </td>
                                <td>
                                    <?php echo $valor["apellidos"]; ?>
                                </td>
                                <td>
                                    <?php echo $valor["correo"]; ?>
                                </td>
                                <td>
                                    <?php echo $valor["nombre_cargo"]; ?>
                                </td>
                                <td>
                                    <button class="btnView" onclick="VerUsuario(<?php echo $valor['id'];?>);">
                                    </button>
                                </td>
                            </tr>
                        <?php } ?>
                    <?php } ?>
                </tbody>
            </table>
        </div>
    </div>

</div>

<?php include_once '../templates/estructura_abajo.php'; ?>
    
</body>
</html>

<script src="js/historial.js"></script>
<script src="js/Tecnicos.js"></script>