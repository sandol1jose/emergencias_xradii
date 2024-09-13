var MargenInferior = 0;

//Efecto de fade para las imagenes
/*$('#btn_Menu').click(function () {
    $("#item3").fadeToggle(100, function () {
        $("#item2").fadeToggle(100, function () {
            $("#item1").fadeToggle(250);
        });
    });
});

$('#btn_close').click(function () {
    $("#item1").fadeToggle(100, function () {
        $("#item2").fadeToggle(100, function () {
            $("#item3").fadeToggle(250);
        });
    });
});*/

function Autorizar(id) {

    var Check = document.getElementById("check_" + id).checked;
    
    $.ajax({
        type: "POST",
        url: "app/autorizar.php",
        data: { "id": id, "Check": Check },
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            const json = JSON.parse(data);
            if(json == 1){
                alertsweetalert2('Cambios realizados', '', 'success2');
            }else{
                alertsweetalert2('Error', 'Ocurrió un error al almacenar los datos', 'error');
            }
        }
    });
}


function UpdateHoraExtra(idDatos) {
    if(idDatos == 1){
        var precio = document.getElementById("horaExtra").value;
    }

    if(idDatos == 2){
        var precio = document.getElementById("horaExtra2").value;
    }
    
    $.ajax({
        type: "POST",
        url: "app/ActualizarHoraExtra.php",
        data: { "precio": precio, "idDatos": idDatos},
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            const json = JSON.parse(data);
            if(json == 1){
                alertsweetalert2('Cambios realizados', '', 'success2');
            }else{
                alertsweetalert2('Error', 'Ocurrió un error al almacenar los datos', 'error');
            }
        }
    });
}