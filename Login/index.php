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
</head>
<body>
    
<?php include '../templates/encabezado.php'; ?>

	<p class="parrafo1">Ingresa tus credenciales</p>

	<form method="POST" action="../app/Logear.php">
		<input type="email" name="correo" id="correo" placeholder="usuario@ejemplo.com" autocomplete="off" required>

		<input type="password" name="pass" id="pass" placeholder="Contraseña"  autocomplete="off" required><br>				

		<a class="Vinculo" href="RecuperarPass.php">¿Olvidaste tu contraseña?</a><br>

		<input class="BotonGuardar" type="submit" name="enviar" value="Ingresar">
	</form>

	<a class="Vinculo" href="registro.php">Registrarme</a><br>



</body>
</html>


