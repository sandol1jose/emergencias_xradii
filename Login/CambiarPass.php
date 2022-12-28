<?php
session_start();
?>


<!DOCTYPE html>
<html lang="en">
<head>
	<title>Restablecer su contraseña</title>

    
    <link href="css/index.css" rel="stylesheet">

</head>
<body>
<?php include_once '../templates/encabezado.php'; ?>


<div class="base">
	<div class="contenedor">
        <span class="parrafo1">Copie el código de restablecimiento de su correo electrónico y péguelo a continuación.</span>
        
        <div class="cuadrado">

            <form method="POST" enctype="multipart/form-data" action="../app/CambiarPass.php">
                
                <input placeholder="Codigo" style="text-transform:uppercase" type="text" name="codigo" id="codigo" autocomplete="off" required><br>
                <input placeholder="Contraseña nueva" onkeyup="verificarContrasenia();" type="password" name="pass" id="pass" autocomplete="off" required><br>
                <input placeholder="Confirmar contraseña" onkeyup="verificarContrasenia();" type="password" name="pass2" id="pass2" autocomplete="off" required>
                
                <div id="DivImg2" class="Imagen2 zoom" style="display: none;">
                    <img src="../imagenes/Cargando6Recorte.gif" width="70px"><br>
                    <span class="Cargando">Cargando</span>
                </div>

                <br>
                <div id="DivButton">
                    <input disabled class="BotonGeneral" type="submit" name="btn" id="btn" value="Siguiente" onclick="CambiarImagen();">
                </div>

                <a href="index.php">Volver</a><br>

            </form>
        </div>
    </div>
</div>

</body>
</html>

<script type="text/javascript">
    function verificarContrasenia(){
        var pass1 = document.getElementById("pass").value;
        var pass2 = document.getElementById("pass2").value;
        if(pass1 != "" || pass2 != ""){
            if(pass1 == pass2){
				document.getElementById("btn").disabled = false;
            }else{
                document.getElementById("btn").disabled = true;
            }
        }
    }
</script>



<script>
	function CambiarImagen(){
		var campo = document.getElementById("").value;
		if(campo != "Codigo"){
			//Solo si el campo "Codigo" no esta vacio
			$("#DivButton").hide();
			$("#DivImg2").show();
		}
	}
</script>