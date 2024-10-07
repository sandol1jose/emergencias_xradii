<?php
session_start();

if(!isset($_SESSION['Usuario'])){
    header('Location: ../Login/index.php');
}
?>

<!DOCTYPE html>
<html>
<head>
	
	<?php include '../templates/encabezado.php'; ?>
	<link href="css/index.css" rel="stylesheet">
</head>
<body>


<?php
//Consultado los cargos
$ruta = dirname( __FILE__ ) . '/../conexion.php';
include $ruta;

// Suponiendo que tienes el ID del usuario almacenado en la sesión
$IDUsuario = $_SESSION['Usuario']["IDUsuario"];

// Consulta para obtener los roles del usuario
$sql = "
    SELECT r.id AS rol_id, r.nombre_rol 
    FROM usuarios_rol ur
    JOIN rol r ON ur.F_rol = r.id
    JOIN usuarios u ON ur.F_usuario = u.id
    WHERE u.id = :idUsuario
";

$sentencia = $base_de_datos->prepare($sql);
$sentencia->bindParam(':idUsuario', $IDUsuario, PDO::PARAM_INT);
$sentencia->execute(); 

// Obtener los roles en un array
$roles = $sentencia->fetchAll(PDO::FETCH_ASSOC);
?>


<div class="base">
	<div class="contenedor">
		<span>Selecciona el Rol</span>

		<div class="cuadrado">
        
            <form method="POST" action="../app/AplicarRol.php">
                <select name="rol" id="rol">
                    <?php foreach ($roles as $rol): ?>
                        <option value="<?php echo $rol['rol_id']; ?>"><?php echo $rol['nombre_rol']; ?></option>
                    <?php endforeach; ?>
                </select><br>
                <input class="BotonGeneral" type="submit" name="enviar" value="Aceptar">	
            </form>

			<div>
		</form>

	</div>
</div>

</body>

</html>

