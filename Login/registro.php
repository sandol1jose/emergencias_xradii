<?php
session_start();
?>

<!DOCTYPE html>
<html>
<head>
	
</head>
<body>
<?php include '../templates/encabezado.php'; ?>


	<form method="POST" action="../app/RegistrarUsuario.php">

		<p>Crea un usuario y contraseña nueva</p>

		<input class="InputGeneral" type="text" id="nombres" name="nombres" placeholder="Nombres" autocomplete="off" required><br>
		
		<input class="InputGeneral" type="text" id="apellidos" name="apellidos" placeholder="Apellidos" utocomplete="off" required><br>
		
		<input class="InputGeneral" type="text" id="rol" name="rol" placeholder="¿Cuál es tu cargo?" autocomplete="off"><br>
		
		<input class="InputGeneral" placeholder="Correo" type="text" name="correo" id="correo" autocomplete="off" spellcheck="false" required><br>
		
		<input class="InputGeneral" onkeyup="verificarContrasenia();" placeholder="Contraseña nueva" type="password" name="pass" id="pass" autocomplete="off" spellcheck="false" required><br>
		
		<input class="InputGeneral" onkeyup="verificarContrasenia();" placeholder="Confirmar contraseña" type="password" name="pass2" id="pass2" autocomplete="off" spellcheck="false" required><br>

		<input class="BotonGeneral" disabled class="BotonGuardar" type="submit" name="btn" id="btn" value="Siguiente" onclick="CambiarImagen();">	

	</form>

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