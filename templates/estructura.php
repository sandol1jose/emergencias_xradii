

<div class="grid-container">
    <div class="item1" id="item1">
        <div class="Logo">
            <img src="../imagenes/Logo Largo Blanco.png" alt="">
        </div>

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
    </div>

    <div class="item2" id="item2">
        <!--<div class="btn_Menu" id="btn_Menu">
            <button>Menu</button>
        </div>-->
        <span>
            <?php if(isset($Titulo)) echo $Titulo ?>
        </span>
    </div>

    <div class="item3" id="item3">