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
    <h2 id="page-title">Registrar Asistencia</h2>
    <p id="page-desc">Escanea el código QR de la entrada/salida.</p>
   
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert-error">
            <span class="material-symbols-outlined">error</span>
            <%= request.getAttribute("error") %>
        </div>
    <% } %>

    <%-- SECCION 1: LECTOR QR --%>
    <div id="reader"></div>

    <%-- SECCION 2: EVIDENCIA (CAMARA) --%>
    <div id="evidence-section" style="display:none; width: 100%; max-width: 400px; text-align: center;">
        <h3 style="color:#006A6A;">Evidencia Requerida</h3>
        <p>Validación exitosa. Ahora toma una foto.</p>
        
        <div style="background:black; width:100%; height:300px; border-radius:24px; overflow:hidden; position:relative; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
            <video id="camera-stream" autoplay playsinline style="width:100%; height:100%; object-fit:cover;"></video>
            <canvas id="camera-canvas" style="display:none;"></canvas>
        </div>

        <div style="margin-top:20px;">
            <button onclick="tomarFotoYEnviar()" style="padding:15px 30px; border-radius:24px; border:none; background:#006A6A; color:white; font-size:16px; width:100%; cursor:pointer; font-weight:bold;">
                <span class="material-symbols-outlined" style="vertical-align:middle; margin-right:5px;">camera</span>
                Tomar Foto y Finalizar
            </button>
        </div>
    </div>

    <div class="actions">
        <md-outlined-button href="${pageContext.request.contextPath}/empleado" style="width: 100%;">
            Cancelar y Volver
        </md-outlined-button>
    </div>

    <form id="formScan" action="${pageContext.request.contextPath}/qr" method="post" enctype="multipart/form-data">
        <input type="hidden" name="qrToken" id="inputToken">
        <input type="file" name="foto" id="inputFoto" style="display:none;">
    </form>

    <script>
        var html5QrcodeScanner = new Html5QrcodeScanner("reader", { fps: 10, qrbox: 250 });
        let videoStream = null;

        function onScanSuccess(decodedText, decodedResult) {
            // 1. Detener Escaner y ocultarlo
            html5QrcodeScanner.clear();
            document.getElementById('reader').style.display = 'none';
            document.querySelector('.actions').style.display = 'none'; // ocultar boton cancelar temporalmente

            // 2. Guardar Token
            document.getElementById('inputToken').value = decodedText;

            // 3. Mostrar Sección Camara
            document.getElementById('evidence-section').style.display = 'block';
            document.getElementById('page-title').innerText = "Verificar Identidad";
            document.getElementById('page-desc').innerText = "Código detectado. Paso final: Foto.";

            // 4. Iniciar Camara
            iniciarCamara();
        }

        html5QrcodeScanner.render(onScanSuccess);

        async function iniciarCamara() {
            const video = document.getElementById('camera-stream');
            try {
                videoStream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "user" } }); // Selfie mode preferible? O environment? User para evidencia de empleado.
                video.srcObject = videoStream;
            } catch (err) {
                alert("Error al acceder a la cámara: " + err);
            }
        }

        function tomarFotoYEnviar() {
            const video = document.getElementById('camera-stream');
            const canvas = document.getElementById('camera-canvas');
            const context = canvas.getContext('2d');
            
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            
            canvas.toBlob(blob => {
                // Adjuntar al form
                const fileInput = document.getElementById('inputFoto');
                const dataTransfer = new DataTransfer();
                const file = new File([blob], "evidencia_qr_" + Date.now() + ".jpg", { type: "image/jpeg" });
                dataTransfer.items.add(file);
                fileInput.files = dataTransfer.files;

                // Enviar
                document.querySelector('button').innerText = "Enviando...";
                document.querySelector('button').disabled = true;
                document.getElementById('formScan').submit();

            }, 'image/jpeg', 0.8);
        }
    </script>
</body>
</html>