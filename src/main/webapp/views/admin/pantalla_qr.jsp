<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Punto de Asistencia QR</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />

    <script type="importmap">
      {
        "imports": {
          "@material/web/": "https://esm.run/@material/web/"
        }
      }
    </script>
    <script type="module">
      import '@material/web/all.js';
      import {styles as typescaleStyles} from '@material/web/typography/md-typescale-styles.js';
      document.adoptedStyleSheets.push(typescaleStyles.styleSheet);
    </script>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f0f2f5; /* Gris muy suave */
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        /* Estilo de Tarjeta Material (Elevation 1) */
        .card-material {
            background-color: white;
            padding: 40px;
            border-radius: 24px; /* Bordes muy redondeados (MD3) */
            box-shadow: 0px 4px 8px 3px rgba(0, 0, 0, 0.05), 0px 1px 3px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 400px;
            width: 90%;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
        }

        h1 {
            margin: 0;
            color: #1f1f1f;
            font-size: 24px;
            font-weight: 500;
        }

        p {
            color: #444746;
            margin: 0;
            font-size: 14px;
        }

        /* Contenedor del QR */
        #qrcode {
            padding: 15px;
            border: 1px solid #e0e2e0;
            border-radius: 16px;
        }

        .estado-chip {
            background-color: #e8f5e9; /* Verde muy claro */
            color: #137a28;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }
    </style>
</head>
<body>

    <div class="card-material">
        <span class="material-symbols-outlined" style="font-size: 48px; color: #006C4C;">qr_code_2</span>
        
        <div>
            <h1>Punto de Asistencia</h1>
            <p>Escanea para registrar tu entrada</p>
        </div>

        <div id="qrcode"></div>

        <div class="estado-chip">
            <span class="material-symbols-outlined" style="font-size: 18px;">sync</span>
            <span id="textoEstado">Generando...</span>
        </div>

        <md-text-button href="${pageContext.request.contextPath}/admin">
            Volver al Dashboard
        </md-text-button>
    </div>

    <script type="text/javascript">
        var qrContainer = document.getElementById("qrcode");
        var qrCodeObj = new QRCode(qrContainer, { width: 200, height: 200 });

        function actualizarQR() {
            var fechaHoy = new Date().toISOString().split('T')[0];
            var tokenSecreto = "GRUPO_PERUANA_" + fechaHoy;

            qrCodeObj.clear(); 
            qrCodeObj.makeCode(tokenSecreto);
            
            document.getElementById("textoEstado").innerText = "Código activo: " + fechaHoy;
        }

        actualizarQR();
        setInterval(actualizarQR, 60000); 
    </script>
</body>
</html>