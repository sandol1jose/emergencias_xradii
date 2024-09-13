<?php
date_default_timezone_set('America/Guatemala');
$contraseña = "";
$usuario = "root";
$nombre_base_de_datos = "u658285525_emergencias";
try{
	$base_de_datos = new PDO('mysql:host=localhost;dbname=' . $nombre_base_de_datos, $usuario, $contraseña);
	$base_de_datos->exec("set names utf8");
}catch(Exception $e){
	echo "Ocurrió algo con la base de datos: " . $e->getMessage();
}
?>