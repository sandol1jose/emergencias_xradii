<?php
date_default_timezone_set('America/Guatemala');
$ip = "http://localhost";
//$ip = "https://alertaempresas.com/";
$Servidor = $ip.'/xradii/Emergencias';
//$Servidor = $ip;
?>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">

<!-- Libreria para mensajes flotantes -->
<script src="//cdn.jsdelivr.net/npm/sweetalert2@10"></script>
<script src="../js/general.js"></script>
<script src="../js/master.js"></script>
<?php
    include '../app/alerts.php'; //Alertas con javascript
?>

<!-- css para la barra lateral y superior -->
<link href="../css/estructura.css" rel="stylesheet">

<!-- Diferentes css -->
<link href="../css/General.css" rel="stylesheet">


<!-- Fuente de google -->
<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Inter">




<script src="<?php echo $Servidor; ?>/Cuenta/js/general.js"></script>