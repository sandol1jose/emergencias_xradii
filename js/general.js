//https://sweetalert2.github.io/#examples

function alertsweetalert2(mensaje1, mensaje2, tipo){
    switch(tipo){
        case 'info':
            ConfirmAlert(mensaje1, mensaje2);
            break;
        case 'error':
            ErrorMensaje(mensaje1, mensaje2);
            break;
        case 'success':
            CheckMensaje(mensaje1);
            break;
    }
}

function ConfirmAlert(mensaje1, mensaje2){
    Swal.fire(
        mensaje1,
        mensaje2,
        'info'
      )
}

function ErrorMensaje(mensaje1, mensaje2){
    Swal.fire(
        mensaje1,
        mensaje2,
        'error'
      )
}

function CheckMensaje(mensaje1){
    Swal.fire({
        position: 'top-end',
        icon: 'success',
        title: mensaje1,
        showConfirmButton: false,
        timer: 1500
      })
}
