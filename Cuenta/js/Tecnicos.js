MargenInferior = 30; //Variable para el margen inferior de la tabla (usado en general.js)

function VerUsuario(idUsuario) {
    console.log(idUsuario);

    $.ajax({
        type: "POST",
        url: "../Sesiones/UsuarioConsulta.php",
        data: {"idUsuarioConsulta": idUsuario},
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            window.location.href = "Historial.php";
        }
    });
}