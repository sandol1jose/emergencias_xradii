var MargenInferior = 0;

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


function UpdateHoraExtra() {
    var precio = document.getElementById("horaExtra").value;
    $.ajax({
        type: "POST",
        url: "app/ActualizarHoraExtra.php",
        data: { "precio": precio},
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