importarScript("../Libraries/compressorjs-master/docs/js/compressor.js");
importarScript("https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js");

let ImagenesCargadas = 0;
let Registros = null;
let MargenInferior = 30; //Variable para el margen inferior de la tabla (usado en general.js)

//Efecto de fade para las imagenes
$('#btn_Menu').click(function () {
    $("#item3").fadeToggle(100, function () {
        $("#item2").fadeToggle(100, function () {
            $("#item1").fadeToggle(250);
        });
    });
});


//DAR CLICK A INPUT FILE
function BuscarArchivo(idFileImagen) {
    document.getElementById(idFileImagen).click();
}

//Cuando el archivo File cambie entonces se realiza ésta accion
try {
    document.getElementById('Input_File').addEventListener('change', (e) => {
        ProcesarImagen('Input_File', 'img', e);
    });
} catch (error) {
    console.log(error);
}


//COMPRIMIR IMAGENES ANTES DE SUBIR
function ProcesarImagen(NameInputFile, NameImage, e) {
    var NumeroImagenes = e.target.files.length;
    document.getElementById("Agg_Img").src = "../imagenes/loading-load.gif";
    document.getElementById("btn_listo").disabled = true;
    for (var i = 0; i <= (e.target.files.length - 1); i++) {
        const file = e.target.files[i];

        console.log(file['size'] / 1000);
        var calidad = 0;
        var Size = (file['size'] / 1000);
        if (Size >= 1000 && Size < 5000) {
            calidad = 0.4;
        } else if (Size >= 5000) {
            calidad = 0.3;
        } else {
            calidad = 0.6;
        }

        if (!file) {
            return;
        }

        new Compressor(file, {
            quality: calidad,

            // The compression process is asynchronous,
            // which means you have to access the `result` in the `success` hook function.
            success(result) {
                console.log(result['size'] / 1000);
                let formData = new FormData();

                // The third parameter is required for server
                formData.append("Imagen", result, result.name);

                let config = {
                    header: {
                        'Content-Type': 'multipart/form-data'
                    }
                }

                axios.post('../Sesiones/RecibirImagen.php', formData, config).then((response) => {
                    console.log('Upload success');
                    ImagenesCargadas++;
                    document.getElementById(NameInputFile).value = null; //Borramos el archivo del imput por que se cargo a una variable de sesion
                    //console.log("ImagenesCargadas: " + ImagenesCargadas);
                    //console.log("NumeroImagenes: " + NumeroImagenes);

                    if (ImagenesCargadas == NumeroImagenes) {
                        ImagenesCargadas = 0;
                        ConsultandoImagenes();
                        document.getElementById("Agg_Img").src = "../imagenes/agg.png";
                        document.getElementById("btn_listo").disabled = false;
                    }

                }).catch(error => {
                    console.log('error', error)
                    document.getElementById("Agg_Img").src = "../imagenes/agg.png";
                    document.getElementById("btn_listo").disabled = false;
                });
            },
            error(err) {
                console.log(err.message);
                document.getElementById(NameInputFile).value = null;
                document.getElementById(NameImage).src = "../imagenes/foto.png";
                alertsweetalert2('Error', 'Por favor carga una imagen', 'error');
                document.getElementById("Agg_Img").src = "../imagenes/agg.png";
                document.getElementById("btn_listo").disabled = false;
            },
        });
    }
}

//consultado con Ajax, la Sesion que contiene las imagenes
function ConsultandoImagenes() {
    $.ajax({
        type: "POST",
        url: "app/VerImagenes.php",
        data: {},
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            if (data != "0") {
                const json = JSON.parse(data);
                $("#Divs_Imagenes").fadeToggle(800, function () {
                    document.getElementById("Divs_Imagenes").innerHTML = "";

                    if (json["SinAgregar"] != null) {
                        /*console.log("SinAgregar");
                        console.log(json["SinAgregar"]);*/
                        var imagenes = json["SinAgregar"];
                        for (var i in imagenes) {
                            var img = '<div class="DivImag_individual">';
                            var img = img + `<div class="div_x">
                                                <button onclick="DeleteImage('${imagenes[i]}', 0);"><img src="../imagenes/ph_trash-fill.png" alt=""></button>
                                            </div>`;
                            var img = img + "<img src='../ImagenesDB/Radiografias/temp/" + imagenes[i] + "' width='70px'  name='img' id='img'>";
                            var img = img + '</div>';
                            $(".Divs_Imagenes").append(img);
                        }
                    }


                    if (json["EnDB"] != null) {
                        /*console.log("EnDB");
                        console.log(json["EnDB"]);*/

                        for (var i in json["EnDB"]) {
                            //console.log(json[i]);
                            var Nombre = json["EnDB"][i];
                            var img = '<div class="DivImag_individual">';
                            var img = img + `<div class="div_x">
                                                <button onclick="DeleteImage('${Nombre}', 1);"><img src="../imagenes/ph_trash-fill.png" alt=""></button>
                                            </div>`;
                            var img = img + "<img src='../ImagenesDB/Radiografias/" + Nombre + "' width='70px'  name='img' id='img'>";
                            var img = img + '</div>';
                            $(".Divs_Imagenes").append(img);
                        }
                    }

                    /*
                    if(json["SinAgregar"] == null){
                        console.log("Es null");
                    }else{
                        console.log(Object.keys(json["SinAgregar"]).length);
                    }*/
                    /*
                    if(Object.keys(json["EnDB"]).length == 0 && Object.keys(json["SinAgregar"]).length == 0){
                        var img = '<div class="DivImag_individual">';
                        var img = `<div class="div_x">
                                    <img src="../imagenes/image.png" width="70px" name="img" id="img">`;
                        var img = img + '</div>';
                        $(".Divs_Imagenes").append(img);
                    }*/

                    $("#Divs_Imagenes").fadeToggle(800);
                });
            } else {
                //Cargamos la imagen de previsualizacion
                $("#Divs_Imagenes").fadeToggle(800, function () {
                    var img = '<div class="DivImag_individual">';
                    var img = img + "<img src='../imagenes/image.png' width='70px'  name='img' id='img'>";
                    var img = img + '</div>';
                    document.getElementById("Divs_Imagenes").innerHTML = img;
                    $("#Divs_Imagenes").fadeToggle(800);
                });
            }
        }
    });
}


function GuardarDatos() {
    var IDEmergencia = document.getElementById("id-Emergencia").value;
    if (IDEmergencia === "") {
        //Se está creando un nuevo registro
        NuevaEmergencia();
    } else {
        //Se quiere modificar una emergencia
        ModificarEmergencia();
    }
}



//Guardando datos de la emergencia
function NuevaEmergencia(){
    var Inicio = document.getElementById("Inicio").value;
    var Fin = document.getElementById("Fin").value;
    var Direccion = document.getElementById("Direccion").value;
    var Honorarios = document.getElementById("Honorarios").value;

    var Precio = document.getElementById("Precio");
    Precio = Precio ? Precio.value : ""; //Esto es un if con else
    var Paciente = document.getElementById("Paciente");
    Paciente = Paciente ? Paciente.value : ""; //Esto es un if con else
    var Edad = document.getElementById("Edad");
    Edad = Edad ? Edad.value : ""; //Esto es un if con else
    var Estudios = document.getElementById("text-Estudios");
    Estudios = Estudios ? Estudios.value : ""; //Esto es un if con else

    var Comentarios = document.getElementById("text-Comentarios").value;

    $.ajax({
        type: "POST",
        url: "app/GuardarRegistro.php",
        data: {
            "Inicio": Inicio,
            "Fin": Fin,
            "Direccion": Direccion,
            "Precio": Precio,
            "Honorarios": Honorarios,
            "Paciente": Paciente,
            "Edad": Edad,
            "Estudios": Estudios,
            "Comentarios": Comentarios
        },
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            const json = JSON.parse(data);
            if (json['Retorno'] == '1') {
                //console.log("Se han almacenado los datos correctamente");
                alertsweetalert2('Emergencia almacenada correctamente', '', 'success2');

                //Limpiando los campos
                document.getElementById("Inicio").value = "";
                document.getElementById("Fin").value = "";
                document.getElementById("Direccion").value = "";
                document.getElementById("Honorarios").value = "";
                var Precio = document.getElementById("Precio");
                if(Precio) Precio.value = "";
                var Paciente = document.getElementById("Paciente");
                if(Paciente) Paciente.value = "";
                var Edad = document.getElementById("Edad");
                if(Edad) Edad.value = "";
                var Estudios = document.getElementById("text-Estudios");
                if(Estudios) Estudios.value = "";
                /*
                document.getElementById("Honorarios").value = "";
                document.getElementById("Paciente").value = "";
                document.getElementById("Edad").value = "";
                document.getElementById("text-Estudios").value = "";
                */
                document.getElementById("text-Comentarios").value = "";
                //Limpiamos las imagenes ya se elimino la sesion en GuardarRegistro.php
                ConsultandoImagenes();

                if (json['Registros'] != null) {
                    PintarTabla(json['Registros']);
                }
            } else if (json['Retorno'] == '0') {
                //console.log("Ocurrio un error al guardar los datos");
                alertsweetalert2('Error', 'Ocurrió un error al almacenar los datos', 'error');
            } else if (json['Retorno'] == "-1") {
                alertsweetalert2('Campos vacíos', 'Por favor llena al menos un campo', 'info');
            } else {
                $Mensaje = json['Error']['errorInfo'][2];
                alertsweetalert2('Error', "Ocurrio un error, no se puede realizar la accion", 'error');
                console.log("Error SQL:" + $Mensaje);
            }
        }
    });
}


function PintarTabla(json) {
    //Funcion para pintar la tabla
    document.getElementById("tbody_tabla").innerHTML = "";
    $Emergencia_En_Edicion = document.getElementById("id-Emergencia").value;
    for (var i in json) {
        var RegistroIndividual = json[i];
        //console.log(RegistroIndividual['inicio']);
        if (RegistroIndividual['id'] != $Emergencia_En_Edicion) {
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
            //if ( == null) RegistroIndividual['precio'] = "";

            var precio = RegistroIndividual['precio'];
            if(precio == null){
                precio = "";
            }else{
                precio = "Q." + precio;
            }

            var honorarios = RegistroIndividual['honorarios'];
            if(honorarios == null){
                honorarios = "";
            }else{
                honorarios = "Q." + honorarios;
            }


            $cadena = `<tr>`;
            $cadena += `<td>${fecha}</td>`;
            $cadena += `<td>${inicio}</td>`;
            $cadena += `<td>${fin}</td>`;
            $cadena += `<td>${RegistroIndividual['estudios']}</td>`;
            $cadena += `<td>${RegistroIndividual['paciente']}</td>`;
            $cadena += `<td>${RegistroIndividual['edad']}</td>`;
            $cadena += `<td>${RegistroIndividual['direccion']}</td>`;
            $cadena += `<td>${precio}</td>`;
            $cadena += `<td>${honorarios}</td>`;
            $cadena += `<td><button class="btnEdit" onclick="BuscarEmergencia('${RegistroIndividual['id']}');">
                        
                        </button></td>`;
            $cadena += `<td><button class="btnDel" onclick="EliminarEmergencia('${RegistroIndividual['id']}', ${RegistroIndividual['f_estado']}, 1);">
                        
                        </button></td>`;
            $cadena += `</tr>`;
            $('#tbody_tabla').append($cadena);
            //<img src='../imagenes/ph_trash-fill-white.png'></img>
            //<img src='../imagenes/clarity_pencil-solid.png'>
        }
    }
    Registros = json;
    //console.log(Registros);
}





function BuscarEmergencia(id) {
    $.ajax({
        type: "POST",
        url: "app/BuscarEmergencia.php",
        data: { "id": id },
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
                $Registro = json['Registros'][0];
                document.getElementById("Inicio").value = $Registro['inicio'];
                document.getElementById("Fin").value = $Registro['fin'];
                document.getElementById("Direccion").value = $Registro['direccion'];
                document.getElementById("Honorarios").value = $Registro['honorarios'];

                var Precio = document.getElementById("Precio");
                if(Precio) Precio.value = $Registro['precio'];
                var Paciente = document.getElementById("Paciente");
                if(Paciente) Paciente.value = $Registro['paciente'];
                var Edad = document.getElementById("Edad");
                if(Edad) Edad.value = $Registro['edad'];
                var Estudios = document.getElementById("text-Estudios");
                if(Estudios) Estudios.value = $Registro['estudios'];

                /*
                document.getElementById("Honorarios").value = $Registro['honorarios'];
                document.getElementById("Paciente").value = $Registro['paciente'];
                document.getElementById("Edad").value = $Registro['edad'];
                document.getElementById("text-Estudios").value = $Registro['estudios'];*/


                document.getElementById("text-Comentarios").value = $Registro['comentario'];
                document.getElementById("id-Emergencia").value = id;

                //if (json['Imagenes'] == true) {
                    //console.log(json['Imagenes2']);
                    ConsultandoImagenes();
                //}

                //Borramos el registro de la tabla inferior
                PintarTabla(Registros);
            } else if (json['Retorno'] == '0') {
                //console.log("Ocurrio un error al guardar los datos");
                alertsweetalert2('Error', 'Ocurrió un error al almacenar los datos', 'error');
            } else {
                $Mensaje = json['Error']['errorInfo'][2];
                alertsweetalert2('Error', "Ocurrio un error, no se puede realizar la accion", 'error');
                console.log("Error SQL:" + $Mensaje);
            }
            //document.getElementById("Error").innerHTML = data;
        }
    });
}



//Modificar la emergencia
function ModificarEmergencia() {
    var Inicio = document.getElementById("Inicio").value;
    var Fin = document.getElementById("Fin").value;
    var Direccion = document.getElementById("Direccion").value;
    var Honorarios = document.getElementById("Honorarios").value;

    var Precio = document.getElementById("Precio");
    Precio = Precio ? Precio.value : ""; //Esto es un if con else
    var Paciente = document.getElementById("Paciente");
    Paciente = Paciente ? Paciente.value : ""; //Esto es un if con else
    var Edad = document.getElementById("Edad");
    Edad = Edad ? Edad.value : ""; //Esto es un if con else
    var Estudios = document.getElementById("text-Estudios");
    Estudios = Estudios ? Estudios.value : ""; //Esto es un if con else
    /*
    var Honorarios = document.getElementById("Honorarios").value;
    var Paciente = document.getElementById("Paciente").value;
    var Edad = document.getElementById("Edad").value;
    var Estudios = document.getElementById("text-Estudios").value;
*/

    var Comentarios = document.getElementById("text-Comentarios").value;
    var IDEmergencia = document.getElementById("id-Emergencia").value;
    document.getElementById("id-Emergencia").value = ""; //Limpiamos el id-Emergencia

    $.ajax({
        type: "POST",
        url: "app/ModificarEmergencia.php",
        data: {
            "Inicio": Inicio,
            "Fin": Fin,
            "Direccion": Direccion,
            "Precio": Precio,
            "Honorarios": Honorarios,
            "Paciente": Paciente,
            "Edad": Edad,
            "Estudios": Estudios,
            "Comentarios": Comentarios,
            "IDEmergencia": IDEmergencia
        },
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            const json = JSON.parse(data);
            if (json['Retorno'] == '1') {
                //console.log("Se han almacenado los datos correctamente");
                alertsweetalert2('Emergencia almacenada correctamente', '', 'success2');

                //Limpiando los campos
                document.getElementById("Inicio").value = "";
                document.getElementById("Fin").value = "";
                document.getElementById("Direccion").value = "";
                document.getElementById("Honorarios").value = "";

                var Precio = document.getElementById("Precio");
                if(Precio) Precio.value = "";
                var Paciente = document.getElementById("Paciente");
                if(Paciente) Paciente.value = "";
                var Edad = document.getElementById("Edad");
                if(Edad) Edad.value = "";
                var Estudios = document.getElementById("text-Estudios");
                if(Estudios) Estudios.value = "";

                /*
                document.getElementById("Honorarios").value = "";
                document.getElementById("Paciente").value = "";
                document.getElementById("Edad").value = "";
                document.getElementById("text-Estudios").value = "";
                */

                document.getElementById("text-Comentarios").value = "";
                //Limpiamos las imagenes ya se elimino la sesion en ModificarEmergencia.php
                ConsultandoImagenes();

                if (json['Registros'] != null) {
                    PintarTabla(json['Registros']);
                }
            } else if (json['Retorno'] == '0') {
                //console.log("Ocurrio un error al guardar los datos");
                alertsweetalert2('Error', 'Ocurrió un error al almacenar los datos', 'error');
            } else if (json['Retorno'] == "-1") {
                alertsweetalert2('Campos vacíos', 'Por favor llena al menos un campo', 'info');
            } else {
                $Mensaje = json['Error']['errorInfo'][2];
                alertsweetalert2('Error', "Ocurrio un error, no se puede realizar la accion", 'error');
                console.log("Error SQL:" + $Mensaje);
            }
        }
    });
}


function HoraActual() {
    //Colocando la hora actual al campo inicio
    var fechaHora = new Date();
    var horas = fechaHora.getHours();
    var minutos = fechaHora.getMinutes();
    var segundos = fechaHora.getSeconds();

    //Añadimos el 0 delante por si solo es de 1 digito
    if (horas < 10) { horas = '0' + horas; }
    if (minutos < 10) { minutos = '0' + minutos; }
    if (segundos < 10) { segundos = '0' + segundos; }
    var hora = horas + ":" + minutos
    document.getElementById("Inicio").value = hora;
}
HoraActual();
setInterval('HoraActual()', 30000);




//Elimina una imagen ya sea de la base de datos o una imagen que está aun en Session
function DeleteImage(Imagen, Modo) {
    //Modo 0 = Imagen sin agregar / 1 = Imagen que ya esta en la base de datos
    /*console.log("Imagen: " + Imagen);
    console.log("Modo: " + Modo);*/

    $.ajax({
        type: "POST",
        url: "app/EliminarImagen_Temp.php",
        data: { "Imagen": Imagen, "Modo": Modo },
        dataType: "html",
        headers: { 'Access-Control-Allow-Origin': 'origin-list' },
        beforeSend: function () {
        },
        error: function (Error) {
            console.log("error petición ajax");
        },
        success: function (data) {
            //const json = JSON.parse(data); 
            //console.log(json);
            ConsultandoImagenes();
        }
    });
}