<?php
//session_start();
//session_destroy();
?>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página en Mantenimiento</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .maintenance-container {
            text-align: center;
            padding: 20px;
            border: 1px solid #dee2e6;
            border-radius: 10px;
            background-color: #ffffff;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        .maintenance-container h1 {
            font-size: 2.5rem;
            margin-bottom: 20px;
        }
        .maintenance-container p {
            font-size: 1.2rem;
            margin-bottom: 20px;
        }
        .maintenance-container .btn {
            font-size: 1rem;
        }
    </style>
</head>
<body>
    <div class="maintenance-container">
        <h1>Estamos en Mantenimiento</h1>
        <p>Estamos trabajando para mejorar nuestro sitio. ¡Volveremos pronto!</p>
        <a href="#" class="btn btn-primary">Volver a la página principal</a>
    </div>
</body>
</html>
