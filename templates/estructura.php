<?php
$RolUsuario = $_SESSION['Usuario']['Rol'];
?>

<div class="Menu" id="Menu">
    <div class="menus" id="menus">
            <div class="Logo">
                <img src="../imagenes/Logo Largo Blanco.png" alt="">
                <div class="btnx"><button class="btn_close" id="btn_close"></button></div>
            </div>


            <?php if($RolUsuario == 1 || $RolUsuario == 4){ //Para tecnicos y piloto ?>

                <div class="Botones">
                    <a href="../Cuenta/index.php">
                        <div class="Vinculo">
                            <img src="../imagenes/dashicons_admin-home.png" alt="">
                            Inicio
                        </div>
                    </a>
                    
                    <a href="../Cuenta/Historial.php">
                        
                        <div class="Vinculo">
                            <img src="../imagenes/fa-solid_history.png" alt="">    
                            Historial
                        </div>
                    </a>

                    <a href="../Cuenta/LogOut.php">
                        <div class="Vinculo">
                            <img src="../imagenes/exit.png" alt="">
                            Cerrar Cesión
                        </div>
                    </a>
                </div>

            <?php }else if($RolUsuario == 2){//Para administrador ?>

                <div class="Botones">
                    <a href="../Cuenta/Tecnicos.php">
                        <div class="Vinculo">
                            <img src="../imagenes/dashicons_admin-home.png" alt="">
                            Inicio
                        </div>
                    </a>
                    
                    <a href="../Cuenta/Historial.php">
                        <div class="Vinculo">
                            <img src="../imagenes/fa-solid_history.png" alt="">    
                            Historial
                        </div>
                    </a>

                    <a href="../Cuenta/LogOut.php">
                        <div class="Vinculo">
                            <img src="../imagenes/exit.png" alt="">
                            Cerrar Cesión
                        </div>
                    </a>
                </div>

            <?php }else if($RolUsuario == 5){//Para admin  ?>

                <div class="Botones">
                    <a href="../Cuenta/Tecnicos.php">
                        <div class="Vinculo">
                            <img src="../imagenes/dashicons_admin-home.png" alt="">
                            Inicio
                        </div>
                    </a>
                    
                    <a href="../Cuenta/Historial.php">
                        
                        <div class="Vinculo">
                            <img src="../imagenes/fa-solid_history.png" alt="">    
                            Historial
                        </div>
                    </a>

                    <a href="../Cuenta/Configuracion.php">
                        <div class="Vinculo">
                            <img src="../imagenes/icon-park_setting-config.png" alt="">    
                            Configuración
                        </div>
                    </a>

                    <a href="../Cuenta/LogOut.php">
                        <div class="Vinculo">
                            <img src="../imagenes/exit.png" alt="">
                            Cerrar Cesión
                        </div>
                    </a>
                </div>

            <?php } ?>
    </div>
</div>

<div class="grid-container">
    <div class="item1" id="item1">
        <div class="Logo">
            <img src="../imagenes/Logo Largo Blanco.png" alt="">
            <div class="btnx"><button class="btn_close" id="btn_close"></button></div>
        </div>


        <?php if($RolUsuario == 1 || $RolUsuario == 4){ //Para tecnicos y piloto ?>

        <div class="Botones">
            <a href="../Cuenta/index.php">
                <div class="Vinculo">
                    <img src="../imagenes/dashicons_admin-home.png" alt="">
                    Inicio
                </div>
            </a>
            
            <a href="../Cuenta/Historial.php">
                
                <div class="Vinculo">
                    <img src="../imagenes/fa-solid_history.png" alt="">    
                    Historial
                </div>
            </a>

            <a href="../Cuenta/LogOut.php">
                <div class="Vinculo">
                    <img src="../imagenes/exit.png" alt="">
                    Cerrar Cesión
                </div>
            </a>
        </div>

        <?php }else if($RolUsuario == 2){//Para administrador ?>

        <div class="Botones">
            <a href="../Cuenta/Tecnicos.php">
                <div class="Vinculo">
                    <img src="../imagenes/dashicons_admin-home.png" alt="">
                    Inicio
                </div>
            </a>
            
            <a href="../Cuenta/Historial.php">
                <div class="Vinculo">
                    <img src="../imagenes/fa-solid_history.png" alt="">    
                    Historial
                </div>
            </a>

            <a href="../Cuenta/LogOut.php">
                <div class="Vinculo">
                    <img src="../imagenes/exit.png" alt="">
                    Cerrar Cesión
                </div>
            </a>
        </div>

    <?php }else if($RolUsuario == 5){//Para admin  ?>

        <div class="Botones">
            <a href="../Cuenta/Tecnicos.php">
                <div class="Vinculo">
                    <img src="../imagenes/dashicons_admin-home.png" alt="">
                    Inicio
                </div>
            </a>
            
            <a href="../Cuenta/Historial.php">
                
                <div class="Vinculo">
                    <img src="../imagenes/fa-solid_history.png" alt="">    
                    Historial
                </div>
            </a>

            <a href="../Cuenta/Configuracion.php">
                <div class="Vinculo">
                    <img src="../imagenes/icon-park_setting-config.png" alt="">    
                    Configuración
                </div>
            </a>

            <a href="../Cuenta/LogOut.php">
                <div class="Vinculo">
                    <img src="../imagenes/exit.png" alt="">
                    Cerrar Cesión
                </div>
            </a>
        </div>

    <?php } ?>


    </div>

    <div class="item2" id="item2">
        <div class="btn_Menu" id="btn_Menu">
            <button></button>
        </div>
        <span>
            <?php if(isset($Titulo)) echo $Titulo ?>
        </span>
    </div>

    <div class="item3" id="item3">


<script>
    const btn = document.querySelector('.btn_Menu')
    btn.addEventListener('click', () => {
        const menu = document.querySelector('.Menu')
        menu.classList.remove('ocultar')
        setTimeout(() => menu.classList.add('mostrar'), 5)
    })

    const btn_close = document.querySelector('.btn_close')
    btn_close.addEventListener('click', () => {
        const menu = document.querySelector('.Menu')
        menu.classList.add('ocultar')
        menu.classList.remove('mostrar')
    })
</script>