<?php
session_start();
if (isset($_SESSION['Usuario'])) {
	// Finalmente, destruir la sesión.
	session_destroy();
	
}

//Eliminamos las Cookies
setcookie("COOKIE_USUARIO_EMAIL", "", time() - 3600, "/");
setcookie("COOKIE_USUARIO_PASS", "", time() - 3600, "/");

session_start();
$_SESSION['Alerta'] = "Logout";
?>

<script type="text/javascript">
	window.location="../Login/index.php";
</script>