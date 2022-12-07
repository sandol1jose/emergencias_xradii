<?php include_once '../templates/encabezado.php'; ?>

<?php
session_start();//inicio de sesion
if(!isset($_SESSION['Usuario'])){
    header('Location: ../Login/index.php');
}

$_SESSION['IDUsuario'] = $_SESSION['Usuario']["IDUsuario"];
$_SESSION['IDUsuario_Modif'] = $_SESSION['Usuario']["IDUsuario"];
$_SESSION['IDEmergencia'] = $_GET['id'];

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

        <!-- The Modal -->
        <div id="myModal" class="modal">
            <span class="close">&times;</span>
            <img class="modal-content" id="img01">
            <div id="caption"></div>
        </div>


        <!--
        <div class="divbtn">
            <button class="BotonGeneral" onclick="GuardarDatos()" id="btn_listo" >Listo</button>
        </div>-->
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

        <div class="botones">

        </div>
    </div>

    <div class="divcomentarios">
        <div class="det_title">
            <h1>Detalles</h1>
        </div>

        <div class="div_tabla">
            <div class="div_Contorno">
                <div class="arriba">
                    <table id="table_coment">
                        <!--
                        <tr>
                            <td>
                            Comentario 1. Lorem ipsum dolor sit amet. 
Quo officia modi ut velit excepturi a 
magni tenetur? At molestiae esse et voluptatum
dolor vel nihil autem a totam quia ut inventore
praesentium et molestias esse hic explicabo dolorum! 
Sit incidunt adipisci aut quae quaerat quo cumque 
natus nam neque totam qui dolores asperiores! Quo 
dolore incidunt qui officiis nostrum et culpa porro.
                            </td>
                            <td>
                                Roberto<br>
                                12/12/22
                                12:30 PM<br>
                            </td>
                        </tr>

                        <tr>
                            <td>
                            Comentario 1. Lorem ipsum dolor sit amet. 
Quo officia modi ut velit excepturi a 
magni tenetur? At molestiae esse et voluptatum
dolor vel nihil autem a totam quia ut inventore
praesentium et molestias esse hic explicabo dolorum! 
Sit incidunt adipisci aut quae quaerat quo cumque 
natus nam neque totam qui dolores asperiores! Quo 
dolore incidunt qui officiis nostrum et culpa porro.
                            </td>
                            <td>
                                Roberto<br>
                                12:30 PM
                            </td>
                        </tr>


                        <tr>
                            <td>
                            Comentario 1. Lorem ipsum dolor sit amet. 
Quo officia modi ut velit excepturi a 
magni tenetur? At molestiae esse et voluptatum
dolor vel nihil autem a totam quia ut inventore
praesentium et molestias esse hic explicabo dolorum! 
Sit incidunt adipisci aut quae quaerat quo cumque 
natus nam neque totam qui dolores asperiores! Quo 
dolore incidunt qui officiis nostrum et culpa porro.
                            </td>
                            <td>
                                Roberto<br>
                                12:30 PM
                            </td>
                        </tr>

                        <tr>
                            <td>
                            Comentario 1. Lorem ipsum dolor sit amet. 
Quo officia modi ut velit excepturi a 
magni tenetur? At molestiae esse et voluptatum
dolor vel nihil autem a totam quia ut inventore
praesentium et molestias esse hic explicabo dolorum! 
Sit incidunt adipisci aut quae quaerat quo cumque 
natus nam neque totam qui dolores asperiores! Quo 
dolore incidunt qui officiis nostrum et culpa porro.
                            </td>
                            <td>
                                Roberto<br>
                                12:30 PM
                            </td>
                        </tr>

                        <tr>
                            <td>
                            Comentario 1. Lorem ipsum dolor sit amet. 
Quo officia modi ut velit excepturi a 
magni tenetur? At molestiae esse et voluptatum
dolor vel nihil autem a totam quia ut inventore
praesentium et molestias esse hic explicabo dolorum! 
Sit incidunt adipisci aut quae quaerat quo cumque 
natus nam neque totam qui dolores asperiores! Quo 
dolore incidunt qui officiis nostrum et culpa porro.
                            </td>
                            <td>
                                Roberto<br>
                                12:30 PM
                            </td>
                        </tr>

                        <tr>
                            <td>
                            Comentario 1. Lorem ipsum dolor sit amet. 
Quo officia modi ut velit excepturi a 
magni tenetur? At molestiae esse et voluptatum
dolor vel nihil autem a totam quia ut inventore
praesentium et molestias esse hic explicabo dolorum! 
Sit incidunt adipisci aut quae quaerat quo cumque 
natus nam neque totam qui dolores asperiores! Quo 
dolore incidunt qui officiis nostrum et culpa porro.
                            </td>
                            <td>
                                Roberto<br>
                                12:30 PM
                            </td>
                        </tr>-->

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