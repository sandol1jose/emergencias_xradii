<?php
session_start();
include_once '../templates/encabezado.php';
?>

<!DOCTYPE html>
<html>
<head>
	<title>Recuperar constraseña</title>

	<link href="css/index.css" rel="stylesheet">
</head>
<body>

<div class="base">

	<div class="contenedor">

		<span>Enviaremos un codigo a tu correo:</span>

		<div class="cuadrado">
			<form action="../app/RecuperarPass.php" method="POST" >
				
				<input type="email" name="Email" id="Email" placeholder="Escribe tu correo" autocomplete="off" required>
				
				<div>
					<div style="display: none;">
						<img class="imgCargando" src="../imagenes/Cargando6Recorte.gif" height="30px">
					</div>
				</div>

				<div class="">
					<input  class="BotonGeneral" type="submit" name="" value="Enviar codigo" onclick="CambiarImagen();">
				</div>
			</form>
		</div>
	</div>
</div>
</body>
</html>