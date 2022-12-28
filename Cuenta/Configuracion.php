<?php
session_start();//inicio de sesion

$Rol = $_SESSION['Usuario']['Rol'];
if($Rol == 1 || $Rol == 4){
    header('Location: ../Login/index.php');
}

$Titulo = "Configuración";
?>

<?php
//Consultado los usuarios
$ruta = dirname( __FILE__ ) . '/../conexion.php';
include $ruta;

$sql = "SELECT u.id, u.nombres, u.apellidos, u.correo, u.autorizacion, r.nombre_rol FROM usuarios u 
JOIN rol r ON u.F_rol = r.id 
WHERE u.F_rol <> 5";
$sentencia = $base_de_datos->prepare($sql);
$sentencia->execute(); 
$registro = $sentencia->fetchAll(PDO::FETCH_ASSOC);

//Consultado el precio de la hora extra
$sql = "SELECT precio FROM datos WHERE dato = 'hora_extra'";
$sentencia = $base_de_datos->prepare($sql);
$sentencia->execute(); 
$registro2 = $sentencia->fetchAll(PDO::FETCH_ASSOC);
$HoraExtra = $registro2[0]["precio"];
?>

<?php include_once '../templates/encabezado.php'; ?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tecnicos</title>

    <link href="css/configuracion.css" rel="stylesheet">
</head>
<body>
<?php include_once '../templates/estructura.php'; ?>


<div class="grid-container-Config">
    <div class="Configitem1">
        <div class="divtabla1">
            <table>
                <thead>
                    <th>Nombres</th>
                    <th>Apellidos</th>
                    <th>Correo</th>
                    <th>Rol</th>
                    <th>Autorizar</th>
                </thead>
                <tbody>

                <?php foreach($registro as $reg){ ?>
                    <tr>
                        <td><?php echo $reg["nombres"] ?></td>
                        <td><?php echo $reg["apellidos"] ?></td>
                        <td><?php echo $reg["correo"] ?></td>
                        <td><?php echo $reg["nombre_rol"] ?></td>
                        <?php 
                        $Checked = "";
                        if($reg["autorizacion"] == 1){
                            $Checked = "checked";
                        }
                        ?>
                        <td><input type="checkbox" onchange="Autorizar(<?php echo $reg['id'] ?>)" id="check_<?php echo $reg["id"] ?>" <?php echo $Checked ?>></td>
                    </tr>
                <?php } ?>
                </tbody>
            </table>
        </div>
    </div>

    <div class="Configitem2">
        <h1>Precio Hora Extra</h1>
        <input id="horaExtra" type="number" step="0.01" min="0.01" value="<?php echo $HoraExtra; ?>">
        <button class="BotonGeneral" onclick="UpdateHoraExtra()">Guardar</button>
    </div>
    <div class="Configitem3"></div>  
    <div class="Configitem4"></div>
</div>


<?php include_once '../templates/estructura_abajo.php'; ?>
</body>
</html>

<script src="js/configuracion.js"></script>