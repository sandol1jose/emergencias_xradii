<?php
//Archivo para crear la seseión del usuario a consultar
if (session_status() == PHP_SESSION_NONE) {
    session_start();//inicio de sesion
}

$_SESSION['UsuarioConsulta'] = $_POST["idUsuarioConsulta"];

?>