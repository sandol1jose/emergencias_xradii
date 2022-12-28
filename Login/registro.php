<?php
session_start();
?>

<!DOCTYPE html>
<html>
<head>
	
	<?php include '../templates/encabezado.php'; ?>
	<link href="css/index.css" rel="stylesheet">
</head>
<body>


<div class="base">
	<div class="contenedor">
		<span>Registrarse</span>

		<div class="cuadrado">

			<form method="POST" action="../app/RegistrarUsuario.php">

			<input class="InputGeneral" type="text" id="nombres" name="nombres" placeholder="Nombres" autocomplete="off" required><br>
			
			<input class="InputGeneral" type="text" id="apellidos" name="apellidos" placeholder="Apellidos" utocomplete="off" required><br>
			
			<select name="rol" id="rol">
				<option value="0" selected>¿Cuál es tu cargo?</option>
				<option value="1">Técnico</option>
				<option value="2">Administrador</option>
				<!--<option value="3">Radiólogo</option>-->
				<option value="4">Piloto</option>
			</select><br>
			<input class="InputGeneral" placeholder="Nombre de usuario" type="text" name="username" id="username" autocomplete="off" spellcheck="false" required><br>

			<input class="InputGeneral" placeholder="Correo" type="text" name="correo" id="correo" autocomplete="off" spellcheck="false" required><br>
			
			<input class="InputGeneral" onkeyup="verificarContrasenia();" placeholder="Contraseña nueva" type="password" name="pass" id="pass" autocomplete="off" spellcheck="false" required><br>
			
			<input class="InputGeneral" onkeyup="verificarContrasenia();" placeholder="Confirmar contraseña" type="password" name="pass2" id="pass2" autocomplete="off" spellcheck="false" required><br>

			<input class="BotonGeneral" disabled class="BotonGuardar" type="submit" name="btn" id="btn" value="Siguiente" onclick="CambiarImagen();">	

			<a href="index.php">Iniciar Sesión</a><br>
			<div>
		</form>

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
