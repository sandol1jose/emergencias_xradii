//Variables
let Registros = null;
let Desde = null;
let Hasta = null;
let MargenInferior = 50; //Variable para el margen inferior de la tabla (usado en general.js)

function PintarTabla(json) {
    //Funcion para pintar la tabla
    document.getElementById("tbody_tabla").innerHTML = "";
    let SUMPrecio = 0;
    let SUMHonorarios = 0;
    let SUMHoraExtra = 0;
    let SUMBonif = 0;
    for (var i in json) {
        var RegistroIndividual = json[i];

        let fecha = RegistroIndividual['fecha'];
        let inicio = RegistroIndividual['inicio'];
        let fin = RegistroIndividual['fin'];
        if(fecha == null){
            fecha = "";
        }else{
            fecha = FormatearFecha(fecha);
        }

        if(inicio == null){
            inicio = "";
        }else{
            inicio = FormatearHora(inicio);
        }

        if(fin == null){
            fin = "";
        }else{
            fin = FormatearHora(fin);
        }

        if (RegistroIndividual['estudios'] == null) RegistroIndividual['estudios'] = "";
        if (RegistroIndividual['paciente'] == null) RegistroIndividual['paciente'] = "";
        if (RegistroIndividual['edad'] == null) RegistroIndividual['edad'] = "";
        if (RegistroIndividual['direccion'] == null) RegistroIndividual['direccion'] = "";


        //Calculando el precio
        var precio = RegistroIndividual['precio'];
        var honorarios = RegistroIndividual['honorarios'];
        var hora_extra = RegistroIndividual['hora_extra'];
        var Bonificacion = 0.00

        if(precio == null){
            precio = "";
        }else{
            Bonificacion = honorarios - hora_extra;
            Bonificacion = Number(Bonificacion.toFixed(2));

            //Sumando Valores totales
            SUMPrecio = SUMPrecio + precio;
            SUMPrecio = Number(SUMPrecio.toFixed(2));

            SUMHonorarios = SUMHonorarios + honorarios;
            SUMHonorarios = Number(SUMHonorarios.toFixed(2));

            SUMHoraExtra = SUMHoraExtra + hora_extra;
            SUMHoraExtra = Number(SUMHoraExtra.toFixed(2));

            SUMBonif = SUMBonif + Bonificacion;
            SUMBonif = Number(SUMBonif.toFixed(2));
        }

        /*Calculando las horas aproximadas*/
        var horas = CalcularHoras(RegistroIndividual['fecha'], RegistroIndividual['inicio'], RegistroIndividual['fin']);
        

        $cadena = `<tr>`;
        $cadena += `<td><div class="divTdEstado"><div class="estado_${RegistroIndividual["f_estado"]}"></div></div></td>`;
        $cadena += `<td>${fecha}</td>`;
        $cadena += `<td>${inicio}</td>`;
        $cadena += `<td>${fin}</td>`;
        $cadena += `<td>${RegistroIndividual['estudios']}</td>`;
        $cadena += `<td>${RegistroIndividual['paciente']}</td>`;
        $cadena += `<td>${RegistroIndividual['edad']}</td>`;
        $cadena += `<td>${RegistroIndividual['direccion']}</td>`;
        $cadena += `<td>${horas}</td>`;
        $cadena += `<td>Q ${precio}</td>`;
        $cadena += `<td>Q ${honorarios}</td>`;
        $cadena += `<td>Q ${hora_extra}</td>`;
        $cadena += `<td>Q ${Bonificacion}</td>`;
        $cadena += `<td><button class="btnView" onclick="VerEmergencia('${RegistroIndividual['id']}');">
                    </button></td>`;

        //Solo se podrán eliminar las que estén en estado 2 = "Ingresada";
        var estado = RegistroIndividual["f_estado"];
        var disabled = "";
        //if(estado != 2) disabled = "disabled";
        if(estado != 2){
            $cadena += `<td></td>`;
        }else{
            $cadena += `<td><button class="btnDel" onclick="EliminarEmergencia('${RegistroIndividual['id']}', ${estado}, 2);"></button></td>`;
        }

        $cadena += `</tr>`;
        $('#tbody_tabla').append($cadena);
    }

    //Pintando el pie de la tabla
    document.getElementById("precio").innerHTML = "Q " + SUMPrecio;
    document.getElementById("honorarios").innerHTML = "Q " + SUMHonorarios;
    document.getElementById("hora_extra").innerHTML = "Q " + SUMHoraExtra;
    document.getElementById("bonificacion").innerHTML = "Q " + SUMBonif;

    Registros = json;
}


function VerEmergencia(id) {
    window.location.href = "view.php?id=" + id;
}


function Filtrar(){
 
    var desde = document.getElementById("desde").value;
    var hasta = document.getElementById("hasta").value;
    var estado = document.getElementById("estado").value;

    if(desde == ""){ //Si no tiene nada el campo desde, le seteamos el primer dia del mes
        var date = new Date();
        var year = date.getFullYear();
        var month = date.getMonth() + 1;
        var primer_dia = new Date(year, month, 1).getDate(); //Fecha del primer día del mes
        desde = year + "-" + month + "-" + primer_dia;
    }

    if(hasta == ""){ //Si no tiene nada el campo hasta, le seteamos el ultimo dia del mes
        var date = new Date();
        var year = date.getFullYear();
        var month = date.getMonth() + 1;
        var ultimo_dia = new Date(year, month, 0).getDate(); //Fecha del último día del mes
        hasta = year + "-" + month + "-" + ultimo_dia;
    }


    if(desde != "" && hasta != ""){
        $.ajax({
            type: "POST",
            url: "app/ConsultarEmergencias.php",
            data: {"desde": desde, "hasta": hasta, "estado": estado},
            dataType: "html",
            headers: { 'Access-Control-Allow-Origin': 'origin-list' },
            beforeSend: function () {
            },
            error: function (Error) {
                console.log("error petición ajax");
            },
            success: function (data) {
                if(data != "0"){
                    const json = JSON.parse(data);
                    PintarTabla(json);
                }else{
                    alertsweetalert2('Faltan fechas', 'Estás olvidando ingresar las fechas para el filtro. Por favor ingresa una fecha válida', 'info');
                }
            }
        });
    }else{
        alertsweetalert2('Faltan fechas', 'Estás olvidando ingresar las fechas para el filtro. Por favor ingresa una fecha válida', 'info');
    }
}