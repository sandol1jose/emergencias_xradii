<?php include_once '../templates/encabezado.php'; ?>

<?php
session_start();//inicio de sesion
if(!isset($_SESSION['Usuario'])){
    header('Location: ../Login/index.php');
}

if(!isset($_GET['id'])){
    header('Location: Tecnicos.php');
}

if(!isset($_SESSION['UsuarioConsulta'])){
    $_SESSION['IDUsuario'] = $_SESSION['Usuario']["IDUsuario"]; //Usuario propietario de la emergencia
    $_SESSION['IDUsuario_Modif'] = $_SESSION['Usuario']["IDUsuario"]; //Usuario que hará las modificaciones
    $_SESSION['IDEmergencia'] = $_GET['id'];
}else{
    $_SESSION['IDUsuario'] = $_SESSION['UsuarioConsulta']; //Usuario propietario de la emergencia
    $_SESSION['IDUsuario_Modif'] = $_SESSION['Usuario']["IDUsuario"]; //Usuario que hará las modificaciones
    $_SESSION['IDEmergencia'] = $_GET['id'];
}


$ruta = dirname( __FILE__ ) . '/../conexion.php';
include $ruta;
$Rol = $_SESSION['Usuario']["Rol"];
//$sql = "SELECT e.f_estado FROM emergencia e WHERE e.id = ".$_GET['id']." AND e.f_usuario = ".$_SESSION['IDUsuario']."";
$sql = "SELECT e.f_estado, r.id Rol_Usuario_Emergencia 
FROM emergencia e
JOIN usuarios u ON u.id = e.f_usuario 
JOIN rol r ON r.id = u.F_rol 
WHERE e.id = ".$_GET['id']." AND e.f_usuario = ".$_SESSION['IDUsuario']."";
$sentencia = $base_de_datos->prepare($sql);
$sentencia->execute(); 
$registro = $sentencia->fetchAll(PDO::FETCH_ASSOC);
if(count($registro) == 1){
    $EstadoEmergencia = $registro[0]["f_estado"];
    //Variable de Session que almacena el Rol del usuario propietario de la Emergencia
    unset($_SESSION['Rol_Usuario_Emergencia']);//Variable de Session que almacena el Rol del usuario propietario de la Emergencia
    $Rol_Usuario_Emergencia = $registro[0]["Rol_Usuario_Emergencia"];
    $_SESSION['Rol_Usuario_Emergencia'] = $Rol_Usuario_Emergencia;
}else{
    header('Location: Tecnicos.php');
}

$Titulo = "Detalle de emergencia";
?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vista</title>

    <link href="css/index.css" rel="stylesheet">
    <link href="css/view.css" rel="stylesheet">
    <link href="../css/modal.css" rel="stylesheet">
</head>
<body>

<?php include_once '../templates/estructura.php'; ?>

<div class="ContenedorBase">
    
    <?php if($Rol_Usuario_Emergencia != 4){ //Si no es piloto el propietario de la emergencia ?>
        <div class="contenedor">
            <div class="estilo1"><span>Inicio</span></div>
            <div class="estilo2"><span>Fin</span></div>
            <div class="estilo3"></div>  
            <div class="estilo4"><input type="time" id="Inicio" required></div>
            <div class="estilo5"><input type="time" id="Fin"></div>
            <div class="estilo8"><input type="text" id="Direccion" placeholder="Direccion / Lugar"></div> 
            <div class="estilo10">
                <input type="number" id="Precio" placeholder="Precio">
                <input type="number" id="Honorarios" placeholder="Honorarios">
            </div>
            <div class="estilo6">
                <input type="text" id="Paciente" placeholder="Paciente">
                <input type="number" id="Edad" placeholder="Edad">
            </div>
            <div class="estilo9"><textarea id="text-Estudios" placeholder="Estudios"></textarea></div>
 
            <div class="estilo7" id="estilo7">
                <div class="DivImag_individual">
                    <img src="../imagenes/image.png"> 
                </div>
            </div>
            <input type="hidden" name="id-Emergencia" id="id-Emergencia">
        </div>
    <?php }else{ ?> 
        <div class="contenedor2">
            <div class="estilo1"><span>Inicio</span></div>
            <div class="estilo2"><span>Fin</span></div>
            <div class="estilo3"></div>  
            <div class="estilo4"><input type="time" id="Inicio" required></div>
            <div class="estilo5"><input type="time" id="Fin"></div>
            <div class="estilo8"><input type="text" id="Direccion" placeholder="Direccion / Lugar"></div> 
            <div class="estilo10">
                <input type="number" id="Honorarios" placeholder="Honorarios">
            </div>
            <div class="estilo6">
                <input type="text" id="Paciente" placeholder="Paciente">
            </div>

            <input type="hidden" name="id-Emergencia" id="id-Emergencia">
        </div>
    <?php } ?> 

        <!-- The Modal -->
        <div id="myModal" class="modal">
            <span class="close">&times;</span>
            <img class="modal-content" id="img01">
            <div id="caption"></div>
        </div>
</div>


<div class="ContenedorBase2">

    <div class="divdetalles">
        <div class="detalles">
            <div class="det_title">
                <h1>Detalles</h1>
            </div>
            <div class="det_tabla">
                <table id="contenido_tabla" name="contenido_tabla">
                </table>
            </div>
        </div>

        <div class="detalles_botones" id="detalles_botones">
            <?php //Para usuario Administador
            if($Rol == 2 && $EstadoEmergencia == 2 ){ ?>
                <label><input type="checkbox" id="cbox1" value="Revision"> Marcar como revisada</label>
                <button class="BotonGeneral" onclick="GuardarCambios('2');">Guardar</button>
            <?php } ?>
            <?php //Para usuario admin
            if($Rol == 5 && $EstadoEmergencia == 3 ){ ?>
                <label><input type="checkbox" name="cboxadmin" id="cbox1" value="Aprobada" class="only-one"> Marcar como aprobada</label>
                <label><input type="checkbox" name="cboxadmin" id="cbox2" value="Rechazar" class="only-one"> Mandar a revisión</label>
                <button class="BotonGeneral" onclick="GuardarCambios('5');">Guardar</button>
            <?php } ?>
        </div>
    </div>

    <div class="divcomentarios">
        <div class="det_title">
            <h1>Comentarios</h1>
        </div>

        <div class="div_tabla">
            <div class="div_Contorno">
                <div class="arriba">
                    <table id="table_coment">
                    </table>
                </div>

                <div class="abajo">
                    <button class="BotonGeneral" onclick="AgregarComent()" id="btn_aggComent" >Agregar comentario</button>
                </div>
            </div>
        </div>
    </div>

</div>


<?php include_once '../templates/estructura_abajo.php'; ?>
</body>
</html>
<script src="js/view.js"></script>