-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 11-09-2024 a las 22:56:01
-- Versión del servidor: 10.11.8-MariaDB-cll-lve
-- Versión de PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `u658285525_emergencias`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`u658285525_emerg`@`127.0.0.1` PROCEDURE `NewCodigoPass` (IN `codigo` VARCHAR(5), IN `fecha` TIMESTAMP, IN `F_usuarioVar` INT)  NO SQL
BEGIN
START TRANSACTION;

	#Si tubiera mas codigos sin aprobar las borramos
	DELETE FROM codigo_update_pass WHERE F_idusuario = F_usuarioVar AND confirmado = 0;

	#insertamos el nuevo codigo
	INSERT INTO codigo_update_pass(codigo, fecha, confirmado, F_idusuario)
    VALUES(codigo, fecha, 0, F_usuarioVar);
    
COMMIT;
END$$

CREATE DEFINER=`u658285525_emerg`@`127.0.0.1` PROCEDURE `NuevaEmergencia` (IN `fecha` DATE, IN `inicio` TIME, IN `fin` TIME, IN `direccion` VARCHAR(100), IN `precio` FLOAT, IN `honorarios` FLOAT, IN `paciente` VARCHAR(100), IN `edad` INT, IN `estudios` TEXT, IN `comentarios` TEXT, IN `IDUsuario` INT, IN `Estado` INT, IN `horas` INT, IN `rol` INT, OUT `IDEmergencia` INT)  BEGIN
START TRANSACTION;

	#consultamos el valor de la hora extra actual
    SET @Hora_Extra = (SELECT d.precio FROM datos d WHERE d.rol = rol); 
    
    SET @Hora_Extra = (@Hora_Extra * horas);

	#insertamos la emergencia
	INSERT INTO emergencia(inicio, fin, direccion, precio, honorarios, hora_extra, paciente, edad, estudios, fecha, f_estado, f_usuario)
    VALUES(inicio, fin, direccion, precio, honorarios, @Hora_Extra, paciente, edad, estudios, fecha, Estado, IDUsuario);
    
    #Obtenemos el ID de la emergencia
    SET @IDEmergencia = LAST_INSERT_ID();
    
    #Insertando el comentario
    IF comentarios IS NOT NULL THEN
    	INSERT INTO comentario(fecha, comentario, motivo, f_usuario, f_emergencia)
    	VALUES(CONCAT(fecha, ' ', inicio), comentarios, 'Inicio Emergencia', IDUsuario, @IDEmergencia);
     END IF;
    
    #Retornando el ID de la Emergencia
    SET IDEmergencia = @IDEmergencia; 
    
COMMIT;
END$$

CREATE DEFINER=`u658285525_emerg`@`127.0.0.1` PROCEDURE `NuevaImagen` (IN `ruta` VARCHAR(150), IN `f_emergencia` INT)  BEGIN
START TRANSACTION;

	INSERT INTO imagen(ruta, f_emergencia) 
    VALUES (ruta, f_emergencia);
    
COMMIT;
END$$

CREATE DEFINER=`u658285525_emerg`@`127.0.0.1` PROCEDURE `NuevoComentario` (IN `fecha` TIMESTAMP, IN `comentario` TEXT, IN `motivo` VARCHAR(50), IN `IDUsuario` INT, IN `IDEmergencia` INT)  BEGIN
START TRANSACTION;

	INSERT INTO comentario(fecha, comentario, motivo, f_usuario, f_emergencia)
	VALUES(fecha, comentario, motivo, IDUsuario, IDEmergencia);
    
COMMIT;
END$$

CREATE DEFINER=`u658285525_emerg`@`127.0.0.1` PROCEDURE `NuevoUsuario` (IN `Nombres` VARCHAR(60), IN `Apellidos` VARCHAR(60), IN `UserName` VARCHAR(20), IN `Correo` VARCHAR(70), IN `Pass` VARCHAR(200), IN `Rol` INT)  NO SQL
BEGIN
START TRANSACTION;

	#insertamos el usuario
	INSERT INTO usuarios(nombres, apellidos, username, correo, pass, autorizacion, F_rol)
    VALUES(Nombres, Apellidos, UserName, Correo, Pass, 0, Rol);
    
COMMIT;
END$$

CREATE DEFINER=`u658285525_emerg`@`127.0.0.1` PROCEDURE `UpdateEmergencia` (IN `fecha` DATE, IN `inicio` TIME, IN `fin` TIME, IN `direccion` VARCHAR(100), IN `precio` FLOAT, IN `honorarios` FLOAT, IN `paciente` VARCHAR(100), IN `edad` INT, IN `estudios` TEXT, IN `comentarios` TEXT, IN `IDEmergencia` INT, IN `Estado` INT, IN `IDUsuario` INT, IN `horas` INT, IN `rol` INT)  BEGIN
START TRANSACTION;

	#consultamos el valor de la hora extra actual
    SET @Hora_Extra = (SELECT d.precio FROM datos d WHERE d.rol = rol);

SET @Hora_Extra = (@Hora_Extra * horas);

	#modificamos la emergencia
	UPDATE emergencia e SET 
		e.inicio = inicio, 
		e.fin = fin, 
		e.direccion = direccion, 
		e.precio = precio,
		e.honorarios = honorarios,
		e.hora_extra = @Hora_Extra,
		e.paciente = paciente,
		e.edad = edad,
		e.estudios = estudios,
		e.f_estado = estado
	WHERE e.id = IDEmergencia;


	#Verificamos que comentarios no sea NULL
	IF comentarios IS NOT NULL THEN
		SET @Comentarios = (SELECT count(c.id) FROM comentario c
		WHERE c.f_emergencia = IDEmergencia
		ORDER BY c.id ASC
		LIMIT 1);
	
		IF @Comentarios > 0 THEN
			#modificamos el primer comentario
			UPDATE comentario c SET c.comentario = comentarios
			WHERE c.f_emergencia = IDEmergencia
			ORDER BY c.id ASC
			LIMIT 1;
		ELSE
			INSERT INTO comentario(fecha, comentario, motivo, f_usuario, f_emergencia)
	    	VALUES(CONCAT(fecha, ' ', inicio), comentarios, 'Inicio Emergencia', IDUsuario, IDEmergencia);
		END IF;
	END IF;
	    
COMMIT;
END$$

CREATE DEFINER=`u658285525_emerg`@`127.0.0.1` PROCEDURE `UpdateEmergencia_Admin` (IN `inicio` TIME, IN `fin` TIME, IN `direccion` VARCHAR(100), IN `precio` FLOAT, IN `honorarios` FLOAT, IN `paciente` VARCHAR(100), IN `edad` INT, IN `estudios` TEXT, IN `IDEmergencia` INT, IN `Estado` INT, IN `horas` INT)  BEGIN
START TRANSACTION;

	#verificamos el estado actual de la emergencia
    SET @EstadoActual = (SELECT e.f_estado FROM emergencia e WHERE e.id = IDEmergencia); 


   	IF @EstadoActual = 2 THEN #Solo se pueden hacer modificaciones cuando el estado es = 2 osea (Ingresasa)
   
   		#Consultamos el rol del usuario propietario de la emergencia
   		SET @Rol = (SELECT r.id FROM emergencia e JOIN usuarios u ON u.id = e.f_usuario
   		JOIN rol r ON r.id = u.F_rol WHERE e.id = IDEmergencia);
   	
   		#consultamos el valor de la hora extra actual
	    SET @Hora_Extra = (SELECT d.precio FROM datos d WHERE d.rol = @Rol); 
	   
	    SET @Hora_Extra = (@Hora_Extra * horas);
   	
		IF Estado IS NOT NULL THEN
			#modificamos la emergencia
			UPDATE emergencia e SET 
				e.inicio = inicio, 
				e.fin = fin, 
				e.direccion = direccion, 
				e.precio = precio,
				e.honorarios = honorarios,
				e.hora_extra = @Hora_Extra,
				e.paciente = paciente,
				e.edad = edad,
				e.estudios = estudios,
				e.f_estado = estado
			WHERE e.id = IDEmergencia;
		ELSE
			#modificamos la emergencia
			UPDATE emergencia e SET 
				e.inicio = inicio, 
				e.fin = fin, 
				e.direccion = direccion, 
				e.precio = precio,
				e.honorarios = honorarios,
				e.hora_extra = @Hora_Extra,
				e.paciente = paciente,
				e.edad = edad,
				e.estudios = estudios
			WHERE e.id = IDEmergencia;
		END IF;
	
	ELSE 
		#cuando el admin esté pasando al estado Aprobado
		IF @EstadoActual = 3 THEN
		
			IF Estado IS NOT NULL THEN
				#modificamos el estado de la emergencia
				UPDATE emergencia e SET 
					e.f_estado = estado
				WHERE e.id = IDEmergencia;
			END IF;
		
		END IF;
	
	END IF;
	    
COMMIT;
END$$

CREATE DEFINER=`u658285525_emerg`@`127.0.0.1` PROCEDURE `UpdatePass` (IN `Codigo` VARCHAR(5), IN `Pass` VARCHAR(200), IN `Correo` VARCHAR(70))  NO SQL
BEGIN
START TRANSACTION;

	#Se actualiza la contraseña
	UPDATE usuarios u SET u.pass = Pass WHERE u.correo = Correo;

	#Actualizamos el estado de codigo_update_pass
	UPDATE codigo_update_pass c SET c.confirmado = 1 WHERE c.codigo = Codigo;
    
COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `codigo_update_pass`
--

CREATE TABLE `codigo_update_pass` (
  `id` int(11) NOT NULL,
  `codigo` varchar(5) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `confirmado` int(11) NOT NULL,
  `F_idusuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `codigo_update_pass`
--

INSERT INTO `codigo_update_pass` (`id`, `codigo`, `fecha`, `confirmado`, `F_idusuario`) VALUES
(2, 'N10PB', '2023-01-27 18:39:29', 1, 2),
(3, 'CX3DS', '2023-11-06 16:01:57', 1, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comentario`
--

CREATE TABLE `comentario` (
  `id` int(11) NOT NULL,
  `fecha` timestamp NULL DEFAULT NULL,
  `comentario` text NOT NULL,
  `motivo` varchar(50) NOT NULL,
  `f_usuario` int(11) NOT NULL,
  `f_emergencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `comentario`
--

INSERT INTO `comentario` (`id`, `fecha`, `comentario`, `motivo`, `f_usuario`, `f_emergencia`) VALUES
(4, '2023-01-02 17:00:00', 'Hoy la emergencia fue con la técnico: Wilda \nEl programa me marca fecha 3 de enero y la emergencia fue 2 de enero.', 'Inicio Emergencia', 6, 5),
(6, '2023-01-02 18:30:00', 'Una Rx de abdomen de perrito, veterinaria de Oriente 02 enero 2023', 'Inicio Emergencia', 5, 7),
(10, '2023-01-07 15:12:00', 'Pasciente tratada con EPOC comenta que desean descartar Neumonía, presenta abundante flema ', 'Inicio Emergencia', 7, 13),
(11, '2023-01-08 17:00:00', 'Por ir a traer muebles de la nueva oficina fue el 4 de enero 2023', 'Inicio Emergencia', 6, 16),
(12, '2023-01-08 17:00:00', 'El 6 de enero se hicieron 2 emergencias en medicall y memorial. Técnico Wilda', 'Inicio Emergencia', 6, 17),
(13, '2023-01-08 12:09:00', 'Emergencia en hospital milenios. Técnico. Scarlett', 'Inicio Emergencia', 6, 18),
(14, '2023-01-11 17:00:00', 'Pasciente con Neumonía ', 'Inicio Emergencia', 7, 19),
(15, '2023-01-12 17:00:00', 'Emergencia 11 de Enero técnico. Scarlett ', 'Inicio Emergencia', 6, 20),
(16, '2023-01-18 19:31:59', 'Modificar horas, honorarios', 'De Sandra para Elder', 4, 4),
(17, '2023-01-18 19:34:22', 'Favor revisar \nNo me aparece el nombre del paciente', 'de Sandra para Elmer', 4, 4),
(18, '2023-01-18 19:36:04', 'Modificar hora, precio, honorarios', 'De Sandra para Elder', 4, 5),
(19, '2023-01-18 19:38:24', 'Revisar hora de salida', 'De Sandra para Elder', 4, 16),
(20, '2023-01-18 19:39:47', 'Revisar fecha', 'De Sandra para Elder', 4, 16),
(21, '2023-01-18 19:42:31', 'Verificar precio y honorarios', 'De Sandra para Elder', 4, 20),
(22, '2023-01-18 19:45:01', 'Revisar horas, precio, honorarios', 'De Sandra para Elder', 4, 18),
(23, '2023-01-18 19:47:44', 'Verificar Memorial\nVerificar horas, precio y honorarios', 'De Sandra para Elder', 4, 17),
(24, '2023-01-20 05:00:00', 'TORAX PA Y LAT\nRX DEL DIA 02 ENERO 2023', 'Inicio Emergencia', 5, 21),
(25, '2023-01-20 06:20:00', '1 ABDOMEN DE GATO\nRX TOMADO EL DIA 03 ENERO 2023', 'Inicio Emergencia', 5, 22),
(26, '2023-01-20 06:20:00', '1 ABDOMEN DE GATO\nRX TOMADO EL DIA 03 ENERO 2023', 'Inicio Emergencia', 5, 23),
(28, '2023-01-20 05:20:00', 'RX TOMADO EL DIA 5 ENERO 2023', 'Inicio Emergencia', 5, 25),
(29, '2023-01-20 05:20:00', 'RX TOMADO EL DIA 05 ENERO 2023', 'Inicio Emergencia', 5, 26),
(30, '2023-01-20 06:45:00', 'ABDOMEN PERRO\nRX TOMADO EL 17 ENERO 2023', 'Inicio Emergencia', 5, 27),
(32, '2023-01-21 19:32:00', 'Portátil fue el 20 de enero con la técnico. Wilda.', 'Inicio Emergencia', 6, 29),
(33, '2023-01-21 09:13:00', 'Rx tomada el dia 20 enero 2023', 'Inicio Emergencia', 5, 30),
(34, '2023-01-21 14:43:00', 'El servicio se hizo en la clínica pero se fue a traer y a dejar a paciente a la universidad cunori. Técnico Scarlett.', 'Inicio Emergencia', 6, 31),
(35, '2023-01-21 14:55:00', 'Exonerado por ING. Elder \nY demostración de equipo para Dr. Mauricio Orellana', 'Inicio Emergencia', 7, 32),
(36, '2023-01-21 19:12:50', 'Exonerado por el Inge. Elder\nY demostración de equipo para el dr. Mauricio Orellana.', 'Agrega comentari.', 6, 31),
(37, '2023-01-23 17:52:00', 'El portátil fue en la ermita concepción las minas técnico. Scarlett ', 'Inicio Emergencia', 6, 33),
(38, '2023-01-24 17:00:00', 'Emergencia en el hospital Milenium técnico. Scarlett ', 'Inicio Emergencia', 6, 35),
(39, '2023-01-24 17:52:00', 'En esta radiografía se le cobro extra al pasciente los honorarios del técnico y del piloto decidí dejar la casilla de honorario en 0 ', 'Inicio Emergencia', 7, 36),
(40, '2023-01-24 18:57:57', 'Rx realizados el día 23 de enero ', 'Especificación ', 7, 36),
(41, '2023-01-27 06:30:00', 'Rx realizados el día 26 de enero ', 'Inicio Emergencia', 7, 39),
(42, '2023-01-27 12:25:48', 'Esta vez se pagarán los honorarios por colaborar con la demostracion', 'es una demostracion al Dr. Mauricio Orellana', 1, 32),
(46, '2023-01-28 12:01:00', '28 enero 2023 \nPortatil ', 'Inicio Emergencia', 5, 42),
(47, '2023-01-28 20:41:34', 'Aparecen 2 horas extras y esas se incluyen en el pago del IGSS', 'De Sandra para Elder', 4, 7),
(48, '2023-01-30 18:45:00', '1 ABDOMEN PERRO', 'Inicio Emergencia', 5, 43),
(49, '2023-01-31 17:45:00', 'ABDOMEN DE 1 PERRO\nABDOMEN DE 1 PERRO\n\n( 1 ABDOMEN POR CADA PERRO, TOTAL 2 PERROS )', 'Inicio Emergencia', 5, 44),
(52, '2023-02-03 12:00:00', 'El portátil se hizo el 28 de enero en centro clínico Chiquimula técnico. Wilda.', 'Inicio Emergencia', 6, 48),
(53, '2023-02-03 21:07:00', 'Emergencia de portatil en hospital siglo 21 técnico. Wilda', 'Inicio Emergencia', 6, 49),
(54, '2023-02-03 21:07:00', 'SE CONSULTA PRECIO A COBRAR Y SE DEJA VALE\n( MADRE DE GERARDO PICEN )', 'Inicio Emergencia', 5, 50),
(55, '2023-02-06 12:45:31', 'todo esta correcto', 'sin comentarios', 2, 51),
(56, '2023-02-06 12:49:04', 'todo correcto', 'sin comentarios', 2, 46),
(57, '2023-02-06 12:51:34', 'todo correcto', 'Dra Marysol autorizo descuento se cobro Q300.00', 2, 50),
(58, '2023-02-06 12:57:19', 'por prueba se borro y se ingreso nuevamente en el mes de febrero \npor lo cual se pagara en el mes de febrero ', 'se verifico la informacion y es correcta', 2, 48),
(59, '2023-02-06 13:04:32', 'todo correcto ', 'Dra marysol autorizo descuento se cobro Q300.00', 2, 49),
(60, '2023-02-07 18:19:00', 'Se realizaron 3 perritos Rx de abdomen a ', 'Inicio Emergencia', 7, 52),
(61, '2023-02-11 14:55:00', 'ABDOMEN SIMPLE, ', 'Inicio Emergencia', 5, 53),
(62, '2023-02-13 19:35:00', 'PX  CON VENTILACION MECANICA', 'Inicio Emergencia', 5, 54),
(63, '2023-02-14 18:33:00', 'se fue al hospital Memorial por una operacion. tecnico Scarlett', 'Inicio Emergencia', 6, 55),
(64, '2023-02-14 14:42:28', 'la fecha fue el 9 de febrero', 'pd', 6, 55),
(65, '2023-02-14 19:34:00', 'fue en fecha 13 de febrero tecnico wilda', 'Inicio Emergencia', 6, 56),
(66, '2023-02-14 21:52:00', 'fecha 13 de febrero se realisaron 2 pacientes llamamos al ingeniero y el nos dijo que sse cobraran los 2 completos. tecnico Wilda.', 'Inicio Emergencia', 6, 57),
(67, '2023-02-14 21:50:00', '0', 'Inicio Emergencia', 5, 58),
(68, '2023-02-14 15:46:07', 'Fecha de ambas emergencias 13 febrero 2024', 'Emergencias', 5, 58),
(69, '2023-02-14 18:33:00', 'ABDOMEN, 1 PERRO', 'Inicio Emergencia', 5, 59),
(70, '2023-02-15 18:24:00', 'Px con seguro', 'Inicio Emergencia', 5, 60),
(71, '2023-02-16 18:18:00', 'ABDOMEN SIMPLE', 'Inicio Emergencia', 5, 61),
(72, '2023-02-17 05:00:00', 'Viaje a ciudad de Guatemala acompañando a Melanie para trámite de X-RADII con el igss.\nEl viaje se realizó el día 15 de febrero ', 'Inicio Emergencia', 6, 62),
(73, '2023-02-17 18:18:00', 'El día 16 de febrero se realizó un portátil técnico. Wilda.', 'Inicio Emergencia', 6, 63),
(74, '2023-02-17 18:30:00', '1 ESTUDIO', 'Inicio Emergencia', 5, 64),
(75, '2023-02-18 16:17:57', 'Nombre de la paciente no coincide con la emergencia', 'Elder', 4, 63),
(76, '2023-02-18 16:19:43', 'Por favor revisar porque el nombre de la paciente es diferente al nombre de la paciente que ingresó Wilda el mismo día', 'ElmeR', 1, 63),
(77, '2023-02-18 20:40:01', 'Delfa Martínez ', 'Px', 6, 63),
(78, '2023-02-20 21:20:00', 'Radiografía realizada el Domingo 19de febrero ', 'Inicio Emergencia', 7, 65),
(79, '2023-02-20 21:02:00', 'Se iso una emergencia en Concepción las minas. El día 19 de febrero técnico. Scarlett.', 'Inicio Emergencia', 6, 67),
(80, '2023-02-21 12:14:20', 'El programa calculó mal las horas\n', 'Elder', 4, 65),
(81, '2023-02-21 12:17:41', 'Se dejó vale en centro clínico\n', 'Forma de pago', 4, 68),
(82, '2023-02-21 19:26:00', 'El 21 se hizo un portátil. Técnico. Scarlett ', 'Inicio Emergencia', 6, 69),
(83, '2023-02-23 05:30:00', 'Se fue a la capital a traer producto de x-tech con el ingeniero ', 'Inicio Emergencia', 6, 71),
(84, '2023-02-23 21:55:00', 'Se hizo un portátil en unidad medica técnico. Scarlett ', 'Inicio Emergencia', 6, 73),
(85, '2023-02-26 19:14:32', 'Programa error en cálculo de horario ', 'Elder', 4, 67),
(86, '2023-02-26 19:15:34', 'Programa da error en cálculo de horario', 'Elder', 4, 62),
(87, '2023-02-26 19:18:22', 'Error en ingreso de costo', 'Elder', 4, 71),
(88, '2023-02-27 16:21:17', 'Modifique al precio en 228 ', 'Modificar ', 7, 65),
(89, '2023-02-27 18:24:00', 'Px valerie marcos. Abdomen\nPx rosa lidia martinez torax pa y lat\nPx oscar lemus abdomen ', 'Inicio Emergencia', 5, 74),
(90, '2023-02-27 18:24:00', 'Px: Valerie Marcos \nPx: Rosalía Martínez\nPx: Óscar Lemus\nel servicio se dio el sabado 25 de febrero\ntecnico. wilda', 'Inicio Emergencia', 6, 75),
(91, '2023-02-27 17:18:00', 'px. Fernando Velásquez \nel servicio se dio el dia domingo 26 de febrero. tecnico. Wilda.', 'Inicio Emergencia', 6, 76),
(92, '2023-02-27 18:40:00', 'Sala de operacion de muñeca izquierda ', 'Inicio Emergencia', 7, 77),
(93, '2023-02-27 17:18:00', '2do px\n\nOtilio Gutierrez. Tobillo ap y lat     \n\n  Y pie ap y lat ( exonerado )\n\n\nemergencias el dia domingo 26 febrero ', 'Inicio Emergencia', 5, 78),
(94, '2023-02-27 19:16:22', 'tomadas el dia sabado 25 febrero', 'emergencias', 5, 74),
(95, '2023-02-27 17:34:00', '2 PX\n\nKARINA CORNEJO ESCOBAR  TORAX PA Y LAT', 'Inicio Emergencia', 5, 79),
(96, '2023-02-27 21:44:00', '2DO. PX\n\nCIRUGIA  A \n\n FERNANDO VELASQUEZ    MANO AP Y LAT', 'Inicio Emergencia', 5, 80),
(97, '2023-02-28 21:44:00', 'Px. Pedro González\nSe realizaron 2 portatiles uno en sala d cirugía y un tórax el día 27 de febrero técnico. Wilda.', 'Inicio Emergencia', 6, 81),
(98, '2023-03-08 12:00:00', 'La emergencia de portatil se realizó el día sábado 4 de marzo.\nTécnico. Scarlett. ', 'Inicio Emergencia', 6, 83),
(99, '2023-03-11 15:26:24', 'Es correcto', 'Revisada', 4, 79),
(100, '2023-03-11 15:58:27', 'Todo correcto', 'Revisada', 4, 80),
(101, '2023-03-11 16:04:28', 'En sala de cirugia los honorarios son de Q 200.00', 'Corregir', 4, 80),
(102, '2023-03-11 13:00:00', 'TORAX PA Y LAT\nABDOMEN', 'Inicio Emergencia', 5, 84),
(103, '2023-03-11 14:50:00', 'TORAX AP,  UNCO ESTUDIO,', 'Inicio Emergencia', 5, 85),
(104, '2023-03-12 13:00:00', 'El día sábado 11 de marzo se realizó este portátil. Técnico. Wilda.', 'Inicio Emergencia', 6, 86),
(105, '2023-03-12 14:50:00', 'El día sábado 11 de marzo se realizó el portátil. Técnico. Wilda.', 'Inicio Emergencia', 6, 87),
(106, '2023-03-13 18:40:00', 'Un abdomen de un perrito', 'Inicio Emergencia', 5, 88),
(107, '2023-03-16 00:24:00', 'Estudio realizado a las cero hrs con 24 min. y finalizado a la 1.14 am del dia 16 de marzo', 'Inicio Emergencia', 5, 89),
(108, '2023-03-17 20:27:00', 'RX EN CIRUGIA EL DIA 16 DE MARZO  SE INGRESO A LAS 22.27 PM Y SE SALIO EL DIA 17 MARZO  A LA  01.16 AM', 'Inicio Emergencia', 5, 90),
(110, '2023-03-18 10:00:50', 'prueba', 'anotacion', 4, 81),
(111, '2023-03-18 20:27:00', 'Se realizó servicio de rayos x en hospital centro medico en horario de 10:27 PM ah 1:16 AM. Fue el día jueves 16 de Marzo técnico. Wilda.', 'Inicio Emergencia', 6, 93),
(112, '2023-03-18 17:00:00', 'Se realizó servicio de rayos x en los Achiotes Ipala. Técnico.Wilda.', 'Inicio Emergencia', 6, 95),
(113, '2023-03-18 06:30:00', 'Atención de emergencias de portatil en hospital Memorial Chiquimula. Técnico Scarlett.', 'Inicio Emergencia', 6, 96),
(114, '2023-03-19 14:00:00', 'Emergencia de portatil en centro clínico. Técnico. Scarlett ', 'Inicio Emergencia', 6, 98),
(115, '2023-03-22 12:14:07', 'Perdon ya le habia dado revisada, pero estaba recordando que a Q 50.00 se les iba a pagar las emergencias', 'Elder', 4, 79),
(116, '2023-03-22 14:07:48', 'Hice la modificacion en honorarios, le agregue el equivalente a 2 horas extras.', 'Modificacion', 4, 93),
(117, '2023-03-24 11:41:23', 'Favor rechazar para poder modificar honorarios', 'Elder', 4, 80),
(118, '2023-03-29 18:35:00', '2 PERRITOS / 2 ABDOMEN  Q 100.00\n\nLOS Q25.00 ADICIONALES\n\n SON POR LA CIRUGIA DEL SIGLO 21 CON FECHA  27 FEBRERO Y UN TORAX SE COLOCO MONTO Q 250.00\n\nCIRUJIA DE FERNANDO VELASQUEZ Y TORAX DE PEDRO GONZALEZ\n\n\n', 'Inicio Emergencia', 5, 103),
(119, '2023-03-30 18:50:00', 'Se realizó una emergencia de portatil en hospital centro clínico Chiquimula. ', 'Inicio Emergencia', 6, 104),
(120, '2023-04-01 16:45:00', 'Le coloque esos honorarios basándome en otro paciente realizado en el mes de febrero (Harrys Paredes ) a cual se le colocó ese monto por lo mismo dos estudios realizados en emergencia en concepción ', 'Inicio Emergencia', 7, 106),
(121, '2023-04-04 18:30:00', 'Rx realizados el lunes 3 de abril ', 'Inicio Emergencia', 7, 108),
(122, '2023-04-04 16:45:00', 'El servicio de portatil se realizó el día sábado 1 de Abril. Técnico. Scarlett.', 'Inicio Emergencia', 6, 109),
(123, '2023-04-04 17:00:00', 'Servicio de portatil se realizó el día 3 de Abril. Técnico. Scarlett.', 'Inicio Emergencia', 6, 110),
(124, '2023-04-06 22:50:00', 'Se realizó emergencia de portatil en hospital siglo 21. Técnico. Scarlett ', 'Inicio Emergencia', 6, 114),
(125, '2023-04-06 00:01:54', 'El portátil se realizó el 5 de abril', 'Fecha corregida ', 6, 114),
(126, '2023-04-06 09:50:00', 'Se realizó servicio de portatil. Técnico. Scarlett ', 'Inicio Emergencia', 6, 115),
(127, '2023-04-06 15:40:00', 'Por mantenimiento en X-RADII.', 'Inicio Emergencia', 6, 117),
(128, '2023-04-10 18:00:00', 'Casa Particular, enfrente clinica dr. Mazariegos ', 'Inicio Emergencia', 5, 119),
(129, '2023-04-11 17:00:00', 'El día 10 de Abril se realizo una emergencia en hospital siglo 21 Chiquimula. Técnico Wilda.', 'Inicio Emergencia', 6, 120),
(130, '2023-04-11 06:55:00', 'Rx horario am, antes del ingreso a clinica', 'Inicio Emergencia', 5, 121),
(131, '2023-04-11 18:00:00', '10 de Abril se realizo portátil en casa particular frente a clínica del Dr. Mazariegos. Técnico. Wilda.', 'Inicio Emergencia', 6, 122),
(132, '2023-04-11 06:55:00', 'Emergencia de portatil hospital unidad medica. Técnico. Wilda.', 'Inicio Emergencia', 6, 123),
(133, '2023-04-16 17:50:00', 'Se realizó emergencia de portatil en hospital siglo 21 Chiquimula. Técnico. Scarlett ', 'Inicio Emergencia', 6, 124),
(134, '2023-04-17 20:45:00', 'El 16 de abril se realizó el portátil en hospital siglo 21 Chiquimula. Técnico. Scarlett ', 'Inicio Emergencia', 6, 127),
(135, '2023-04-21 21:30:00', 'Se realizó portátil técnico. Scarlett ', 'Inicio Emergencia', 6, 133),
(136, '2023-04-21 22:15:00', 'Se realizó servicio de portatil en sala de cirugía en hospital centro clínico Chiquimula. Técnico. Scarlett ', 'Inicio Emergencia', 6, 134),
(137, '2023-04-22 22:15:00', 'Cirugía ', 'Inicio Emergencia', 7, 135),
(138, '2023-04-22 12:15:00', 'Se realizó portátil en centro clínico Chiquimula. Técnico. Wilda ', 'Inicio Emergencia', 6, 136),
(139, '2023-04-22 12:15:00', 'CONTROL POST OPERATORIO', 'Inicio Emergencia', 5, 137),
(140, '2023-04-22 01:15:00', 'RX CONTROL , FEMUR DERECHO', 'Inicio Emergencia', 5, 138),
(141, '2023-04-23 22:05:00', 'Emergencia de portatil. Técnico. Wilda ', 'Inicio Emergencia', 6, 139),
(142, '2023-04-23 22:05:00', '1 mes 15 dias', 'Inicio Emergencia', 5, 140),
(143, '2023-04-24 08:56:35', 'Lo corregí porque decia de 12:15 pm a 1:15 am', 'Horario', 4, 137),
(144, '2023-04-24 06:00:00', 'Perrito', 'Inicio Emergencia', 5, 141),
(145, '2023-04-25 12:02:09', 'Es correcto', 'Revisada', 4, 103),
(147, '2023-04-29 20:30:00', '.', 'Inicio Emergencia', 7, 144),
(148, '2023-05-01 10:00:00', 'Se realizó emergencia de portatil en Concepción las minas el día 1 de mayo. Técnico. Scarlett ', 'Inicio Emergencia', 6, 147),
(149, '2023-05-01 11:33:00', 'Se realizó Emergencia de portatil en Esquipulas Olopita el día 1 de mayo en casa particular. Técnico. Scarlett ', 'Inicio Emergencia', 6, 148),
(150, '2023-05-04 18:30:00', 'Portátil en medical técnico. Scarlett ', 'Inicio Emergencia', 6, 152),
(151, '2023-05-05 17:00:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 153),
(152, '2023-05-05 17:30:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 154),
(153, '2023-05-07 12:55:00', 'Técnico. Wilda ', 'Inicio Emergencia', 6, 158),
(154, '2023-05-07 13:51:00', 'Técnico. Wilda', 'Inicio Emergencia', 6, 159),
(155, '2023-05-07 12:55:00', 'BEBE DE 7 HRAS DE NACIDA', 'Inicio Emergencia', 5, 161),
(156, '2023-05-08 18:10:42', 'Px de Hospital Integral', 'EMERGENCIA', 4, 144),
(157, '2023-05-08 18:13:06', 'Efectivo', 'FORMA DE PAGO', 4, 155),
(158, '2023-05-08 18:14:39', 'Vale Q 550.00', 'FORMA DE PAGO', 4, 156),
(159, '2023-05-08 18:25:16', 'Efectivo Q 550.00\nEmergencia px de Medicall', 'FORMA DE PAGO', 4, 160),
(160, '2023-05-08 18:28:34', 'Px de Centro Medico, canceló en efectivo Q 550.00', 'FORMA DE PAGO', 4, 161),
(161, '2023-05-08 18:30:54', 'Px de Centro Clinico de Chiquimula, Canceló Q 550.00 en efectivo', 'FORMA DE PAGO', 4, 162),
(162, '2023-05-08 18:38:37', 'Px canceló en efectivo ', 'FORMA DE PAGO', 4, 157),
(163, '2023-05-08 19:03:00', 'Técnico. Wilda', 'Inicio Emergencia', 6, 163),
(164, '2023-05-08 06:00:00', '2 PERRITOS\n\n1 POR ABDOMEN Y \n1 POR CRANEO', 'Inicio Emergencia', 5, 164),
(165, '2023-05-08 06:51:00', 'INTENSIVO', 'Inicio Emergencia', 5, 165),
(166, '2023-05-08 07:50:00', 'ABDOMEN SUPINO Y BIPEDESTACION', 'Inicio Emergencia', 5, 166),
(167, '2023-05-09 06:03:00', '1 Gatito', 'Inicio Emergencia', 5, 168),
(168, '2023-05-14 14:30:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 169),
(169, '2023-05-15 18:27:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 171),
(170, '2023-05-16 06:27:00', 'Rx realizados el día 15/05/2023', 'Inicio Emergencia', 7, 172),
(171, '2023-05-16 20:00:00', 'Emergencia ', 'Inicio Emergencia', 7, 174),
(172, '2023-05-18 12:15:32', 'Se dejo vale', 'FORMA DE PAGO', 4, 165),
(173, '2023-05-18 12:18:25', 'Cancelo en efectivo', 'FORMA DE PAGO', 4, 166),
(174, '2023-05-18 12:45:16', 'Efectivo', 'FORMA DE PAGO', 4, 167),
(175, '2023-05-18 12:58:34', 'Con vale, px de Centro Medico', 'FORMA DE PAGO', 4, 174),
(176, '2023-05-18 13:01:17', 'Elder favor rechazarla para poder corregir horario. Gracias', 'RECHARZAR', 4, 172),
(177, '2023-05-21 11:20:00', 'PX CANELA EN EFECTIVO', 'Inicio Emergencia', 5, 176),
(178, '2023-05-21 11:20:00', 'Técnico. Wilda ', 'Inicio Emergencia', 6, 177),
(179, '2023-05-21 16:45:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 178),
(180, '2023-05-21 04:45:00', 'PX INTENSIVO,  CON VALE', 'Inicio Emergencia', 5, 179),
(181, '2023-05-25 12:00:00', 'Nos reunimos el 29 de abril pero se modificó debido a que coloque mal los datos y no se pudo modificar al momento de querer arreglarlo ', 'Inicio Emergencia', 7, 180),
(182, '2023-05-27 12:00:00', 'Técnico. Scarlett.\n', 'Inicio Emergencia', 6, 185),
(183, '2023-05-27 15:39:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 186),
(184, '2023-05-30 17:00:00', 'Fecha: 29 de mayo de 2023 con ingeniero Elder ', 'Inicio Emergencia', 6, 188),
(185, '2023-05-31 19:30:00', 'Emergencia de portatil el día lunes en el centro clínico Chiquimula. Técnico. Scarlett.', 'Inicio Emergencia', 6, 189),
(186, '2023-05-31 18:50:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 190),
(187, '2023-06-03 12:00:00', 'Px cancela en efectivo ', 'Inicio Emergencia', 5, 192),
(188, '2023-06-04 17:30:00', 'Estudio realizado el día viernes 02  de Junio,olvide agregarla ese día ', 'Inicio Emergencia', 7, 193),
(189, '2023-06-06 12:00:00', 'Servicio de portatil se realizó el día sábado 3 de Junio. Técnico. Wilda ', 'Inicio Emergencia', 6, 194),
(190, '2023-06-06 19:50:00', 'Px con vale', 'Inicio Emergencia', 5, 195),
(191, '2023-06-07 19:50:00', 'Emergencia de portatil en centro clínico Chiquimula el día 6 de junio ', 'Inicio Emergencia', 6, 197),
(192, '2023-06-07 22:24:00', 'Px vale', 'Inicio Emergencia', 5, 198),
(193, '2023-06-07 22:24:00', 'Técnico. Wilda ', 'Inicio Emergencia', 6, 199),
(194, '2023-06-10 10:33:50', 'Haciendo mediciones y probando rutas para instalación de cable ethernet hacia las oficinas de la parte de adelante de la clinica.', 'Planificación de Instalación Ethernet', 1, 188),
(195, '2023-06-17 21:10:00', 'No coloque el precio debido a que nose cuánto es el monto a cobrar ', 'Inicio Emergencia', 7, 200),
(196, '2023-06-19 16:25:00', 'Px con vale, estudio tomado el sábado 17 junio', 'Inicio Emergencia', 5, 201),
(197, '2023-06-20 03:00:00', 'La hora de salida fue a las 5:00 am y regresamos a las 7:00 pm pero pusimos las 2 horas en la mañana xq el sistema no deja agregar en la tarde instrucciones del ing', 'Inicio Emergencia', 6, 203),
(198, '2023-06-21 04:48:49', 'El viaje se realizó el día jueves 15 de junio ', 'Nota', 6, 203),
(199, '2023-06-21 16:25:00', 'Servicio de portatil se realizó el día sábado 17 de Junio en hospital siglo 21. Técnico. Wilda.', 'Inicio Emergencia', 6, 204),
(200, '2023-06-21 17:00:00', 'Se realizó la compra de una lavadora el día lunes 19 de Junio.', 'Inicio Emergencia', 6, 205),
(201, '2023-06-21 07:05:00', 'Hora de extra por cubrir a Meli el día 20 de junio ', 'Inicio Emergencia', 6, 206),
(202, '2023-06-21 07:00:00', 'Hora extra por cubrir a Meli el día 21 de junio ', 'Inicio Emergencia', 6, 207),
(203, '2023-06-23 17:05:00', 'En precio coloque eso de referencia,  px de el dia 22 junio', 'Inicio Emergencia', 5, 208),
(204, '2023-06-23 18:40:00', 'Precio de referencia', 'Inicio Emergencia', 5, 209),
(205, '2023-06-24 13:30:57', 'Por esta ocasión se pagará el tiempo extraordinario, ya que la paciente entro a las 5:00 y el portón todavía estaba abierto, y el personal todavía se encontraba dentro de las instalaciones.', 'HORARIO', 4, 208),
(206, '2023-06-24 14:00:06', 'Tiene razón Sandrita, anteriormente habíamos acordado que cuando el portón está abierto e ingresa un paciente procederíamos a atenderlo de manera normal, en este caso el portón aún estaba abierto cuando el paciente ingresó por lo que no se cobra como emergencia y tampoco se paga como emergencia, sin embargo se procede a pagar el tiempo extraordinario. Por eso es importante estar todos pendiente que cerremos el portón a las cinco de la tarde.', 'Corrección', 1, 208),
(207, '2023-06-24 14:01:43', 'A la paciente se le cobró precio normal.', 'Precio Normal', 1, 208),
(208, '2023-06-24 07:00:00', 'El día 23 se iso hora extra x cubrir vacaciones ', 'Inicio Emergencia', 6, 210),
(209, '2023-06-24 13:30:00', 'Cancelaron en clinica', 'Inicio Emergencia', 7, 211),
(210, '2023-06-24 16:25:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 212),
(211, '2023-06-24 17:49:31', 'Cancelaron en efectivo ', 'Dato ', 7, 213),
(212, '2023-06-26 09:44:20', 'En este caso los ingresos de tomografía serán cobrados por X-RADII y los Rayos X por Memorial/X-RADII, favor ingresar otra emergencia solo por la radiografía', 'CORRECCION', 4, 200),
(214, '2023-06-26 22:00:00', 'Rx realizados el día el 17 de junio \n', 'Inicio Emergencia', 7, 215),
(215, '2023-06-26 12:38:20', 'Skarleth, Sandrita hizo la correcció y se colocó en este registro unicamente el dato de la tomografía. Por favor, ingresar otro registro como ese específicamente para los rayos x que se hicieron al paciente. Gracias', 'Tomografía', 1, 200),
(216, '2023-06-29 17:00:00', 'Los rayos X se realizaron el Miércoles 28 de Junio ', 'Inicio Emergencia', 7, 217),
(217, '2023-07-01 21:13:00', 'Px con vale', 'Inicio Emergencia', 5, 218),
(218, '2023-07-02 18:19:00', 'Px con vale', 'Inicio Emergencia', 5, 220),
(219, '2023-07-04 11:56:43', 'Px del Memorial', 'HOSPITAL', 4, 219),
(220, '2023-07-04 18:15:00', 'Px pago por transferencia', 'Inicio Emergencia', 5, 221),
(221, '2023-07-04 19:55:00', 'Px cirugia con vale por seguro', 'Inicio Emergencia', 5, 222),
(223, '2023-07-07 12:00:00', 'El día sábado 1 de julio se realizó la instalación de cables de red con el ingeniero.', 'Inicio Emergencia', 6, 225),
(224, '2023-07-07 21:13:00', 'El día sábado 1 de julio se realizó portátil en hospital siglo 21. Técnico. Wilda.', 'Inicio Emergencia', 6, 226),
(225, '2023-07-07 18:00:00', 'El día domingo 1 de julio se realizó portátil en hospital siglo 21. Técnico. Wilda.', 'Inicio Emergencia', 6, 227),
(226, '2023-07-07 04:00:00', 'El día martes 4 d julio se realizó un viaje a la capital a recoger libro de actas a l ministerio de trabajo a traer mercadería de X-RADII y a las oficinas de dacotrans.', 'Inicio Emergencia', 6, 228),
(227, '2023-07-07 18:15:00', 'El día martes 4 d julio se realizó portátil en casa particular. Técnico Wilda.', 'Inicio Emergencia', 6, 229),
(228, '2023-07-07 19:55:00', 'El día martes 4 d julio se realizó portátil en centro médico en sala de cirugía. Técnico. Wilda.', 'Inicio Emergencia', 6, 230),
(229, '2023-07-08 13:20:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 232),
(230, '2023-07-09 06:14:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 236),
(231, '2023-07-09 06:14:00', 'Se dejó vale ', 'Inicio Emergencia', 7, 237),
(232, '2023-07-10 17:00:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 241),
(233, '2023-07-10 17:35:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 242),
(234, '2023-07-11 17:30:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 243),
(235, '2023-07-11 21:50:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 244),
(237, '2023-07-16 20:16:00', 'Px con vale', 'Inicio Emergencia', 5, 248),
(238, '2023-07-17 20:16:00', 'El día 16 de julio del 2023 se realizó un portátil en hospital siglo 21 Chiquimula. Técnico. Wilda.', 'Inicio Emergencia', 6, 249),
(239, '2023-07-17 17:00:00', 'Técnico. Wilda ', 'Inicio Emergencia', 6, 250),
(240, '2023-07-17 17:00:00', 'Px con vale', 'Inicio Emergencia', 5, 251),
(241, '2023-07-18 09:41:58', 'Efectivo', 'FORMA DE PAGO', 4, 235),
(242, '2023-07-18 09:45:35', 'Transferencia', 'FORMA DE PAGO', 4, 238),
(243, '2023-07-18 09:46:51', 'Efectivo', 'FORMA DE PAGO', 4, 239),
(244, '2023-07-18 09:48:54', 'Efectivo', 'FORMA DE PAGO', 4, 245),
(245, '2023-07-18 09:54:04', 'Efectivo, \nnombre de la paciente Sandra Ramirez', 'FORMA DE PAGO', 4, 246),
(246, '2023-07-18 09:57:09', 'Domingo 2', 'FECHA', 4, 227),
(247, '2023-07-18 13:52:00', '6 meses', 'Inicio Emergencia', 5, 252),
(248, '2023-07-20 18:00:00', 'Px vale', 'Inicio Emergencia', 5, 253),
(249, '2023-07-20 21:15:00', 'Px vale', 'Inicio Emergencia', 5, 254),
(250, '2023-07-20 18:00:00', 'El día 20 de julio. Se realizó un servicio de portatil en sala de cirugía en hospital centro medico Chiquimula. Técnico. Wilda ', 'Inicio Emergencia', 6, 255),
(251, '2023-07-20 21:15:00', 'El día 20 de julio en hospital siglo 21 Chiquimula Técnico. Wilda.', 'Inicio Emergencia', 6, 256),
(252, '2023-07-21 18:52:00', 'Px vale', 'Inicio Emergencia', 5, 257),
(253, '2023-07-21 18:52:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 258),
(254, '2023-07-24 17:00:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 260),
(255, '2023-07-24 19:30:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 262),
(256, '2023-07-25 08:44:42', 'Efectivo', 'FORMA DE PAGO', 4, 259),
(257, '2023-07-25 09:10:53', 'Realizada el 15/07/2023\nCancelaron en efectivo', 'FECHA', 4, 252),
(258, '2023-07-27 20:08:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 265),
(259, '2023-07-30 18:25:00', 'Px con vale', 'Inicio Emergencia', 5, 268),
(260, '2023-07-30 18:28:00', 'Técnico. Wilda', 'Inicio Emergencia', 6, 269),
(261, '2023-07-31 21:10:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 270),
(262, '2023-07-31 21:10:00', 'Px vale', 'Inicio Emergencia', 5, 271),
(263, '2023-08-01 21:30:00', '2da llamada para el mismo px, otro rx', 'Inicio Emergencia', 5, 273),
(264, '2023-08-01 20:15:00', 'Técnico. Wilda ', 'Inicio Emergencia', 6, 274),
(265, '2023-08-01 21:30:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 275),
(266, '2023-08-04 17:00:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 276),
(267, '2023-08-04 17:00:00', 'Px con vale', 'Inicio Emergencia', 5, 277),
(268, '2023-08-07 15:00:00', 'El día 6 de agosto se realizó una emergencia de portatil en hospital memorial Chiquimula. Técnico. Scarlett ', 'Inicio Emergencia', 6, 280),
(269, '2023-08-07 15:00:00', 'La radiografía fue realizada el 6 de agosto ', 'Inicio Emergencia', 7, 281),
(270, '2023-08-07 17:00:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 284),
(271, '2023-08-07 17:30:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 285),
(272, '2023-08-08 18:20:00', 'Se realizó servicio de portatil en salsa de cirugía. Técnico. Scarlett ', 'Inicio Emergencia', 6, 287),
(273, '2023-08-08 20:45:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 288),
(274, '2023-08-08 18:20:00', 'Se dejó vale ', 'Inicio Emergencia', 7, 289),
(275, '2023-08-08 20:45:00', 'Cancelo con vale ', 'Inicio Emergencia', 7, 290),
(276, '2023-08-10 20:00:00', 'Cancelo con vale ', 'Inicio Emergencia', 7, 291),
(277, '2023-08-11 17:00:00', 'Cancelo en efectivo ', 'Inicio Emergencia', 7, 292),
(278, '2023-08-12 17:00:00', 'Se realizó mantenimiento de la impresora de rayos x el día jueves 10 de agosto. ', 'Inicio Emergencia', 6, 293),
(279, '2023-08-12 17:00:00', 'Se realizó servicio de portatil al doc. Álvaro el día viernes 11 de agosto. Técnico. Scarlett.', 'Inicio Emergencia', 6, 294),
(281, '2023-08-13 18:00:00', 'El día sábado 12 de agosto se realizó un servicio de portatil. Técnico. Wilda.', 'Inicio Emergencia', 6, 297),
(282, '2023-08-13 18:30:00', 'El día sábado 12 de agosto se realizó un servicio de portatil. Técnico. Wilda.', 'Inicio Emergencia', 6, 298),
(283, '2023-08-14 16:50:00', 'Vale', 'Inicio Emergencia', 5, 299),
(284, '2023-08-15 16:50:00', 'El día lunes 14 de agosto se realizó portátil en hospital siglo 21. Técnico. Wilda.', 'Inicio Emergencia', 6, 300),
(286, '2023-08-15 08:30:00', 'Px con vale\n07 tomas Rx', 'Inicio Emergencia', 5, 302),
(287, '2023-08-15 08:30:00', 'Se realizó servicio de portatil en hospital siglo 21 Chiquimula. Técnico. Wilda.', 'Inicio Emergencia', 6, 303),
(288, '2023-08-18 17:00:00', 'Vale', 'Inicio Emergencia', 5, 304),
(289, '2023-08-19 17:00:00', 'El día viernes 18 de agosto se realizó servicio de portatil. Técnico. Wilda ', 'Inicio Emergencia', 6, 305),
(290, '2023-08-19 15:30:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 306),
(291, '2023-08-19 15:30:00', 'Le coloque lo que es el precio en Q350 debido a que ese es el precio en clínica solo para llenar la casilla ya que desconozco el precio ', 'Inicio Emergencia', 7, 307),
(292, '2023-08-20 08:40:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 309),
(293, '2023-08-20 20:15:00', 'Cancelo con efectivo los RX y el Ultrasonido total 650 doctora no cobro emergencia de USG', 'Inicio Emergencia', 7, 310),
(294, '2023-08-22 20:40:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 312),
(295, '2023-08-24 17:01:00', 'Px vale', 'Inicio Emergencia', 5, 295),
(296, '2023-08-24 17:30:00', 'Px del dia 12 agosto 2023', 'Inicio Emergencia', 5, 315),
(297, '2023-08-24 17:00:00', 'Px del dia 12', 'Inicio Emergencia', 5, 316),
(298, '2023-08-25 17:00:00', 'Se preparó impresora para entrega en Salamá ', 'Inicio Emergencia', 6, 317),
(299, '2023-08-25 05:00:00', 'Viaje para entrega de impresora en hospital de Salamá ', 'Inicio Emergencia', 6, 318),
(300, '2023-08-26 13:30:00', 'Px, vale 495', 'Inicio Emergencia', 5, 319),
(301, '2023-08-26 13:30:00', 'Técnico. Wilda ', 'Inicio Emergencia', 6, 320),
(302, '2023-08-27 17:30:00', 'Px cancela en efectivo', 'Inicio Emergencia', 5, 321),
(303, '2023-08-27 17:20:00', 'Px en efectivo', 'Inicio Emergencia', 5, 322),
(304, '2023-08-27 18:00:00', 'Px con vale', 'Inicio Emergencia', 5, 323),
(305, '2023-08-27 17:30:00', 'El día sábado 26 de agosto se realizó servicio de portatil en Esquipulas. Técnico. Wilda', 'Inicio Emergencia', 6, 324),
(306, '2023-08-27 17:20:00', 'Técnico. Wilda ', 'Inicio Emergencia', 6, 325),
(307, '2023-08-27 18:00:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 326),
(308, '2023-08-29 19:30:00', 'Px con vale', 'Inicio Emergencia', 5, 327),
(309, '2023-08-29 20:15:00', 'Px con vale', 'Inicio Emergencia', 5, 328),
(310, '2023-08-30 19:30:00', 'El día martes 29 de agosto se realizó servicio de portatil en hospital siglo 21. Técnico. Wilda ', 'Inicio Emergencia', 6, 329),
(311, '2023-08-30 20:15:00', 'El día martes se realizó servicio de portatil. Técnico. Wilda.', 'Inicio Emergencia', 6, 330),
(313, '2023-08-30 17:00:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 332),
(314, '2023-08-30 17:00:00', 'Px con vale', 'Inicio Emergencia', 5, 333),
(315, '2023-08-30 21:05:00', 'Cancela en efect.', 'Inicio Emergencia', 5, 334),
(316, '2023-09-07 16:50:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 335),
(317, '2023-09-09 21:13:00', 'El día sábado 9 d septiembre se realizó una jornada médica en ciudad Capital consegsa. Doc. Selvin Fuentes condado Naranjo. Técnico. Wilda.', 'Inicio Emergencia', 6, 337),
(318, '2023-09-10 12:25:00', 'Técnico.Wilda.', 'Inicio Emergencia', 6, 339),
(319, '2023-09-10 13:00:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 340),
(320, '2023-09-10 18:50:00', 'Px con vale', 'Inicio Emergencia', 5, 341),
(321, '2023-09-10 12:25:00', 'Px en efectivo', 'Inicio Emergencia', 5, 342),
(322, '2023-09-10 13:00:00', 'Px en efect', 'Inicio Emergencia', 5, 343),
(323, '2023-09-10 18:50:00', 'Tecnico. Wilda.', 'Inicio Emergencia', 6, 344),
(324, '2023-09-13 17:00:00', 'El día martes 12 de septiembre se realizó un servicio de portatil en casa particular en la col. Bamvi. Técnico. Wilda.', 'Inicio Emergencia', 6, 345),
(325, '2023-09-14 17:00:00', 'Px cancelo en clinica', 'Inicio Emergencia', 5, 346),
(326, '2023-09-14 17:30:00', 'Dr. Alvaro cancela en efectivo ', 'Inicio Emergencia', 5, 348),
(327, '2023-09-15 09:20:00', 'cirugia, px con vale', 'Inicio Emergencia', 5, 349),
(328, '2023-09-15 11:00:00', '2 perritos', 'Inicio Emergencia', 5, 350),
(329, '2023-09-15 12:00:00', 'px con vale', 'Inicio Emergencia', 5, 351),
(330, '2023-09-15 15:42:00', 'no se dejo vale, ni se recibió efect.', 'Inicio Emergencia', 5, 352),
(331, '2023-09-16 03:00:00', 'El día jueves 14 de septiembre se fue a la capital a traer el tubo de la tomografía a las bodegas de Combexin con el ingeniero Elder.\nSe coloca las 3 horas juntas porque el programa no deja realizas las horas como son fue de 5:00 am ah 7:00 pm ', 'Inicio Emergencia', 6, 353),
(332, '2023-09-16 09:20:00', 'Se realizó servicio de portatil en sala de cirugía con el doc. Silver el día jueves 15 de septiembre. Técnico. Wilda', 'Inicio Emergencia', 6, 354),
(333, '2023-09-16 11:00:00', 'Se realizó el día jueves 15 de septiembre servicio de portatil en veterinaria el molino de 2 perros. Tecnico. Wilda.', 'Inicio Emergencia', 6, 355),
(334, '2023-09-16 12:00:00', 'El día jueves 15 de septiembre se realizó servicio de portatil. Técnico. Wilda.', 'Inicio Emergencia', 6, 356),
(335, '2023-09-16 15:42:00', 'El día jueves 15 de septiembre se realizó emergencia en hospital Memorial Chiquimula. Técnico. Wilda.', 'Inicio Emergencia', 6, 357),
(336, '2023-09-16 08:00:00', 'Jornada RX El Naranjo Dr. selvin. Sabado 09. Septiembre 2023', 'Inicio Emergencia', 5, 338),
(337, '2023-09-16 12:00:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 358),
(338, '2023-09-17 12:00:00', 'Rx realizados el Sábado 16 de Septiembre ', 'Inicio Emergencia', 7, 360),
(339, '2023-09-17 12:00:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 362),
(340, '2023-09-17 15:00:00', 'Se arregló la máquina de rayos x con el ingeniero Elder ', 'Inicio Emergencia', 6, 363),
(341, '2023-09-18 23:00:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 364),
(342, '2023-09-19 23:00:00', 'Px realizada el día 18 de Septiembre cancelan con vale ', 'Inicio Emergencia', 7, 365),
(343, '2023-09-22 20:00:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 366),
(344, '2023-09-22 17:00:00', 'El día miércoles 20 de septiembre se realizó instalación de cable de red de la oficina de conta ah al taller con Denilson. ', 'Inicio Emergencia', 6, 367),
(345, '2023-09-24 14:10:00', 'Px viene del centro clinico del dr. Medina\n\n', 'Inicio Emergencia', 5, 369),
(346, '2023-09-27 17:00:00', 'Dr. Alvaro Montoy', 'Inicio Emergencia', 5, 370),
(347, '2023-10-01 07:15:00', 'El día viernes 29 de septiembre se realizó un servicio de emergencia en hospital Memorial. Técnico. Wilda ', 'Inicio Emergencia', 6, 371),
(348, '2023-10-01 19:00:00', 'Sala de cirugía. Técnico. Scarlett ', 'Inicio Emergencia', 6, 372),
(349, '2023-10-02 07:00:00', 'Rx realizados en emergencia el día 01/10/2023 cancelaron con vale ', 'Inicio Emergencia', 7, 373),
(350, '2023-10-02 21:00:00', 'Cancelo con vale ', 'Inicio Emergencia', 7, 374),
(351, '2023-10-03 21:00:00', 'El día lunes 2 de octubre se realizó servicio de portatil. Técnico. Scarlett ', 'Inicio Emergencia', 6, 376),
(352, '2023-10-04 17:00:00', 'Se realizó emergencia de portatil en veterinaria el Molino. Técnico. Scarlett ', 'Inicio Emergencia', 6, 378),
(353, '2023-10-05 07:00:00', 'Técnico. Scarlett. ', 'Inicio Emergencia', 6, 380),
(354, '2023-10-07 12:00:00', 'El día sábado 7 de octubre se realizó trabajos en la tomografía con el ingeniero y Denilson.', 'Inicio Emergencia', 6, 382),
(355, '2023-10-15 15:30:00', 'El día domingo 15 de octubre se realizó servicio a la tomografía con el Inge ', 'Inicio Emergencia', 6, 383),
(356, '2023-10-17 06:00:00', 'Rx realizados el día 16 de octubre ', 'Inicio Emergencia', 7, 384),
(357, '2023-10-20 19:00:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 385),
(358, '2023-10-21 07:15:00', 'PX EXONERADO\nRX CON FECHA 29 DE SEPT. 2023', 'Inicio Emergencia', 5, 387),
(359, '2023-10-21 15:20:00', 'PX CON SEGURO', 'Inicio Emergencia', 5, 389),
(360, '2023-10-22 12:00:00', 'El día sábado 21 de octubre se realizó fumigación en  X-RADII.', 'Inicio Emergencia', 6, 390),
(361, '2023-10-22 13:45:00', 'El día sábado 21 de octubre se realizó servicio de emergencia de portatil en veterinaria del doc. Álvaro. Técnico. Wilda.', 'Inicio Emergencia', 6, 391),
(362, '2023-10-22 13:15:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 392),
(363, '2023-10-22 01:15:00', 'px control', 'Inicio Emergencia', 5, 393),
(364, '2023-10-24 15:00:00', 'El día domingo 24 de octubre se realizó mantenimiento a la tomografía. ', 'Inicio Emergencia', 6, 394),
(366, '2023-10-24 17:00:00', 'El dia lunes 25 se realizó mantenimiento a la tomografía ', 'Inicio Emergencia', 6, 397),
(367, '2023-10-24 17:00:00', 'El día 26 de octubre se realizó mantenimiento a la tomografía ', 'Inicio Emergencia', 6, 398),
(368, '2023-10-24 17:00:00', 'El día miércoles 27 de octubre se realizó mantenimiento a la tomografía ', 'Inicio Emergencia', 6, 399),
(369, '2023-10-26 17:35:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 400),
(370, '2023-10-26 17:30:00', 'Cancela en efect', 'Inicio Emergencia', 5, 401),
(372, '2023-10-27 11:23:34', 'Arregle de 19 a 20 ', 'Correcciones ', 7, 386),
(373, '2023-10-27 11:58:10', 'ya se le soluciono la hora de ingreso y egreso de la emergencia ', 'modificación ', 2, 381),
(374, '2023-10-27 11:59:57', 'modificación de horario ', 'modificación ', 2, 386),
(375, '2023-10-28 12:00:00', 'Técnico. Scarlett ', 'Inicio Emergencia', 6, 403),
(376, '2023-10-28 13:00:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 404),
(377, '2023-10-28 19:00:00', 'Técnico. Scarlett.', 'Inicio Emergencia', 6, 405),
(378, '2023-10-29 17:00:00', 'Cancelo en efectivo ', 'Inicio Emergencia', 7, 410),
(379, '2023-10-29 12:00:00', 'Cancelaron en efectivo Rx realizados el 28 de octubre ', 'Inicio Emergencia', 7, 409),
(380, '2023-10-29 13:00:00', 'Px cancelaron con vale y se les envío radiografía digital e impresa ', 'Inicio Emergencia', 7, 407),
(381, '2023-10-29 17:56:46', 'Rx realizados el 28 de octubre ', 'Fecha ', 7, 407),
(382, '2023-10-29 00:00:00', 'Cancelaron en efectivo Rx realizados el 28 de octubre ', 'Inicio Emergencia', 7, 408),
(383, '2023-11-04 11:40:00', 'PX CON VALE', 'Inicio Emergencia', 5, 411),
(384, '2023-11-04 12:30:00', 'PX CON TRANSFERENCIA', 'Inicio Emergencia', 5, 412),
(385, '2023-11-04 13:05:00', 'CANCEL. EN RECEPCION', 'Inicio Emergencia', 5, 413),
(386, '2023-11-06 16:45:00', 'El día 31 de octubre se realizo una emergencia en hospital Memorial. Técnico. Skarleth', 'Inicio Emergencia', 6, 414),
(387, '2023-11-06 11:40:00', 'El día sábado 4 de octubre se realizo emergencia de portátil. Técnico. Wilda.', 'Inicio Emergencia', 6, 415),
(388, '2023-11-06 12:30:00', 'El día sábado 4 de noviembre se realizo emergencia de portátil en hospital unidad medica. Técnico. Wilda', 'Inicio Emergencia', 6, 416),
(389, '2023-11-06 18:30:00', 'Px con vale', 'Inicio Emergencia', 5, 417),
(390, '2023-11-06 18:30:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 418),
(391, '2023-11-08 17:00:00', 'El día miércoles 8 de noviembre se realizo emergencia de portátil en hospital centro medico por cirugía. Técnico. Wilda', 'Inicio Emergencia', 6, 419),
(392, '2023-11-08 17:15:00', 'Se dejo vale', 'Inicio Emergencia', 5, 420),
(393, '2023-11-09 16:45:00', 'Px con vale', 'Inicio Emergencia', 5, 421),
(394, '2023-11-09 22:50:00', 'Px con vale', 'Inicio Emergencia', 5, 422),
(395, '2023-11-11 16:45:00', 'El día 9 de noviembre se realizo una emergencia en hospital Memorial. Técnico. Wilda.', 'Inicio Emergencia', 6, 423),
(396, '2023-11-11 17:00:00', 'El día viernes 10 de noviembre se realizo traslado de Densitometro ah Centro Medico Zacapa con el ingeniero. ', 'Inicio Emergencia', 6, 424),
(397, '2023-11-12 08:30:00', 'Técnico.  Skarleth', 'Inicio Emergencia', 6, 425),
(398, '2023-11-12 09:22:00', 'Técnico.  Skarleth ', 'Inicio Emergencia', 6, 426),
(399, '2023-11-12 08:30:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 427),
(400, '2023-11-12 09:22:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 428),
(401, '2023-11-12 14:20:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 429),
(402, '2023-11-12 14:20:00', 'Técnico.  Skarleth. ', 'Inicio Emergencia', 6, 430),
(403, '2023-11-12 14:55:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 431),
(404, '2023-11-12 14:55:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 432),
(405, '2023-11-12 15:22:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 433),
(406, '2023-11-12 15:22:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 434),
(407, '2023-11-16 06:38:00', 'px de seguro, se dejo vale', 'Inicio Emergencia', 5, 435),
(408, '2023-11-17 08:07:00', 'PX  CON SE GURO\nSE DEJA VALE', 'Inicio Emergencia', 5, 436),
(409, '2023-11-18 20:07:00', 'El día 17 de noviembre se realizo servicio de emergencia. Técnico. Wilda', 'Inicio Emergencia', 6, 437),
(410, '2023-11-18 12:00:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 438),
(411, '2023-11-18 12:00:00', 'PX CON VALE', 'Inicio Emergencia', 5, 439),
(412, '2023-11-18 07:45:00', 'PS CON VALE  PARA CENTRO CLINICO\nSE ENTREGA VALE A PX\nDOCT. REALIZO  ULTRA', 'Inicio Emergencia', 5, 440),
(413, '2023-11-19 11:46:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 441),
(414, '2023-11-19 11:46:00', 'PX CONTROL POST OPERATORIO\nPX SEGURO\nSE DEJA VALE', 'Inicio Emergencia', 5, 442),
(415, '2023-11-20 05:00:00', 'PX CON SE GURO\nSE DEJA VALE', 'Inicio Emergencia', 5, 443),
(416, '2023-11-20 06:00:00', 'PX CON SEGURO\nSE DEJA VALE', 'Inicio Emergencia', 5, 444),
(417, '2023-11-20 17:00:00', 'Técnico.  Wilda. ', 'Inicio Emergencia', 6, 445),
(418, '2023-11-20 18:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 446),
(419, '2023-11-22 17:45:00', 'Px con seguro\nSe deja vale', 'Inicio Emergencia', 5, 447),
(420, '2023-11-23 17:45:00', 'El día  miércoles 22 de noviembre se realizo emergencia en Hospital Memorial. Técnico. Wilda ', 'Inicio Emergencia', 6, 448),
(422, '2023-11-28 08:25:00', 'PX DE SEGURO\nSE DEJA   VALE', 'Inicio Emergencia', 5, 450),
(423, '2023-11-28 20:25:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 451),
(424, '2023-11-30 06:20:00', 'SE REALIZO ULTRA ABDOMINAL', 'Inicio Emergencia', 5, 452),
(426, '2023-12-01 19:20:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 454),
(427, '2023-12-01 07:20:00', 'SE DEJA VALE\nPX CON SEGURO', 'Inicio Emergencia', 5, 455),
(428, '2023-12-02 12:00:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 456),
(429, '2023-12-04 12:00:00', 'El día sábado 2 de emergencia se realizo servicio de emergencia de portátil en casa particular. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 457),
(430, '2023-12-04 17:00:00', 'Técnico. Skarleth ', 'Inicio Emergencia', 6, 458),
(431, '2023-12-14 16:50:00', 'Px en intensivo, se deja vale', 'Inicio Emergencia', 5, 459),
(432, '2023-12-17 13:30:00', 'Rx realizados el día 16 de Diciembre ', 'Inicio Emergencia', 7, 460),
(433, '2023-12-17 17:00:00', 'Rx realizados el 02/12/2023', 'Inicio Emergencia', 7, 461),
(434, '2023-12-23 20:00:00', 'Rx realizados el día 22/12/23 cancelaron con vale ', 'Inicio Emergencia', 7, 463),
(435, '2023-12-23 17:00:00', 'Rx realizados en clínica el día 21/12/23', 'Inicio Emergencia', 7, 462),
(436, '2023-12-26 12:30:00', 'Rx realizados el Sábado 23 de Diciembre cancelo en efectivo ', 'Inicio Emergencia', 7, 464),
(437, '2023-12-27 19:00:00', 'Rx realizados el día 26 de Diciembre ', 'Inicio Emergencia', 7, 465),
(438, '2023-12-27 21:00:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 466),
(439, '2024-01-05 16:50:00', 'El día jueves 14 de diciembre del  2023 se realizo una emergencia de portátil en Hospital Centro Medico Chiquimula. Técnico. Wilda. ', 'Inicio Emergencia', 6, 467),
(440, '2024-01-05 17:00:00', 'Técnico. Skarleth ', 'Inicio Emergencia', 6, 468),
(441, '2024-01-05 20:00:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 469),
(442, '2024-01-07 17:00:00', 'Cancelo por transferencia RX realizados el 5 de enero ', 'Inicio Emergencia', 7, 470),
(443, '2024-01-07 20:00:00', 'Rx realizados el 5 de enero cancelo en efectivo ', 'Inicio Emergencia', 7, 471),
(444, '2024-01-09 17:00:00', 'El día lunes 8 de enero de 2024 se realizo servicio de mantenimiento a la tomografía con el ingeniero Elder.', 'Inicio Emergencia', 6, 472),
(445, '2024-01-09 18:35:00', 'El día 28 de noviembre se realizo servicio de fumigacion en X-RADII.', 'Inicio Emergencia', 6, 473),
(446, '2024-01-09 17:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 474),
(447, '2024-01-13 13:00:00', 'Se realizo fumigacion en X-RADII Chiquimula.', 'Inicio Emergencia', 6, 476),
(448, '2024-01-18 16:45:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 477),
(449, '2024-01-18 16:45:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 478),
(450, '2024-01-20 02:15:00', 'EXONERADO, AUT.  DRA MARISOL', 'Inicio Emergencia', 5, 479),
(451, '2024-01-20 16:26:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 480),
(452, '2024-01-20 04:25:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 481),
(453, '2024-01-20 17:53:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 482),
(454, '2024-01-20 05:53:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 483),
(455, '2024-01-20 18:20:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 484),
(456, '2024-01-20 06:20:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 485),
(457, '2024-01-20 18:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 486),
(458, '2024-01-20 06:50:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 487),
(459, '2024-01-20 20:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 488),
(460, '2024-01-20 08:50:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 489),
(461, '2024-01-21 12:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 490),
(462, '2024-01-22 16:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 491),
(463, '2024-01-22 17:40:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 492),
(464, '2024-01-22 12:00:00', 'PX  DEL DIA DE AYER 21 ENERO 2024', 'Inicio Emergencia', 5, 493),
(465, '2024-01-22 04:50:00', 'PX CON SEGURO', 'Inicio Emergencia', 5, 494),
(466, '2024-01-22 05:40:00', 'SE DEJA VALE ', 'Inicio Emergencia', 5, 495),
(468, '2024-01-25 17:00:00', 'El día martes 23 de enero se realizo mantenimiento a la impresora de rayos x con el ingeniero. ', 'Inicio Emergencia', 6, 497),
(469, '2024-01-26 17:30:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 498),
(470, '2024-01-26 17:30:00', 'Se deja vale, px con seguro', 'Inicio Emergencia', 5, 499),
(471, '2024-01-28 15:25:00', 'El día sábado 27 de enero se realizo emergencia de portátil. Técnico. Skarleth ', 'Inicio Emergencia', 6, 500),
(472, '2024-01-28 20:50:00', 'El día sábado 27 de enero se realizo emergencia de portátil. Técnico. Skarleth ', 'Inicio Emergencia', 6, 502),
(473, '2024-01-29 15:25:00', 'Rx realizados el Sabado 27 de enero Cancelaron en efectivo ya se entrego el día lunes 29 a meilyn ', 'Inicio Emergencia', 7, 503),
(474, '2024-01-29 20:50:00', 'Rx realizados el día sábado 27 cancelaron en efectivo ya fue entregado a meilyn ', 'Inicio Emergencia', 7, 504),
(475, '2024-01-30 18:30:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 505),
(476, '2024-02-01 17:00:00', 'Se les dio vale al de la ambulancia del millenium y se les entrego su placa de RX', 'Inicio Emergencia', 7, 506),
(477, '2024-02-01 22:08:11', 'Rx realizados el dia Martes 31 de enero ', 'Nota ', 7, 506),
(478, '2024-02-03 12:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 507),
(479, '2024-02-03 16:30:00', 'Ser realizo servicio de emergencia en sala de operaciones para 2 cirugía. Técnico. Wilda. ', 'Inicio Emergencia', 6, 508),
(480, '2024-02-03 12:00:00', '1- tobillo ver fractura\n2- tobillo luego de procedimiento con Dr. silver', 'Inicio Emergencia', 5, 509),
(481, '2024-02-03 16:30:00', 'Cirugia de segundo dedo/ mano , y tobillo ', 'Inicio Emergencia', 5, 510),
(482, '2024-02-04 11:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 511),
(483, '2024-02-05 20:20:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 512),
(484, '2024-02-05 11:00:00', 'Px dia domingo 4 feb 2024', 'Inicio Emergencia', 5, 513),
(485, '2024-02-05 20:20:00', 'Px en habitacion, se deja vale', 'Inicio Emergencia', 5, 514),
(486, '2024-02-10 12:00:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 515),
(487, '2024-02-11 07:30:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 516),
(488, '2024-02-11 12:00:00', 'realizados el 10 de febrero cancelaron en efectivo ', 'Inicio Emergencia', 7, 517),
(489, '2024-02-11 07:30:00', 'Cancelo en efectivo ', 'Inicio Emergencia', 7, 518),
(490, '2024-02-11 12:05:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 519),
(491, '2024-02-11 12:05:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 520),
(492, '2024-02-13 17:00:00', 'Doctora no cobro pero indico que lo agg al sistema ', 'Inicio Emergencia', 7, 521),
(493, '2024-02-14 07:15:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 522),
(494, '2024-02-14 19:50:00', 'Técnico. Skarleth ', 'Inicio Emergencia', 6, 523),
(495, '2024-02-14 07:15:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 524),
(496, '2024-02-14 19:50:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 525),
(497, '2024-02-15 18:00:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 526),
(498, '2024-02-15 18:00:00', 'Cancelaron con vale', 'Inicio Emergencia', 7, 527),
(499, '2024-02-17 07:15:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 528),
(500, '2024-02-17 17:45:00', 'Servicio de emergencia en sala de cirugía. Técnico. Wilda ', 'Inicio Emergencia', 6, 529),
(501, '2024-02-17 18:37:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 530);
INSERT INTO `comentario` (`id`, `fecha`, `comentario`, `motivo`, `f_usuario`, `f_emergencia`) VALUES
(502, '2024-02-17 07:10:00', 'SE DEJA VALE, HORARIO AM', 'Inicio Emergencia', 5, 531),
(503, '2024-02-17 05:45:00', 'PX CIRUGIA, SE DEJA VALE, DR. MANUEL PINTO', 'Inicio Emergencia', 5, 532),
(504, '2024-02-17 06:37:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 533),
(505, '2024-02-17 18:00:00', 'No se cobro,Ingeniero comento que siempre lo anotara', 'Inicio Emergencia', 7, 534),
(506, '2024-02-18 15:00:00', 'Solo coloque el apellido ya que no me acuerdo de su nombre (: cancelaron en efectivo ', 'Inicio Emergencia', 7, 535),
(507, '2024-02-20 17:00:00', 'El 7 de febrero se le dio mantenimiento a la tomografía con el ingeniero.', 'Inicio Emergencia', 6, 536),
(508, '2024-02-20 18:00:00', 'El día lunes 19 de febrero se realizó fumigacion en X-RADII. ', 'Inicio Emergencia', 6, 537),
(509, '2024-02-22 05:00:00', 'CANCELAN EN EFECT', 'Inicio Emergencia', 5, 538),
(510, '2024-02-24 19:20:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 539),
(511, '2024-03-02 06:36:00', 'SE DEJA VALE\nPX  CON PORTATIL ( SE ENCONTRABA EN RECUPERACION, EN  CUARTO ) ', 'Inicio Emergencia', 5, 542),
(512, '2024-03-04 18:36:00', 'El día sábado 2 de marzo se relaizo servicio de emergencia en HM. Técnico. Wilda. ', 'Inicio Emergencia', 6, 543),
(513, '2024-03-05 17:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 544),
(514, '2024-03-06 05:00:00', 'CANCELA EN EFECTIVO\n\nPX DEL DIA 05 MARZO 2024', 'Inicio Emergencia', 5, 545),
(515, '2024-03-06 09:15:00', 'SE DEJA   VALE\n\nPX DEL DIA 05 MARZO 2024', 'Inicio Emergencia', 5, 546),
(516, '2024-03-06 21:15:00', 'El día martes 5 de marzo se realizó un servicio de emergencia de portátil en hospital siglo 21. Técnico. Wilda. ', 'Inicio Emergencia', 6, 547),
(517, '2024-03-06 20:30:00', 'Técnico. Denilson.', 'Inicio Emergencia', 6, 548),
(518, '2024-03-06 21:45:00', 'Técnico. Denilson.', 'Inicio Emergencia', 6, 549),
(519, '2024-03-11 18:30:00', 'Se realizo mantenimiento al aire acondicionado del ultrasonido.', 'Inicio Emergencia', 6, 550),
(520, '2024-03-14 17:00:00', 'El día martes 12 de marzo se realizó emergencia de portátil casa particular Col. Rumano. Técnico. Skarleth ', 'Inicio Emergencia', 6, 551),
(521, '2024-03-15 17:00:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 552),
(522, '2024-03-16 20:15:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 553),
(523, '2024-03-16 20:15:00', 'Px con vale', 'Inicio Emergencia', 5, 554),
(524, '2024-03-19 05:30:00', 'CANCELAN EN EFECTIVO', 'Inicio Emergencia', 5, 555),
(525, '2024-03-20 18:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 556),
(526, '2024-03-20 20:27:00', 'Técnico. Wilda.', 'Inicio Emergencia', 6, 557),
(527, '2024-03-21 17:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 558),
(528, '2024-03-21 05:30:00', 'El día de hoy 21 de Marzo se realizó mantenimiento con el inge. Elder, en el Hospital del Dr. Orellana en Salama', 'Inicio Emergencia', 6, 559),
(529, '2024-03-21 18:00:00', 'Px del dia 20 de marzo\nSe deja vale', 'Inicio Emergencia', 5, 560),
(530, '2024-03-21 20:27:00', 'Px del dia 20 de marzo\nCancelan en efectivo ', 'Inicio Emergencia', 5, 561),
(531, '2024-03-21 17:00:00', 'Se deja vale', 'Inicio Emergencia', 5, 562),
(532, '2024-03-23 14:00:00', 'Se realizo servicio en sala de cirugía. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 563),
(533, '2024-03-23 14:00:00', 'Estuvimos 4 horas en sala de operaciones y se cobro adicional 200 empezaron con la cirugía después de lo previsto ', 'Inicio Emergencia', 7, 564),
(534, '2024-03-25 17:00:00', 'Se realizo fumigacion en X-RADII. ', 'Inicio Emergencia', 6, 565),
(535, '2024-03-26 11:17:13', 'TC Cerebral, Dra. Ligia Urrutia ', 'Hospital Siglo 21', 2, 541),
(536, '2024-03-26 18:00:00', 'No se cobro pero doctora undico que se ingresara ', 'Inicio Emergencia', 7, 566),
(537, '2024-03-27 18:00:00', 'El día martes 26 de marzo se realizó emergencia de portátil. Técnico. Skarleth ', 'Inicio Emergencia', 6, 567),
(538, '2024-03-28 07:00:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 568),
(539, '2024-03-28 21:25:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 571),
(540, '2024-03-29 07:15:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 572),
(541, '2024-03-29 12:15:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 574),
(542, '2024-03-29 22:00:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 575),
(543, '2024-03-29 10:00:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 576),
(544, '2024-03-29 12:15:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 578),
(545, '2024-03-31 16:20:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 579),
(546, '2024-03-31 16:58:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 580),
(547, '2024-03-31 16:20:00', 'Cancela en efectivo', 'Inicio Emergencia', 5, 581),
(548, '2024-03-31 16:58:00', 'Se dejo vale', 'Inicio Emergencia', 5, 582),
(549, '2024-04-02 17:55:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 583),
(550, '2024-04-02 17:55:00', 'Px cancela rn efectivo', 'Inicio Emergencia', 5, 584),
(551, '2024-04-07 10:21:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 585),
(552, '2024-04-09 06:35:00', 'Técnico. Skarleth ', 'Inicio Emergencia', 6, 586),
(553, '2024-04-09 17:55:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 588),
(554, '2024-04-10 17:55:00', 'Rx realizados el 9 de abril ', 'Inicio Emergencia', 7, 589),
(555, '2024-04-10 17:00:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 590),
(556, '2024-04-11 17:00:00', 'El día 10 de abril se realizó emergencia de portátil. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 591),
(557, '2024-04-11 17:50:00', 'El día miércoles 10 de abril se realizó mantenimiento al ultrasonido.', 'Inicio Emergencia', 6, 592),
(558, '2024-04-11 17:00:00', 'Se realizo mantenimiento a la mamografia.', 'Inicio Emergencia', 6, 593),
(559, '2024-04-12 18:20:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 594),
(560, '2024-04-14 17:35:00', 'El día sábado 13 de abril se realizó emergencia de portátil. Técnico. Wilda. ', 'Inicio Emergencia', 6, 595),
(561, '2024-04-16 17:35:00', 'Px cancela en efectivo \nPx del dia sabado 13 abril 2024', 'Inicio Emergencia', 5, 596),
(562, '2024-04-16 17:00:00', 'Se deja vale', 'Inicio Emergencia', 5, 597),
(563, '2024-04-16 18:00:00', 'Px cancela en efectivo ', 'Inicio Emergencia', 5, 598),
(564, '2024-04-16 17:00:00', 'El día lunes 15 de abril se le realizó mantenimiento al aire acondicionado de recepción.', 'Inicio Emergencia', 6, 599),
(565, '2024-04-16 17:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 600),
(566, '2024-04-16 18:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 601),
(567, '2024-04-16 18:45:00', 'Se le realizo mantenimiento a la tomografía del balance.', 'Inicio Emergencia', 6, 602),
(568, '2024-04-18 17:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 603),
(569, '2024-04-18 17:00:00', 'Se deja vale', 'Inicio Emergencia', 5, 604),
(570, '2024-04-21 12:00:00', 'El día sábado 20 de abril se realizó la emergencia de portátil. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 605),
(571, '2024-04-21 20:05:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 606),
(572, '2024-04-21 12:00:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 607),
(573, '2024-04-21 13:00:00', 'Cancelaron con efectivo ', 'Inicio Emergencia', 7, 608),
(574, '2024-04-21 20:05:00', 'Se realizó vale ', 'Inicio Emergencia', 7, 609),
(575, '2024-04-25 19:35:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 610),
(576, '2024-04-25 23:15:00', 'Cancelaron. En efectivo RX realizados el 24 de abril ', 'Inicio Emergencia', 7, 611),
(577, '2024-04-25 19:35:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 612),
(578, '2024-04-28 11:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 613),
(579, '2024-04-28 12:10:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 614),
(580, '2024-04-28 12:30:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 615),
(581, '2024-04-28 11:50:00', 'CANCCELAN EN EFECTIVO', 'Inicio Emergencia', 5, 616),
(582, '2024-04-28 12:10:00', 'SE DEJA VALE  LLENO COMO ISABEL LUX', 'Inicio Emergencia', 5, 617),
(584, '2024-04-28 12:30:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 619),
(585, '2024-04-29 16:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 620),
(586, '2024-04-29 18:13:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 621),
(587, '2024-04-29 04:50:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 622),
(588, '2024-04-29 06:13:00', 'CANCELAN EN EFECTIVO\n SE  FIRMA CUADERNO EN UNIDAD MEDICA, CONTROL QUE PAGO PX', 'Inicio Emergencia', 5, 623),
(589, '2024-04-30 17:25:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 624),
(590, '2024-04-30 05:25:00', 'CANCELAN EN EFECTIVO', 'Inicio Emergencia', 5, 625),
(591, '2024-04-30 06:50:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 626),
(592, '2024-04-30 07:25:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 627),
(595, '2024-04-30 08:00:00', 'CANCELA EN EFECTIVO', 'Inicio Emergencia', 5, 630),
(597, '2024-04-30 18:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 632),
(598, '2024-04-30 19:25:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 633),
(599, '2024-04-30 20:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 634),
(600, '2024-05-01 07:15:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 635),
(650, '2024-05-01 19:15:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 685),
(651, '2024-05-04 12:00:00', 'Cancelaron con efectivo ', 'Inicio Emergencia', 7, 686),
(652, '2024-05-04 12:45:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 687),
(653, '2024-05-04 12:00:00', 'Técnico. Skarleth ', 'Inicio Emergencia', 6, 688),
(654, '2024-05-04 12:45:00', 'Técnico. Skarleth ', 'Inicio Emergencia', 6, 689),
(655, '2024-05-04 14:44:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 690),
(656, '2024-05-04 17:25:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 691),
(657, '2024-05-04 18:15:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 692),
(658, '2024-05-04 19:00:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 693),
(659, '2024-05-04 19:25:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 694),
(660, '2024-05-04 21:08:00', 'El dia 2 de mayo se realizo un viaje a la capital con el ingeniero a traer papel de Ultrasonido y repuestos de la tomografía. Se salio a las 6 de la mañana y se regreso a las 7 pero como el software no permite poner las horas partidas, por orden del inge se puso de 4 ah 8 ', 'Inicio Emergencia', 6, 695),
(661, '2024-05-05 14:44:00', 'Cancelaron en efectivo Rx realizadas el 4/4/2024', 'Inicio Emergencia', 7, 696),
(662, '2024-05-05 17:25:00', 'Rx realizados el 4/4/2024', 'Inicio Emergencia', 7, 697),
(663, '2024-05-05 18:15:00', 'Rx realizados el 4/4/2024', 'Inicio Emergencia', 7, 698),
(664, '2024-05-05 19:00:00', 'Rx realizados el 4/4/2024', 'Inicio Emergencia', 7, 699),
(665, '2024-05-05 19:25:00', 'Cancelo en efectivo Q825.00 \nRx realizados el 4/4/2024', 'Inicio Emergencia', 7, 700),
(666, '2024-05-09 17:00:00', 'El día miércoles 8 de mayo se realizó fumigacion en X-RADII. ', 'Inicio Emergencia', 6, 701),
(667, '2024-05-09 20:00:00', 'Técnico. Skarleth ', 'Inicio Emergencia', 6, 702),
(668, '2024-05-11 13:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 703),
(669, '2024-05-11 15:45:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 704),
(670, '2024-05-11 19:35:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 705),
(671, '2024-05-11 01:50:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 706),
(672, '2024-05-11 03:45:00', 'SE DEJA VALE\n\nDOCT. REALIZA USG , PRECIO INCLUIDO EN VALE\n\n300.00 ULTRA\n400.00 RX', 'Inicio Emergencia', 5, 707),
(673, '2024-05-11 07:35:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 708),
(674, '2024-05-12 21:25:00', 'Px exonerado por instrucciones del Ingeniero ( px familiar )', 'Inicio Emergencia', 5, 709),
(675, '2024-05-12 21:25:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 710),
(676, '2024-05-14 18:05:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 711),
(677, '2024-05-14 18:05:00', 'Se deja vale', 'Inicio Emergencia', 5, 712),
(678, '2024-05-15 07:52:00', 'PX CANCELA EN EFECTIVO', 'Inicio Emergencia', 5, 713),
(679, '2024-05-15 19:52:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 714),
(681, '2024-05-15 22:05:00', 'Px von vale', 'Inicio Emergencia', 5, 716),
(682, '2024-05-16 22:05:00', 'El día miércoles 15 de mayo se realizó la emergencia de portátil. Técnico. Wilda. ', 'Inicio Emergencia', 6, 717),
(683, '2024-05-16 19:05:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 718),
(684, '2024-05-16 19:05:00', 'Px con vale', 'Inicio Emergencia', 5, 719),
(685, '2024-05-18 20:00:00', 'Rx realizados el 9 de mayo ', 'Inicio Emergencia', 7, 720),
(686, '2024-05-18 13:50:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 722),
(687, '2024-05-24 09:00:00', 'Rx realizados el Domingo 19 de mayo cancelaron con vale ', 'Inicio Emergencia', 7, 723),
(688, '2024-05-24 09:30:00', 'Rx realizados el domingo 19 de mayo cancelaron con vale', 'Inicio Emergencia', 7, 724),
(689, '2024-05-24 10:30:00', 'Rx realizados el Domingo 19 de mayo cancelaron con vale ', 'Inicio Emergencia', 7, 725),
(690, '2024-05-25 13:30:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 726),
(692, '2024-05-26 12:01:00', 'px en clínica, ya habían cancelado en recep.\nPX del dia 25 mayo 2024', 'Inicio Emergencia', 5, 728),
(693, '2024-05-26 01:10:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 729),
(694, '2024-05-26 03:50:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 730),
(695, '2024-05-27 12:10:29', 'Elmer debió escribir de 04:00 a 08:00 y no 04:00 a 20:00\n\nDebe arregrlarlo', 'El tiempo aparece negativo', 1, 695),
(696, '2024-05-27 12:13:20', 'Elmer debe corregir a un valor de Q 65.00 en lugar de Q 50.00 porque estuvieron realizando varios intentos para tomar los rayos x y no se pudo por falla del detector. hora de inicio y fin está bien', 'Falla del detector', 1, 722),
(697, '2024-05-27 12:18:45', 'Se va a corregir en el excel porque el programa no permite ya corregir despuús de haber grabado.', 'Error de llenado de casillas', 1, 611),
(698, '2024-05-27 12:19:25', 'Se va a corregir en el excel porque el programa no permite ya corregir despuús de haber grabado.', 'Error en llenado de casillas', 1, 696),
(699, '2024-05-27 13:10:00', 'El día domingo 26 de mayo se realizo el servicio. Técnico. Wilda. ', 'Inicio Emergencia', 6, 731),
(700, '2024-05-27 15:50:00', 'El día domingo de mayo se realizo el servicio. Técnico. Wilda. ', 'Inicio Emergencia', 6, 732),
(701, '2024-05-27 13:00:00', 'El día sábado 25 de mayo se realizo la instalación de los aires acondicionados de la oficina de administración y de el ex taller.', 'Inicio Emergencia', 6, 733),
(702, '2024-05-27 19:35:00', 'Se deja vale', 'Inicio Emergencia', 5, 734),
(703, '2024-05-27 19:48:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 735),
(704, '2024-05-29 17:47:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 737),
(705, '2024-05-29 19:17:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 738),
(706, '2024-05-29 05:46:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 739),
(707, '2024-05-29 07:15:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 740),
(708, '2024-05-30 19:25:00', 'Cancelaron con vale la doctora y el ingeniero llevaron el vale a memorial para la firma ', 'Inicio Emergencia', 7, 741),
(709, '2024-05-31 06:00:00', 'Se puso ese horario pero fueron mis horas de almuerzo porque no las tome xq fuimos al igss y después al portátil y no hagarre las 2 horas d almuerzo.', 'Inicio Emergencia', 6, 743),
(710, '2024-05-31 20:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 744),
(711, '2024-06-01 17:45:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 745),
(712, '2024-06-01 20:10:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 746),
(713, '2024-06-02 22:45:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 747),
(714, '2024-06-04 07:25:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 748),
(715, '2024-06-04 17:45:00', 'Cancelaron con vale Rx realizados el día Sábado 1 de junio ', 'Inicio Emergencia', 7, 749),
(716, '2024-06-04 20:10:00', 'Cancelaron con efectivo  Rx realizados el día Sábado 1 de junio ', 'Inicio Emergencia', 7, 750),
(717, '2024-06-04 22:45:00', 'Rx realizados el DOMINGO 2 de Junio ', 'Inicio Emergencia', 7, 751),
(718, '2024-06-04 07:25:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 752),
(719, '2024-06-06 19:25:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 753),
(720, '2024-06-08 08:40:00', 'px del dia 31 mayo 2024\n\nse dejo vale', 'Inicio Emergencia', 5, 754),
(721, '2024-06-09 09:30:00', '-PX CANCELAN EN EFECTIVO\n-PX NO COLABORABA, Y ENFERMERA ( LO CANALIZO 2 VECES ANTES DE INICIAR CON LOS RX YA QUE PX SE QUITABA CATETER ) MOTIVO POR EL CUAL NOS TARDAMOS\n-', 'Inicio Emergencia', 5, 755),
(722, '2024-06-09 09:30:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 756),
(723, '2024-06-09 03:25:00', 'PX CANCELA EN EFECTIVO\n', 'Inicio Emergencia', 5, 757),
(724, '2024-06-09 15:25:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 758),
(725, '2024-06-15 05:00:00', 'El día martes 11 de junio se realizó el viaje a la capital con el ingeniero la hora fue de 5:30 ah 8:00 am y de 5:00 ah 5:30 pm pero porque no se puede poner así en el sistema se puso de 5 ah 8 ', 'Inicio Emergencia', 6, 759),
(726, '2024-06-17 17:00:00', 'El día 17 de junio se realizó fumigacion en X-RADII ', 'Inicio Emergencia', 6, 760),
(727, '2024-06-17 20:54:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 761),
(728, '2024-06-19 19:45:00', '2/6/24', 'Inicio Emergencia', 7, 762),
(729, '2024-06-19 20:54:00', 'Rx realizados el 17 de junio ', 'Inicio Emergencia', 7, 763),
(730, '2024-06-21 18:55:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 764),
(731, '2024-06-22 07:00:00', 'El día viernes 21 de Junio m toco cubrir a Meli x sus vacaciones.', 'Inicio Emergencia', 6, 765),
(732, '2024-06-22 21:13:00', 'Se deja vale', 'Inicio Emergencia', 5, 766),
(733, '2024-06-22 21:13:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 767),
(734, '2024-06-23 19:00:00', 'Rx realizados el día viernes 21 de junio cancelaron con vale ', 'Inicio Emergencia', 7, 768),
(735, '2024-06-23 11:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 769),
(736, '2024-06-23 11:50:00', 'Cancela efectivo', 'Inicio Emergencia', 5, 770),
(737, '2024-06-23 17:46:00', 'Cancela en efectivo ', 'Inicio Emergencia', 5, 771),
(738, '2024-06-25 07:01:00', 'El día lunes 25 de junio me toco cubrir a Meli. ', 'Inicio Emergencia', 6, 772),
(739, '2024-06-25 07:00:00', 'El 25 se cubrió a Meli ', 'Inicio Emergencia', 6, 773),
(740, '2024-06-25 19:30:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 774),
(741, '2024-06-25 20:35:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 775),
(742, '2024-06-27 00:45:00', 'El día miércoles 26 de julio se realizó servicio de emergencia en sala de cirugía. Técnico. Wilda. ', 'Inicio Emergencia', 6, 776),
(743, '2024-06-27 07:00:00', 'El día miércoles 26 toco cubrir a Meli ', 'Inicio Emergencia', 6, 777),
(744, '2024-06-29 11:20:00', 'Técnico. Denilson. ', 'Inicio Emergencia', 6, 778),
(745, '2024-06-30 05:35:00', 'Técnico. Denilson. ', 'Inicio Emergencia', 6, 779),
(746, '2024-06-30 10:30:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 780),
(747, '2024-07-02 07:00:00', 'El día lunes 1 de julio toco cubrir a Meli', 'Inicio Emergencia', 6, 781),
(748, '2024-07-03 07:00:00', 'El día martes 2 de julio.', 'Inicio Emergencia', 6, 782),
(749, '2024-07-04 07:00:00', 'El día miércoles 3 de julio ', 'Inicio Emergencia', 6, 783),
(750, '2024-07-04 20:56:00', 'El día miércoles 3 de julio se realizó emergencia de portátil. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 784),
(751, '2024-07-04 05:13:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 785),
(752, '2024-07-04 07:02:00', 'Cubriendo a Meli ', 'Inicio Emergencia', 6, 786),
(755, '2024-07-04 22:00:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 789),
(756, '2024-07-04 22:30:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 790),
(757, '2024-07-06 14:30:00', 'Se deja vale', 'Inicio Emergencia', 5, 791),
(758, '2024-07-06 19:30:00', 'Se deja vale\nPx del 25 junio 2024 ', 'Inicio Emergencia', 5, 792),
(759, '2024-07-06 20:35:00', 'Se deja vale\nPx del 25 junio 2024', 'Inicio Emergencia', 5, 793),
(760, '2024-07-06 00:45:00', 'Cirugia\nCadera derecha\nPx de la madrugada del 26 junio 2024', 'Inicio Emergencia', 5, 794),
(761, '2024-07-07 09:10:00', 'SE DEJA VALE', 'Inicio Emergencia', 5, 795),
(762, '2024-07-07 14:30:00', 'El día sábado 6de julio se realizó la emergencia. Técnico. Wilda. ', 'Inicio Emergencia', 6, 796),
(763, '2024-07-07 09:10:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 797),
(764, '2024-07-07 07:00:00', 'El día viernes 5 de Julio ', 'Inicio Emergencia', 6, 798),
(765, '2024-07-08 16:55:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 800),
(766, '2024-07-10 07:00:00', 'El día martes 9 de julio', 'Inicio Emergencia', 6, 801),
(767, '2024-07-12 22:30:00', 'Rx realizados el 29 de junio cancelaron con vale ', 'Inicio Emergencia', 7, 802),
(768, '2024-07-12 17:49:51', 'Perdón fue el 30 de Junio ', 'Correccion', 7, 802),
(769, '2024-07-12 21:00:00', 'Rx realizados el día 3 de julio, cancelaron con efectivo ', 'Inicio Emergencia', 7, 803),
(770, '2024-07-12 17:30:00', 'Rx realizados el 4 de julio ', 'Inicio Emergencia', 7, 804),
(771, '2024-07-12 17:00:00', 'Precio autorizado por doctora cancelo en efectivo rx realizados el martes  2 de julio en clínica ', 'Inicio Emergencia', 7, 805),
(772, '2024-07-12 22:00:00', 'Rx realizados el 4 de julio cancelaron en efectivo ', 'Inicio Emergencia', 7, 806),
(773, '2024-07-12 22:30:00', 'Rx realizados el 4 de julio cancelaron con vale ', 'Inicio Emergencia', 7, 807),
(774, '2024-07-12 17:30:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 808),
(775, '2024-07-12 18:10:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 809),
(776, '2024-07-12 17:30:00', 'Px cancela en efectivo', 'Inicio Emergencia', 5, 810),
(777, '2024-07-12 18:10:00', 'Se deja vale', 'Inicio Emergencia', 5, 811),
(778, '2024-07-13 15:38:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 812),
(779, '2024-07-13 16:10:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 813),
(780, '2024-07-13 15:38:00', 'Cancelo con vale ', 'Inicio Emergencia', 7, 814),
(781, '2024-07-13 16:10:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 815),
(783, '2024-07-13 18:24:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 817),
(784, '2024-07-13 18:45:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 819),
(785, '2024-07-13 19:15:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 820),
(786, '2024-07-14 18:24:00', 'Rx realizados sábado 13 de julio cancelo en efectivo ', 'Inicio Emergencia', 7, 821),
(787, '2024-07-14 18:45:00', 'Rx realizados el 13 de julio cancelo en vale ', 'Inicio Emergencia', 7, 822),
(788, '2024-07-15 20:15:00', 'Emergencia en sala de cirugía. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 823),
(789, '2024-07-15 20:15:00', 'Cirugía', 'Inicio Emergencia', 7, 824),
(790, '2024-07-17 18:35:00', 'El día martes 16 de julio se realizó fumigacion en X-RADII ', 'Inicio Emergencia', 6, 825),
(791, '2024-07-17 17:35:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 826),
(792, '2024-07-17 22:30:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 827),
(793, '2024-07-18 17:30:00', 'Rx realizados el 17 de junio cancelaron en efectivo ', 'Inicio Emergencia', 7, 828),
(794, '2024-07-18 22:30:00', 'Rx realizados el día miércoles 17 de julio cancelaron con vale ', 'Inicio Emergencia', 7, 829),
(795, '2024-07-18 07:20:00', 'Cancelaron con efectivo ', 'Inicio Emergencia', 7, 830),
(796, '2024-07-18 21:04:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 831),
(797, '2024-07-18 07:20:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 832),
(798, '2024-07-18 20:59:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 833),
(799, '2024-07-20 19:38:00', 'Px con vale', 'Inicio Emergencia', 5, 834),
(800, '2024-07-20 19:38:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 835),
(801, '2024-07-21 16:30:00', 'Px cancela efectivo', 'Inicio Emergencia', 5, 836),
(802, '2024-07-21 16:35:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 837),
(803, '2024-07-23 05:05:00', 'Se deja vale', 'Inicio Emergencia', 5, 838),
(804, '2024-07-23 05:10:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 839),
(805, '2024-07-25 20:50:00', 'Px cancela en efectivo', 'Inicio Emergencia', 5, 840),
(806, '2024-07-25 21:30:00', 'Px camcela en efectivo', 'Inicio Emergencia', 5, 841),
(807, '2024-07-25 20:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 842),
(808, '2024-07-25 21:35:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 843),
(809, '2024-07-28 17:00:00', 'El día viernes 26 de julio se le realizo mantenimiento al Densitometro de centro medico Zacapa. Con el Inge.', 'Inicio Emergencia', 6, 844),
(810, '2024-07-29 09:11:19', 'Realice cambio de horario', 'Cambio ', 7, 804),
(811, '2024-07-30 17:00:00', 'Px cancela en clinica', 'Inicio Emergencia', 5, 845),
(812, '2024-07-31 16:20:00', 'Emergencia en sala de cirugía. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 846),
(813, '2024-07-31 16:20:00', 'Cirugia se cobo extra un dedo ap y lateral por eso es el precio y se agregarin los 75 extra de la radiografía ', 'Inicio Emergencia', 7, 847),
(814, '2024-08-02 19:33:00', 'El día jueves 1 de agosto se realizó emergencia de portátil. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 848),
(815, '2024-08-04 06:50:00', 'px con vale', 'Inicio Emergencia', 5, 849),
(816, '2024-08-04 07:30:00', 'px cancela con transferencia', 'Inicio Emergencia', 5, 850),
(817, '2024-08-04 08:15:00', 'px con vale', 'Inicio Emergencia', 5, 851),
(818, '2024-08-04 11:17:42', 'px del dia 03 de agosto', 'px del dia 03 de agosto', 5, 851),
(819, '2024-08-04 20:15:00', 'El día sábado 3 de agosto se realizó la emergencia. Técnico. Wilda. ', 'Inicio Emergencia', 6, 852),
(820, '2024-08-04 06:50:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 853),
(821, '2024-08-04 07:30:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 854),
(822, '2024-08-06 17:20:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 855),
(823, '2024-08-06 17:20:00', 'Px con vale', 'Inicio Emergencia', 5, 856),
(824, '2024-08-06 20:20:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 857),
(825, '2024-08-06 20:20:00', 'Se deja vale', 'Inicio Emergencia', 5, 858),
(826, '2024-08-06 21:00:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 859),
(827, '2024-08-06 21:00:00', 'Se deja vale', 'Inicio Emergencia', 5, 860),
(828, '2024-08-07 17:20:00', 'Se deja vale', 'Inicio Emergencia', 5, 861),
(829, '2024-08-07 05:30:00', 'El día miércoles 7 de agosto se realizó viaje a la capital a traer Sonigel con Denilson.', 'Inicio Emergencia', 6, 862),
(830, '2024-08-07 17:20:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 863),
(831, '2024-08-08 19:25:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 864),
(832, '2024-08-08 20:00:00', 'Fueron 2 horas extras Técnico. Wilda. ', 'Inicio Emergencia', 6, 865),
(834, '2024-08-08 20:00:00', 'Se deja vale, px con seguro', 'Inicio Emergencia', 5, 867),
(835, '2024-08-08 19:25:00', 'Se deja vale', 'Inicio Emergencia', 5, 868),
(836, '2024-08-10 12:37:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 869),
(837, '2024-08-10 13:20:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 870),
(838, '2024-08-10 14:08:00', 'Sala de cirugía. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 871),
(839, '2024-08-10 17:00:00', 'Sala de cirugía. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 872),
(840, '2024-08-10 18:30:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 873),
(841, '2024-08-11 00:17:00', 'Rx realizados el 01 de agosto emergencia ', 'Inicio Emergencia', 7, 874),
(842, '2024-08-11 12:37:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 875),
(843, '2024-08-11 12:20:00', 'Rx realizados 10/08/2024 cancelaron en efectivo ', 'Inicio Emergencia', 7, 876),
(844, '2024-08-11 14:08:00', 'Se le cobraron dos ya que se tomaron 11 disparos por lo cual se le agrego 1000 más los 1200 de lo que fue el paquete extra ', 'Inicio Emergencia', 7, 877),
(846, '2024-08-11 18:30:00', 'Rx realizados el 10/08/2024 cancelaron en efectivo ', 'Inicio Emergencia', 7, 879),
(847, '2024-08-11 17:00:00', 'Cirugia realizada el 10/08/2024 cancelaron con vale 1200', 'Inicio Emergencia', 7, 880),
(848, '2024-08-11 08:30:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 881),
(849, '2024-08-11 09:30:00', 'Cancelaron en efectivo ', 'Inicio Emergencia', 7, 882),
(850, '2024-08-11 10:05:00', 'Px cancelaron con vale paciente RN ', 'Inicio Emergencia', 7, 883),
(851, '2024-08-11 16:30:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 884),
(852, '2024-08-11 16:30:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 885),
(853, '2024-08-11 22:00:00', 'Cancelaron con vale ', 'Inicio Emergencia', 7, 886),
(854, '2024-08-12 22:00:00', 'El día domingo 11 de agosto se realizó la emergencia de portátil. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 887),
(855, '2024-08-14 16:50:00', 'Se realizo fumigacion en X-RADII. ', 'Inicio Emergencia', 6, 888),
(856, '2024-08-14 17:45:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 889),
(857, '2024-08-14 18:35:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 890),
(858, '2024-08-16 12:30:00', 'El día jueves 15 de agosto se realizó la emergencia. Técnico. Skarleth.', 'Inicio Emergencia', 6, 891),
(859, '2024-08-17 15:55:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 892),
(860, '2024-08-20 12:00:00', 'El día domingo 18 de agosto se realizó la emergencia. Técnico. Denilson. ', 'Inicio Emergencia', 6, 893),
(861, '2024-08-20 19:28:00', 'Técnico. Denilson ', 'Inicio Emergencia', 6, 894),
(862, '2024-08-23 17:15:00', 'La emergencia se realizo el día jueves 22 de agosto. Técnico. Denilson. ', 'Inicio Emergencia', 6, 895),
(865, '2024-08-24 14:00:00', 'Técnico. Denilson. ', 'Inicio Emergencia', 6, 898),
(866, '2024-08-24 18:50:00', 'Sala de cirugía. Técnico. Denilson. ', 'Inicio Emergencia', 6, 899),
(867, '2024-08-25 18:35:00', 'Rx realizados el 14 de agosto cancelaron con vale ', 'Inicio Emergencia', 7, 901),
(868, '2024-08-25 15:55:00', 'Rx realizados el día 15 de agosto cancelaron en efectivo y se imprimieron placas y entregaron ', 'Inicio Emergencia', 7, 902),
(869, '2024-08-25 15:56:00', 'Rx realizados el 17 de agosto cancelaron con vale ', 'Inicio Emergencia', 7, 903),
(870, '2024-08-29 20:21:00', 'El día miércoles 28 de agosto. Técnico. Skarleth ', 'Inicio Emergencia', 6, 904),
(871, '2024-08-30 07:00:00', ' cubriendo a Meli', 'Inicio Emergencia', 6, 905),
(872, '2024-08-30 17:55:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 906),
(873, '2024-08-31 12:00:00', 'Se realizo mantenimiento a la mesa de rayos x con el ingeniero.', 'Inicio Emergencia', 6, 907),
(874, '2024-09-02 17:55:00', 'El día domingo 1 de septiembre se realizó la emergencia. Técnico. Denilson. ', 'Inicio Emergencia', 6, 908),
(875, '2024-09-02 17:00:00', 'Se le dio mantenimiento a la mesa de rayos x con el ingeniero se cambio la tarjeta madre.', 'Inicio Emergencia', 6, 909),
(876, '2024-09-02 18:45:00', 'Técnico. Denilson. ', 'Inicio Emergencia', 6, 910),
(877, '2024-09-03 19:10:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 911),
(878, '2024-09-03 19:10:00', 'Px con vale', 'Inicio Emergencia', 5, 912),
(879, '2024-09-04 05:20:00', 'CANCELAN EN EFECTIVO', 'Inicio Emergencia', 5, 914),
(880, '2024-09-04 17:20:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 915),
(881, '2024-09-04 20:45:00', 'Cqncela en efectivo ', 'Inicio Emergencia', 5, 916),
(882, '2024-09-04 20:45:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 917),
(883, '2024-09-05 19:45:00', 'Se deja vale', 'Inicio Emergencia', 5, 918),
(884, '2024-09-05 19:45:00', 'Técnico. Wilda. ', 'Inicio Emergencia', 6, 919),
(885, '2024-09-07 13:41:00', 'Técnico. Skarleth. ', 'Inicio Emergencia', 6, 920),
(886, '2024-09-09 18:52:00', 'El día domingo 8 de septiembre. Técnico. Skarleth. ', 'Inicio Emergencia', 6, 921),
(887, '2024-09-09 17:00:00', 'Se realizo mantenimiento a impresora de rayos x con el ingeniero Elder. ', 'Inicio Emergencia', 6, 922),
(888, '2024-09-10 17:00:00', 'Técnico. Denilson. ', 'Inicio Emergencia', 6, 923);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos`
--

CREATE TABLE `datos` (
  `id` int(11) NOT NULL,
  `dato` varchar(30) NOT NULL,
  `precio` float NOT NULL,
  `rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `datos`
--

INSERT INTO `datos` (`id`, `dato`, `precio`, `rol`) VALUES
(1, 'hora_extra', 20.17, 1),
(2, 'hora_extra_2', 20.17, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `emergencia`
--

CREATE TABLE `emergencia` (
  `id` int(11) NOT NULL,
  `inicio` time DEFAULT NULL,
  `fin` time DEFAULT NULL,
  `direccion` varchar(100) DEFAULT NULL,
  `precio` float DEFAULT NULL,
  `honorarios` float DEFAULT NULL,
  `hora_extra` float DEFAULT NULL,
  `paciente` varchar(100) DEFAULT NULL,
  `edad` int(11) DEFAULT NULL,
  `estudios` text DEFAULT NULL,
  `fecha` date NOT NULL,
  `f_estado` int(11) NOT NULL,
  `f_usuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `emergencia`
--

INSERT INTO `emergencia` (`id`, `inicio`, `fin`, `direccion`, `precio`, `honorarios`, `hora_extra`, `paciente`, `edad`, `estudios`, `fecha`, `f_estado`, `f_usuario`) VALUES
(4, '17:26:00', '18:28:00', 'centro clinico', NULL, 2, 36.48, 'javier ', NULL, NULL, '2023-01-02', 3, 6),
(5, '17:00:00', '18:20:00', 'Centro clínico Chiquimula ', NULL, 1, 37.94, 'Juan Pérez ', NULL, NULL, '2023-01-02', 3, 6),
(7, '18:30:00', '19:42:00', 'Clinica X Radii', 300, 50, 39.38, 'centro veterinario de oriente', 0, 'Abdomen ', '2023-01-02', 4, 5),
(13, '15:12:00', '15:34:00', 'Clínica X-Radii', 350, 75, 19.69, 'María del Carmen Lemus Flores ', 76, 'Rx Tórax pa/lateral ', '2023-01-07', 4, 7),
(14, '12:21:00', '13:13:00', 'Portátil Millenium ', 550, 75, 19.69, 'Florinda Lemus ', 83, 'Rx de tórax ap/lateral ', '2023-01-08', 4, 7),
(16, '17:00:00', '18:20:00', 'Clinica', NULL, 1, 37.94, 'Trabajo', NULL, NULL, '2023-01-08', 3, 6),
(17, '17:00:00', '19:40:00', 'Hospital medicall y hospital memorial', NULL, 1, 56.91, 'Inés Recinos y Martha Morales ', NULL, NULL, '2023-01-08', 3, 6),
(18, '12:09:00', '13:23:00', 'Hospital milenium.', NULL, 1, 37.94, 'Florinda Lemus ', NULL, NULL, '2023-01-08', 3, 6),
(19, '17:00:00', '17:45:00', 'Punto Médico ', 550, 75, 19.69, 'Darwin Manchame ', 1, 'Rx tórax ap/lat', '2023-01-11', 4, 7),
(20, '17:00:00', '17:40:00', 'Punto médico ', NULL, 1, 18.97, 'Darwin Manchame', NULL, NULL, '2023-01-12', 3, 6),
(21, '05:00:00', '06:20:00', 'CENTRO CLINICO DE ESPECIALIDADES', 550, 75, 39.38, 'JUAN PEREZ', 0, '550.00', '2023-01-20', 4, 5),
(22, '06:20:00', '07:00:00', 'XRADII', 300, 50, 19.69, 'CENTRO VETERINARIO DE ORIENTE', 0, 'ABDOMEN', '2023-01-20', 4, 5),
(23, '06:20:00', '07:00:00', 'XRADII', 300, 50, 19.69, 'CENTRO VETERINARIO DE ORIENTE', 0, 'ABDOMEN', '2023-01-20', 4, 5),
(25, '05:20:00', '07:20:00', 'MEDICALL', 550, 75, 39.38, 'INES RECINOS', 0, 'TORAX PA Y LAT', '2023-01-20', 4, 5),
(26, '05:20:00', '07:20:00', 'MEMORIAL', 550, 75, 39.38, 'MARTHA MORALES', 0, 'TORAX PA Y LAT', '2023-01-20', 4, 5),
(27, '06:45:00', '07:02:00', 'XRADII', 300, 50, 19.69, 'VETERINARIA DE ORIENTE', 0, 'ABDOMEN', '2023-01-20', 4, 5),
(29, '19:32:00', '20:40:00', 'Centro clínico Chiquimula ', NULL, 1, 37.94, 'Milagro Sánchez ', NULL, NULL, '2023-01-21', 2, 6),
(30, '19:32:00', '20:40:00', 'CENTRO CLINICO DE ESPECIALIDADES', 550, 75, 39.38, 'MILAGRO SANCHEZ', 0, 'Pierna ap y lat', '2023-01-21', 4, 5),
(31, '14:43:00', '16:08:00', 'Universidad cunori ', NULL, 1, 37.94, 'Armando Nájera ', NULL, NULL, '2023-01-21', 2, 6),
(32, '14:55:00', '16:15:00', 'Clínica / Cunori ', 0, 75, 39.38, 'Armando Nájera ', 20, 'Rx de mano izq AP, laterial y oblicua \n', '2023-01-21', 4, 7),
(33, '17:52:00', '21:00:00', 'Concepción las minas ', NULL, 1, 75.88, 'Carmen Guerra Monroy ', NULL, NULL, '2023-01-23', 2, 6),
(34, '17:00:00', '17:56:00', 'Hospital Millenium ', 450, 75, 19.69, 'Dolores Flores ', 65, 'Rx Abdomen Completo', '2023-01-24', 4, 7),
(35, '17:00:00', '17:55:00', 'Hospital Milenium ', NULL, 1, 18.97, 'Dolores Flores', NULL, NULL, '2023-01-24', 2, 6),
(36, '17:52:00', '21:00:00', 'La Ermita Concepción las Minas ', 1200, 153, 78.76, 'Carmen Guerra ', 87, 'Rx de tórax ap/lateral ', '2023-01-24', 4, 7),
(39, '06:30:00', '06:50:00', 'X-radi ', 300, 50, 19.69, 'Perrito del molino ', 0, 'Rx de mano ap/lateral ', '2023-01-27', 4, 7),
(42, '12:01:00', '12:50:00', 'CENTRO CLINICO DE ESPECIALIDADES', 550, 75, 19.69, 'Ivan Salguero', 64, 'Torax Ap y lat', '2023-01-28', 4, 5),
(43, '18:45:00', '19:25:00', 'XRADII', 300, 50, 19.69, 'CDENTRO VETERINARIO DE ORIENTE', 1, '1 ABDOMEN', '2023-01-30', 4, 5),
(44, '17:45:00', '18:50:00', 'XRADII', 600, 100, 39.38, 'CENTRO VETERINARIO DE ORIENTE', 1, '2 ABDOMEN', '2023-01-31', 4, 5),
(46, '17:50:00', '18:15:00', 'XRADII', 350, 75, 19.69, 'LUISA VALLE', 5, 'TORAX PA Y LAT', '2023-02-03', 4, 5),
(48, '12:00:00', '12:50:00', 'Centro clínico Chiquimula ', NULL, 50, 18.97, 'Iván Salguero ', NULL, NULL, '2023-02-03', 4, 6),
(49, '21:07:00', '22:01:00', 'Hospital siglo 21 ', NULL, 50, 18.97, 'Maria Evangelina Picen ', NULL, NULL, '2023-02-03', 4, 6),
(50, '21:07:00', '22:01:00', 'HOSPITAL SIGLO 21', 300, 75, 19.69, 'MARIA EVANGELINA PICEN', 89, 'TORAX AP, \nNO SE TOMA RX  LAT.', '2023-02-03', 4, 5),
(51, '13:55:00', '14:35:00', 'Emergencia Portátil centro clínico ', 550, 75, 19.69, 'Byron Hernández ', 43, 'Rx Abdomen Completo', '2023-02-05', 4, 7),
(52, '18:19:00', '18:44:00', 'Clínica X-Radii ', 900, 150, 19.69, '3 Perritos ', 0, 'Se realizaron 3 perritos Rx de abdomen a c/u ', '2023-02-07', 4, 7),
(53, '14:55:00', '15:15:00', 'XRADII', 300, 75, 19.69, 'FRANCISCO ROSA RAMIREZ', 1, 'ABDOMEN SIMPLE', '2023-02-11', 4, 5),
(54, '19:35:00', '20:22:00', 'SIGLO 21', 550, 75, 19.69, 'CRISTIAN ALEXANDER GIRON', 15, 'TORAX AP', '2023-02-13', 4, 5),
(55, '18:33:00', '20:22:00', 'hostital Memorial', NULL, 50, 37.94, 'Nineth Hernandez', NULL, NULL, '2023-02-14', 4, 6),
(56, '19:34:00', '20:21:00', 'hospital siglo 21', NULL, 50, 18.97, 'Cristian Giron', NULL, NULL, '2023-02-14', 4, 6),
(57, '21:52:00', '23:12:00', 'hospital siglo 21', NULL, 100, 37.94, 'Diego Valdez / Adrian Palacios', NULL, NULL, '2023-02-14', 4, 6),
(58, '21:50:00', '23:12:00', 'Siglo 21', 1100, 150, 39.38, 'Diego Valdez / Adrian Palacios', 1, 'Antebrazo / Torax', '2023-02-14', 4, 5),
(59, '18:33:00', '18:55:00', 'XRADII', 300, 50, 19.69, 'CENTRO VETERINARIO DE ORIENTE', 1, 'ABDOMEN ', '2023-02-14', 4, 5),
(60, '18:24:00', '18:53:00', 'XRADII', 450, 75, 19.69, 'Maria Guadalupe Hernandez', 1, 'Columna lumbar Ap y lat', '2023-02-15', 4, 5),
(61, '18:18:00', '18:15:00', 'UNIDAD MEDICA', 550, 75, 39.38, 'DELFA MARTINEZ', 1, 'ABDOMEN SIMPLE', '2023-02-16', 4, 5),
(62, '04:15:00', '08:00:00', 'IGSS de la zona 1 Guatemala ', NULL, 125, 75.88, 'Viaje al IGSS ', NULL, NULL, '2023-02-17', 4, 6),
(63, '18:18:00', '19:36:00', 'Hospital unidad medica', NULL, 50, 37.94, 'Nora Yaneth Morataya', NULL, NULL, '2023-02-17', 4, 6),
(64, '18:30:00', '19:00:00', 'XRADII', 300, 50, 19.69, 'CENTRO VETERINARIO DE ORIENTE', 1, '1 PIE AP LAT', '2023-02-17', 4, 5),
(65, '21:20:00', '23:59:00', 'Centro Clínico Concepción las minas ', 1450, 228, 57.07, 'Harrys Paredes ', 10, 'Tórax AP y húmero AP/lateral ', '2023-02-20', 4, 7),
(66, '18:30:00', '19:00:00', 'Xradi ', 600, 100, 19.69, '2 perritos ', 0, 'Rx de cráneo AP/lateral\nRx de tórax ap/lat', '2023-02-20', 4, 7),
(67, '21:02:00', '23:59:00', 'Centro clínico concepción las minas ', NULL, 107, 56.91, 'Harris Paredes ', NULL, NULL, '2023-02-20', 4, 6),
(68, '19:00:00', '20:15:00', 'Centro clínico ', 550, 75, 39.38, 'Santos Portillo', 52, 'Rx de tórax ', '2023-02-20', 4, 7),
(69, '19:26:00', '20:00:00', 'Centró clínico Chiquimula ', NULL, 50, 18.97, 'Santos Portillo Monrroy ', NULL, NULL, '2023-02-21', 4, 6),
(70, '19:00:00', '19:30:00', 'Clínica X-Radii ', 350, 75, 19.69, 'Jerónimo García ', 83, 'Rx de tórax pa/Lateral ', '2023-02-21', 4, 7),
(71, '05:30:00', '08:00:00', 'Bodegas Capital ', NULL, 125, 56.91, 'X-TECH ', NULL, NULL, '2023-02-23', 4, 6),
(72, '21:55:00', '22:50:00', 'Unidad Médica ', 550, 75, 19.69, 'Glenda Hernández ', 86, 'Rx torax ap/lat', '2023-02-23', 4, 7),
(73, '21:55:00', '22:46:00', 'Unidad medica ', NULL, 50, 18.97, 'Glenda Hernández ', NULL, NULL, '2023-02-23', 4, 6),
(74, '18:24:00', '22:46:00', 'Centro clinico concepcion', 2200, 378, 98.45, 'Wilmer acosta', 6, 'Torax pa y lat', '2023-02-27', 4, 5),
(75, '18:24:00', '23:46:00', 'Centro clínico concepción las minas ', NULL, 296, 115.38, 'Wilmer Acosta ', NULL, NULL, '2023-02-27', 4, 6),
(76, '17:18:00', '21:40:00', 'Centro clínico concepción las minas ', NULL, 125, 96.15, 'Otilio Gutiérrez ', NULL, NULL, '2023-02-27', 4, 6),
(77, '18:40:00', '20:20:00', 'Hospital memorial ', 1200, 200, 39.38, 'Nineth Hernández ', 52, 'Rx muñeca izquierda ', '2023-02-27', 4, 7),
(78, '17:18:00', '21:40:00', 'Centro clinico Concepcion', 1700, 200, 98.45, 'Fernando velasquez', 1, 'torax pa y Parrilla costal\n\ny  muñeca izquierda\n', '2023-02-27', 4, 5),
(79, '17:34:00', '18:24:00', 'X RADII', 700, 150, 19.69, 'GEOVANY SAMAYOA CABRERA', 1, 'TORAX PA Y LAT', '2023-02-27', 4, 5),
(80, '21:44:00', '23:35:00', 'SIGLO 21', 1550, 250, 39.38, 'PEDRO GONZALEZ', 1, 'TORAX AP', '2023-02-27', 4, 5),
(81, '21:44:00', '23:25:00', 'Hospital siglo 21 ', NULL, 100, 37.94, 'Fernando Velásquez ', NULL, NULL, '2023-02-28', 4, 6),
(82, '12:00:00', '13:00:00', 'Unidad médica ', 550, 75, 19.69, 'Presentación Jacome ', 84, 'Rx de tórax ap/lat', '2023-03-04', 4, 7),
(83, '12:00:00', '12:50:00', 'Hospital unidad medica Chiquimula ', NULL, 50, 19.23, 'Presentación Jácome ', NULL, NULL, '2023-03-08', 4, 6),
(84, '13:00:00', '14:45:00', 'CENTRO CLINICO', 800, 150, 39.38, 'ROBERTO SANDOVAL ARGUETA', 1, 'TORAX PA Y LAT\nABDOMEN', '2023-03-11', 4, 5),
(85, '14:50:00', '15:54:00', 'HOSPITAL SIGLO 21', 550, 75, 39.38, 'FERNANDO GOMEZ', 1, 'TORAX AP', '2023-03-11', 4, 5),
(86, '13:00:00', '14:45:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 38.46, 'Roberto Sandoval ', NULL, NULL, '2023-03-12', 4, 6),
(87, '14:50:00', '14:54:00', 'Hospital siglo 21 ', NULL, 50, 19.23, 'Fernando Gómez ', NULL, NULL, '2023-03-12', 4, 6),
(88, '18:40:00', '19:07:00', 'XRADII', 300, 50, 19.69, 'Centro veterinario de Oriente', 1, 'Abdomen', '2023-03-13', 4, 5),
(89, '00:24:00', '01:14:00', 'Hospital siglo 21', 550, 75, 19.69, 'Claudio Nerio', 19, 'Torax ap', '2023-03-16', 4, 5),
(90, '20:27:00', '23:16:00', 'CENTRO MEDICO DE CHIQUIMULA', 1200, 200, 59.07, 'JOSE ABEL MARTINEZ', 51, 'MUÑECA    AP  Y LAT            ', '2023-03-17', 4, 5),
(93, '20:27:00', '23:16:00', 'Hospital Centro Medico Chiquimula ', NULL, 88.46, 57.69, 'José Abel Martínez ', NULL, NULL, '2023-03-18', 4, 6),
(94, '06:30:00', '08:00:00', 'Memorial ', 400, 75, 39.38, 'José Manchame ', 9, 'Rx pie comparativa', '2023-03-18', 4, 7),
(95, '17:00:00', '18:00:00', 'Los Achiotes Ipala ', NULL, 19.23, 19.23, 'Gumercinda García Nolasco ', NULL, NULL, '2023-03-18', 4, 6),
(96, '06:30:00', '08:00:00', 'Hospital Memorial Chiquimula ', NULL, 50, 38.46, 'José Jacobo Manchame', NULL, NULL, '2023-03-18', 4, 6),
(97, '14:00:00', '15:00:00', 'Centro Clínico Chiquimula ', 550, 75, 19.69, 'Yasmin Polanco ', 23, 'Rx torax ap ', '2023-03-19', 4, 7),
(98, '14:00:00', '15:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Yasmin ', NULL, NULL, '2023-03-19', 4, 6),
(99, '19:05:00', '19:36:00', 'Clínica X-Radii ', 300, 50, 19.69, 'Perrito ', 0, 'Rx de cráneo ', '2023-03-20', 4, 7),
(100, '18:20:00', '19:00:00', 'X-radii ', 300, 50, 19.69, 'Gato ', 0, 'Rx de cadera ', '2023-03-22', 4, 7),
(101, '18:10:00', '18:45:00', 'X-radii', 600, 100, 19.69, 'Vet El Molio', 0, 'Rx de pierna y cadera ', '2023-03-24', 4, 7),
(102, '17:05:00', '17:25:00', 'X RADII', 350, 75, 19.69, 'HORTENCIA VELASQUEZ', 85, 'TORAX PA Y LAT', '2023-03-29', 4, 5),
(103, '18:35:00', '19:10:00', 'XRADII', 600, 125, 19.69, 'CENTRO VETERINARIO DE ORIENTE', 1, '2 ABDOMEN', '2023-03-29', 4, 5),
(104, '18:50:00', '19:50:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Mynor Sagastume ', NULL, NULL, '2023-03-30', 4, 6),
(105, '18:55:00', '19:55:00', 'CENTRO CLINICO DEESPECIALIDADES', 800, 150, 19.69, 'MYNOR SAGASTUME', 41, 'TORAX PA Y HOMBRO', '2023-03-30', 4, 5),
(106, '16:45:00', '19:45:00', 'Concepción las Minas ', 1500, 228, 59.07, 'Oseas ', 25, 'Rx de tórax ap y Abdomen AP ', '2023-04-01', 4, 7),
(107, '17:00:00', '17:46:00', 'Centro clínico chiquimula ', 550, 75, 19.69, 'Juan Antonio Duarte ', 63, 'Rx de Abdomen ', '2023-04-03', 4, 7),
(108, '18:30:00', '19:30:00', 'Xradi', 300, 50, 19.69, 'Vets ', 0, 'Cráneo AP/Lateral ', '2023-04-04', 4, 7),
(109, '16:45:00', '19:45:00', 'Centro clínico concepción las minas ', NULL, 125, 57.69, 'Oseas Boya', NULL, NULL, '2023-04-04', 4, 6),
(110, '17:00:00', '17:35:00', 'Centro clínico Chiquimula ', NULL, 50, 19.23, 'Juan Antonio Duarte ', NULL, NULL, '2023-04-04', 4, 6),
(111, '19:00:00', '19:35:00', 'XRADII', 350, 75, 19.69, 'Arelis Arbizu ', 53, 'Rx de hombro ', '2023-04-04', 4, 7),
(112, '15:30:00', '16:05:00', 'XRADII', 350, 75, 19.69, 'Arelis Arbizu ', 53, 'Columna Cervical ', '2023-04-05', 4, 7),
(113, '22:50:00', '23:40:00', 'Siglo 21', 550, 75, 19.69, 'Francisco López Ramírez ', 68, 'Rx torax ap', '2023-04-05', 4, 7),
(114, '22:50:00', '23:40:00', 'Hospital siglo 21 ', NULL, 50, 19.23, 'Francisco López Ramírez ', NULL, NULL, '2023-04-06', 4, 6),
(115, '09:50:00', '10:50:00', 'Hospital siglo 21 ', NULL, 50, 19.23, 'Yeison Ortiz ', NULL, NULL, '2023-04-06', 4, 6),
(116, '09:40:00', '10:40:00', 'Siglo21 ', 550, 75, 19.69, 'Geison Ortiz ', 20, 'Rx pierna AP/latera', '2023-04-06', 4, 7),
(117, '15:40:00', '16:45:00', 'X-RADII ', NULL, 50, 38.46, 'mantenimiento ', NULL, NULL, '2023-04-06', 4, 6),
(118, '17:00:00', '18:00:00', 'SIGLO 21', 550, 75, 19.69, 'Francisco Lopez', 1, 'Torax Ap', '2023-04-10', 4, 5),
(119, '18:21:00', '19:21:00', 'Casa Particular, enfrente clinica dr. Mazariegos', 800, 150, 19.69, 'MARIA CONCEPCION CARDONA', 1, 'Pelvis\nCadera derecha', '2023-04-10', 4, 5),
(120, '17:00:00', '18:00:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Francisco López ', NULL, NULL, '2023-04-11', 4, 6),
(121, '06:55:00', '07:55:00', 'Unidad Medica', 550, 75, 19.69, 'Henry Estrada ', 19, 'Torax Pa', '2023-04-11', 4, 5),
(122, '18:21:00', '19:21:00', 'Casa particular frente a clínica del Dr Mazariegos.', NULL, 50, 19.23, 'Maria Cardona ', NULL, NULL, '2023-04-11', 4, 6),
(123, '06:55:00', '07:55:00', 'Unidad Medica ', NULL, 50, 19.23, 'Henry Estrada ', NULL, NULL, '2023-04-11', 4, 6),
(124, '17:50:00', '18:45:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Ana Leticia Méndez ', NULL, NULL, '2023-04-16', 4, 6),
(125, '17:50:00', '18:45:00', 'SIGLO 21', 550, 75, 19.69, 'Ana Mendez', 64, 'Rx de pelvis ap', '2023-04-16', 4, 7),
(126, '20:45:00', '21:15:00', 'SIGLO 21', 550, 75, 19.69, 'Kristel Osorio ', 27, 'Pie derecho ', '2023-04-16', 4, 7),
(127, '20:45:00', '21:15:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Kristhel Andrea Osorio', NULL, NULL, '2023-04-17', 4, 6),
(128, '17:40:00', '18:06:00', 'XRADII', 300, 50, 19.69, 'Perrito ', 0, 'Abdomen ', '2023-04-19', 4, 7),
(129, '17:00:00', '18:00:00', 'XRADII', 350, 75, 19.69, 'Pilar Morales ', 11, 'Rx mano derecha ', '2023-04-20', 4, 7),
(130, '18:00:00', '18:37:00', 'Xradi', 600, 100, 19.69, 'Perritos ', 0, 'Rx de fémur \nRx de cuello ', '2023-04-21', 4, 7),
(131, '18:00:00', '19:00:00', 'XRADII', 350, 75, 19.69, 'Tiffany Cardona ', 7, 'Rx de abdomen ', '2023-04-21', 4, 7),
(132, '21:30:00', '22:12:00', ' HOSPITAL CENTRO CLINICO DE ESPECIALIDADES', 800, 150, 19.69, 'Rudy Guerra Vasquez', 12, 'Rx de pelvis AP y fémur ', '2023-04-21', 4, 7),
(133, '21:30:00', '22:12:00', 'Centro clínico Chiquimula ', NULL, 50, 19.23, 'Rudy Guerra Vasquez ', NULL, NULL, '2023-04-21', 4, 6),
(134, '22:15:00', '23:15:00', 'Centro clínico Chiquimula ', NULL, 85, 19.23, 'Angel David Martínez ', NULL, NULL, '2023-04-21', 4, 6),
(135, '22:15:00', '23:15:00', 'Centro clínico ', 1200, 200, 19.69, 'Angel David Martínez ', 33, 'Rx de tobillo ap/lat', '2023-04-21', 4, 7),
(136, '12:15:00', '13:15:00', 'Centro clínico Chiquimula ', NULL, 50, 19.23, 'Angel Martínez ', NULL, NULL, '2023-04-22', 4, 6),
(137, '12:15:00', '13:15:00', 'CENTRO CLINICO', 550, 75, 19.69, 'ANGEL MATIAS', 33, 'TOBILLO AP Y LAT', '2023-04-22', 4, 5),
(138, '01:15:00', '01:58:00', 'XRADII', 250, 75, 19.69, 'JULIETA RICARDO', 60, 'FEMUR DERECHO  AP Y LAT', '2023-04-22', 4, 5),
(139, '22:05:00', '22:55:00', 'Centro clínico Chiquimula ', NULL, 50, 19.23, 'Junior Lopes ', NULL, NULL, '2023-04-23', 4, 6),
(140, '22:05:00', '22:55:00', 'Centro clinico de especialidades Chiquimula ', 550, 75, 19.69, 'Junior lopez', 1, 'Torax ap y lat', '2023-04-23', 4, 5),
(141, '18:00:00', '18:38:00', 'XRadii', 300, 50, 19.69, 'Centro Veterinario de Oriente', 1, 'Pierna ap y lat', '2023-04-24', 4, 5),
(143, '14:30:00', '15:30:00', 'Xradii ', 1850, 250, 19.69, 'Aida Samayoa ', 88, 'Tomografía cerebral simple', '2023-04-29', 4, 7),
(144, '20:30:00', '21:30:00', 'XRADII', 0, 250, 19.69, 'Teresa Dubon', 57, 'Tomografía ', '2023-04-29', 4, 7),
(145, '10:00:00', '11:33:00', 'Concepción las minas ', 1200, 228, 39.38, 'Blanca Interiano ', 58, 'Rx de tórax pa/lateral ', '2023-05-01', 4, 7),
(146, '11:33:00', '14:10:00', 'Olopita Esquipulas ', 1300, 228, 59.07, 'Jose Antonio Rosa ', 88, 'Rx de tórax ap/lateral ', '2023-05-01', 4, 7),
(147, '10:00:00', '11:33:00', 'Hospital centro clínico concepción las minas ', NULL, 125, 38.46, 'Blanca interiano', NULL, NULL, '2023-05-01', 4, 6),
(148, '11:33:00', '14:10:00', 'Esquipulas Olopita', NULL, 125, 57.69, 'José Antonio Rosa', NULL, NULL, '2023-05-01', 4, 6),
(149, '15:00:00', '16:00:00', 'Xradii ', 300, 50, 19.69, 'Perrito', 0, 'Rx de abdomen ', '2023-05-01', 4, 7),
(150, '17:30:00', '18:20:00', 'XRADII', 350, 75, 19.69, 'Sara Estrada ', 8, 'Rx húmero ', '2023-05-01', 4, 7),
(151, '18:30:00', '19:25:00', 'Medicall', 550, 75, 19.69, 'Abigail Aldana ', 1, 'Rx torax ap/lat', '2023-05-04', 4, 7),
(152, '18:30:00', '19:25:00', 'Hospital Medicall Chiquimula ', NULL, 50, 19.23, 'Abigail Aldana ', NULL, NULL, '2023-05-04', 4, 6),
(153, '17:00:00', '17:30:00', 'Hospital unidad medica Chiquimula ', NULL, 50, 19.23, 'José Armando Sintuj ', NULL, NULL, '2023-05-05', 4, 6),
(154, '17:30:00', '18:15:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Maria Mendoza ', NULL, NULL, '2023-05-05', 4, 6),
(155, '17:00:00', '17:30:00', 'Unidad Médica ', 550, 75, 19.69, 'José Armando Sintuj ', 40, 'Rx de abdomen Simple', '2023-05-05', 4, 7),
(156, '17:30:00', '18:15:00', 'Siglo 21 ', 550, 75, 19.69, 'María Mendoza ', 53, 'Rx torax ', '2023-05-05', 4, 7),
(157, '19:00:00', '20:00:00', 'XRADII', 1850, 250, 19.69, 'Ashlyn Catalella Linares ', 1, 'Tomografia cerebral ', '2023-05-06', 4, 7),
(158, '12:55:00', '13:51:00', 'Centro medico Chiquimula ', NULL, 50, 19.23, 'Deily Hernández ', NULL, NULL, '2023-05-07', 4, 6),
(159, '13:51:00', '14:33:00', 'Centro clínico Chiquimula ', NULL, 50, 19.23, 'Perfecto Díaz ', NULL, NULL, '2023-05-07', 4, 6),
(160, '10:47:00', '11:47:00', 'XRADII', 550, 75, 19.69, 'ARELY ARBIZU', 1, 'TORAX PA Y LAT', '2023-05-07', 4, 5),
(161, '12:55:00', '13:51:00', 'CENTRO MEDICO DE CHIQUIMULA', 550, 75, 19.69, 'HIJA DE DEILY HERNANDEZ', 1, 'TORAX AP Y LAT', '2023-05-07', 4, 5),
(162, '13:51:00', '14:33:00', 'CENTRO CLINICO DE ESPECIALIDADES CHIQ.', 550, 75, 19.69, 'PERFECTO DIAZ', 81, 'TORAX PA Y LAT', '2023-05-07', 4, 5),
(163, '19:03:00', '19:56:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Maria Ramos ', NULL, NULL, '2023-05-08', 4, 6),
(164, '06:00:00', '06:51:00', 'XRADII', 600, 100, 19.69, 'CENTRO VETERINARIO DE ORIENTE', 2, '1 ABDOMEN\n1 CRANEO', '2023-05-08', 4, 5),
(165, '06:51:00', '07:50:00', 'SIGLO 21', 550, 75, 19.69, 'MARIA RAMOS', 1, 'TORAX AP', '2023-05-08', 4, 5),
(166, '07:50:00', '08:45:00', 'XRADII', 300, 75, 19.69, 'CONSUELO PAREDES', 69, 'ABDOMEN', '2023-05-08', 4, 5),
(167, '17:00:00', '17:32:00', 'XRADII', 300, 75, 19.69, 'RICHARD HERNANDEZ', 6, 'ABDOMEN', '2023-05-09', 4, 5),
(168, '18:03:00', '18:44:00', 'XRADII', 300, 50, 19.69, 'CENTRO VETERINARIO DE ORIENTE', 1, 'ABDOMEN', '2023-05-09', 4, 5),
(169, '14:30:00', '15:30:00', 'Unidad medica Chiquimula ', NULL, 50, 19.23, 'Eliseo Gutiérrez ', NULL, NULL, '2023-05-14', 4, 6),
(170, '14:30:00', '15:30:00', 'Unidad Médica ', 550, 75, 19.69, 'Elíseo Gutiérrez ', 80, 'Rx torax', '2023-05-14', 4, 7),
(171, '18:27:00', '19:14:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Pedro Monroy ', NULL, NULL, '2023-05-15', 4, 6),
(172, '18:27:00', '18:14:00', 'Centro clínico ', 550, 75, 0, 'Pedro Monroy ', 62, 'Rx torax ap/lat', '2023-05-16', 4, 7),
(173, '18:30:00', '19:00:00', 'X-RADII ', 300, 50, 19.69, 'Perrito', 0, 'Tibia AP/lat', '2023-05-16', 4, 7),
(174, '20:00:00', '20:58:00', 'X-RADII ', 1850, 250, 19.69, 'Delfina Gómez ', 74, 'Tomografía ', '2023-05-16', 4, 7),
(175, '18:00:00', '18:30:00', 'X-Radii ', 300, 50, 19.69, 'Perrito ', 0, 'Rx Abdomen ', '2023-05-19', 4, 7),
(176, '11:20:00', '12:10:00', 'CENTRO CLINICO DE ESPECIALIDADES', 550, 75, 19.69, 'CUPERTINA ALONZO', 66, 'ANTEBRAZO AP Y LAT', '2023-05-21', 4, 5),
(177, '11:20:00', '12:10:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Cubertina Alonzo', NULL, NULL, '2023-05-21', 4, 6),
(178, '16:45:00', '17:38:00', 'Hospital centro medico Chiquimula ', NULL, 50, 19.23, 'Maria Ramos Cheguen', NULL, NULL, '2023-05-21', 4, 6),
(179, '16:45:00', '17:38:00', 'CENTRO MEDICO DE CHIQUIMULA', 550, 75, 19.69, 'MARIA ISABEL RAMOS CHEGUEN', 34, 'TORAX AP', '2023-05-21', 4, 5),
(180, '12:00:00', '13:00:00', 'X-Radii ', 0, 20, 19.69, 'Plan de Seguridad de trabajo ', 0, '....', '2023-05-25', 4, 7),
(181, '17:20:00', '17:47:00', 'XRADII', 350, 75, 19.69, 'Alba Mireya', 3, 'Torax ap y lat ', '2023-05-26', 4, 5),
(182, '12:00:00', '12:30:00', 'Hermano Pedro ', 550, 75, 19.69, 'Virginia Felipe ', 74, 'Rx torax ', '2023-05-27', 4, 7),
(183, '12:30:00', '13:15:00', 'X-radii ', 350, 75, 19.69, 'Emma Sandoval ', 11, 'Tórax AP lateral ', '2023-05-27', 4, 7),
(184, '15:19:00', '17:15:00', 'Sábana Grande ', 550, 75, 39.38, 'María Rosa Díaz Calderón ', 84, 'Rx torax pa/lateral', '2023-05-27', 4, 7),
(185, '12:00:00', '12:35:00', 'Casa de salud hermano Pedro ', NULL, 50, 19.23, 'Virginia Felipe ', NULL, NULL, '2023-05-27', 4, 6),
(186, '15:39:00', '17:15:00', 'Sabana grande casa particular.', NULL, 50, 38.46, 'Marta Rosa Diaz', NULL, NULL, '2023-05-27', 4, 6),
(187, '19:30:00', '20:30:00', 'Centro clínico de especialidades ', 550, 75, 19.69, 'Rosa Cardona ', 71, 'Rx torax pa/lateral', '2023-05-29', 4, 7),
(188, '17:00:00', '18:30:00', 'X-RADII ', NULL, 75, 38.46, 'Mantenimiento ', NULL, NULL, '2023-05-30', 4, 6),
(189, '19:30:00', '20:30:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Rosa de María Cardona ', NULL, NULL, '2023-05-31', 4, 6),
(190, '18:50:00', '19:50:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Maria López ', NULL, NULL, '2023-05-31', 4, 6),
(191, '19:30:00', '20:30:00', 'CENTRO CLINICO DE ESPECIALIDADES CHIQ.', 550, 75, 19.69, 'María López', 63, 'Rx torax ', '2023-05-31', 4, 7),
(192, '12:00:00', '13:00:00', 'Medicall', 550, 75, 19.69, 'Victorino linares', 1, 'Torax ap lat', '2023-06-03', 4, 5),
(193, '17:30:00', '18:00:00', 'Xradii ', 300, 50, 19.69, 'Gato', 0, 'Rx Abdomen ', '2023-06-04', 4, 7),
(194, '12:00:00', '13:00:00', 'Hospital Medicall Chiquimula ', NULL, 50, 19.23, 'Victorino Linares Sagastume ', NULL, NULL, '2023-06-06', 4, 6),
(195, '19:50:00', '21:05:00', 'Centro clinico de especialidades', 950, 150, 39.38, 'Randy helgemos', 67, 'Torax ap, lateral. Y. Abdomen', '2023-06-06', 4, 5),
(197, '19:50:00', '21:05:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 38.46, 'Randy Helgemoe', NULL, NULL, '2023-06-07', 4, 6),
(198, '22:24:00', '23:24:00', 'Centro Clinico de especialidades', 550, 75, 19.69, 'Margarita Alarcon', 1, 'Torax pa y lat', '2023-06-07', 4, 5),
(199, '22:24:00', '23:24:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Margarita Alarcón ', NULL, NULL, '2023-06-07', 4, 6),
(200, '21:10:00', '22:00:00', 'X-RADII ', 1850, 250, 19.69, 'Jairo Castillo ', 25, 'Emergencia TAC Cerebral Simple ', '2023-06-17', 4, 7),
(201, '16:25:00', '17:25:00', 'Siglo 21', 550, 75, 19.69, 'Melhar singh', 1, 'Torax ap', '2023-06-19', 4, 5),
(202, '18:35:00', '18:57:00', 'Xradii', 300, 50, 19.69, 'Centeo veterinario de oriente', 1, 'Perrito', '2023-06-19', 4, 5),
(203, '03:00:00', '08:00:00', 'Viaje a la capital a traer Soni gel a dejar papel al ministerio de trabajo también a dacotrans y a c', NULL, 125, 96.15, 'Vieja a la capital a traer mercadería y mandados a instituciones ', NULL, NULL, '2023-06-20', 4, 6),
(204, '16:25:00', '17:25:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Mehar Sing', NULL, NULL, '2023-06-21', 4, 6),
(205, '17:00:00', '17:45:00', 'Diligencia con el ingeniero ', NULL, 20, 19.23, 'Ingeniero ', NULL, NULL, '2023-06-21', 4, 6),
(206, '07:05:00', '08:05:00', 'X-RADII ', NULL, 20, 19.23, 'Cubriendo a Meli ', NULL, NULL, '2023-06-21', 4, 6),
(207, '07:00:00', '08:00:00', 'X-RADII ', NULL, 20, 19.23, 'Cubriendo a Meli ', NULL, NULL, '2023-06-21', 4, 6),
(208, '17:05:00', '17:21:00', 'XRadii', 500, 20, 19.69, 'Angie Chinchilla', 12, 'Mano ( edad osea )\nSenos paranasales', '2023-06-23', 4, 5),
(209, '18:40:00', '19:10:00', 'XRADII', 350, 75, 19.69, 'Matias Cruz', 1, 'Torax AP y Lat', '2023-06-23', 4, 5),
(210, '07:00:00', '08:00:00', 'X-RADII ', NULL, 20, 19.23, 'Cubriendo a Meli', NULL, NULL, '2023-06-24', 4, 6),
(211, '13:30:00', '15:00:00', 'X-RADII ', 1850, 250, 39.38, 'Brayan Ramos ', 16, 'Tomografía Cerebral', '2023-06-24', 4, 7),
(212, '16:25:00', '17:35:00', 'Centro clínico Chiquimula ', NULL, 50, 38.46, 'Baltazar Lemus ', NULL, NULL, '2023-06-24', 4, 6),
(213, '16:25:00', '17:35:00', 'Centro clínico especialidades', 550, 75, 39.38, 'Baltazar ', 31, 'Rx de abdomen ', '2023-06-24', 4, 7),
(215, '22:00:00', '23:00:00', 'X-Radii Memorial ', 0, 75, 19.69, 'Jairo Castillo ', 25, 'Rx torax ap/lat', '2023-06-26', 4, 7),
(216, '18:54:00', '19:25:00', 'X-RADII ', 350, 75, 19.69, 'Gildarto Flores ', 66, 'Rx torax ', '2023-06-26', 4, 7),
(217, '17:00:00', '18:00:00', 'X-radii', 300, 50, 19.69, 'Perrito', 0, 'Rx Abdomen simple', '2023-06-29', 4, 7),
(218, '21:13:00', '22:00:00', 'Siglo 21', 550, 75, 19.69, 'Delmy Marilu Ramirez', 45, 'Torax ap ', '2023-07-01', 4, 5),
(219, '10:35:00', '11:27:00', 'XRADII', 1850, 250, 19.69, 'Berta Díaz de españa', 72, 'TAC CEREBRAL SIMPLE ', '2023-07-02', 4, 7),
(220, '18:19:00', '18:56:00', 'Siglo 21', 550, 75, 19.69, 'Marlin marilu Ramirez', 45, 'Torax ap ', '2023-07-02', 4, 5),
(221, '18:15:00', '19:15:00', '3 calle Casa particular', 550, 75, 19.69, 'Maria Ernestina Barahona', 90, 'Torax ap y lat', '2023-07-04', 4, 5),
(222, '19:55:00', '21:15:00', 'Centro medico chiquimula', 1200, 200, 39.38, 'José Guillermo Salguero ', 19, 'Mano ', '2023-07-04', 4, 5),
(223, '17:15:00', '18:15:00', 'Xradi ', 540, 75, 19.69, 'Miriam Erazo ', 61, 'TAC cerebral / COVID', '2023-07-06', 4, 7),
(225, '12:00:00', '16:00:00', 'X-RADII ', NULL, 150, 76.92, 'Instalación de internet ', NULL, NULL, '2023-07-07', 4, 6),
(226, '21:13:00', '22:00:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Marilú Ramírez ', NULL, NULL, '2023-07-07', 4, 6),
(227, '18:00:00', '18:56:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Marilú Ramírez ', NULL, NULL, '2023-07-07', 4, 6),
(228, '04:00:00', '08:00:00', 'Viaje a la Capital ', NULL, 125, 76.92, 'Viaje a la Capital con el Inge ', NULL, NULL, '2023-07-07', 4, 6),
(229, '18:15:00', '19:20:00', 'Casa particular ', NULL, 50, 38.46, 'Maria Barahona ', NULL, NULL, '2023-07-07', 4, 6),
(230, '19:55:00', '21:15:00', 'Hospital centro medico Chiquimula ', NULL, 89, 38.46, 'José Guillermo Salguero ', NULL, NULL, '2023-07-07', 4, 6),
(231, '17:17:00', '17:37:00', 'XRADII', 450, 75, 19.69, 'Armando Monroy', 63, 'Columna dorso lumbar ap y lt', '2023-07-07', 4, 5),
(232, '14:00:00', '15:00:00', 'Col. San Francisco casa particular.', NULL, 50, 19.23, 'Maria Leal de Duarte ', NULL, NULL, '2023-07-08', 4, 6),
(233, '13:00:00', '13:30:00', 'XRADII', 700, 150, 19.69, 'Emma Calderon Ramos', 5, 'Rx torax y senos paranasales ', '2023-07-08', 4, 7),
(234, '13:30:00', '14:00:00', 'XRADII', 700, 150, 19.69, 'Jean Carlos  Najarro ', 9, 'Rx torax ap y SPN', '2023-07-08', 4, 7),
(235, '14:00:00', '14:30:00', 'Portatil ', 550, 75, 19.69, 'María Leal de Duarte ', 96, 'Pelvis ', '2023-07-08', 4, 7),
(236, '06:14:00', '07:10:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Maria Evangelina Ruballos ', NULL, NULL, '2023-07-09', 4, 6),
(237, '18:14:00', '19:10:00', 'Siglo 21', 550, 75, 19.69, 'María Evangelina Ruballos', 63, 'Rx torax ap ', '2023-07-09', 4, 7),
(238, '17:00:00', '17:35:00', '13 calle ', 550, 75, 19.69, 'María Ernestina Salinas ', 90, 'Rx torax ap/lateral', '2023-07-10', 4, 7),
(239, '17:35:00', '18:10:00', 'Unidad medica ', 550, 75, 19.69, 'Olivia Guerra ', 83, 'Rx torax ap/lateral ', '2023-07-10', 4, 7),
(240, '18:10:00', '18:30:00', 'XRADII', 300, 50, 19.69, 'Perrito ', 0, 'Mano ', '2023-07-10', 4, 7),
(241, '17:00:00', '17:35:00', 'Casa particular ', NULL, 50, 19.23, 'Maria Esther Barahona ', NULL, NULL, '2023-07-10', 4, 6),
(242, '17:35:00', '18:30:00', 'Hospital unidad medica ', NULL, 50, 19.23, 'Olivia Guerra ', NULL, NULL, '2023-07-10', 4, 6),
(243, '17:30:00', '18:30:00', 'Veterinaria ', NULL, 50, 19.23, 'Un perrito ', NULL, NULL, '2023-07-11', 4, 6),
(244, '21:50:00', '22:40:00', 'Centro clínico Chiquimula ', NULL, 50, 19.23, 'Saida Ramírez / SANDRA RAMIREZ', NULL, NULL, '2023-07-11', 4, 6),
(245, '17:30:00', '18:30:00', 'Centro veterinario ', 550, 75, 19.69, 'Perrito', 0, 'Estudio portatil Rx abdomen ', '2023-07-11', 4, 7),
(246, '21:50:00', '22:40:00', 'Centro clínico ', 550, 75, 19.69, 'Saida Ramos / SANDRA RAMIREZ', 28, 'Rx de tórax ap ', '2023-07-11', 4, 7),
(248, '20:16:00', '21:14:00', 'Siglo 21', 550, 75, 19.69, 'Lucia vasquez', 77, 'Torax ap', '2023-07-16', 4, 5),
(249, '20:16:00', '21:14:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Lucia Vásquez ', NULL, NULL, '2023-07-17', 4, 6),
(250, '17:00:00', '17:30:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Marilú Ramírez ', NULL, NULL, '2023-07-17', 4, 6),
(251, '17:00:00', '17:30:00', 'Siglo 21', 550, 75, 19.69, 'Marlin Marilu Ramirez', 47, 'Torax ap', '2023-07-17', 4, 5),
(252, '13:52:00', '14:16:00', 'XRADII', 350, 75, 19.69, 'Walter Cisneros', 6, 'Torax ap lat', '2023-07-18', 4, 5),
(253, '18:00:00', '19:00:00', 'Centro Medico', 1200, 200, 19.69, 'Raul Erazo', 27, 'Cirugia hombro ', '2023-07-20', 4, 5),
(254, '21:15:00', '22:10:00', 'Siglo 21', 550, 75, 19.69, 'Marilu Ramirez', 45, 'Torax ap', '2023-07-20', 4, 5),
(255, '18:00:00', '19:00:00', 'Hospital centro medico Chiquimula ', NULL, 89, 19.23, 'Raúl Erazo ', NULL, NULL, '2023-07-20', 4, 6),
(256, '21:15:00', '22:10:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Marilú Ramírez ', NULL, NULL, '2023-07-20', 4, 6),
(257, '18:52:00', '19:50:00', 'Centro clinico de especialidades ', 550, 75, 19.69, 'Sara oliva', 1, 'Torax ap lat', '2023-07-21', 4, 5),
(258, '18:52:00', '19:50:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Sara Oliva ', NULL, NULL, '2023-07-21', 4, 6),
(259, '17:00:00', '17:30:00', 'Centro clinico', 550, 75, 19.69, 'María Roque ', 48, 'Rx torax ap/lat', '2023-07-24', 4, 7),
(260, '17:00:00', '17:30:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Maria Roque', NULL, NULL, '2023-07-24', 4, 6),
(261, '19:30:00', '20:00:00', 'Centro clínico ', 550, 75, 19.69, 'Edwin Edilso Javier', 20, 'Rx torax pa/lat', '2023-07-24', 4, 7),
(262, '19:30:00', '20:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Elwin Edilso Javier ', NULL, NULL, '2023-07-24', 4, 6),
(263, '17:15:00', '17:40:00', 'XRADII', 350, 75, 19.69, 'Cristian cáceres ', 32, 'Rx tobillo ', '2023-07-27', 4, 7),
(265, '20:08:00', '21:55:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 38.46, 'Marilu Ramírez ', NULL, NULL, '2023-07-27', 4, 6),
(266, '20:08:00', '21:55:00', 'Siglo 21 ', 900, 150, 39.38, 'Marilu Ramirez ', 46, '2 Rx de Tórax para ver la colocación de un primer y segundo  TIC # 466', '2023-07-27', 4, 7),
(267, '17:00:00', '17:30:00', 'X-RADII ', 350, 75, 19.69, 'Rutilia Monroy ', 74, 'Rx pelvis y cadera axial ', '2023-07-28', 4, 7),
(268, '18:25:00', '19:23:00', 'Siglo 21', 550, 75, 19.69, 'Marilu Ramirez', 45, 'Torax ap #470', '2023-07-30', 4, 5),
(269, '18:28:00', '19:25:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Marilu Ramírez ', NULL, NULL, '2023-07-30', 4, 6),
(270, '21:10:00', '22:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 19.23, 'Marilu Ramírez ', NULL, NULL, '2023-07-31', 4, 6),
(271, '21:10:00', '22:10:00', 'Siglo 21', 550, 75, 19.69, 'Marilu Ramirez', 45, 'Torax ap # 472', '2023-07-31', 4, 5),
(272, '20:15:00', '21:30:00', 'Memorial', 550, 75, 39.38, 'Anderson lopez', 10, 'Antebrazo ap ylat', '2023-08-01', 4, 5),
(273, '21:30:00', '22:50:00', 'Memorial', 550, 75, 39.38, 'Anderson lopez', 10, 'Humero', '2023-08-01', 4, 5),
(274, '20:15:00', '21:30:00', 'Hospital memorial Chiquimula ', NULL, 50, 38.46, 'Anderson López ', NULL, NULL, '2023-08-01', 4, 6),
(275, '21:30:00', '22:50:00', 'Hospital memorial Chiquimula ', NULL, 50, 38.46, 'Anderson López ', NULL, NULL, '2023-08-01', 4, 6),
(276, '17:00:00', '17:45:00', 'Centro Medico Chiquimula ', NULL, 50, 19.23, 'Humberto Alarcón ', NULL, NULL, '2023-08-04', 4, 6),
(277, '17:00:00', '17:45:00', 'Centro Medico', 550, 75, 19.69, 'Humberto Alarcon', 1, 'Torax ap # 477', '2023-08-04', 4, 5),
(278, '14:20:00', '15:00:00', 'Clínica X-radii ', 350, 75, 19.69, 'Andrea ileascas', 27, 'Rx de tórax pa /lateral ', '2023-08-06', 4, 7),
(280, '15:00:00', '17:00:00', 'Hospital memorial Chiquimula ', NULL, 50, 38.46, 'Santos López González ', NULL, NULL, '2023-08-07', 4, 6),
(281, '15:00:00', '17:00:00', 'Memorial ', 350, 75, 39.38, 'Santos López Gonzáles ', 0, 'Tórax pa /lateral ', '2023-08-07', 4, 7),
(282, '17:00:00', '17:30:00', 'Centro clínico ', 550, 75, 19.69, 'Jorge Miliam ', 41, 'Rx torax ap /lat', '2023-08-07', 4, 7),
(283, '17:30:00', '18:00:00', 'Siglo 21 ', 550, 75, 19.69, 'María Lemus ', 0, 'Rx torax ap/lat # 479', '2023-08-07', 4, 7),
(284, '17:00:00', '17:30:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Jorge Milian', NULL, NULL, '2023-08-07', 4, 6),
(285, '17:30:00', '18:00:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Maria Lemus ', NULL, NULL, '2023-08-07', 4, 6),
(286, '18:00:00', '18:30:00', 'Xradi ', 300, 50, 19.69, 'Perrito ', 0, 'Abdomen ', '2023-08-07', 4, 7),
(287, '18:20:00', '20:20:00', 'Hospital centro medico Chiquimula ', NULL, 89, 38.46, 'Florinda Carranza', NULL, NULL, '2023-08-08', 4, 6),
(288, '20:45:00', '21:23:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Kimberly Franco', NULL, NULL, '2023-08-08', 4, 6),
(289, '18:20:00', '20:20:00', 'Centro médico Cirugía ', 1200, 200, 39.38, 'Florencia Carranza ', 64, 'Rx de húmero # 480', '2023-08-08', 4, 7),
(290, '20:45:00', '21:23:00', 'Centro Clínico ', 550, 75, 19.69, 'Kimberly Franco ', 7, 'Tórax AP/lateral # 481', '2023-08-08', 4, 7),
(291, '20:00:00', '22:00:00', 'X-Radii ', 2550, 400, 39.38, 'Geovany Hernández ', 19, 'TAC cerebral\nRx pierna izquierda\nRx torax ap  # 401', '2023-08-10', 4, 7),
(292, '17:00:00', '18:00:00', 'Centro veterinario ', 550, 75, 19.69, 'Perrito ', 0, 'Patita frontal ', '2023-08-11', 4, 7),
(293, '17:00:00', '18:00:00', 'X-RADII ', NULL, 35, 19.23, 'Ingeniero Elder ', NULL, NULL, '2023-08-12', 4, 6),
(294, '17:00:00', '18:00:00', 'Veterinaria Molino', NULL, 50, 19.23, 'Perrito', NULL, NULL, '2023-08-12', 4, 6),
(295, '12:00:00', '12:30:00', 'Xradii', 350, 75, 19.69, 'Juana Camacho', 39, 'Tobillo ap y lat', '2023-08-12', 4, 5),
(297, '18:00:00', '18:30:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Irene abzun', NULL, NULL, '2023-08-13', 4, 6),
(298, '18:30:00', '19:00:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Reyna Guerra ', NULL, NULL, '2023-08-13', 4, 6),
(299, '17:00:00', '17:30:00', 'Siglo 21', 550, 75, 19.69, 'Reyna Guerra', 60, 'Torax ap # 486', '2023-08-14', 4, 5),
(300, '17:00:00', '17:30:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Reyna Guerra ', NULL, NULL, '2023-08-15', 4, 6),
(302, '08:30:00', '11:15:00', 'Siglo 21', 1450, 200, 59.07, 'Alexander Peraza', 54, 'Cirugia muñeca izq. # 487', '2023-08-15', 4, 5),
(303, '08:30:00', '11:15:00', 'Hospital siglo 21 Chiquimula ', NULL, 89, 57.69, 'Alexander Peraza ', NULL, NULL, '2023-08-15', 4, 6),
(304, '17:00:00', '18:00:00', 'Centro Medico', 550, 75, 19.69, 'Virgilio Lopez', 60, 'Torax ap # 488', '2023-08-18', 4, 5),
(305, '17:00:00', '18:00:00', 'Hospital centro medico Chiquimula ', NULL, 50, 19.23, 'Virgilio López ', NULL, NULL, '2023-08-19', 4, 6),
(306, '15:30:00', '16:50:00', 'Hospital Memorial ', NULL, 50, 38.46, 'Juan Guerra ', NULL, NULL, '2023-08-19', 4, 6),
(307, '15:30:00', '16:50:00', 'Memorial ', 350, 75, 39.38, 'Juan Miguel Guerra ', 14, 'Rx de hombro ', '2023-08-19', 4, 7),
(308, '08:40:00', '09:40:00', 'Memorial ', 350, 75, 19.69, 'Juan Miguel Guerra ', 14, 'Rx hombro AP/axial ', '2023-08-20', 4, 7),
(309, '08:40:00', '09:40:00', 'Hospital Memorial ', NULL, 50, 19.23, 'Juan Miguel Guerra ', NULL, NULL, '2023-08-20', 4, 6),
(310, '20:15:00', '20:35:00', 'Xradi ', 350, 75, 19.69, 'William René Romero ', 10, 'Rx torax pa/lat', '2023-08-20', 4, 7),
(311, '17:00:00', '18:00:00', 'Xradii ', 700, 150, 19.69, 'Santiago Valdez ', 10, 'Rx de Tórax AP/lat \nRx de mano derecha ', '2023-08-21', 4, 7),
(312, '20:40:00', '21:30:00', 'Hospital siglo 21 ', NULL, 50, 19.23, 'Petronila Marroquín ', NULL, NULL, '2023-08-22', 4, 6),
(313, '20:45:00', '21:30:00', 'Siglo 21', 550, 75, 19.69, 'Petronila Marroquín ', 76, 'Rx torax # 490', '2023-08-22', 4, 7),
(315, '17:30:00', '18:00:00', 'Siglo 21', 550, 75, 19.69, 'Irene Abzun', 55, 'Torax ap # 484', '2023-08-24', 4, 5),
(316, '17:00:00', '17:30:00', 'Siglo 21', 550, 75, 19.69, 'Reyna Guerra', 60, 'Torax ap # 483', '2023-08-24', 4, 5),
(317, '17:00:00', '18:00:00', 'X-RADII ', NULL, 35, 19.23, 'Inge Elder ', NULL, NULL, '2023-08-25', 4, 6),
(318, '05:00:00', '08:00:00', 'X-TECH ', NULL, 125, 57.69, 'Ingeniero Elder ', NULL, NULL, '2023-08-25', 4, 6),
(319, '13:30:00', '14:30:00', 'Siglo 21', 550, 75, 19.69, 'Mariq Mendez', 56, 'Torax ap', '2023-08-26', 4, 5),
(320, '13:30:00', '14:30:00', 'Hospital siglo 21 ', NULL, 50, 19.23, 'Maria Méndez ', NULL, NULL, '2023-08-26', 4, 6),
(321, '17:30:00', '23:50:00', 'Centro Medico Esquipulas', 2350, 200, 137.83, 'Oseas de Jesus gregorio', 50, 'Cirugia de columna', '2023-08-27', 3, 5),
(322, '17:20:00', '18:00:00', 'Centro clinico de especialidades', 550, 75, 19.69, 'Samuel Rivera', 3, 'Torax ap y lat', '2023-08-27', 4, 5),
(323, '18:00:00', '18:40:00', 'Centro clinico de especialidades ', 550, 75, 19.69, 'Mery alvarez', 68, 'Torax ap y lat # 496', '2023-08-27', 4, 5),
(324, '17:30:00', '23:50:00', 'Hospital centro medico Esquipulas ', NULL, 296, 134.61, 'Oseas de Jesús Gregorio ', NULL, NULL, '2023-08-27', 4, 6),
(325, '17:20:00', '18:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Samuel Rivera ', NULL, NULL, '2023-08-27', 4, 6),
(326, '18:00:00', '18:40:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Mery Álvarez ', NULL, NULL, '2023-08-27', 4, 6),
(327, '19:30:00', '20:00:00', 'Siglo 21', 900, 150, 19.69, 'Rosa elena calderon', 69, 'Torax ap. \nTobillo derecho # 498', '2023-08-29', 4, 5),
(328, '20:15:00', '21:00:00', 'Siglo 21', 550, 75, 19.69, 'Hijo de neidy sagastume', 1, 'Torax ap y lat # 499', '2023-08-29', 4, 5),
(329, '19:30:00', '20:15:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Rosa Elena calderon ', NULL, NULL, '2023-08-30', 4, 6),
(330, '20:15:00', '21:00:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Hijo de Neli Sagastume ', NULL, NULL, '2023-08-30', 4, 6),
(332, '17:00:00', '17:40:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Lixie Fortín ', NULL, NULL, '2023-08-30', 4, 6),
(333, '17:00:00', '17:30:00', 'Centro clinico de especialidades', 550, 75, 19.69, 'Lixie fortin', 18, 'Torax ap y lat', '2023-08-30', 4, 5),
(334, '21:05:00', '21:35:00', 'XRadii', 650, 150, 19.69, 'Arturo Mauricio Garcia', 50, 'Torax pa y lat.  \n\nAbdomen', '2023-08-30', 4, 5),
(335, '16:50:00', '17:30:00', 'Casa particular ', NULL, 50, 19.23, 'Ruth Noemí González Pineda ', NULL, NULL, '2023-09-07', 4, 6),
(336, '17:40:00', '17:30:00', 'A Domicilio ', 550, 75, 0, 'Ruth Noemí ', 41, 'Rx de tobillo ', '2023-09-07', 4, 7),
(337, '06:59:00', '23:59:00', 'Jornada médica doc. Selvin ciudad Capital.', NULL, 450, 326.91, 'Jornada médica doc. Selvin Fuentes ', NULL, NULL, '2023-09-09', 4, 6),
(338, '06:59:00', '23:59:00', 'Jornada RX El Naranjo ', 7350, 1200, 334.73, '49 pacientes', 49, 'Rayos x de torax PA', '2023-09-09', 4, 5),
(339, '12:25:00', '13:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Amanda Ventura ', NULL, NULL, '2023-09-10', 4, 6),
(340, '13:00:00', '13:30:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Mateo Gael Giron', NULL, NULL, '2023-09-10', 4, 6),
(341, '18:50:00', '19:40:00', 'Siglo 21', 550, 75, 19.69, 'Rosa calderon', 68, 'Torax ap', '2023-09-10', 4, 5),
(342, '12:25:00', '13:00:00', 'Centro clinico de especialidades ', 550, 75, 19.69, 'Amada Ventura', 72, 'Torax ap y lat', '2023-09-10', 4, 5),
(343, '13:00:00', '13:30:00', 'Centro clinico', 550, 75, 19.69, 'Mateo giron', 15, 'Abdomen', '2023-09-10', 4, 5),
(344, '18:50:00', '19:40:00', 'Hospital siglo 21 ', NULL, 50, 19.23, 'Rosa Calderón ', NULL, NULL, '2023-09-10', 4, 6),
(345, '17:00:00', '18:40:00', 'Casa particular en col. Bamvi', NULL, 50, 38.46, 'Maura Medrano Olivares ', NULL, NULL, '2023-09-13', 4, 6),
(346, '17:00:00', '18:40:00', 'Casa particular', 550, 75, 39.38, 'Maura medrano olivares', 83, 'Torax ap y lat', '2023-09-14', 4, 5),
(348, '17:30:00', '18:20:00', 'XRadii', 300, 50, 19.69, 'Perrito', 1, 'Abdomen', '2023-09-14', 4, 5),
(349, '09:20:00', '11:00:00', 'centro medico', 1200, 200, 39.38, 'Miriam Yolanda Contreras', 56, 'muñeca', '2023-09-15', 4, 5),
(350, '11:00:00', '12:00:00', 'centro veterinario de oriente', 1100, 100, 19.69, 'Dr Alvaro Monroy', 2, '1 abdomen\n1 brazo', '2023-09-15', 4, 5),
(351, '12:00:00', '13:00:00', 'Centro Clinico de Especialidades', 550, 75, 19.69, 'Eithan Diaz', 1, 'torax ap y lat', '2023-09-15', 4, 5),
(352, '15:42:00', '16:50:00', 'Memorial', 550, 75, 39.38, 'Ana Sofia Diaz', 1, 'codo izq. ap y lat', '2023-09-15', 4, 5),
(353, '03:00:00', '08:00:00', 'Viaje a la capital ', NULL, 125, 96.15, 'Tubo para la tomografía ', NULL, NULL, '2023-09-16', 4, 6),
(354, '09:20:00', '11:00:00', 'Hospital centro medico Chiquimula ', NULL, 89, 38.46, 'Miriam Yolanda Contreras ', NULL, NULL, '2023-09-16', 4, 6),
(355, '11:00:00', '12:00:00', 'Veterinaria Molino ', NULL, 100, 19.23, '2 perritos ', NULL, NULL, '2023-09-16', 4, 6),
(356, '12:00:00', '13:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Eithan René Díaz ', NULL, NULL, '2023-09-16', 4, 6),
(357, '15:42:00', '16:50:00', 'Hospital Memorial Chiquimula ', NULL, 50, 38.46, 'Sofía Díaz Castellon ', NULL, NULL, '2023-09-16', 4, 6),
(358, '12:00:00', '13:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Albertina Jacinto', NULL, NULL, '2023-09-16', 4, 6),
(360, '12:00:00', '13:00:00', 'Centro Clínico ', 550, 75, 19.69, 'Albertina Jacinto', 82, 'Rx torax ', '2023-09-17', 4, 7),
(361, '12:00:00', '12:50:00', 'Centró Clínico ', 550, 75, 19.69, 'Adelmo Arita ', 95, 'Rx torax pa/lat', '2023-09-17', 4, 7),
(362, '12:00:00', '12:50:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Adelmo Arita ', NULL, NULL, '2023-09-17', 4, 6),
(363, '15:00:00', '18:00:00', 'X-RADII ', NULL, 105, 57.69, 'Arreglando rayos con el Inge ', NULL, NULL, '2023-09-17', 4, 6),
(364, '23:00:00', '23:45:00', 'Hospital siglo 21 Chiquimula ', NULL, 50, 19.23, 'Alison Rocío Asencio ', NULL, NULL, '2023-09-18', 4, 6),
(365, '23:00:00', '23:40:00', 'Siglos 21', 550, 75, 19.69, 'Alisson Asencio ', 1, 'Rx torax ', '2023-09-19', 4, 7),
(366, '20:00:00', '21:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Cristofer Recinos', NULL, NULL, '2023-09-22', 4, 6),
(367, '17:00:00', '18:30:00', 'X-RADII ', NULL, 52.5, 38.46, 'Instalación de cable ', NULL, NULL, '2023-09-22', 4, 6),
(368, '20:00:00', '21:00:00', 'Centro Clínico ', 550, 75, 19.69, 'Cristofer Recinos ', 11, 'Rx torax ', '2023-09-23', 4, 7),
(369, '14:10:00', '15:15:00', 'Xradii', 550, 75, 39.38, 'Ester Rivera', 68, 'Torax pa y lat', '2023-09-24', 4, 5),
(370, '17:00:00', '18:00:00', 'XRadii', 300, 50, 19.69, 'Centro veterinario de oriente', 1, 'Abdomen de 1 perrito', '2023-09-27', 4, 5),
(371, '07:15:00', '08:00:00', 'Hospital Memorial ', NULL, 50, 19.23, 'Walter Maldonado Bran', NULL, NULL, '2023-10-01', 3, 6),
(372, '19:00:00', '22:20:00', 'Hospital centro medico Chiquimula ', NULL, 89, 76.92, 'Bruno Ramírez ', NULL, NULL, '2023-10-01', 3, 6),
(373, '07:00:00', '10:20:00', 'Centró Médico ', 1200, 200, 78.76, 'Bruno Ramírez ', 72, 'Rx de cadera derecha ', '2023-10-02', 3, 7),
(374, '21:00:00', '22:00:00', 'Centro médico ', 550, 75, 19.69, 'Adelina Martinez ', 84, 'Tórax AP/lat\n', '2023-10-02', 3, 7),
(376, '21:00:00', '22:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Adelina Martínez ', NULL, NULL, '2023-10-03', 3, 6),
(377, '17:00:00', '18:00:00', 'Veterinaria molino ', 1100, 150, 19.69, '2 perritos ', 0, 'Rx se realizaron 2 perritos ', '2023-10-04', 3, 7),
(378, '17:00:00', '18:00:00', 'Veterinaria el Molino ', NULL, 100, 19.23, '2 px en veterinaria del doctor Álvaro ', NULL, NULL, '2023-10-04', 3, 6),
(380, '07:00:00', '08:00:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Silvia Méndez ', NULL, NULL, '2023-10-05', 3, 6),
(381, '07:00:00', '08:00:00', 'Centro clínico ', 550, 75, 19.69, 'Silvia Mendez ', 84, 'Rx torax ap/lat ', '2023-10-05', 3, 7),
(382, '12:00:00', '15:45:00', 'X-RADII ', NULL, 132, 76.92, 'Arreglando la tomografía ', NULL, NULL, '2023-10-07', 3, 6),
(383, '15:30:00', '18:40:00', 'X-RADII área tomografia', NULL, 105, 76.92, 'Mantenimiento en la tomografía ', NULL, NULL, '2023-10-15', 3, 6),
(384, '06:00:00', '07:00:00', 'Centro clínico de Chiquimula ', 550, 75, 19.69, 'María Catalina López ', 79, 'Rx de tórax pa/lateral ', '2023-10-17', 3, 7),
(385, '19:00:00', '20:00:00', 'Hospital Memorial Chiquimula ', NULL, 50, 19.23, 'Saori Ana Sofía Mena Escobar ', NULL, NULL, '2023-10-20', 3, 6),
(386, '19:00:00', '20:00:00', 'Memorial ', 0, 75, 19.69, 'Saori Ana Sofía ', 5, 'Rx de rodilla derecha ', '2023-10-20', 4, 7),
(387, '07:15:00', '08:00:00', 'MEMORIAL', 550, 75, 19.69, 'WALTER MALDONADO', 1, 'ABDOMEN', '2023-10-21', 3, 5),
(388, '13:45:00', '14:50:00', 'CENTRO VETRERINARIO DE ORIENTE', 550, 50, 39.38, 'PERRITO', 1, 'MANO', '2023-10-21', 3, 5),
(389, '15:20:00', '16:15:00', 'MEMORIAL', 550, 75, 19.69, 'SUGEYDI VALDEZ', 12, 'CODO DERECHO AP Y LAT', '2023-10-21', 3, 5),
(390, '12:00:00', '13:40:00', 'X-RADII ', NULL, 40, 38.46, 'Fumigaciones en X-RADII ', NULL, NULL, '2023-10-22', 3, 6),
(391, '13:45:00', '14:50:00', 'Centro veterinario de oriente ', NULL, 50, 38.46, 'Perrito', NULL, NULL, '2023-10-22', 3, 6),
(392, '13:15:00', '14:30:00', 'Hospital Memorial ', NULL, 50, 38.46, 'Douglas Kevin Ramírez ', NULL, NULL, '2023-10-22', 3, 6),
(393, '01:15:00', '02:30:00', 'memoprial', 550, 75, 39.38, 'douglas kevin ramirez', 10, 'pierna derecha', '2023-10-22', 3, 5),
(394, '15:00:00', '23:00:00', 'X-RADII ', NULL, 244.8, 153.84, 'Tomografía ', NULL, NULL, '2023-10-24', 4, 6),
(397, '17:00:00', '23:59:00', 'X-RADII ', NULL, 214.2, 134.61, 'Tomografía ', NULL, NULL, '2023-10-24', 4, 6),
(398, '17:00:00', '23:59:00', 'X-RADII ', NULL, 214.2, 134.61, 'Tomografía ', NULL, NULL, '2023-10-24', 4, 6),
(399, '17:00:00', '20:30:00', 'X-RADII ', NULL, 107.1, 76.92, 'Tomografía ', NULL, NULL, '2023-10-24', 4, 6),
(400, '17:35:00', '18:33:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Emma Alarcón ', NULL, NULL, '2023-10-26', 4, 6),
(401, '17:30:00', '18:30:00', 'Centro clinico de especialidades', 550, 75, 19.69, 'Emma Alarcon', 80, 'Torax ap y lat', '2023-10-26', 4, 5),
(403, '12:00:00', '13:00:00', 'Centro veterinario de oriente ', NULL, 50, 19.23, 'Un Perrito ????', NULL, NULL, '2023-10-28', 4, 6),
(404, '13:00:00', '14:00:00', 'Hospital centro medico Chiquimula ', NULL, 50, 19.23, 'Luisa Linares ', NULL, NULL, '2023-10-28', 4, 6),
(405, '19:00:00', '19:40:00', 'Hospital centro clínico Chiquimula ', NULL, 50, 19.23, 'Charly Manuel Yaz', NULL, NULL, '2023-10-28', 4, 6),
(407, '13:00:00', '14:00:00', 'Centro médico ', 550, 75, 19.69, 'Luisa Linares ', 81, 'Rx de tórax AP ', '2023-10-29', 4, 7),
(408, '19:00:00', '20:00:00', 'Centro Clínico ', 550, 75, 19.69, 'Charly Manuel Yas ', 27, 'Rx de Abdomen Simple ', '2023-10-29', 4, 7),
(409, '12:00:00', '13:00:00', 'Veterinaria el molino ', 550, 75, 19.69, 'Perrita ', 8, 'Rx de Abdomen ', '2023-10-29', 4, 7),
(410, '17:00:00', '17:30:00', 'Clínica Xradi ', 350, 75, 19.69, 'Alex Agustín Martínez ', 34, 'Rx de Rodilla AP/lateral ', '2023-10-29', 4, 7),
(411, '11:40:00', '12:30:00', 'SIGLO 21', 550, 75, 19.69, 'ELENA LEMUS', 80, 'TORAX AP', '2023-11-04', 4, 5),
(412, '12:30:00', '13:05:00', 'UNIDAD MEDICA', 550, 75, 19.69, 'JUAN CARLOS ORELLANA', 29, 'TORAX AP Y LAT', '2023-11-04', 4, 5),
(413, '13:05:00', '13:30:00', 'XRADII', 350, 75, 19.69, 'DAYLIN MEJIA', 8, 'TORAX AP Y LAT', '2023-11-04', 4, 5),
(414, '16:45:00', '17:30:00', 'Hospital Memorial Chiquimula', NULL, 50, 19.23, 'Pablo Fernando Tejada Asencio', NULL, NULL, '2023-11-06', 4, 6),
(415, '11:40:00', '12:30:00', 'Hospital Siglo 21 Chiquimula', NULL, 50, 19.23, 'Elena Lemus ', NULL, NULL, '2023-11-06', 4, 6),
(416, '12:30:00', '13:05:00', 'Hospital Unidad Medica ', NULL, 50, 19.23, 'Juan Carlos Orellana Flores', NULL, NULL, '2023-11-06', 4, 6),
(417, '18:30:00', '20:00:00', 'Siglo 21', 550, 75, 39.38, 'Gilma villela', 61, 'Torax ap', '2023-11-06', 4, 5),
(418, '18:30:00', '20:00:00', 'Hospital Siglo 21', NULL, 50, 38.46, 'Gilma Villela', NULL, NULL, '2023-11-06', 4, 6),
(419, '17:00:00', '18:30:00', 'Hospitale Centro Medico Chiquimula', NULL, 89, 38.46, 'Vilma Johana Orellana', NULL, NULL, '2023-11-08', 4, 6),
(420, '17:15:00', '18:30:00', 'Centro medico', 1450, 200, 39.38, 'Vilma Orellana', 51, 'Cirugia antebrazo', '2023-11-08', 4, 5),
(421, '16:45:00', '17:40:00', 'Memorial', 550, 75, 19.69, 'Jefri cervantes', 12, 'Muñeca', '2023-11-09', 4, 5),
(422, '22:50:00', '23:31:00', 'Siglo 21', 550, 75, 19.69, 'Hijo de berta acevedo', 1, 'Torax ap y lat', '2023-11-09', 4, 5),
(423, '16:45:00', '17:40:00', 'Hospital Memorial Chiquimula', NULL, 50, 19.23, 'Jefri Jose Cervantes.', NULL, NULL, '2023-11-11', 4, 6),
(424, '17:00:00', '21:00:00', 'Centro Medico Zacapa', NULL, 132, 76.92, 'Densitometro', NULL, NULL, '2023-11-11', 4, 6),
(425, '08:30:00', '09:22:00', 'Hospital Memorial Chiquimula ', NULL, 50, 19.23, 'Cristofer Damian Mejia Soliz', NULL, NULL, '2023-11-12', 4, 6),
(426, '09:22:00', '10:05:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 19.23, 'Hija de Berta Acevedo', NULL, NULL, '2023-11-12', 4, 6),
(427, '08:30:00', '09:23:00', 'Memorial', 550, 75, 19.69, 'Cristofer Damian Mejia ', 10, 'Rx de antebrazo derecho ', '2023-11-12', 4, 7),
(428, '09:22:00', '10:05:00', 'Siglo 21', 550, 75, 19.69, 'Hija de Berta ', 0, 'Rx de tórax ap/lateral ', '2023-11-12', 4, 7);
INSERT INTO `emergencia` (`id`, `inicio`, `fin`, `direccion`, `precio`, `honorarios`, `hora_extra`, `paciente`, `edad`, `estudios`, `fecha`, `f_estado`, `f_usuario`) VALUES
(429, '14:20:00', '14:55:00', 'Centro Clinico ', 550, 75, 19.69, 'Francisco Padilla ', 64, 'Rx tórax pa/lateral', '2023-11-12', 4, 7),
(430, '14:20:00', '14:55:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 19.23, 'Francisco Padilla', NULL, NULL, '2023-11-12', 4, 6),
(431, '14:55:00', '15:22:00', 'Siglo 21', 550, 75, 19.69, 'Maria Berganza', 61, 'Rx tórax ap/lateral ', '2023-11-12', 4, 7),
(432, '14:55:00', '15:22:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 19.23, 'Maria Verganza', NULL, NULL, '2023-11-12', 4, 6),
(433, '15:22:00', '15:55:00', 'Siglo 21 ', 550, 75, 19.69, 'Frankis javier ', 19, 'Rx pa ', '2023-11-12', 4, 7),
(434, '15:22:00', '15:55:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 19.23, 'Flankis Javier ', NULL, NULL, '2023-11-12', 4, 6),
(435, '06:38:00', '07:52:00', 'memorial', 400, 75, 39.38, 'juan carlos reyes', 8, 'parrilla costal derecha', '2023-11-16', 4, 5),
(436, '08:07:00', '09:23:00', 'MEMORIAL', 400, 75, 39.38, 'DANIEL ELIAS   IPIÑA', 12, 'MUÑECA IZQ', '2023-11-17', 4, 5),
(437, '20:07:00', '21:23:00', 'Hospital Memorial ', NULL, 50, 38.46, 'Daniel Elias Ipiña', NULL, NULL, '2023-11-18', 4, 6),
(438, '12:00:00', '12:45:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 19.23, 'Vitalino Corado', NULL, NULL, '2023-11-18', 4, 6),
(439, '12:00:00', '12:45:00', 'SIGLO 21', 800, 150, 19.69, 'VITALINO', 81, 'TORAX AP \nABDOMEN', '2023-11-18', 4, 5),
(440, '07:45:00', '08:15:00', 'XRADII', 600, 75, 19.69, 'ZOILA OLIVA', 69, 'ABDOMEN ', '2023-11-18', 4, 5),
(441, '11:46:00', '12:46:00', 'Hospital Memorial Chiquimula ', NULL, 50, 19.23, 'Daniel Elias Ipiña', NULL, NULL, '2023-11-19', 4, 6),
(442, '11:46:00', '12:46:00', 'MEMORIAL', 400, 75, 19.69, 'DANIEL IPIÑA', 12, 'MUÑECA IZQ. AP Y LAT', '2023-11-19', 4, 5),
(443, '05:00:00', '05:55:00', 'MEMORIAL', 400, 75, 19.69, 'ANYELY     CETINO', 16, 'MUÑECA  AP Y LAT                                                                                                        ', '2023-11-20', 4, 5),
(444, '06:00:00', '06:50:00', 'MEMORIAL', 400, 75, 19.69, 'IAN SANTIAGO', 5, 'MANO PA Y LAT', '2023-11-20', 4, 5),
(445, '17:00:00', '17:55:00', 'Hospital Memorial Chiquimula ', NULL, 50, 19.23, 'Anyely Cetino', NULL, NULL, '2023-11-20', 4, 6),
(446, '18:00:00', '18:50:00', 'Hospital Memorial Chiquimula ', NULL, 50, 19.23, 'Ian Santiago ', NULL, NULL, '2023-11-20', 4, 6),
(447, '17:45:00', '18:50:00', 'Memorial', 400, 75, 39.38, 'Diego perez', 12, 'Muñeca pa y lat', '2023-11-22', 4, 5),
(448, '17:45:00', '18:50:00', 'Hospital Memorial ', NULL, 50, 38.46, 'Diego Miguel Perez Avalo', NULL, NULL, '2023-11-23', 4, 6),
(450, '08:25:00', '09:23:00', 'MEMORIAL', 400, 75, 19.69, 'muñeca iz', 12, 'MUÑECA  IZQ AP Y LAT', '2023-11-28', 4, 5),
(451, '20:25:00', '21:23:00', 'Hospital Memorial Chiquimula ', NULL, 50, 19.23, 'Edgar Hector Fernando Rodriguez Menendez.', NULL, NULL, '2023-11-28', 4, 6),
(452, '06:20:00', '07:20:00', 'XRADII', 350, 75, 19.69, 'ANGIE ESPAÑA', 16, 'ABDOMEN', '2023-11-30', 4, 5),
(454, '19:20:00', '20:20:00', 'Hospital Memorial Chiquimula ', NULL, 50, 19.23, 'Leslie Sarai Cordero Morales ', NULL, NULL, '2023-12-01', 4, 6),
(455, '07:20:00', '08:20:00', 'MEMORIAL', 400, 75, 19.69, 'LESLI SARAI CORDERO', 9, 'MUÑECA DERECHA ', '2023-12-01', 4, 5),
(456, '12:00:00', '13:00:00', 'A la par de pollo a las Brazas ', 550, 75, 19.69, 'Miguel Angel ', 88, 'Rx tórax ap/lateral ', '2023-12-02', 4, 7),
(457, '12:00:00', '13:30:00', '8av. 2-21 zona 1 casa particular ', NULL, 50, 38.46, 'Miguel Angel Roldan Orellana ', NULL, NULL, '2023-12-04', 4, 6),
(458, '17:00:00', '17:30:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 19.23, 'Jose Diaz', NULL, NULL, '2023-12-04', 4, 6),
(459, '16:50:00', '17:20:00', 'Centro medico ', 550, 75, 19.69, 'Alba arita', 64, 'Torax ap', '2023-12-14', 4, 5),
(460, '13:30:00', '14:00:00', 'Clinica Xradi ', 350, 75, 19.69, 'Sara Lopez ', 2, 'Rx de tórax ', '2023-12-17', 4, 7),
(461, '17:00:00', '17:30:00', 'Hospital centro medico ', 550, 75, 19.69, 'Jose Diaz ', 0, 'Rx tórax ', '2023-12-17', 4, 7),
(462, '17:00:00', '17:30:00', 'X-radii', 350, 75, 19.69, 'Adriana Morales', 9, 'Edad osea ', '2023-12-21', 4, 7),
(463, '20:00:00', '20:50:00', 'Centro Clinico ', 550, 75, 19.69, 'H/Dulce Guancin', 0, 'Rx de abdomen ', '2023-12-23', 4, 7),
(464, '12:30:00', '13:25:00', 'Xradi ', 350, 75, 19.69, 'Daniela Moran ', 23, 'Rx de rodilla izquierda ap/lat', '2023-12-26', 4, 7),
(465, '19:00:00', '20:00:00', 'Centro clinico ', 550, 75, 19.69, 'Maria Perez ', 86, 'Rx de mano izquierda ', '2023-12-27', 4, 7),
(466, '21:00:00', '22:00:00', 'Siglo21', 550, 75, 19.69, 'Vostoria Aguirre', 87, 'Rx tórax ap', '2023-12-27', 4, 7),
(467, '16:50:00', '17:20:00', 'Hospital Centro Medico ', NULL, 50, 19.23, 'Alba Arita', NULL, NULL, '2024-01-05', 4, 6),
(468, '17:00:00', '18:15:00', 'Hospital Unidad Médica ', NULL, 50, 38.46, 'Kevin Velasquez', NULL, NULL, '2024-01-05', 4, 6),
(469, '20:00:00', '21:00:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 19.23, 'Dorotea Torres ', NULL, NULL, '2024-01-05', 4, 6),
(470, '17:00:00', '18:15:00', 'Unidad Medica ', 550, 75, 39.38, 'Kevin velasquez ', 31, 'Rx tórax ', '2024-01-07', 4, 7),
(471, '20:00:00', '21:00:00', 'Centro clinico ', 550, 75, 19.69, 'Dorotea Torres ', 78, 'Rx de cadera ', '2024-01-07', 4, 7),
(472, '17:00:00', '18:45:00', 'X-RADII Chiquimula ', NULL, 70, 38.46, 'Tomografía ', NULL, NULL, '2024-01-09', 4, 6),
(473, '18:35:00', '19:25:00', 'X-RADII Chiquimula ', NULL, 20, 19.23, 'Se realizo fumigacion ', NULL, NULL, '2024-01-09', 4, 6),
(474, '17:00:00', '18:30:00', 'Hospital Memorial Chiquimula ', NULL, 50, 38.46, 'Elizabeth Lobos ', NULL, NULL, '2024-01-09', 4, 6),
(475, '17:00:00', '18:30:00', 'Memorial', 400, 75, 39.38, 'Elizabeth Lobos', 3, 'Torax ap y lat', '2024-01-09', 4, 5),
(476, '13:00:00', '13:50:00', 'X-RADII Chiquimula ', NULL, 20, 19.23, 'Se realizo fumigacion ', NULL, NULL, '2024-01-13', 4, 6),
(477, '16:45:00', '17:30:00', 'Hospital Unidad Médica ', NULL, 50, 19.23, 'Mario Ordoñez', NULL, NULL, '2024-01-18', 4, 6),
(478, '16:45:00', '17:30:00', 'Unidad medica ', 475, 75, 19.69, 'Mario ordoñez', 47, 'Rx tórax ', '2024-01-18', 4, 7),
(479, '02:15:00', '02:30:00', 'XRADII', 350, 75, 19.69, 'MIRIAM ESPINAL', 38, 'TORAX PA Y LAT', '2024-01-20', 4, 5),
(480, '16:26:00', '17:35:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 38.46, 'Syndi Martinez ', NULL, NULL, '2024-01-20', 4, 6),
(481, '04:25:00', '05:35:00', 'CENTRO MEDICO', 475, 75, 39.38, 'SINDY MARTINEZ', 35, 'TORAX AP Y LAT', '2024-01-20', 4, 5),
(482, '17:53:00', '18:20:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 19.23, 'Julissa Hernandez Valdez', NULL, NULL, '2024-01-20', 4, 6),
(483, '05:53:00', '06:20:00', 'CENTRO MEDICO', 475, 75, 19.69, 'JULISSA HERNANDEZ', 8, 'MANO PA', '2024-01-20', 4, 5),
(484, '18:20:00', '18:50:00', 'Hospital Centro Medico ', NULL, 50, 19.23, 'Heleodoro Galvez', NULL, NULL, '2024-01-20', 4, 6),
(485, '06:20:00', '06:50:00', 'CENTRO MEDICO', 475, 75, 19.69, 'HELEODORO GALVEZ', 88, 'TORAX AP Y LAT', '2024-01-20', 4, 5),
(486, '18:50:00', '19:50:00', 'Hospital Memorial ', NULL, 50, 19.23, 'David Mayorga', NULL, NULL, '2024-01-20', 4, 6),
(487, '06:50:00', '07:50:00', 'MEMORIAL', 400, 75, 19.69, 'DAVID MAYORGA', 8, 'CODO DERECHO AP LAT', '2024-01-20', 4, 5),
(488, '20:50:00', '22:00:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 38.46, 'Lucila Archila Vargas', NULL, NULL, '2024-01-20', 4, 6),
(489, '08:50:00', '10:00:00', 'CENTRO MEDICO', 725, 150, 39.38, 'LUCILA ARCHILA', 58, 'HUMERO Y PIE IZQ', '2024-01-20', 4, 5),
(490, '12:00:00', '13:15:00', 'Hospital Centro Medico ', NULL, 50, 38.46, 'Mario David Lima Monroy ', NULL, NULL, '2024-01-21', 4, 6),
(491, '16:50:00', '17:40:00', 'Hospital Memorial Chiquimula ', NULL, 50, 19.23, 'Daylin Liliana Lopez', NULL, NULL, '2024-01-22', 4, 6),
(492, '17:40:00', '18:30:00', 'Hospital Multimedica de Oriente. ', NULL, 50, 19.23, 'Ofelia Sagastune ', NULL, NULL, '2024-01-22', 4, 6),
(493, '12:00:00', '13:15:00', 'CENTRO MEDICO', 575, 75, 39.38, 'MARIO DAVID LIMA', 35, 'COLUMA DORSO LUMBAR', '2024-01-22', 4, 5),
(494, '04:50:00', '05:40:00', 'MEMORIAL', 400, 75, 19.69, 'DAYLIN LILIANA LOPEZ', 9, 'MUÑECA DERECHA PA Y LAT', '2024-01-22', 4, 5),
(495, '05:40:00', '06:30:00', 'MULTIMEDICA', 475, 75, 19.69, 'OFELIA SAGASTUME', 65, 'TORAX AP Y LAT', '2024-01-22', 4, 5),
(497, '17:00:00', '19:00:00', 'X-RADII Chiquimula ', NULL, 53, 38.46, 'Mantenimiento de impresora XR.', NULL, NULL, '2024-01-25', 4, 6),
(498, '17:30:00', '18:20:00', 'Hospital Memorial Chiquimula ', NULL, 50, 20.17, 'Luis Francisco Pelico Rodriguez ', NULL, NULL, '2024-01-26', 4, 6),
(499, '17:30:00', '18:20:00', 'Memorial', 400, 75, 20.17, 'Luis pelico', 9, 'Cadera ap y axial', '2024-01-26', 4, 5),
(500, '15:25:00', '16:35:00', 'Hospital Centro Clínico ', NULL, 50, 40.34, 'Aura Ortega ', NULL, NULL, '2024-01-28', 4, 6),
(502, '20:50:00', '22:00:00', 'Hospital Unidad Médica ', NULL, 50, 40.34, 'Evangelisiata Aldana', NULL, NULL, '2024-01-28', 4, 6),
(503, '15:25:00', '16:34:00', 'Centro clinico ', 475, 75, 40.34, 'Aura ortega ', 78, 'Rx abdomen ', '2024-01-29', 4, 7),
(504, '20:50:00', '22:00:00', 'Unidad medica ', 475, 75, 40.34, 'Evangelista aldana ', 76, 'Rx de tórax ap y lat', '2024-01-29', 4, 7),
(505, '18:30:00', '19:25:00', 'Unidad Medica ', 475, 75, 20.17, 'Telma Hernandez ', 74, 'Rx de tórax ', '2024-01-30', 4, 7),
(506, '17:00:00', '18:00:00', 'Clinica X-radii', 350, 75, 20.17, 'Julian Martinez ', 83, 'Rx de tórax ap /lat', '2024-02-01', 4, 7),
(507, '12:00:00', '13:40:00', 'Hospital Multimedica de Oriente Chiquimula ', NULL, 50, 40.34, 'Rodrigo Israel Diaz Tejada', NULL, NULL, '2024-02-03', 4, 6),
(508, '16:30:00', '20:05:00', 'Hospital Multimedica de Oriente Chiquimula ', NULL, 180, 80.68, 'Rodrigo Israel Diaz Tejada ', NULL, NULL, '2024-02-03', 4, 6),
(509, '12:00:00', '13:40:00', 'Multimedica', 1475, 375, 40.34, 'Rodrigo Israel Diaz Tejada', 33, 'Mano, tobillo, craneo, maxilar , tobillo', '2024-02-03', 4, 5),
(510, '16:30:00', '20:05:00', 'Multimedica ', 1880, 200, 80.68, 'Rodrigo Israel Diaz Tejada', 33, 'Cirugia ', '2024-02-03', 4, 5),
(511, '11:00:00', '12:10:00', 'Hospital Memorial Chiquimula ', NULL, 50, 40.34, 'Julia Suchite', NULL, NULL, '2024-02-04', 4, 6),
(512, '20:20:00', '21:20:00', 'Hospital Memorial Chiquimula ', NULL, 50, 20.17, 'Vicenta Berganza', NULL, NULL, '2024-02-05', 4, 6),
(513, '11:00:00', '12:10:00', 'Memorial', 350, 75, 40.34, 'Julia Suchite', 50, 'Abdomen', '2024-02-05', 4, 5),
(514, '20:20:00', '21:20:00', 'Memorial', 350, 75, 20.17, 'Vicenta Berganza', 64, 'Abddomen', '2024-02-05', 4, 5),
(515, '12:00:00', '13:00:00', 'Hospital Unidad Médica ', NULL, 50, 20.17, 'Crisanta Argueta', NULL, NULL, '2024-02-10', 4, 6),
(516, '07:30:00', '08:25:00', 'Hospital Unidad Médica ', NULL, 50, 20.17, 'Eloisa Morales ', NULL, NULL, '2024-02-11', 4, 6),
(517, '12:00:00', '13:00:00', 'Unidad Medica', 475, 75, 20.17, 'Crisanta Argueta ', 83, 'Rx tórax ap', '2024-02-11', 4, 7),
(518, '07:30:00', '08:30:00', 'Unidad Medica ', 475, 75, 20.17, 'Eloisa Morales ', 86, 'Rx tórax ap/lat', '2024-02-11', 4, 7),
(519, '12:05:00', '13:00:00', 'Hospital Centro Medico ', NULL, 50, 20.17, 'Kristel Peinado ', NULL, NULL, '2024-02-11', 4, 6),
(520, '12:05:00', '13:00:00', 'Centro medico ', 475, 75, 20.17, 'Kristel peinado ', 2, 'Rx de tórax ', '2024-02-11', 4, 7),
(521, '17:00:00', '18:00:00', 'Xradi', 0, 75, 20.17, 'Perrito doc utrilla', 0, 'Rx de patita ', '2024-02-13', 4, 7),
(522, '07:15:00', '08:00:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Hija de Ana Luisa ', NULL, NULL, '2024-02-14', 4, 6),
(523, '19:50:00', '20:45:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 20.17, 'Josefina Cabrera', NULL, NULL, '2024-02-14', 4, 6),
(524, '07:15:00', '08:00:00', 'Siglo 21', 475, 75, 20.17, 'Hija de Maria ', 0, 'Rx tórax ap', '2024-02-14', 4, 7),
(525, '19:50:00', '20:45:00', 'Centro Medico ', 475, 75, 20.17, 'Jose Fina Cabrera ', 63, 'Rx tórax ap ', '2024-02-14', 4, 7),
(526, '18:00:00', '19:25:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 40.34, 'Nolfa Rodriguez ', NULL, NULL, '2024-02-15', 4, 6),
(527, '18:00:00', '19:25:00', 'Siglo 21', 475, 75, 40.34, 'Numfa Rodriguez ', 46, 'Rx tórax ap', '2024-02-15', 4, 7),
(528, '07:15:00', '08:00:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Noe Alexander Aguilar', NULL, NULL, '2024-02-17', 4, 6),
(529, '17:45:00', '18:37:00', 'Hospital Centro Medico ', NULL, 90, 20.17, 'Denia Lisseth Aranda ', NULL, NULL, '2024-02-17', 4, 6),
(530, '18:37:00', '19:55:00', 'Hospital Memorial ', NULL, 50, 40.34, 'Hugo Castellon ', NULL, NULL, '2024-02-17', 4, 6),
(531, '07:10:00', '08:00:00', 'UNIDAD MEDICA', 475, 75, 20.17, 'NOE ALEXANDER AGUILAR', 22, 'TORAX AP Y LAT', '2024-02-17', 4, 5),
(532, '05:45:00', '06:37:00', 'CENTRO MEDICO', 1000, 200, 20.17, 'DENIA ARANDA', 32, 'LAT CRANEO', '2024-02-17', 4, 5),
(533, '06:37:00', '07:55:00', 'MEMORIAL', 350, 75, 40.34, 'HUGO CASTELLON', 27, 'TORAX Y PARRILLA COSTAL D.', '2024-02-17', 4, 5),
(534, '18:00:00', '18:45:00', 'Xradi', 0, 75, 20.17, 'Hermano de Doctora joselin ', 36, 'Rx parrilla costal ', '2024-02-17', 4, 7),
(535, '15:00:00', '17:00:00', 'Xradii', 1850, 250, 40.34, 'Sandoval ', 0, 'Tomografía cerebral ', '2024-02-18', 4, 7),
(536, '17:00:00', '18:00:00', 'X-RADII Chiquimula ', NULL, 30, 20.17, 'Tomografía ', NULL, NULL, '2024-02-20', 4, 6),
(537, '18:00:00', '19:00:00', 'X-RADII ', NULL, 40, 20.17, 'Arjuna Fumigacion ', NULL, NULL, '2024-02-20', 4, 6),
(538, '05:00:00', '05:50:00', 'XRADII', 350, 75, 20.17, 'JUAN SEBASTIAN   BAUTISTA UMAÑA', 13, 'SENOS PARANASALES', '2024-02-22', 4, 5),
(539, '19:20:00', '20:14:00', 'Centro Clinico de especialidades ', 475, 75, 20.17, 'Abelino Ramirez ', 39, 'Rx de pierna derecha ', '2024-02-24', 4, 7),
(540, '20:30:00', '21:30:00', 'Clinica x-radii ', 1850, 250, 20.17, 'Hernesto de Jesus', 53, 'Tomografía cerebral ', '2024-02-26', 4, 7),
(541, '20:30:00', '23:00:00', 'Xradi', 185, 250, 60.51, 'Katherine Sofia Duarte Pascual ', 3, 'TAC Cerebral', '2024-02-26', 4, 7),
(542, '06:36:00', '07:45:00', 'MEMORIAL', 350, 75, 40.34, 'CRISTOBAL MENDEZ CASTILLO', 79, 'ABDOMEN', '2024-03-02', 4, 5),
(543, '18:36:00', '19:45:00', 'Hospital Memorial ', NULL, 50, 40.34, 'Cristobal Mendez', NULL, NULL, '2024-03-04', 4, 6),
(544, '17:00:00', '17:50:00', 'Hospital Unidad Médica ', NULL, 50, 20.17, 'Byron Vasquez ', NULL, NULL, '2024-03-05', 4, 6),
(545, '05:00:00', '05:50:00', 'UNIDAD MEDICA', 475, 75, 20.17, 'BYRON JOEL VASQUEZ', 17, 'ABDOMEN', '2024-03-06', 4, 5),
(546, '09:15:00', '11:59:00', 'SIGLO 21', 2050, 450, 60.51, 'LESBIA LOPEZ', 24, 'TORAX, COL. CERVICAL,  DORSAL, LUMBAR, PELVIS , TORAX ( 2 VEZ  POR PROCEDIMIENTO EFECTUADO )', '2024-03-06', 4, 5),
(547, '21:15:00', '23:59:00', 'Hospital Siglo 21 Chiquimula ', NULL, 90, 60.51, 'Lesbia Lopez', NULL, NULL, '2024-03-06', 4, 6),
(548, '20:30:00', '21:45:00', 'Hospital Memorial Chiquimula ', NULL, 50, 40.34, 'Katalina Sagatume ', NULL, NULL, '2024-03-06', 4, 6),
(549, '21:45:00', '22:25:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 20.17, 'Lubia Monroy ', NULL, NULL, '2024-03-06', 4, 6),
(550, '18:30:00', '19:30:00', 'X-RADII ', NULL, 40, 20.17, 'Mantenimiento de aire acondicionado ', NULL, NULL, '2024-03-11', 4, 6),
(551, '17:00:00', '17:35:00', 'Casa particular Col. Ruano ', NULL, 50, 20.17, 'Rufina Garcia ', NULL, NULL, '2024-03-14', 4, 6),
(552, '17:00:00', '17:35:00', 'A domicilio col. RUANO', 575, 75, 20.17, 'Rufina Cruz Garcia Ramires ', 69, 'Rx de pelvis ', '2024-03-15', 4, 7),
(553, '20:15:00', '21:30:00', 'Hospital Centro Clínico ', NULL, 50, 40.34, 'Hortencia Gonzales', NULL, NULL, '2024-03-16', 4, 6),
(554, '20:15:00', '21:30:00', 'CENTRO CLINICO DE ESP.', 725, 150, 40.34, 'HORTENCIA GONZALEZ', 94, 'Torax ap y lat\nAbfomen simple', '2024-03-16', 4, 5),
(555, '05:30:00', '06:30:00', 'XRADII', 350, 75, 20.17, 'SERGIO CORDON Y CORDON', 61, 'TORAX AP Y LAT', '2024-03-19', 4, 5),
(556, '18:00:00', '19:00:00', 'Hospital Siglo 21 ', NULL, 50, 20.17, 'Josue Aguilar', NULL, NULL, '2024-03-20', 4, 6),
(557, '20:27:00', '22:40:00', 'Hospital San Vicente de Paul Zacapa', NULL, 50, 60.51, 'Delvin Perez ', NULL, NULL, '2024-03-20', 4, 6),
(558, '17:00:00', '17:50:00', 'Hospital Siglo 21', NULL, 50, 20.17, 'Josue Aguilar ', NULL, NULL, '2024-03-21', 4, 6),
(559, '05:30:00', '08:00:00', 'Salama ', NULL, 125, 60.51, 'Hospital  del Dr. Orellana Salama', NULL, NULL, '2024-03-21', 4, 6),
(560, '18:00:00', '19:00:00', 'Siglo 21', 475, 75, 20.17, 'Josue Aguilar', 20, 'Abdomen', '2024-03-21', 4, 5),
(561, '20:27:00', '22:40:00', 'Hospital san Vicente de Paul, Zacapa', 550, 75, 60.51, 'Delvin Romaldo', 23, 'Pie derecho ap lat oblic', '2024-03-21', 4, 5),
(562, '17:00:00', '17:50:00', 'Siglo 21', 475, 75, 20.17, 'Josue Aguilar', 20, 'Torax ap', '2024-03-21', 4, 5),
(563, '14:00:00', '18:35:00', 'Hospital Siglo 21 Chiquimula ', NULL, 180, 100.85, 'Josue Aguilar ', NULL, NULL, '2024-03-23', 4, 6),
(564, '14:00:00', '18:35:00', 'Siglo 21', 1200, 200, 100.85, 'Josue Aguilar ', 22, 'Cirugia de pelvis ', '2024-03-23', 4, 7),
(565, '17:00:00', '18:30:00', 'X-RADII ', NULL, 60, 40.34, 'Arjuna Fumigacion ', NULL, NULL, '2024-03-25', 4, 6),
(566, '18:00:00', '18:40:00', 'Casa del doctor medina ', 0, 75, 20.17, 'Vilma Jordan ', 64, 'Rx tórax pa/lateral ', '2024-03-26', 4, 7),
(567, '18:00:00', '18:50:00', 'Casa particular ', NULL, 50, 20.17, 'Vilma Jordan ', NULL, NULL, '2024-03-27', 4, 6),
(568, '07:00:00', '10:15:00', 'Santa Catarina Mita Jutiapa', NULL, 85, 80.68, 'Vitalina Recinos', NULL, NULL, '2024-03-28', 4, 6),
(569, '07:00:00', '10:15:00', 'Santa catarina mita Jutiapa', 750, 150, 80.68, 'Vitalina Recinos', 84, 'Rx tórax ap/lateral ', '2024-03-28', 4, 7),
(570, '21:25:00', '22:10:00', 'Siglo 21', 475, 75, 20.17, 'Eugenio lopez', 86, 'Rx tórax ap', '2024-03-28', 4, 7),
(571, '21:25:00', '22:10:00', 'Hospital Siglo 21', NULL, 50, 20.17, 'Eugenio Lopez ', NULL, NULL, '2024-03-28', 4, 6),
(572, '07:15:00', '10:00:00', 'Xradi', 1850, 250, 60.51, 'Maria angelina cruz ', 84, 'TAC CEREBRAL ', '2024-03-29', 4, 7),
(574, '12:15:00', '13:10:00', 'Multimedica ', 475, 75, 20.17, 'Maria Reina Cruz ', 81, 'Rx tórax ap/lateral', '2024-03-29', 4, 7),
(575, '22:00:00', '23:00:00', 'Siglo 21', 725, 150, 20.17, 'Silvio archila', 84, 'Rx de.torax y abdomen ', '2024-03-29', 4, 7),
(576, '10:00:00', '11:05:00', 'Hospital Siglo 21 ', NULL, 50, 40.34, 'Silvio Archila', NULL, NULL, '2024-03-29', 4, 6),
(577, '11:10:00', '12:15:00', 'X-RADII ', NULL, 50, 40.34, 'Se rrego la grama ', NULL, NULL, '2024-03-29', 4, 6),
(578, '12:15:00', '13:10:00', 'Hospital Multimedica de Oriente ', NULL, 50, 20.17, 'Maria Reina Cruz', NULL, NULL, '2024-03-29', 4, 6),
(579, '16:20:00', '16:58:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 20.17, 'Leonor Berganza ', NULL, NULL, '2024-03-31', 4, 6),
(580, '16:58:00', '17:36:00', 'Hospital Siglo 21', NULL, 50, 20.17, 'Silvio Archila ', NULL, NULL, '2024-03-31', 4, 6),
(581, '16:20:00', '16:58:00', 'CENTRO CLINICO DE ESPECIALIDADES ', 475, 75, 20.17, 'LEONOR BERGANZA', 87, 'Abdomen', '2024-03-31', 4, 5),
(582, '16:58:00', '17:36:00', 'SIGLO 21', 475, 75, 20.17, 'SILVIO ARCHILA', 84, 'Torax ap', '2024-03-31', 4, 5),
(583, '17:55:00', '18:45:00', 'Hospital Multimedica de Oriente Chiquimula ', NULL, 50, 20.17, 'Norma Martinez ', NULL, NULL, '2024-04-02', 4, 6),
(584, '17:55:00', '18:45:00', 'Multimedica', 475, 75, 20.17, 'Norma Martinez', 22, 'Torax ap y lat', '2024-04-02', 4, 5),
(585, '10:21:00', '11:30:00', 'Siglo 21', 725, 150, 40.34, 'Resucindo Monroy', 81, 'Rx tórax y abdomen ', '2024-04-07', 4, 7),
(586, '06:35:00', '07:30:00', 'Hospital Unidad Médica ', NULL, 50, 20.17, 'Modesta Lemus ', NULL, NULL, '2024-04-09', 4, 6),
(587, '06:35:00', '07:30:00', 'Unidad Medica ', 475, 75, 20.17, 'Modesta Lemus ', 61, 'Rx de tórax ap/lateral ', '2024-04-09', 4, 7),
(588, '17:55:00', '18:50:00', 'Hospital Unidad Médica ', NULL, 50, 20.17, 'Jonathan Rolda', NULL, NULL, '2024-04-09', 4, 6),
(589, '17:55:00', '18:50:00', 'Unidad Medica ', 475, 75, 20.17, 'Jonatan Roldan', 33, 'Rx abdomen ', '2024-04-10', 4, 7),
(590, '17:00:00', '17:55:00', 'Centro clinico', 475, 75, 20.17, 'Hectir valdez ', 87, 'Rx tórax ap /lateral', '2024-04-10', 4, 7),
(591, '17:00:00', '17:45:00', 'Hospital Centro Clínico ', NULL, 50, 20.17, 'Hector Raul Valdez', NULL, NULL, '2024-04-11', 4, 6),
(592, '17:50:00', '22:26:00', 'X-RADII Chiquimula ', NULL, 210, 100.85, 'Ultrasonido ', NULL, NULL, '2024-04-11', 4, 6),
(593, '17:00:00', '23:00:00', 'X-RADII ', NULL, 210, 121.02, 'Mamografia ', NULL, NULL, '2024-04-11', 4, 6),
(594, '18:20:00', '19:00:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Leonel Gregorio ', NULL, NULL, '2024-04-12', 4, 6),
(595, '17:35:00', '18:35:00', 'Hospital Multimedica ', NULL, 50, 20.17, 'Delma Diaz ', NULL, NULL, '2024-04-14', 4, 6),
(596, '17:35:00', '18:35:00', 'Multimedica', 475, 75, 20.17, 'Delma Diaz', 36, 'Abdomen', '2024-04-16', 4, 5),
(597, '17:00:00', '18:00:00', 'Memorial', 400, 75, 20.17, 'Jose Contreras', 75, 'Torax ap y lat', '2024-04-16', 4, 5),
(598, '18:00:00', '18:35:00', 'Centro Clinico de Especialidades ', 475, 75, 20.17, 'Amanda vidal', 49, 'Abdomen', '2024-04-16', 4, 5),
(599, '17:00:00', '17:45:00', 'X-RADII ', NULL, 40, 20.17, 'Aire acondicionado ', NULL, NULL, '2024-04-16', 4, 6),
(600, '17:00:00', '18:01:00', 'Hospital Memorial ', NULL, 50, 40.34, 'Jose Rene Contreras ', NULL, NULL, '2024-04-16', 4, 6),
(601, '18:00:00', '18:42:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 20.17, 'Amanda Consuelo Vidal Martinez ', NULL, NULL, '2024-04-16', 4, 6),
(602, '18:45:00', '22:50:00', 'X-RADII ', NULL, 140, 100.85, 'Mantenimiento tomografía ', NULL, NULL, '2024-04-16', 4, 6),
(603, '17:00:00', '17:40:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Jose Alejandro Guerra ', NULL, NULL, '2024-04-18', 4, 6),
(604, '17:00:00', '17:40:00', 'Siglo 21', 475, 75, 20.17, 'Jose Alejandro Guerra', 46, 'Abdomen', '2024-04-18', 4, 5),
(605, '12:00:00', '13:00:00', 'Hospital Multimedica de Oriente Chiquimula ', NULL, 50, 20.17, 'Santos Juarez. ', NULL, NULL, '2024-04-21', 4, 6),
(606, '20:05:00', '21:40:00', 'Hospital Memorial ', NULL, 50, 40.34, 'Florindan Gregorio de Perez', NULL, NULL, '2024-04-21', 4, 6),
(607, '12:00:00', '13:00:00', 'Multimedica', 475, 75, 20.17, 'Santos Juarez', 68, 'Rx de tórax ap/lateral', '2024-04-21', 4, 7),
(608, '13:00:00', '15:30:00', 'Clinica Xradi', 1850, 250, 60.51, 'Samuel Flores ', 0, 'TAC cerebral ', '2024-04-21', 4, 7),
(609, '20:05:00', '21:40:00', 'Memorial', 400, 75, 40.34, 'Florinda Perez', 68, 'Rx de tórax pa/lateral ', '2024-04-21', 4, 7),
(610, '19:35:00', '20:30:00', 'Hospital Unidad Médica ', NULL, 50, 20.17, 'Evangelista Aldana ', NULL, NULL, '2024-04-25', 4, 6),
(611, '23:15:00', '12:00:00', 'Multimedica ', 475, 75, -221.87, 'Carlos Garnica ', 72, 'Rx tórax ap/lateral ', '2024-04-25', 4, 7),
(612, '19:35:00', '20:30:00', 'Multimedica ', 475, 75, 20.17, 'Evangelista Aldana ', 77, 'Rx de tórax pa/lateral', '2024-04-25', 4, 7),
(613, '11:50:00', '12:10:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 20.17, 'Ericka Miguel ', NULL, NULL, '2024-04-28', 4, 6),
(614, '12:10:00', '12:30:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 20.17, 'Isabel Lux', NULL, NULL, '2024-04-28', 4, 6),
(615, '12:30:00', '13:00:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Ingrid Gutierrez ', NULL, NULL, '2024-04-28', 4, 6),
(616, '11:50:00', '12:10:00', 'CCH', 475, 75, 20.17, 'ERICKA MIGUEL', 5, 'TORAX AP Y LAT', '2024-04-28', 4, 5),
(617, '12:10:00', '12:30:00', 'CCH', 475, 75, 20.17, 'ALEXANDRA ISABEL LUX', 8, 'TORAX AP Y LAT', '2024-04-28', 4, 5),
(619, '12:30:00', '01:00:00', 'SIGLO 21', 475, 75, -221.87, 'INGRID GUTIERREZ', 19, 'ABVDOMEN SIMPLE', '2024-04-28', 4, 5),
(620, '16:50:00', '17:35:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Karin Aldana ', NULL, NULL, '2024-04-29', 4, 6),
(621, '18:13:00', '19:02:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Patrick Alarcon', NULL, NULL, '2024-04-29', 4, 6),
(622, '04:50:00', '05:51:00', 'SIGLO 21', 475, 75, 40.34, 'KARIN  ALDANA', 40, 'ABDOMEN SIMPLE', '2024-04-29', 4, 5),
(623, '06:13:00', '07:02:00', 'UNIDAD MEDICA', 475, 75, 20.17, 'PATRICK ALARCON', 24, 'MUÑECA IZQ. AP LAT', '2024-04-29', 4, 5),
(624, '17:25:00', '18:35:00', 'Casa particular, barrio la Democracia Chiquimula. ', NULL, 50, 40.34, 'Maria Portillo Mendez.', NULL, NULL, '2024-04-30', 4, 6),
(625, '05:25:00', '06:35:00', 'BARRIO LA DEMOCRACIA', 525, 75, 40.34, 'MARIA PORTILLO', 88, 'CADERA DERECHA', '2024-04-30', 4, 5),
(626, '06:50:00', '07:25:00', 'SIGLO 21', 475, 75, 20.17, 'EVANGELISTA ALDANA', 77, 'ABDOMEN', '2024-04-30', 4, 5),
(627, '07:25:00', '08:00:00', 'SIGLO 21', 475, 75, 20.17, 'NOLBERTO JIMENEZ', 42, 'TORAX AP', '2024-04-30', 4, 5),
(630, '08:00:00', '08:55:00', 'UNIDAD MEDICA', 475, 75, 20.17, 'AUGUSTO MOLINA', 83, 'TORAX AP Y LAT', '2024-04-30', 4, 5),
(632, '18:50:00', '19:25:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Evangelista Aldana ', NULL, NULL, '2024-04-30', 4, 6),
(633, '19:25:00', '20:00:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Nolberto Jimenez', NULL, NULL, '2024-04-30', 4, 6),
(634, '20:00:00', '20:55:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Augusto Molina', NULL, NULL, '2024-04-30', 4, 6),
(635, '07:15:00', '08:20:00', 'UNIDAD MEDICA', 475, 75, 40.34, 'JUANA CARRANZA', 58, 'TORAX AP LAT', '2024-05-01', 4, 5),
(685, '19:15:00', '20:20:00', 'Hospital Unidad Médica Chiquimula. ', NULL, 50, 40.34, 'Juana Carranza', NULL, NULL, '2024-05-01', 4, 6),
(686, '12:00:00', '12:45:00', 'Hermano Pedro ', 475, 75, 20.17, 'Marcos Gael ', 5, 'Rx de abdomen simple ', '2024-05-04', 4, 7),
(687, '12:45:00', '13:15:00', 'Siglo 21 ', 475, 75, 20.17, 'Merlin Perez ', 27, 'Rx de tórax ap/lateral', '2024-05-04', 4, 7),
(688, '12:00:00', '12:45:00', 'Hospital Casa de Salud Chiquimula ', NULL, 50, 20.17, 'Marcos Gael Esquivel', NULL, NULL, '2024-05-04', 4, 6),
(689, '12:45:00', '13:15:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Merlyn Siomara Perez Geronimo', NULL, NULL, '2024-05-04', 4, 6),
(690, '14:44:00', '15:35:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 20.17, 'Bertina Lopez ', NULL, NULL, '2024-05-04', 4, 6),
(691, '17:25:00', '18:15:00', 'Hospital Casa de Salud Chiquimula ', NULL, 50, 20.17, 'Rosa Elvira Mejia Salazar', NULL, NULL, '2024-05-04', 4, 6),
(692, '18:15:00', '19:00:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Brenda Escobar ', NULL, NULL, '2024-05-04', 4, 6),
(693, '19:00:00', '19:25:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Wilson Recinos', NULL, NULL, '2024-05-04', 4, 6),
(694, '19:25:00', '20:30:00', 'Hospital Casa de Salud Chiquimula ', NULL, 50, 40.34, 'Oscar Raymundo Pop', NULL, NULL, '2024-05-04', 4, 6),
(695, '04:00:00', '20:00:00', 'Vieja a la Capital', NULL, 125, 322.72, 'Papel de Ultrasonido, Carbones y Fusibles ', NULL, NULL, '2024-05-04', 3, 6),
(696, '14:44:00', '03:35:00', 'Centro Clinico ', 475, 75, -221.87, 'Bertina Lopez ', 62, 'Rx de tórax ap/lateral', '2024-05-05', 4, 7),
(697, '17:25:00', '18:15:00', 'Casa de Salud ', 475, 75, 20.17, 'Rosa elvira mejia', 47, 'Rx tórax ap/lateral ', '2024-05-05', 4, 7),
(698, '18:15:00', '19:00:00', 'Unidad Medica ', 475, 75, 20.17, 'brenda escobar espino', 49, 'Rx de tórax ap/lateral ', '2024-05-05', 4, 7),
(699, '19:00:00', '19:25:00', 'Unidad Medica ', 475, 75, 20.17, 'Misael Solis Recinos ', 45, 'Rx de tórax pa/lateral', '2024-05-05', 4, 7),
(700, '19:25:00', '20:30:00', 'Casa de salud ', 825, 150, 40.34, 'Oscar Raymundo ', 45, 'Rx de tórax ap/lat y RX de pie izquierdo ', '2024-05-05', 4, 7),
(701, '17:00:00', '17:55:00', 'X-RADII Chiquimula ', NULL, 40, 20.17, 'Fumigacion en X-RADII ', NULL, NULL, '2024-05-09', 4, 6),
(702, '20:00:00', '20:55:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Edmundo Martinez ', NULL, NULL, '2024-05-09', 4, 6),
(703, '13:50:00', '14:50:00', 'Hospital Unidad Médica ', NULL, 50, 20.17, 'Santiago Ponce ', NULL, NULL, '2024-05-11', 4, 6),
(704, '15:45:00', '16:45:00', 'Hospital Memorial Chiquimula ', NULL, 50, 20.17, 'Isaias Erazo', NULL, NULL, '2024-05-11', 4, 6),
(705, '19:35:00', '20:30:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Manuel Buezo ', NULL, NULL, '2024-05-11', 4, 6),
(706, '01:50:00', '02:50:00', 'UNIDAD MEDICA', 475, 75, 20.17, 'SANTIAGO PONCE', 10, 'TORAX AP Y LAT', '2024-05-11', 4, 5),
(707, '03:45:00', '04:45:00', 'MEMORIAL', 700, 75, 20.17, 'MEMORIAL', 64, 'TORAX PA Y LAT. Y USG', '2024-05-11', 4, 5),
(708, '07:35:00', '08:30:00', 'SIGLO 21', 475, 75, 20.17, 'MANUEL BUEZO', 77, 'TORAX AP', '2024-05-11', 4, 5),
(709, '21:25:00', '22:15:00', 'Centro clinico', 475, 75, 20.17, 'Juan Antonio Mazariegos', 74, 'Torax ap', '2024-05-12', 4, 5),
(710, '21:25:00', '22:15:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 20.17, 'Juan Antonio Mazariegos', NULL, NULL, '2024-05-12', 4, 6),
(711, '18:05:00', '19:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 40.34, 'H/ de Anthony Garcia ', NULL, NULL, '2024-05-14', 4, 6),
(712, '18:05:00', '19:10:00', 'Siglo 21', 725, 150, 40.34, 'Hijo de antony Garcia', 1, 'Torax ap. Y abdomen', '2024-05-14', 4, 5),
(713, '07:52:00', '08:50:00', 'UNIDAD MEDICA', 475, 75, 20.17, 'CONSUELO MORALES', 73, 'TORAX AP Y LAT', '2024-05-15', 4, 5),
(714, '19:52:00', '20:50:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Consuelo Morales ', NULL, NULL, '2024-05-15', 4, 6),
(716, '22:05:00', '23:05:00', 'Unidad medica', 475, 75, 20.17, 'Ramiro menendez', 73, 'Torax ap y lat', '2024-05-15', 4, 5),
(717, '22:05:00', '23:05:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Ramiro Menendez', NULL, NULL, '2024-05-16', 4, 6),
(718, '19:05:00', '20:20:00', 'Hospital Memorial Chiquimula ', NULL, 50, 40.34, 'Manuel de Jesús Guerra ', NULL, NULL, '2024-05-16', 4, 6),
(719, '19:05:00', '20:20:00', 'Memorial', 400, 75, 40.34, 'Manuel de Jesus Guerra', 55, 'Torax ap y lat', '2024-05-16', 4, 5),
(720, '20:00:00', '20:55:00', 'Siglo 21', 475, 75, 20.17, 'Edmundo Martinez ', 79, 'Rx de tórax ap/lateral ', '2024-05-18', 4, 7),
(721, '13:50:00', '16:40:00', 'Multimedica', 475, 75, 60.51, 'Claudia Mariela Castillo ', 32, 'Rx de abdomen simple ', '2024-05-18', 4, 7),
(722, '13:50:00', '16:40:00', 'Hospital Multimedica de Oriente Chiquimula ', NULL, 50, 60.51, 'Claudia Mariela Castillo ', NULL, NULL, '2024-05-18', 3, 6),
(723, '09:00:00', '09:30:00', 'Siglo 21', 475, 75, 20.17, 'Alejandra Mauricio', 75, 'Mano izq', '2024-05-24', 4, 7),
(724, '09:30:00', '10:00:00', 'Siglo 21', 475, 75, 20.17, 'Olga Guerra ', 75, 'Tórax ap ', '2024-05-24', 4, 7),
(725, '10:30:00', '11:45:00', 'Multimedica ', 475, 75, 40.34, 'Hija de Yesenia Osorio ', 2, 'Rx tórax ap', '2024-05-24', 4, 7),
(726, '13:30:00', '14:50:00', 'Xradi', 1850, 250, 40.34, 'Bartolome Garcia ', 71, 'TAC cerebral ', '2024-05-25', 4, 7),
(728, '12:01:00', '12:30:00', 'XRADII', 350, 75, 20.17, 'ROSALINDA GUERRA', 77, 'TORAX PA Y  LAT', '2024-05-26', 4, 5),
(729, '01:10:00', '02:00:00', 'SIGLO 21', 475, 75, 20.17, 'TERESA BERRIDOS', 88, 'TORAX AP Y LAT', '2024-05-26', 4, 5),
(730, '03:50:00', '04:30:00', 'SIGLO 21', 475, 75, 20.17, 'TERESA BERRIDOS', 88, 'ABDOMEN', '2024-05-26', 4, 5),
(731, '13:10:00', '14:00:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Teresa Berridos ', NULL, NULL, '2024-05-27', 4, 6),
(732, '15:50:00', '16:30:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Teresa Berridos', NULL, NULL, '2024-05-27', 4, 6),
(733, '13:00:00', '20:47:00', 'X-RADII Chiquimula ', NULL, 350, 161.36, 'Se realizo instalación de los aires acondicionados.', NULL, NULL, '2024-05-27', 4, 6),
(734, '19:35:00', '20:45:00', 'Unidad medica', 475, 75, 40.34, 'Steven lopez', 5, 'Torax ap y lat', '2024-05-27', 4, 5),
(735, '19:48:00', '20:45:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Steven Lopez', NULL, NULL, '2024-05-27', 4, 6),
(737, '17:47:00', '19:17:00', 'Hospital Memorial Chiquimula ', NULL, 50, 40.34, 'Juan Antonio Villalta', NULL, NULL, '2024-05-29', 4, 6),
(738, '19:17:00', '19:57:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Miguel Vasquez.', NULL, NULL, '2024-05-29', 4, 6),
(739, '05:46:00', '07:15:00', 'MEMORIAL', 400, 75, 40.34, 'JUAN  ANTONIO VILLALTA', 63, 'TORAX PA Y LAT', '2024-05-29', 4, 5),
(740, '07:15:00', '08:00:00', 'SIGLO 21', 475, 75, 20.17, 'MIGUEL VELASQUEZ', 70, 'TORAX AP', '2024-05-29', 4, 5),
(741, '19:25:00', '20:40:00', 'Xradi ', 3250, 250, 40.34, 'Johan Jongenzon', 54, 'TAC abdominal completa ', '2024-05-30', 4, 7),
(743, '06:00:00', '08:00:00', 'X-RADII Chiquimula ', NULL, 60, 40.34, 'Cubriendo a Meli', NULL, NULL, '2024-05-31', 4, 6),
(744, '20:50:00', '21:50:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Glendy Aldana', NULL, NULL, '2024-05-31', 4, 6),
(745, '17:45:00', '18:35:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Gael Marin ', NULL, NULL, '2024-06-01', 4, 6),
(746, '20:10:00', '21:15:00', 'Hospital Medicall Chiquimula ', NULL, 50, 40.34, 'Walter Sanchez', NULL, NULL, '2024-06-01', 4, 6),
(747, '22:45:00', '23:22:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Jose Villeda ', NULL, NULL, '2024-06-02', 4, 6),
(748, '07:25:00', '08:40:00', 'Hospital Memorial Chiquimula ', NULL, 50, 40.34, 'Jose Guerra ', NULL, NULL, '2024-06-04', 4, 6),
(749, '17:45:00', '18:35:00', 'Unidad Medica ', 475, 75, 20.17, 'Gael Marin ', 4, 'Rx tórax ap', '2024-06-04', 4, 7),
(750, '20:10:00', '21:15:00', 'Medicall', 475, 75, 40.34, 'Walter Sanchez ', 15, 'Rx de Tórax ap ', '2024-06-04', 4, 7),
(751, '22:45:00', '23:22:00', 'Siglo 21 ', 475, 75, 20.17, 'Jose Villefa ', 77, 'Rx tórax ', '2024-06-04', 4, 7),
(752, '07:25:00', '08:40:00', 'Memorial ', 350, 75, 40.34, 'Jose Guerra ', 40, 'Abdomen completo ', '2024-06-04', 4, 7),
(753, '19:25:00', '20:40:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 40.34, 'Jose Villeda ', NULL, NULL, '2024-06-06', 4, 6),
(754, '08:40:00', '09:50:00', 'unidad medica', 475, 75, 40.34, 'glendy aldana', 25, 'rodilla ap y lat', '2024-06-08', 4, 5),
(755, '09:30:00', '11:15:00', 'HCCE', 975, 225, 40.34, 'TRANSITO HERNANDEZ', 88, 'TORAX AP\nHOMBRO Y SUS ROT\nPELVIS', '2024-06-09', 4, 5),
(756, '09:30:00', '11:17:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 40.34, 'Tránsito Hernandez', NULL, NULL, '2024-06-09', 4, 6),
(757, '03:25:00', '04:20:00', 'HCCE', 725, 150, 20.17, 'TRANSITO HERNANDEZ', 88, 'ABDOMEN\nTORAX AP ', '2024-06-09', 4, 5),
(758, '15:25:00', '16:25:00', 'Hospital Centro Clínico ', NULL, 50, 20.17, 'Tránsito Hernandez ', NULL, NULL, '2024-06-09', 4, 6),
(759, '05:00:00', '08:00:00', 'Viaje a ciudad capital ', NULL, 125, 60.51, 'Flat panel eco rey', NULL, NULL, '2024-06-15', 4, 6),
(760, '17:00:00', '18:00:00', 'X-RADII ', NULL, 40, 20.17, 'Fumigacion ', NULL, NULL, '2024-06-17', 4, 6),
(761, '20:54:00', '21:33:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Hija de Odeli Orellana ', NULL, NULL, '2024-06-17', 4, 6),
(762, '22:45:00', '23:22:00', 'Hospital Siglo 21 ', 475, 75, 20.17, 'Jose Villeda ', 0, 'Tórax ap', '2024-06-19', 4, 7),
(763, '20:54:00', '21:33:00', 'Siglo 21 ', 475, 75, 20.17, 'HIJA DE ODELI ORELLANA ', 0, 'Abdomen ', '2024-06-19', 4, 7),
(764, '18:55:00', '20:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 40.34, 'Jose Barrera', NULL, NULL, '2024-06-21', 4, 6),
(765, '07:00:00', '08:00:00', 'X-RADII Chiquimula ', NULL, 21, 20.17, 'Cubriendo a Meli', NULL, NULL, '2024-06-22', 4, 6),
(766, '21:13:00', '22:10:00', 'Centro medico', 475, 75, 20.17, 'Anastacio Crisostomo', 80, 'Torax ap', '2024-06-22', 4, 5),
(767, '21:13:00', '22:10:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 20.17, 'Anastacio Crisistomo', NULL, NULL, '2024-06-22', 4, 6),
(768, '19:00:00', '20:15:00', 'Siglo 21', 800, 150, 40.34, 'Jose Raul Barrera ', 19, 'Rx de craneo y arcos cigomaticos', '2024-06-23', 4, 7),
(769, '11:50:00', '12:50:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Pompilia Elias ', NULL, NULL, '2024-06-23', 4, 6),
(770, '11:50:00', '12:50:00', 'Siglo 21', 475, 75, 20.17, 'Pompilia Elias', 70, 'Torax pa y lat', '2024-06-23', 4, 5),
(771, '17:46:00', '18:33:00', 'XRadii', 600, 75, 20.17, 'Karla Erita', 25, 'Rx abdomen\nUsg abdomen', '2024-06-23', 4, 5),
(772, '07:01:00', '08:01:00', 'X-RADII Chiquimula ', NULL, 21, 20.17, 'Cubriendo a Meli', NULL, NULL, '2024-06-25', 4, 6),
(773, '07:00:00', '08:00:00', 'X-RADII Chiquimula ', NULL, 21, 20.17, 'Cubriendo a Meli ', NULL, NULL, '2024-06-25', 4, 6),
(774, '19:30:00', '20:35:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 40.34, 'Alicia Chang', NULL, NULL, '2024-06-25', 4, 6),
(775, '20:35:00', '21:11:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Hijo de Kimberly Argueta', NULL, NULL, '2024-06-25', 4, 6),
(776, '00:45:00', '02:45:00', 'Hospital Siglo 21 Chiquimula ', NULL, 100, 40.34, 'Alicia Chang', NULL, NULL, '2024-06-27', 3, 6),
(777, '07:00:00', '08:00:00', 'X-RADII Chiquimula ', NULL, 21, 20.17, 'Cubriendo a Meli ', NULL, NULL, '2024-06-27', 3, 6),
(778, '11:20:00', '12:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Francis Jimenez', NULL, NULL, '2024-06-29', 3, 6),
(779, '05:35:00', '06:30:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Erazmo Pacheco ', NULL, NULL, '2024-06-30', 3, 6),
(780, '10:30:00', '11:24:00', 'Hospital MediCall Chiquimula ', NULL, 50, 20.17, 'Crisostomo Guerra ', NULL, NULL, '2024-06-30', 3, 6),
(781, '07:00:00', '08:00:00', 'X-RADII ', NULL, 21, 20.17, 'Cubriendo a Meli', NULL, NULL, '2024-07-02', 4, 6),
(782, '07:00:00', '08:00:00', 'X-RADII ', NULL, 21, 20.17, 'Cubriendo a Meli ', NULL, NULL, '2024-07-03', 4, 6),
(783, '07:00:00', '08:00:00', 'X-RADII ', NULL, 21, 20.17, 'Cubriendo a Meli', NULL, NULL, '2024-07-04', 4, 6),
(784, '20:56:00', '21:41:00', 'Hospital Centro Clínico ', NULL, 50, 20.17, 'Darwin Sola', NULL, NULL, '2024-07-04', 4, 6),
(785, '05:13:00', '06:05:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Brianda Suchite', NULL, NULL, '2024-07-04', 4, 6),
(786, '07:02:00', '08:00:00', 'X-RADII Chiquimula ', NULL, 21, 20.17, 'Cubriendo a Meli ', NULL, NULL, '2024-07-04', 4, 6),
(789, '22:00:00', '22:30:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Sayra Garcia ', NULL, NULL, '2024-07-04', 4, 6),
(790, '22:30:00', '23:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Hortencia Perez', NULL, NULL, '2024-07-04', 4, 6),
(791, '14:30:00', '15:30:00', 'Siglo 21', 475, 75, 20.17, 'Benedicta jacome', 79, 'Pie derecho  ap y oblic', '2024-07-06', 4, 5),
(792, '19:30:00', '20:35:00', 'Siglo 21', 1175, 225, 40.34, 'Alicia chang', 94, 'Columna lumbar\nTorax\nPelvis', '2024-07-06', 4, 5),
(793, '20:35:00', '21:11:00', 'Siglo 21', 850, 150, 20.17, 'Hija de kimberly argueta', 1, 'Torax\nAbdomen', '2024-07-06', 4, 5),
(794, '00:45:00', '02:45:00', 'Siglo 21', 1200, 200, 40.34, 'Alicia chang', 94, 'Cadera derecha', '2024-07-06', 4, 5),
(795, '09:10:00', '10:10:00', 'HCCE', 475, 75, 20.17, 'HIJA DE DELMY NERIO', 1, 'TORAX AP', '2024-07-07', 4, 5),
(796, '14:30:00', '15:30:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Benedicta Jacome', NULL, NULL, '2024-07-07', 4, 6),
(797, '09:10:00', '10:10:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 20.17, 'Hija se Delmy Nerio', NULL, NULL, '2024-07-07', 4, 6),
(798, '07:00:00', '08:00:00', 'X-RADII ', NULL, 21, 20.17, 'Cubriendo a Meli ', NULL, NULL, '2024-07-07', 4, 6),
(799, '07:00:00', '08:00:00', 'X-RADII ', NULL, 21, 20.17, 'Cubriendo a Meli ', NULL, NULL, '2024-07-08', 4, 6),
(800, '16:55:00', '17:30:00', 'Hospital Nazareno ', NULL, 50, 20.17, 'Angel Alvarez ', NULL, NULL, '2024-07-08', 4, 6),
(801, '07:00:00', '08:00:00', 'X-RADII ', NULL, 21, 20.17, 'Cubriendo a Meli ', NULL, NULL, '2024-07-10', 4, 6),
(802, '22:30:00', '23:30:00', 'Siglo 21 ', 475, 75, 20.17, 'Crisostomo Guerra ', 62, 'Tórax ', '2024-07-12', 4, 7),
(803, '21:00:00', '22:00:00', 'Centro clinico de especialidades ', 475, 75, 20.17, 'Darein sola ', 14, 'Rx de rodilla ', '2024-07-12', 4, 7),
(804, '17:30:00', '18:00:00', 'Siglo 21', 475, 75, 20.17, 'Brianda Suchite ', 2, 'Rx de tórax ', '2024-07-12', 4, 7),
(805, '17:00:00', '17:50:00', 'Xradii', 175, 75, 20.17, 'Mishell portela ', 27, 'Rx tórax ap', '2024-07-12', 4, 7),
(806, '22:00:00', '22:30:00', 'Siglo 21', 475, 75, 20.17, 'Sayra elizabeth Garcia Vasquez ', 24, 'Rx de tórax ap/lat', '2024-07-12', 4, 7),
(807, '22:30:00', '23:30:00', 'Siglo 21 ', 475, 75, 20.17, 'Hortencia perez', 68, 'Tórax ap/lateral ', '2024-07-12', 4, 7),
(808, '17:30:00', '18:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Blanca Suchite', NULL, NULL, '2024-07-12', 4, 6),
(809, '18:10:00', '18:55:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Maria Julia Damazo', NULL, NULL, '2024-07-12', 4, 6),
(810, '17:30:00', '18:10:00', 'Siglo 21', 475, 75, 20.17, 'Blanca Suchite', 60, 'Torax ap y lat', '2024-07-12', 4, 5),
(811, '18:10:00', '18:55:00', 'Siglo 21', 475, 75, 20.17, 'Maria Julia Damaso', 84, 'Torax ap y lat', '2024-07-12', 4, 5),
(812, '15:38:00', '16:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Jorge Mario España Lemus', NULL, NULL, '2024-07-13', 4, 6),
(813, '16:10:00', '16:53:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Enma Magaly', NULL, NULL, '2024-07-13', 4, 6),
(814, '15:38:00', '16:10:00', 'Siglo 21', 475, 75, 20.17, 'Jorge mario españa lemus ', 80, 'Rx de rodilla izquierda ', '2024-07-13', 4, 7),
(815, '16:10:00', '16:53:00', 'Siglo 21 ', 475, 75, 20.17, 'Enma magaly Ramos ', 63, 'Rx de rodilla derecha ', '2024-07-13', 4, 7),
(817, '18:24:00', '18:45:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Marilu Martinez ', NULL, NULL, '2024-07-13', 4, 6),
(819, '18:45:00', '19:15:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Angelica Guerra ', NULL, NULL, '2024-07-13', 4, 6),
(820, '19:15:00', '19:54:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Alicia Josefina Chang Perez ', NULL, NULL, '2024-07-13', 4, 6),
(821, '18:24:00', '18:45:00', 'Unidad medica ', 800, 150, 20.17, 'Marylu Martinez ', 64, 'Tórax y cervicales ', '2024-07-14', 4, 7),
(822, '18:14:00', '18:45:00', 'Unidad medica ', 475, 75, 20.17, 'Angelica Guerra ', 67, 'Tórax ap/lateral ', '2024-07-14', 4, 7),
(823, '20:15:00', '21:31:00', 'Hospital Centro Medico Chiquimula ', NULL, 100, 40.34, 'Marlon Morales ', NULL, NULL, '2024-07-15', 4, 6),
(824, '20:15:00', '21:30:00', 'Centro Medico ', 800, 75, 40.34, 'Marlon Morales ', 20, 'Rx de mano DERECHA ', '2024-07-15', 4, 7),
(825, '18:35:00', '19:20:00', 'X-RADII ', NULL, 40, 20.17, 'Fumigacion', NULL, NULL, '2024-07-17', 4, 6),
(826, '17:35:00', '18:25:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Sofia Garcia ', NULL, NULL, '2024-07-17', 4, 6),
(827, '22:30:00', '23:05:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Santos de Maria Ortega ', NULL, NULL, '2024-07-17', 4, 6),
(828, '17:30:00', '18:15:00', 'Unidad Medica ', 475, 75, 20.17, 'Sofia Martinez ', 3, 'Rx d etirax ap /lateral ', '2024-07-18', 4, 7),
(829, '22:30:00', '23:15:00', 'Siglo 21 ', 475, 75, 20.17, 'Santos de maria Ortega ', 83, 'Rx de tórax ap ', '2024-07-18', 4, 7),
(830, '07:20:00', '08:20:00', 'Unidad Medi a ', 475, 75, 20.17, 'Maria perez ', 64, 'Abdomen simple ', '2024-07-18', 4, 7),
(831, '21:04:00', '21:45:00', 'Centro clinico de especialidades', 475, 75, 20.17, 'Rodrigo Gregorio ', 59, 'Rx de abdomen simple ', '2024-07-18', 4, 7),
(832, '07:20:00', '08:15:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Maria Perez ', NULL, NULL, '2024-07-18', 4, 6),
(833, '20:59:00', '21:40:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 20.17, 'Rodrigo Gregorio', NULL, NULL, '2024-07-18', 4, 6),
(834, '19:38:00', '20:20:00', 'SIGLO 21', 475, 75, 20.17, 'Emilio Perez', 76, 'Torax ap y lat', '2024-07-20', 4, 5),
(835, '19:38:00', '20:20:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Emilio Perez', NULL, NULL, '2024-07-20', 4, 6),
(836, '16:30:00', '17:30:00', 'Siglo 21', 475, 75, 20.17, 'Juan jose Lopez', 53, 'Abdomen', '2024-07-21', 4, 5),
(837, '16:35:00', '17:30:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Juan Jose Lopez', NULL, NULL, '2024-07-21', 4, 6),
(838, '05:05:00', '05:45:00', 'Siglo 21', 475, 75, 20.17, 'Hijo de Victor Hernandez', 1, 'Torax ap y Abdomen\n\n( se cobro solo el torax, abdomen es como si se hubiera sacado lat. De torax )', '2024-07-23', 4, 5),
(839, '05:10:00', '05:46:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Victor Hernandez ', NULL, NULL, '2024-07-23', 4, 6),
(840, '20:50:00', '21:30:00', 'Siglo 21', 475, 75, 20.17, 'Jose Serafin', 81, 'Torax ap y lat', '2024-07-25', 4, 5),
(841, '21:30:00', '22:05:00', 'Siglo 21', 475, 75, 20.17, 'Elena Mendez', 76, 'Abdomen ', '2024-07-25', 4, 5),
(842, '20:50:00', '21:35:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Jose Serafin', NULL, NULL, '2024-07-25', 4, 6),
(843, '21:35:00', '22:05:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Elena Mendez Lopez', NULL, NULL, '2024-07-25', 4, 6),
(844, '17:00:00', '19:00:00', 'Centro Medico Zacapa ', NULL, 66, 40.34, 'Mantenimiento Densitometro ', NULL, NULL, '2024-07-28', 4, 6),
(845, '17:00:00', '17:30:00', 'Xradii', 350, 75, 20.17, 'Debora sarai zuquino', 4, 'Craneo ap y lat', '2024-07-30', 4, 5),
(846, '16:20:00', '19:20:00', 'Hospital Siglo 21 Chiquimula ', NULL, 125, 60.51, 'David Omar Escobar ', NULL, NULL, '2024-07-31', 4, 6),
(847, '16:20:00', '19:20:00', 'Siglo 21 ', 1550, 275, 60.51, 'David Omar Escobar ', 29, 'Muñeca izq', '2024-07-31', 4, 7),
(848, '19:33:00', '20:18:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Matias Sebastian Esquivel', NULL, NULL, '2024-08-02', 4, 6),
(849, '06:50:00', '07:30:00', 'siglo 21', 475, 75, 20.17, 'carlos guillen', 81, 'torax ap', '2024-08-04', 4, 5),
(850, '07:30:00', '08:05:00', 'siglo 21', 475, 75, 20.17, 'diana valdez', 4, 'torax ap y lat', '2024-08-04', 4, 5),
(851, '08:15:00', '09:10:00', 'siglo 21', 475, 75, 20.17, 'hijo de andrea ortiz', 1, 'torax y  abdomen\n', '2024-08-04', 4, 5),
(852, '20:15:00', '21:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Hijo de Andrea Ruiz ', NULL, NULL, '2024-08-04', 4, 6),
(853, '06:50:00', '07:30:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Carlos Humberto Guillen', NULL, NULL, '2024-08-04', 4, 6),
(854, '07:30:00', '08:05:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Diana Valdez', NULL, NULL, '2024-08-04', 4, 6),
(855, '17:20:00', '18:20:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Hija de Maria Perez ', NULL, NULL, '2024-08-06', 4, 6),
(856, '17:20:00', '18:20:00', 'Siglo 21', 475, 75, 20.17, 'Hija de maria perez', 1, 'Torax ap', '2024-08-06', 4, 5),
(857, '20:20:00', '21:00:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 20.17, 'Maria Barrientos', NULL, NULL, '2024-08-06', 4, 6),
(858, '20:20:00', '21:00:00', 'Centro medico', 475, 75, 20.17, 'Maria barrientos portillo', 80, 'Torax ap', '2024-08-06', 4, 5),
(859, '21:00:00', '21:50:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 20.17, 'Marta Landaverry', NULL, NULL, '2024-08-06', 4, 6),
(860, '21:00:00', '21:50:00', 'Centro medico', 475, 75, 20.17, 'Marta landaverry', 92, 'Torax ap', '2024-08-06', 4, 5),
(861, '17:20:00', '18:20:00', 'Multimedica', 475, 75, 20.17, 'Hija de Joselinn', 1, 'Torax ap y lat', '2024-08-07', 4, 5),
(862, '05:30:00', '08:00:00', 'Ciudad Capital ', NULL, 125, 60.51, 'Viaje a traer Sonigel ', NULL, NULL, '2024-08-07', 4, 6),
(863, '17:20:00', '18:20:00', 'Hospital Multimedica de Oriente ', NULL, 50, 20.17, 'Hija de Joselin Sandoval ', NULL, NULL, '2024-08-07', 4, 6),
(864, '19:25:00', '20:00:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 20.17, 'Hijo de Evelyn Garcia ', NULL, NULL, '2024-08-08', 4, 6),
(865, '20:00:00', '22:30:00', 'Hospital Siglo 21 Chiquimula ', NULL, 100, 60.51, 'Idania Marisol Alfaro', NULL, NULL, '2024-08-08', 4, 6),
(867, '20:00:00', '22:30:00', 'Siglo 21', 2575, 525, 60.51, 'Idania Alfaro', 38, 'Craneo ap y lat\nCervicales ap y lat\nTorax\nCodo ap y lat\nMano ap y lat\nPelvis \nRodilla ap y lat', '2024-08-08', 4, 5),
(868, '19:25:00', '20:00:00', 'Siglo 21', 475, 75, 20.17, 'Hijo de evelyn garcia', 1, 'Torax ao y lat', '2024-08-08', 4, 5),
(869, '12:37:00', '13:20:00', 'Hospital Centro Medico Chiquimula ', NULL, 50, 20.17, 'Marta Maria Barrientos', NULL, NULL, '2024-08-10', 4, 6),
(870, '13:20:00', '14:08:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Evenecer Pacheco ', NULL, NULL, '2024-08-10', 4, 6),
(871, '14:08:00', '17:00:00', 'Hospital Centro Médico Chiquimula ', NULL, 200, 60.51, 'Sonia Tobar', NULL, NULL, '2024-08-10', 4, 6),
(872, '17:00:00', '18:30:00', 'Hospital Centro Medico Chiquimula ', NULL, 100, 40.34, 'Luis Lemus ', NULL, NULL, '2024-08-10', 4, 6),
(873, '18:30:00', '19:21:00', 'Hospital Nazareno ', NULL, 50, 20.17, 'Herminda Jordan ', NULL, NULL, '2024-08-10', 4, 6),
(874, '19:33:00', '20:18:00', 'Siglo 21', 475, 75, 20.17, 'Matias sebastian ', 8, 'Rx de abdomen ', '2024-08-11', 4, 7),
(875, '12:37:00', '13:20:00', 'Centro Medico ', 475, 75, 20.17, 'Marta Barrientos ', 80, 'Rx de tórax ', '2024-08-11', 4, 7),
(876, '12:20:00', '14:08:00', 'Siglo 21', 1125, 225, 40.34, 'Evenecer Pacheco', 24, 'Rx de hombro derecho , hombro izquierdo , humero derecho ', '2024-08-11', 4, 7),
(877, '14:08:00', '17:00:00', 'Centro Medico ', 2200, 400, 60.51, 'Sonia Tobar ', 72, 'Rx de cirugía cadera ', '2024-08-11', 4, 7),
(879, '18:30:00', '19:21:00', 'Nazareno ', 475, 75, 20.17, 'Herminda Ester Jordan ', 69, 'Rx de tórax ', '2024-08-11', 4, 7),
(880, '17:00:00', '18:30:00', 'Centro Medico ', 1200, 200, 40.34, 'Luis Lemus ', 37, 'Cirugia de tobillo ', '2024-08-11', 4, 7),
(881, '08:30:00', '09:15:00', 'Clinica Xradi', 350, 75, 20.17, 'Saide Diaz ', 67, 'Rx de tórax ', '2024-08-11', 4, 7),
(882, '09:30:00', '10:00:00', 'Siglo 21 ', 475, 75, 20.17, 'Derick omar Omar Lopez Cruz ', 12, 'Rx tórax ap/lateral ', '2024-08-11', 4, 7),
(883, '10:05:00', '10:40:00', 'Siglo 21 ', 475, 75, 20.17, 'Hijo de Eliza Garcia ', 1, 'Rx de tórax ap ', '2024-08-11', 4, 7),
(884, '16:30:00', '17:25:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Maria Luisa Aguirre', NULL, NULL, '2024-08-11', 4, 6),
(885, '16:30:00', '17:25:00', 'Siglo 21 ', 475, 75, 20.17, 'Maria Luisa ', 82, 'Rx de tórax ', '2024-08-11', 4, 7);
INSERT INTO `emergencia` (`id`, `inicio`, `fin`, `direccion`, `precio`, `honorarios`, `hora_extra`, `paciente`, `edad`, `estudios`, `fecha`, `f_estado`, `f_usuario`) VALUES
(886, '22:00:00', '22:45:00', 'Siglo 21', 475, 75, 20.17, 'Matias omar  esquivel ', 9, 'Rx de abdomen', '2024-08-11', 4, 7),
(887, '22:00:00', '22:45:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Matias Esquivel ', NULL, NULL, '2024-08-12', 4, 6),
(888, '16:50:00', '17:45:00', 'X-RADII ', NULL, 40, 20.17, 'Fumigacion en X-RADII ', NULL, NULL, '2024-08-14', 4, 6),
(889, '17:45:00', '18:35:00', 'Hospital Centro Clínico Chiquimula ', NULL, 50, 20.17, 'Rosalbina Perez ', NULL, NULL, '2024-08-14', 4, 6),
(890, '18:35:00', '19:35:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Maria Guerra ', NULL, NULL, '2024-08-14', 4, 6),
(891, '12:30:00', '14:00:00', 'Hospital Nacional Chiquimula ', NULL, 50, 40.34, 'Hija de Elisa Garcia ', NULL, NULL, '2024-08-16', 4, 6),
(892, '15:55:00', '16:40:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Mercedes Osorio', NULL, NULL, '2024-08-17', 4, 6),
(893, '12:00:00', '12:55:00', 'Hospital Memorial Chiquimula ', NULL, 50, 20.17, 'Fidel Villanueva', NULL, NULL, '2024-08-20', 4, 6),
(894, '19:28:00', '20:15:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'H/ Cristina Sanchez ', NULL, NULL, '2024-08-20', 4, 6),
(895, '17:15:00', '18:05:00', 'Hospital Casa de Salud Chiquimula ', NULL, 50, 20.17, 'Rubila Roque', NULL, NULL, '2024-08-23', 4, 6),
(898, '14:00:00', '14:57:00', 'Hospital Memorial Chiquimula ', NULL, 50, 20.17, 'Ronal Garcia ', NULL, NULL, '2024-08-24', 4, 6),
(899, '18:50:00', '20:40:00', 'Hospital Centro Medico Chiquimula ', NULL, 100, 40.34, 'Byron Rene Lopez Lopez ', NULL, NULL, '2024-08-24', 4, 6),
(900, '17:45:00', '18:35:00', 'Centro Clinico ', 475, 75, 20.17, 'ROSALBINA PEREZ ', 72, 'Rx de tórax ', '2024-08-25', 4, 7),
(901, '18:35:00', '19:34:00', 'Siglo 21 ', 475, 75, 20.17, 'Maria Guerra ', 60, 'Rx de tórax ', '2024-08-25', 4, 7),
(902, '15:55:00', '16:40:00', 'Hospital Nacional ', 475, 75, 20.17, 'Hijo de eliza Garcia ', 0, 'Rx tórax ', '2024-08-25', 4, 7),
(903, '15:56:00', '17:40:00', 'Siglo 21', 475, 75, 40.34, 'Mercedes Osorio ', 0, 'Tórax ap ', '2024-08-25', 4, 7),
(904, '20:21:00', '21:01:00', 'Hospital Multimedica de Oriente Chiquimula ', NULL, 50, 20.17, 'Cristofer Javier', NULL, NULL, '2024-08-29', 3, 6),
(905, '07:00:00', '08:00:00', 'X-RADII Chiquimula ', NULL, 40, 20.17, 'Cubriendo a Meli ', NULL, NULL, '2024-08-30', 2, 6),
(906, '17:55:00', '18:54:00', 'Hospital Unidad Médica Chiquimula ', NULL, 50, 20.17, 'Adan Alberto Monroy Urrutia', NULL, NULL, '2024-08-30', 3, 6),
(907, '12:00:00', '13:00:00', 'X-RADII ', NULL, NULL, 20.17, 'Mantenimiento ', NULL, NULL, '2024-08-31', 1, 6),
(908, '17:55:00', '18:56:00', 'Hospital Centro Clínico ', NULL, 50, 40.34, 'Lisbeth Pineda ', NULL, NULL, '2024-09-02', 3, 6),
(909, '17:00:00', '18:45:00', 'X-RADII ', NULL, NULL, 40.34, 'Mantenimiento de la mesa de rayos x ', NULL, NULL, '2024-09-02', 1, 6),
(910, '18:45:00', '19:25:00', 'Hospital Nazareno Chiquimula ', NULL, 50, 20.17, 'Marina Mateo Molina', NULL, NULL, '2024-09-02', 3, 6),
(911, '19:10:00', '20:10:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Keily Lemus ', NULL, NULL, '2024-09-03', 3, 6),
(912, '19:10:00', '20:10:00', 'Siglo 21', 475, 75, 20.17, 'Keily lemus', 22, 'Craneo ap y lat', '2024-09-03', 2, 5),
(914, '05:20:00', '06:20:00', 'HNCH', 400, 75, 20.17, 'MARIAN NERIO', 1, 'TORAX AP', '2024-09-04', 2, 5),
(915, '17:20:00', '18:20:00', 'Hospital Nacional Chiquimula ', NULL, 50, 20.17, 'Marian Victoria Nerio', NULL, NULL, '2024-09-04', 2, 6),
(916, '20:45:00', '21:25:00', 'Siglo 21', 475, 75, 20.17, 'Mayra Martinez', 3, 'Abdomen', '2024-09-04', 2, 5),
(917, '20:45:00', '21:25:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Mayra Martinez ', NULL, NULL, '2024-09-04', 2, 6),
(918, '19:45:00', '20:35:00', 'Siglo 21', 475, 75, 20.17, 'Sara Lemus', 69, 'Abdomen', '2024-09-05', 2, 5),
(919, '19:45:00', '20:35:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 20.17, 'Sara de Maria Lemus ', NULL, NULL, '2024-09-05', 2, 6),
(920, '13:41:00', '14:45:00', 'Hospital Siglo 21 Chiquimula ', NULL, 50, 40.34, 'Martin Polanco ', NULL, NULL, '2024-09-07', 2, 6),
(921, '18:52:00', '19:40:00', 'Hospital Nacional Chiquimula ', NULL, 50, 20.17, 'Fredy Perez ', NULL, NULL, '2024-09-09', 2, 6),
(922, '17:00:00', '18:46:00', 'X-RADII Chiquimula ', NULL, NULL, 40.34, 'Mantenimiento impresora', NULL, NULL, '2024-09-09', 1, 6),
(923, '17:00:00', '17:40:00', 'Hospital Nacional Chiquimula ', NULL, 50, 20.17, 'Yuri Hernandez ', NULL, NULL, '2024-09-10', 2, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado`
--

CREATE TABLE `estado` (
  `id` int(11) NOT NULL,
  `nombre_estado` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `estado`
--

INSERT INTO `estado` (`id`, `nombre_estado`) VALUES
(1, 'Incompleta'),
(2, 'Ingresada'),
(3, 'Revisada'),
(4, 'Aprobada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `imagen`
--

CREATE TABLE `imagen` (
  `id` int(11) NOT NULL,
  `ruta` varchar(150) NOT NULL,
  `f_emergencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `imagen`
--

INSERT INTO `imagen` (`id`, `ruta`, `f_emergencia`) VALUES
(9, 'E13_U7_1.2.156.112677.1000.301.20230107151952.4_032935.JPG', 13),
(10, 'E13_U7_1.2.156.112677.1000.301.20230107151952.5_032940.JPG', 13),
(11, 'E14_U7_2301081234470734_florinda_Lemus_01-08-2023 12_53_16_1-2_010211.jpg', 14),
(12, 'E14_U7_2301081234470734_florinda_Lemus_01-08-2023 12_43_25_1-1_010220.jpg', 14),
(13, 'E19_U7_IMG_20230111_173110.jpg', 19),
(14, 'E19_U7_IMG_20230111_173124.jpg', 19),
(15, 'E32_U7_2301211528540433_Joel_Acevedo Najera_01-21-2023 15_39_34_1-3_034356.jpg', 32),
(16, 'E32_U7_2301211528540433_Joel_Acevedo Najera_01-21-2023 15_35_53_1-2_034355.jpg', 32),
(17, 'E32_U7_2301211528540433_Joel_Acevedo Najera_01-21-2023 15_31_53_1-1_034346.jpg', 32),
(18, 'E34_U7_IMG_20230124_173413.jpg', 34),
(19, 'E36_U7_IMG_20230123_195503.jpg', 36),
(20, 'E36_U7_IMG_20230123_195420.jpg', 36),
(23, 'E39_U7_1.2.156.112677.1000.301.20230126183750.5_064306.JPG', 39),
(24, 'E39_U7_1.2.156.112677.1000.301.20230126183751.6_064304.JPG', 39),
(27, 'E42_U5_E2773640-CBD2-4AE6-B85A-FE4C0E8A3913.jpeg', 42),
(28, 'E42_U5_B2D5D1DD-710E-4659-B016-33E41D870057.jpeg', 42),
(29, 'E42_U5_2A710E13-AFFF-476F-A197-0FE2FD849310.jpeg', 42),
(30, 'E51_U7_IMG_20230205_143618.jpg', 51),
(31, 'E52_U7_1.2.156.112677.1000.301.20230207183105.142_063459.JPG', 52),
(32, 'E52_U7_1.2.156.112677.1000.301.20230207182756.137_063508.JPG', 52),
(33, 'E52_U7_1.2.156.112677.1000.301.20230207182347.132_063520.JPG', 52),
(34, 'E65_U7_IMG_20230219_231057.jpg', 65),
(35, 'E65_U7_IMG_20230219_231158.jpg', 65),
(36, 'E65_U7_2302192225040463_Harrdys_Paredes_02-19-2023 22_39_44_1-2_105552.jpg', 65),
(37, 'E65_U7_2302192225040463_Harrdys_Paredes_02-19-2023 22_29_00_1-1_105535.jpg', 65),
(38, 'E66_U7_1.2.156.112677.1000.301.20230220190529.14_071244.JPG', 66),
(39, 'E66_U7_1.2.156.112677.1000.301.20230220190529.13_071240.JPG', 66),
(40, 'E66_U7_1.2.156.112677.1000.301.20230220185303.4_071219.JPG', 66),
(41, 'E66_U7_1.2.156.112677.1000.301.20230220185612.9_071210.JPG', 66),
(42, 'E68_U7_IMG_20230220_194955.jpg', 68),
(43, 'E68_U7_IMG_20230220_195013.jpg', 68),
(44, 'E70_U7_1.2.156.112677.1000.301.20230221192006.9_072626.JPG', 70),
(45, 'E70_U7_1.2.156.112677.1000.301.20230221191652.7_072632.JPG', 70),
(46, 'E72_U7_IMG_20230223_223848.jpg', 72),
(47, 'E72_U7_IMG_20230223_223904.jpg', 72),
(48, 'E77_U7_2302091909400760___02-09-2023 19_39_27_1-4_081053.jpg', 77),
(49, 'E77_U7_2302091909400760___02-09-2023 19_20_53_1-1_081051.jpg', 77),
(50, 'E77_U7_2302091909400760___02-09-2023 19_46_10_1-3_081046.jpg', 77),
(51, 'E77_U7_2302091909400760___02-09-2023 19_37_37_1-2_081052.jpg', 77),
(52, 'E82_U7_IMG_20230304_124730.jpg', 82),
(53, 'E82_U7_2303041208050753_Presentacion__03-04-2023 12_22_28_1-4_122723.jpg', 82),
(54, 'E82_U7_IMG_20230304_124715.jpg', 82),
(55, 'E94_U7_2303180806080657_Jose_Fuerra Manchame_03-18-2023 08_09_43_1-1 (2)_091755.jpg', 94),
(56, 'E97_U7_2303191421330163_Yasmin_Polaco_03-19-2023 14_30_56_1-1_024841.jpg', 97),
(57, 'E99_U7_1.2.156.112677.1000.301.20230320191826.4_073317.JPG', 99),
(58, 'E99_U7_1.2.156.112677.1000.301.20230320192718.7_073232.JPG', 99),
(59, 'E100_U7_1.2.156.112677.1000.301.20230322183735.5_064209.JPG', 100),
(60, 'E100_U7_1.2.156.112677.1000.301.20230322183942.9_064221.JPG', 100),
(61, 'E101_U7_1.2.156.112677.1000.301.20230324182515.7_063832.JPG', 101),
(62, 'E101_U7_1.2.156.112677.1000.301.20230324182515.5_063833.JPG', 101),
(63, 'E101_U7_1.2.156.112677.1000.301.20230324183026.9_063830.JPG', 101),
(64, 'E101_U7_1.2.156.112677.1000.301.20230324183205.12_063821.JPG', 101),
(65, 'E106_U7_IMG-20230401-WA0033.jpg', 106),
(66, 'E106_U7_IMG-20230401-WA0034.jpg', 106),
(67, 'E107_U7_IMG_20230403_173320.jpg', 107),
(68, 'E108_U7_1.2.156.112677.1000.301.20230403185127.5_065446.JPG', 108),
(69, 'E108_U7_1.2.156.112677.1000.301.20230403185259.9_065506.JPG', 108),
(70, 'E112_U7_1.2.156.112677.1000.301.20230405155918.9_040416.JPG', 112),
(71, 'E112_U7_1.2.156.112677.1000.301.20230405155105.5_040409.JPG', 112),
(72, 'E113_U7_2304052316490812_Francisco_Lopez Ramirez_04-05-2023 23_22_52_1-1_112658.jpg', 113),
(73, 'E116_U7_IMG_20230406_102248.jpg', 116),
(74, 'E116_U7_IMG_20230406_102232.jpg', 116),
(75, 'E125_U7_IMG-20230416-WA0011.jpg', 125),
(76, 'E126_U7_2304162053130887_Kristhal_Osorio_04-16-2023 21_00_20_1-2_090340.jpg', 126),
(77, 'E126_U7_2304162053130887_Kristhal_Osorio_04-16-2023 20_59_22_1-1_090333.jpg', 126),
(78, 'E128_U7_1.2.156.112677.1000.301.20230419174052.4_060541.JPG', 128),
(79, 'E130_U7_1.2.156.112677.1000.301.20230421183118.14_063504.JPG', 130),
(80, 'E130_U7_1.2.156.112677.1000.301.20230421182513.5_063453.JPG', 130),
(81, 'E130_U7_1.2.156.112677.1000.301.20230421182713.10_063518.JPG', 130),
(82, 'E132_U7_2304212142540253_Rudy_Guerra vasquez_04-21-2023 21_59_15_1-4_101453.jpg', 132),
(83, 'E132_U7_2304212142540253_Rudy_Guerra vasquez_04-21-2023 22_04_04_1-5_101455.jpg', 132),
(84, 'E132_U7_2304212142540253_Rudy_Guerra vasquez_04-21-2023 21_56_25_1-1_101442.jpg', 132),
(85, 'E135_U7_2304212234080255_David_Martinez_04-21-2023 22_47_08_1-2 (1)_105305.jpg', 135),
(86, 'E135_U7_2304212234080255_David_Martinez_04-21-2023 22_46_39_1-1 (1)_105300.jpg', 135),
(87, 'E145_U7_2305011114140966_Blanca_Interino_05-01-2023 11_21_54_1-2 (1)_112640.jpg', 145),
(88, 'E145_U7_2305011114140966_Blanca_Interino_05-01-2023 11_19_43_1-3_112645.jpg', 145),
(89, 'E145_U7_2305011114140966_Blanca_Interino_05-01-2023 11_21_54_1-2 (1)_112640.jpg', 145),
(90, 'E145_U7_2305011114140966_Blanca_Interino_05-01-2023 11_19_43_1-3_112645.jpg', 145),
(91, 'E146_U7_2305011220500665_Jose_Rosa_05-01-2023 12_28_03_1-2_123150.jpg', 146),
(92, 'E146_U7_2305011220500665_Jose_Rosa_05-01-2023 12_24_33_1-1_123141.jpg', 146),
(93, 'E150_U7_1.2.156.112677.1000.301.20230501180738.4_061421.JPG', 150),
(94, 'E150_U7_1.2.156.112677.1000.301.20230501180738.5_061418.JPG', 150),
(95, 'E151_U7_IMG_20230504_191529.jpg', 151),
(96, 'E151_U7_2305041854220202_Abigail_Aldana_05-04-2023 19_06_42_1-3_071115.jpg', 151),
(97, 'E155_U7_2305051721170304_Jose_Sintuj_05-05-2023 17_23_27_1-1_052516.jpg', 155),
(98, 'E156_U7_2305051745580340_Maria_Mendoza_05-05-2023 17_51_29_1-1_055754.jpg', 156),
(99, 'E156_U7_2305051745580340_Maria_Mendoza_05-05-2023 17_54_28_1-2_055807.jpg', 156),
(100, 'E170_U7_IMG-20230514-WA0020.jpg', 170),
(101, 'E170_U7_IMG-20230514-WA0022.jpg', 170),
(102, 'E172_U7_IMG_20230515_185604.jpg', 172),
(103, 'E172_U7_IMG_20230515_185628.jpg', 172),
(104, 'E173_U7_1.2.156.112677.1000.301.20230516183714.7_063854.JPG', 173),
(105, 'E173_U7_1.2.156.112677.1000.301.20230516183713.5_063900.JPG', 173),
(106, 'E174_U7_IMG_20230516_221447.jpg', 174),
(107, 'E182_U7_IMG_20230527_123046.jpg', 182),
(108, 'E182_U7_2305271205260473_Virginia_Felipe_05-27-2023 12_12_38_1-2_122944.jpg', 182),
(109, 'E183_U7_1.2.156.112677.1000.301.20230527130639.9_011826.JPG', 183),
(110, 'E183_U7_1.2.156.112677.1000.301.20230527130457.7_011822.JPG', 183),
(111, 'E184_U7_2305271623380796_Marta_Diaz Calderon_05-27-2023 16_30_40_1-2_043722.jpg', 184),
(112, 'E184_U7_2305271623380796_Marta_Diaz Calderon_05-27-2023 16_33_16_1-3_043732.jpg', 184),
(113, 'E187_U7_2305291955530879_Rosa_Cardona_05-29-2023 20_07_49_1-4_081209.jpg', 187),
(114, 'E187_U7_2305291955530879_Rosa_Cardona_05-29-2023 20_02_49_1-2_081150.jpg', 187),
(115, 'E200_U7_IMG_20230617_225453.jpg', 200),
(116, 'E213_U7_IMG_20230624_170840.jpg', 213),
(117, 'E216_U7_1.2.156.112677.1000.301.20230626190213.5_071151.JPG', 216),
(118, 'E216_U7_1.2.156.112677.1000.301.20230626190213.4_071208.JPG', 216),
(119, 'E217_U7_1.2.156.112677.1000.301.20230628174200.9_055839.JPG', 217),
(120, 'E217_U7_1.2.156.112677.1000.301.20230628174200.10_055851.JPG', 217),
(121, 'E219_U7_IMG_20230702_103402.jpg', 219),
(122, 'E223_U7_IMG-20230706-WA0047.jpg', 223),
(123, 'E233_U7_IMG-20230708-WA0031.jpg', 233),
(124, 'E234_U7_IMG-20230708-WA0037.jpg', 234),
(125, 'E235_U7_2307081433250379_Marian_De Duarte_07-08-2023 14_37_15_1-1_024242.jpg', 235),
(126, 'E259_U7_IMG_20230724_171717.jpg', 259),
(127, 'E259_U7_IMG_20230724_171732.jpg', 259),
(128, 'E263_U7_1.2.156.112677.1000.301.20230727171946.5_052321.JPG', 263),
(129, 'E263_U7_1.2.156.112677.1000.301.20230727171946.4_052313.JPG', 263),
(130, 'E282_U7_2308071656070633_Jorge_Milian_08-07-2023 17_02_55_1-3_050708.jpg', 282),
(131, 'E282_U7_2308071656070633_Jorge_Milian_08-07-2023 17_01_24_1-2_050703.jpg', 282),
(132, 'E283_U7_IMG_20230807_175115.jpg', 283),
(133, 'E283_U7_2308071737270510_Maria_Lemus_08-07-2023 17_48_11_1-3_055030.jpg', 283),
(134, 'E286_U7_1.2.156.112677.1000.301.20230807182550.4_062552.JPG', 286),
(135, 'E289_U7_IMG_20230808_211350.jpg', 289),
(136, 'E290_U7_IMG_20230808_211336.jpg', 290),
(137, 'E290_U7_2308082054240860_Kimberly_Franco_08-08-2023 21_06_38_1-6_090819.jpg', 290),
(138, 'E290_U7_2308082054240860_Kimberly_Franco_08-08-2023 20_58_16_1-4_090810.jpg', 290),
(139, 'E291_U7_IMG-20230810-WA0084.jpg', 291),
(140, 'E310_U7_ROMERO^WILLIAM^RENE1.2.156.112677.1000.301.20230820201944.5_082400.JPG', 310),
(141, 'E310_U7_ROMERO^WILLIAM^RENE1.2.156.112677.1000.301.20230820201944.4_082414.JPG', 310),
(142, 'E346_U5_image.jpg', 346),
(143, 'E373_U7_IMG-20231002-WA0000.jpg', 373),
(144, 'E377_U7_2310041728510788_Perrito_Perrito_10-04-2023 17_30_45_1-1_053139.jpg', 377),
(145, 'E377_U7_2310041734150051_Perrito_Perrito 2_10-04-2023 17_42_42_1-3_054330.jpg', 377),
(146, 'E410_U7_IMG-20231029-WA0005.jpg', 410),
(147, 'E410_U7_IMG-20231029-WA0003.jpg', 410),
(148, 'E410_U7_IMG-20231029-WA0004.jpg', 410),
(149, 'E463_U7_2312222040050378_Hija de Dulce_Guancing_12-22-2023 20_44_36_1-1.jpg', 463),
(150, 'E503_U7_2401271551120124_Aura_Ortega_01-27-2024 16_15_44_1-2.jpg', 503),
(151, 'E504_U7_2401272113510791_Evangelista_Aldana_01-27-2024 21_29_25_1-3.jpg', 504),
(152, 'E504_U7_2401272113510791_Evangelista_Aldana_01-27-2024 21_31_49_1-2.jpg', 504);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id` int(11) NOT NULL,
  `nombre_rol` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id`, `nombre_rol`) VALUES
(1, 'Técnico de Rayos X\nnivel I'),
(2, 'Administrador'),
(3, 'Radiólogo'),
(4, 'Laborante de mantenimiento'),
(5, 'admin'),
(6, 'Gerente General'),
(7, 'Director General'),
(8, 'Asistente de radiología'),
(9, 'Asistente Administrativo II'),
(10, 'Técnico de Rayos X nivel II'),
(11, 'Secretaria recepcionista'),
(12, 'Conserje'),
(13, 'Asistente de Técnico de Rayos X'),
(14, 'Coordinadora de Recursos Humanos'),
(15, 'Contador General '),
(16, 'Supervisor Operativo y Soporte Técnico');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombres` varchar(60) NOT NULL,
  `apellidos` varchar(60) NOT NULL,
  `username` varchar(20) NOT NULL,
  `correo` varchar(70) NOT NULL,
  `pass` varchar(200) NOT NULL,
  `autorizacion` tinyint(1) NOT NULL,
  `F_rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombres`, `apellidos`, `username`, `correo`, `pass`, `autorizacion`, `F_rol`) VALUES
(1, 'Elder Armando', 'Morales Solís', 'elder', 'elder.morales@x-radii.com', '$2y$10$NOUYLQ5knBxAXUbPUufXvOc5l1BtJsE9cYbkHta8Nhd5Bb/KKp.gi', 1, 5),
(2, 'Melanee', 'Luango', 'melanee', 'melanee.luango@x-radii.com', '$2y$10$YBnwkravpBK26Dh9Njnx0.WyHOC/J4qDGMQaHC4HXiLQpB1.81.kW', 1, 2),
(4, 'Sandra Jeannette', 'Morales Villeda', 'sandra23', 'sandra.morales@x-radii.com', '$2y$10$DvpD2FpmzJgqP5qBsyosqOtONmkCub.as.BzXUqHNO7qAW4iw/pq.', 0, 2),
(5, 'Wilda Aracely', 'Lemus Paiz', 'wilda lemus', 'lwildaaracely@yahoo.com', '$2y$10$CjQgBRBNWudG3YeLR8ilbeHvQoeWP8vwXDVJwSzovEBl/yx20f7m2', 1, 1),
(6, 'Elmer  Adonai', 'Alvarado Zacarias', 'elmer08', 'elmeralvarado059@gmail.com', '$2y$10$YB4C.8JtF8mRPQpxSiIKYO4/6cljtIkwz0BN9DWYs8KuiXNfj7sDG', 1, 4),
(7, 'Skarleth Hernandez ', 'Hernandez Cetino ', 'skarr ', 'skarlinda1@hotmail.com ', '$2y$10$g02HBIAwNEXZeWCMT1u/L.Hg8bAY.t9ip6t/z1lQFttgFcupWBb2S', 1, 1),
(8, 'Melvy Marysol', 'Hernández Cabrera', 'marysol', 'marysol.hernandez@x-radii.com', '$2y$10$VjOkkFB.cQAKguMwJSX3w.YsGvojkg6QCZtH2lI3ZmoZZ.HjH.YUy', 1, 6),
(9, 'Prueba', 'Prueba', 'prueba', 'prueba@gmail.com', '$2y$10$p7UvXbwGwnenNwF3G8BNWeZ0U0bBJuOpsHZtUNk9llrwjQ7hmVzv2', 1, 5),
(10, 'Tecnico', 'Prueba', 'tecnico', 'tecnico@gmail.com', '$2y$10$Co8WGJHC5ElN7jnKuqRs8uvPOf1hdseuhmMNlwU0XT7ABGpn7GjO2', 1, 1),
(11, 'Piloto', 'Prueba', 'piloto', 'piloto@gmail.com', '$2y$10$o8KjcOtPfW/8rWLgonvyAujbYe8Sxr9qTZpyOO/dZb8DOPoL8DJ6u', 1, 4);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `codigo_update_pass`
--
ALTER TABLE `codigo_update_pass`
  ADD PRIMARY KEY (`id`),
  ADD KEY `codigo_update_pass-usuarios` (`F_idusuario`);

--
-- Indices de la tabla `comentario`
--
ALTER TABLE `comentario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `comentario-usuarios` (`f_usuario`),
  ADD KEY `comentario-emergencia` (`f_emergencia`);

--
-- Indices de la tabla `datos`
--
ALTER TABLE `datos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `datos_rol` (`rol`);

--
-- Indices de la tabla `emergencia`
--
ALTER TABLE `emergencia`
  ADD PRIMARY KEY (`id`),
  ADD KEY `emergencia-usuario` (`f_usuario`),
  ADD KEY `emergencia-estado` (`f_estado`);

--
-- Indices de la tabla `estado`
--
ALTER TABLE `estado`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `imagen`
--
ALTER TABLE `imagen`
  ADD PRIMARY KEY (`id`),
  ADD KEY `imagen-emergencia` (`f_emergencia`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuarios-rol` (`F_rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `codigo_update_pass`
--
ALTER TABLE `codigo_update_pass`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `comentario`
--
ALTER TABLE `comentario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=889;

--
-- AUTO_INCREMENT de la tabla `datos`
--
ALTER TABLE `datos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `emergencia`
--
ALTER TABLE `emergencia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=924;

--
-- AUTO_INCREMENT de la tabla `estado`
--
ALTER TABLE `estado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `imagen`
--
ALTER TABLE `imagen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=153;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `codigo_update_pass`
--
ALTER TABLE `codigo_update_pass`
  ADD CONSTRAINT `codigo_update_pass-usuarios` FOREIGN KEY (`F_idusuario`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `comentario`
--
ALTER TABLE `comentario`
  ADD CONSTRAINT `comentario-emergencia` FOREIGN KEY (`f_emergencia`) REFERENCES `emergencia` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `comentario-usuarios` FOREIGN KEY (`f_usuario`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `datos`
--
ALTER TABLE `datos`
  ADD CONSTRAINT `datos_rol` FOREIGN KEY (`rol`) REFERENCES `rol` (`id`);

--
-- Filtros para la tabla `emergencia`
--
ALTER TABLE `emergencia`
  ADD CONSTRAINT `emergencia-estado` FOREIGN KEY (`f_estado`) REFERENCES `estado` (`id`),
  ADD CONSTRAINT `emergencia-usuario` FOREIGN KEY (`f_usuario`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `imagen`
--
ALTER TABLE `imagen`
  ADD CONSTRAINT `imagen-emergencia` FOREIGN KEY (`f_emergencia`) REFERENCES `emergencia` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios-rol` FOREIGN KEY (`F_rol`) REFERENCES `rol` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
