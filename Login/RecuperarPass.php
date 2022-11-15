<?php
session_start();
include_once '../templates/encabezado.php';
?>

<!DOCTYPE html>
<html>
<head>
	<title>Recuperara password</title>
</head>
<body>

		<p class="parrafo1">Enviaremos un codigo a tu correo:</p>

		<form action="../app/RecuperarPass.php" method="POST" >
			
			<input type="email" name="Email" id="Email" placeholder="Escribe tu correo" autocomplete="off" required>
			
			<div  class="DivContenedorImagen">
				<div id="DivImg2" style="display: none;">
					<img class="imgCargando" src="../imagenes/Cargando6Recorte.gif" height="30px">
				</div>
			</div>

			<div id="DivButton" class="">
				<input class="BotonGuardar" type="submit" name="" value="Enviar codigo" onclick="CambiarImagen();">
			</div>
		</form>

</body>
</html>