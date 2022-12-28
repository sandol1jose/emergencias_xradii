<?php
session_start();
?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
	<link href="css/index.css" rel="stylesheet">
</head>
<body>

<?php include '../templates/encabezado.php'; ?>



<div class="base">

	<div class="contenedor">
		<span>Inicio de Sesión</span>

		<div class="cuadrado">
			<form method="POST" action="../app/Logear.php">
				<input type="text" name="usuario" id="usuario" placeholder="usuario / correo" autocomplete="off" required>

				<input type="password" name="pass" id="pass" placeholder="Contraseña"  autocomplete="off" required><br>				

				<a href="RecuperarPass.php">¿Olvidaste tu contraseña?</a><br><br>

				<input class="BotonGeneral" type="submit" name="enviar" value="Ingresar">
			</form>

			<a href="registro.php">Registrarme</a><br>
		</div>
	</div>

</div>

</body>
</html>



