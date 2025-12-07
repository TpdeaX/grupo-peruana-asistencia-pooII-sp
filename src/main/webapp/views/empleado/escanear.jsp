<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Escanear QR</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />

    <script type="importmap">
      { "imports": { "@material/web/": "https://esm.run/@material/web/" } }
    </script>
    <script type="module">import '@material/web/all.js';</script>

    <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>

    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #fff;
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            min-height: 100vh;
        }

        h2 { text-align: center; color: #1f1f1f; margin-bottom: 5px; }
        p { text-align: center; color: #757575; margin-top: 0; margin-bottom: 20px; font-size: 14px;}

        /* Estilo de la cámara */
        #reader {
            width: 100%;
            max-width: 400px;
            border-radius: 24px !important;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            background: #000;
        }

        /* Ajustes para los botones dentro de la librería de la cámara */
        #reader button {
            background-color: #006C4C;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 20px;
            font-family: 'Roboto', sans-serif;
            margin-top: 10px;
            cursor: pointer;
        }

        .actions {
            margin-top: 30px;
            width: 100%;
            max-width: 400px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        /* Mensajes de error/exito que vienen del Controller */
        .alert-error {
            background-color: #FFdad6;
            color: #410002;
            padding: 15px;
            border-radius: 12px;
            width: 100%;
            max-width: 370px;
            margin-bottom: 15px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
    </style>
</head>
<body>

    <span class="material-symbols-outlined" style="font-size: 40px; color: #006C4C; margin-top: 20px;">qr_code_scanner</span>
    <h2>Registrar Asistencia</h2>
   

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert-error">
            <span class="material-symbols-outlined">error</span>
            <%= request.getAttribute("error") %>
        </div>
    <% } %>

    <div id="reader"></div>

    <div class="actions">
        <md-outlined-button href="${pageContext.request.contextPath}/empleado" style="width: 100%;">
            Cancelar y Volver
        </md-outlined-button>
    </div>

    <form id="formScan" action="${pageContext.request.contextPath}/qr" method="post">
        <input type="hidden" name="qrToken" id="inputToken">
    </form>

    <script>
        function onScanSuccess(decodedText, decodedResult) {
            html5QrcodeScanner.clear();
            document.getElementById('inputToken').value = decodedText;
            
            // Simular un "loading" visual antes de enviar
            document.querySelector('h2').innerText = "Procesando...";
            document.querySelector('p').innerText = "Validando código, espere...";
            
            document.getElementById('formScan').submit();
        }

        var html5QrcodeScanner = new Html5QrcodeScanner("reader", { fps: 10, qrbox: 250 });
        html5QrcodeScanner.render(onScanSuccess);
    </script>
</body>
</html>