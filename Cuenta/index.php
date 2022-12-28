<?php include_once '../templates/encabezado.php'; ?>

<?php
session_start();//inicio de sesion
if(!isset($_SESSION['Usuario'])){
    header('Location: ../Login/index.php');
}

$Rol = $_SESSION['Usuario']['Rol'];

if($Rol == 2 || $Rol == 3 || $Rol == 5){
    header('Location: ../Login/index.php');
}

include_once 'app/VaciarTemp.php'; //Vaciamos la carpeta temp
unset($_SESSION["IMAGENES_PRODUCTO"]);
unset($_SESSION["IMAGENES_PRODUCTO_ENDB"]);
unset($_SESSION['IMAGENES_AELIMINAR']);
//var_dump($_SESSION["IMAGENES_PRODUCTO"]);

$Titulo = "Ingresar nueva emergencia";


?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cuenta</title>

    <link href="css/index.css" rel="stylesheet">
</head>
<body>



<?php include_once '../templates/estructura.php'; ?>

<div class="ContenedorBase">
    

    <?php if($Rol != 4){ ?>
        <div class="contenedor">
            <div class="estilo1"><span>Inicio</span></div>
            <div class="estilo2"><span>Fin</span></div>
            <div class="estilo3"></div>  
            <div class="estilo4"><input type="time" id="Inicio" required></div>
            <div class="estilo5"><input type="time" id="Fin"></div>
            <div class="estilo8"><input type="text" id="Direccion" placeholder="Direccion / Lugar" autocomplete="off"></div> 
            <div class="estilo10">
                <input type="number" id="Precio" placeholder="Precio">
                <input type="number" id="Honorarios" placeholder="Honorarios">
            </div>
            <div class="estilo6">
                <input type="text" id="Paciente" placeholder="Paciente" autocomplete="off">
                <input type="number" id="Edad" placeholder="Edad">
            </div>
            <div class="estilo9"><textarea id="text-Estudios" placeholder="Estudios"></textarea></div>
            <div class="estilo7"><textarea id="text-Comentarios" placeholder="Comentarios"></textarea></div>
            <input type="hidden" name="id-Emergencia" id="id-Emergencia">
        </div>

    <?php }else{ ?>
        <div class="contenedor">
            <div class="estilo1"><span>Inicio</span></div>
            <div class="estilo2"><span>Fin</span></div>
            <div class="estilo3"></div>  
            <div class="estilo4"><input type="time" id="Inicio" required></div>
            <div class="estilo5"><input type="time" id="Fin"></div>
            <div class="estilo8"><input type="text" id="Direccion" placeholder="Direccion / Lugar" autocomplete="off"></div> 
            <div class="estilo10">
                <input type="number" id="Honorarios" placeholder="Honorarios">
            </div>
            <div class="estilo6">
                <input type="text" id="Paciente" placeholder="Paciente" autocomplete="off">
            </div>
            <div class="estilo7"><textarea id="text-Comentarios" placeholder="Comentarios"></textarea></div>
            <input type="hidden" name="id-Emergencia" id="id-Emergencia">
        </div>
    <?php } ?>

    <?php if($Rol != 4){ ?>
        <div class="Cont-Imagenes">
            <div class="Divs_Imagenes" id="Divs_Imagenes" name="Divs_Imagenes">
                <div class="DivImag_individual">
                    <img src="../imagenes/image.png" width="70px" name="img" id="img"> 
                </div>
            </div>

            <div class="Agg_Img DivImag_individual">
                <img onclick="BuscarArchivo('Input_File')" width="65px" src="../imagenes/agg.png" name="Agg_Img" id="Agg_Img">
                <input hidden type="file" name="Input_File" id="Input_File" accept="image/*" multiple>
            </div>
        </div>
    <?php } ?>

        <div class="divbtn">
            <button class="BotonGeneral" onclick="GuardarDatos()" id="btn_listo" >Listo</button>
        </div>


</div>



<div class="ContenedorBase2">


    
    <div class="divTabla">
        <div class="divtabla2">
            <table>
                <thead>
                    <tr>
                        <th class="tdfecha">Fecha</th>
                        <th class="tdfecha">Inicio</th>
                        <th class="tdfecha">Fin</th>
                        <th class="tdestudios">Estudios</th>
                        <th class="tdpaciente">Paciente</th>
                        <th class="tdprecio">Edad</th>
                        <th class="tdDireccion">Direccion</th>
                        <th class="tdprecio">Precio</th>
                        <th class="tdprecio">Hon.</th>
                        <th class="tdbtn_edit">Editar</th>
                        <th class="tdbtn_eliminar">Del.</th>
                    </tr>
                </thead>
                <tbody id="tbody_tabla" name="tbody_tabla">
                </tbody>
            </table>
        </div>
    </div>

</div>


<?php include_once '../templates/estructura_abajo.php'; ?>



</body>
</html>
<script src="js/index.js"></script>


<?php
//Consultamos las Emergencias "Incompletas"
include_once 'app/ConsultarEmergencias.php';
$Registros = ConsultarEmergencias($_SESSION['Usuario']['IDUsuario'], 1);
if($Registros != false){
    $Registros = json_encode($Registros);
    echo '<script>PintarTabla('.$Registros.');</script>';
}
?>