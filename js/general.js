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
        case 'success2':
            Little_Confirm(mensaje1);
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



function Little_Confirm(mensaje) {
    const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 2000,
        timerProgressBar: true,
        didOpen: (toast) => {
          toast.addEventListener('mouseenter', Swal.stopTimer)
          toast.addEventListener('mouseleave', Swal.resumeTimer)
        }
      })
      
    Toast.fire({
    icon: 'success',
    title: mensaje
    })
}