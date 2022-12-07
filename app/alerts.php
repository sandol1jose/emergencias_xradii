<?php
	if(isset($_SESSION["Alerta"])){
		$Alerta = $_SESSION["Alerta"];
        
		if (strcmp($Alerta, "passUpdate") === 0){
			echo "<script> alertsweetalert2('Contraseña recuperada', '', 'success'); </script>";
		}

		if (strcmp($Alerta, "passIncorrect") === 0){
			echo "<script> alertsweetalert2('Contraseña incorrecta', '', 'error'); </script>";
		}

		if (strcmp($Alerta, "MailNoExist") === 0){
			echo "<script> alertsweetalert2('El correo ingresado no existe', '', 'error'); </script>";
		}

        if(strcmp($Alerta, 'RegistroCorrecto') === 0){
			echo "<script> alertsweetalert2('Registro completado exitosamente', '', 'success'); </script>";
		}

		if (strcmp($Alerta, "CodCaducate") === 0){
			echo "<script> alertsweetalert2('El código ha caducado', '', 'error'); </script>";
		}

		if(strcmp($Alerta, 'CorreoYaExiste') === 0){
			echo "<script> alertsweetalert2('Error', 'El correo ya existe', 'error'); </script>";
		}

		if(strcmp($Alerta, 'CodpassSend') === 0){
			echo "<script> alertsweetalert2('Enviamos un código a tu correo', '', 'success'); </script>";
		}
		
		if(strcmp($Alerta, 'CodPassIncorrect') === 0){
            echo "<script> alertsweetalert2('Error', 'El código es incorrecto', 'error'); </script>";
        }

		if(strcmp($Alerta, 'RolIncorrecto') === 0){
            echo "<script> alertsweetalert2('Error', 'Por favor elige un cargo', 'info'); </script>";
        }
		
		if(strcmp($Alerta, 'Logout') === 0){
            echo "<script> alertsweetalert2('Saliste de tu cuenta', '', 'success'); </script>";;
        }

		unset($_SESSION["Alerta"]);
	}
?>