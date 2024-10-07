/* FUNCION PARA CALCULAR LA DIMENSION DEL DIV DE LA TABLA */
function CalcularDiv() {
    if(typeof MargenInferior !== 'undefined'){
        var ContenedorBase = $(".ContenedorBase").height();
        var item2 = $(".item2").height();
        var heightCompleto = $(window).height();
        var Restante = heightCompleto - ContenedorBase - item2 - MargenInferior;
        $('.divTabla').height(Restante);
        $('.divTabla2').height(Restante);
    }
}

$(window).resize(function(){
    CalcularDiv();
});

$(document).ready(function(){
    CalcularDiv();
});






/* FORMATOS DE FECHA Y HORA */
function FormatearHora(hora) {
    const myArray = hora.split(":");
    var da = new Date();
    da.setHours(myArray[0]);
    da.setMinutes(myArray[1]);
    da.setSeconds(myArray[2]);

    //Funcion que convierte de 24 horas a 12 horas
    var d = new Date(da.getTime());
    //var d = date;
    var hh = d.getHours();
    var m = d.getMinutes();
    var s = d.getSeconds();
    var dd = "AM";
    var h = hh;
    if (h >= 12) {
        h = hh-12;
        dd = "PM";
    }
    if (h == 0) {
        h = 12;
    }
    m = m<10?"0"+m:m;
    
    s = s<10?"0"+s:s;

    /* if you want 2 digit hours: */
    h = h<10?"0"+h:h;

    //return h+":"+m+":"+s+" "+dd;
    return h+":"+m+" "+dd;
}

function FormatearFecha(fecha){
    var date = new Date(fecha);
    const FormatearHora = (date)=>{
        let formatted_date = (date.getDate()+1) + "/" + (date.getMonth() + 1) + "/" + (date.getYear() - 100);
        return formatted_date;
    }
    return FormatearHora(date);
}

//Calcula las horas aproximadas
function CalcularHorasAproximadas(Fecha, horaInicio, HoraFin){
    var fechaInicio = new Date(Fecha + " " + horaInicio).getTime();
    var fechaFin    = new Date(Fecha + " " + HoraFin).getTime();
    var diff = fechaFin - fechaInicio;
    var horas = diff / (1000*60*60);  // (1000*60*60*24) --> milisegundos -> segundos -> minutos -> horas -> días
    horas = Math.ceil(horas); //Aproxima al siguiente numero
    return horas;
}

//Calcula las horas sin aproximar
function CalcularHoras(Fecha, horaInicio, HoraFin) {
    var fechaInicio = new Date(Fecha + " " + horaInicio).getTime();
    var fechaFin = new Date(Fecha + " " + HoraFin).getTime();
    var diff = fechaFin - fechaInicio;
    var horas = diff / (1000 * 60 * 60); // convierte milisegundos a horas
    return horas.toFixed(2); // asegura que el resultado tenga 4 decimales
}



function EliminarEmergencia(id, estado, tipo) {
    $.ajax({
        type: "POST",
        url: "app/EliminarEmergencia.php",
        data: { "id": id, "estado": estado, "tipo": tipo},
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            //console.log(data);
            const json = JSON.parse(data);
            if (json['Retorno'] == '1') {
                //console.log("Se han almacenado los datos correctamente");
                alertsweetalert2('Emergencia eliminada correctamente', '', 'success2');

                if (json['Registros'] != null) {
                    PintarTabla(json['Registros']);
                }else if(tipo == 2){
                    /*Si es de tipo 2 quiere decir que vamos a pintar la tabla
                     con el filtro establecido en la pantall "historial"*/
                    Filtrar();
                }
            } else if (json['Retorno'] == '0') {
                //console.log("Ocurrio un error al guardar los datos");
                alertsweetalert2('Error', 'Ocurrió un error al almacenar los datos', 'error');
            }else if(json['Retorno'] == '2'){
                alertsweetalert2('Acción no permitida', 'Solo el propietario puede eliminar la emergencia', 'info');
            } else {
                $Mensaje = json['Error']['errorInfo'][2];
                alertsweetalert2('Error', "Ocurrio un error, no se puede realizar la accion", 'error');
                console.log("Error SQL:" + $Mensaje);
            }
        }
    });
}