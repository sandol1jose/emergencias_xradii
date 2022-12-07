let MargenInferior = 50; //Variable para el margen inferior de la tabla (usado en general.js)
/*const GidEmergencia = null;
const GIDUsuario = null;
*/


BuscarEmergencia();
function BuscarEmergencia(){
    $.ajax({
        type: "POST",
        url: "app/BuscarEmergencia.php",
        data: {},
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            const json = JSON.parse(data);
            //console.log(json);
            if (json['Retorno'] == '1') {
                //Llenando los campos
                Registro = json['Registros'][0];
                document.getElementById("Inicio").value = Registro['inicio'];
                document.getElementById("Fin").value = Registro['fin'];
                document.getElementById("Direccion").value = Registro['direccion'];
                document.getElementById("Precio").value = Registro['precio'];
                document.getElementById("Honorarios").value = Registro['honorarios'];
                document.getElementById("Paciente").value = Registro['paciente'];
                document.getElementById("Edad").value = Registro['edad'];
                document.getElementById("text-Estudios").value = Registro['estudios'];
                
                document.getElementById("contenido_tabla").innerHTML = "";
                var fecha = FormatearFecha(Registro["fecha"]);
                
                 /*calculaos varios para los detalles
                Calculando las horas aproximadas*/
                var horas = CalcularHoras(Registro['fecha'], Registro['inicio'], Registro['fin']);


                //Calculando el precio
                var precio = Registro['precio'];
                var honorarios = Registro['honorarios'];
                var hora_extra = Registro['hora_extra'];
                var Bonificacion = 0.00

                if(precio == null){
                    precio = "";
                }else{
                    Bonificacion = honorarios - hora_extra;
                    Bonificacion = Number(Bonificacion.toFixed(2));
                }

                //Pintamos la tabla de detalles
                PintarTabla_Detalles("Fecha", fecha);
                PintarTabla_Detalles("Horas Aprox.", horas);
                PintarTabla_Detalles("Precio", "Q " + precio);
                PintarTabla_Detalles("Honorarios", "Q " + honorarios);
                PintarTabla_Detalles("Hora Extra Q.", "Q " + hora_extra);
                PintarTabla_Detalles("Bonificacion", "Q " + Bonificacion);
                PintarTabla_Detalles("Estado", Registro["nombre_estado"]);

                if (json['Imagenes'] == true) {
                    PintarImagenes(json['Imagenes2']);
                }

                //Ahora consultamos todos los comentarios
                ConsultarComentarios();

            } else if (json['Retorno'] == '0') {
                //console.log("Ocurrio un error al guardar los datos");
                alertsweetalert2('Error', 'Ocurrió un error al buscar los datos', 'error');
            } else {
                $Mensaje = json['Error']['errorInfo'][2];
                alertsweetalert2('Error', "Ocurrio un error, no se puede realizar la accion", 'error');
                console.log("Error SQL:" + $Mensaje);
            }
        }
    });
}


function PintarTabla_Detalles(nombre, registro) {
    var table = '<tr>';
    var table = table + `<th>${nombre}</th>`;
    var table = table + `<td>${registro}</td>`;
    var table = table + `</tr>`;
    $("#contenido_tabla").append(table);
}


function PintarImagenes(Imagenes) {
    document.getElementById("estilo7").innerHTML = "";
    
    for (var i in Imagenes) {
        var idImage = i;
        var name = Imagenes[i];
        var img = '<div class="DivImag_individual">';
        var img = img + `<img class='myImg' id='myImg_${idImage}' onclick=Modal('myImg_${idImage}') src='../ImagenesDB/Radiografias/${name}'>`;
        var img = img + '</div>';
        $(".estilo7").append(img);
    }
}


function ConsultarComentarios(){
    $.ajax({
        type: "POST",
        url: "app/ConsultarComentarios.php",
        data: {},
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            const json = JSON.parse(data);
            //console.log(json);
            if (json['Retorno'] == '1') {
                //Llenando los campos
                Comentarios = json['Registros'];
                document.getElementById("table_coment").innerHTML = "";
                for (var i in Comentarios) {
                    ComentSolo = Comentarios[i];
                    var ArrayFecha = FormatearFechaYHora(ComentSolo["fecha"]);
                    var img = `<tr><td><b>${ComentSolo["motivo"]}:</b></br>`;
                    var img = img + `${ComentSolo["comentario"]}</td>`;
                    var img = img + `<td>${ComentSolo["usuario"]}</br>`;
                    var img = img + `<span class="span_fecha">${ArrayFecha[0]}</span></br>`;
                    var img = img + `<span class="span_fecha">${ArrayFecha[1]}</span></td></tr>`;
                    $("#table_coment").append(img);
                    var img = "";
                }
                
            } else if (json['Retorno'] == '0') {
                //console.log("Ocurrio un error al guardar los datos");
                alertsweetalert2('Error', 'Ocurrió un error al buscar los comentarios', 'error');
            } else {
                $Mensaje = json['Error']['errorInfo'][2];
                alertsweetalert2('Error', "Ocurrio un error, no se puede realizar la accion", 'error');
                console.log("Error SQL:" + $Mensaje);
            }
        }
    });
}


function FormatearFechaYHora(fechaString) {
    var date = new Date(fechaString).toLocaleString();
    const myArray = date.split(",");
    var hora = FormatearHora(myArray[1].trim()); 
    var fecha = myArray[0];

    var ArrayRetorno = new Array();
    ArrayRetorno[0] = fecha;
    ArrayRetorno[1] = hora;
    return ArrayRetorno;
}



/*FUNCIONES PARA EL MODAL DE LA IMAGEN */
// Get the modal
var modal = document.getElementById("myModal");
// Get the <span> element that closes the modal
var span = document.getElementsByClassName("close")[0];

// When the user clicks on <span> (x), close the modal
span.onclick = function() { 
    modal.style.display = "none";
}

function Modal(idImagen) {
    // Get the image and insert it inside the modal - use its "alt" text as a caption
    var img = document.getElementById(idImagen);
    var modalImg = document.getElementById("img01");
    var captionText = document.getElementById("caption");

    modal.style.display = "block";
    modalImg.src = img.src;
    captionText.innerHTML = img.alt;
}





function AgregarComent() {
    const { value: formValues } = Swal.fire({
        title: 'Agregar comentario',
        html:
          '<input id="swal-input1" class="swal2-input" placeholder="Asunto">' +
          '<textarea id="swal-input2" class="swal2-input txtComent" placeholder="Comentario"></textarea>',
        focusConfirm: false,
        showCancelButton: true,
        preConfirm: () => {
          return [
            motivo = document.getElementById('swal-input1').value,
            comentario = document.getElementById('swal-input2').value,
            GuardarComentario(motivo, comentario)
          ]
        }
    })

    if (formValues) {
        Swal.fire(formValues)
    }
}



function GuardarComentario(motivo, comentario) {
    if(motivo != "" && comentario != ""){
        $.ajax({
            type: "POST",
            url: "app/GuardarComentario.php",
            data: {"motivo": motivo, "comentario": comentario},
            dataType: "html",
            headers: { 'Access-Control-Allow-Origin': 'origin-list' },
            beforeSend: function () {
            },
            error: function (Error) {
                console.log("error petición ajax");
            },
            success: function (data) {
                console.log(data);
                const json = JSON.parse(data);
                console.log(json);
                if (json['Retorno'] == '1') {
                    ConsultarComentarios();
                    alertsweetalert2('Comentario agregado', '', 'success2');
                } else if (json['Retorno'] == '0') {
                    //console.log("Ocurrio un error al guardar los datos");
                    alertsweetalert2('Error', 'Ocurrió un error al buscar los comentarios', 'error');
                } else {
                    $Mensaje = json['Error']['errorInfo'][2];
                    alertsweetalert2('Error', "Ocurrio un error, no se puede realizar la accion", 'error');
                    console.log("Error SQL:" + $Mensaje);
                }
            }
        });
    }else{
        alertsweetalert2('Campos vacios', 'No llenaste ningún campo', 'info');
    }
}
