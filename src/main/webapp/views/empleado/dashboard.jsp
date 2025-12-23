<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${sessionScope.usuario == null}">
    <c:redirect url="/index.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Asistencia</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>

    <style>
        body { margin: 0; font-family: 'Roboto', sans-serif; background-color: #F4FBF9; padding-bottom: 80px;}
        .mobile-container { padding: 20px; text-align: center; }
        
        .welcome-card { background: white; border-radius: 24px; padding: 30px 20px; margin-bottom: 24px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .big-clock { font-size: 2.5rem; font-weight: bold; color: #006A6A; margin: 10px 0; }
        
        .action-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        
        .action-btn {
            background: white; border-radius: 16px; padding: 20px; cursor: pointer;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05); display: flex; flex-direction: column; align-items: center; justify-content: center; transition: 0.2s;
            height: 100%;
        }
        .action-btn:active { background-color: #E0F2F1; transform: scale(0.98); }
        .action-btn label, .action-btn h3 { margin-top: 10px; color: #333; font-size: 1rem; font-weight: 500; margin-bottom: 0;}
        
        .toast {
            visibility: hidden; min-width: 250px; background-color: #333; color: #fff;
            text-align: center; border-radius: 8px; padding: 16px; position: fixed;
            z-index: 1000; left: 50%; bottom: 30px; transform: translateX(-50%);
        }
        .toast.show { visibility: visible; animation: fadein 0.5s, fadeout 0.5s 2.5s; }
        .toast.success { background-color: #1b5e20; }
        .toast.error { background-color: #b71c1c; }
        
        @keyframes fadein { from {bottom: 0; opacity: 0;} to {bottom: 30px; opacity: 1;} }
        @keyframes fadeout { from {bottom: 30px; opacity: 1;} to {bottom: 0; opacity: 0;} }

        .turno-pendiente { border-left-color: #ff9800 !important; }
        .status-early { border-left-color: #2196f3 !important; } 
        .status-ontime { border-left-color: #4caf50 !important; } 
        .status-late { border-left-color: #f44336 !important; }
        
       
        .card-success {
            background-color: #e8f5e9; 
            border: 1px solid #c8e6c9; 
            border-radius: 24px;
            padding: 30px;
            text-align: center;
        }
    </style>
</head>
<body>

    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
    <div class="mobile-container">
        
        <div class="welcome-card">
            <div>Hora Actual</div>
            <div class="big-clock" id="reloj">00:00:00</div>
            <div class="date-display" id="fecha">...</div>
        </div>
        
        <h3 style="text-align: left; margin-bottom: 15px;">Mis Turnos de Hoy</h3>
        
        <c:if test="${empty reporteDiario}">
            <div style="background: #fff3e0; border-radius: 16px; padding: 15px; margin-bottom: 24px;">
                <span style="color: #ef6c00; font-weight:bold;">Sin turnos:</span> 
                No tienes turnos programados para hoy.
            </div>
        </c:if>

        <div id="lista-turnos">
            <c:forEach var="turno" items="${reporteDiario}">
                <div class="turno-card ${turno.estado == 'PENDIENTE' ? 'turno-pendiente' : ''} ${turno.claseCss}" 
                     data-inicio="${turno.horario.horaInicio}" 
                     data-fin="${turno.horario.horaFin}"
                     style="background: white; border-radius: 16px; padding: 15px; margin-bottom: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); border-left: 5px solid #ccc; position: relative;">
                    
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:5px;">
                        <strong style="font-size: 1.1rem; color:#333;">${turno.horario.tipoTurno}</strong>
                        <span style="font-size: 0.8rem; padding: 4px 8px; border-radius: 12px; background: #eee; color: #555; font-weight: bold;">
                            ${turno.mensajeEstado}
                        </span>
                    </div>
                    <div style="color: #555;">
                        <span class="material-symbols-outlined" style="font-size: 16px; vertical-align: middle;">schedule</span>
                        ${turno.horario.horaInicio} - ${turno.horario.horaFin}
                    </div>
                    <c:if test="${not empty turno.asistencia}">
                            <c:if test="${not empty turno.asistencia.fotoUrl}">
                                <a href="${pageContext.request.contextPath}/${turno.asistencia.fotoUrl}" target="_blank" style="margin-left:5px; color:#006A6A; font-weight:bold;">[Foto Entrada]</a>
                            </c:if>
                        </div>
                         <c:if test="${not empty turno.asistencia.horaSalida}">
                            <div style="margin-top: 5px; font-size: 0.9rem; color: #ef6c00;"> <!-- Color naranja para salida -->
                                <span class="material-symbols-outlined" style="font-size: 16px; vertical-align: middle;">logout</span>
                                Salida: ${turno.asistencia.horaSalida}
                                <c:if test="${not empty turno.asistencia.fotoUrlSalida}">
                                    <a href="${pageContext.request.contextPath}/${turno.asistencia.fotoUrlSalida}" target="_blank" style="margin-left:5px; color:#ef6c00; font-weight:bold;">[Foto Salida]</a>
                                </c:if>
                            </div>
                        </c:if>
                    </c:if>
                </div>
            </c:forEach>
        </div>

        <h3 style="text-align: left;">Marcar Asistencia</h3>

        <c:choose>
            <%-- Caso 1: Turno Abierto (Salida) --%>
            <c:when test="${hayTurnoAbierto == true}">
                <div class="card-success" style="border-color: #ffcc80; background-color: #fff3e0;">
                    <span class="material-symbols-outlined" style="font-size: 48px; color: #ef6c00; display:block; margin-bottom:10px;">timelapse</span>
                    <h2 style="color: #ef6c00; margin: 0; font-size: 1.2rem;">Turno en Curso</h2>
                    <p style="color: #e65100; margin-top: 5px;">Tienes una actividad activa.</p>
                    
                    <div style="margin-top: 15px;">
                        <button class="action-btn" onclick="prepararMarca('UBICACION')" style="background: #ef6c00; color: white; width: 100%; border: none;">
                            <span class="material-symbols-outlined" style="font-size: 24px; color: white;">logout</span>
                            <label style="color: white; margin-top:5px;">Marcar Salida (Foto)</label>
                        </button>
                    </div>
                </div>
            </c:when>

            <%-- Caso 2: Dia Justificado (PRIORIDAD ALTA) --%>
            <c:when test="${esDiaJustificado == true}">
                <div class="card-success" style="border-color: #81d4fa; background-color: #e1f5fe;">
                    <span class="material-symbols-outlined" style="font-size: 48px; color: #0288d1; display:block; margin-bottom:10px;">verified</span>
                    <h2 style="color: #0277bd; margin: 0; font-size: 1.2rem;">Día Justificado</h2>
                    <p style="color: #01579b; margin-top: 5px;">Tu inasistencia ha sido justificada. No es necesario marcar hoy.</p>
                </div>
            </c:when>

            <%-- Caso 3: Fin de Jornada --%>
            <c:when test="${finJornada == true}">
                <div class="card-success" style="border-color: #a5d6a7; background-color: #e8f5e9;">
                    <span class="material-symbols-outlined" style="font-size: 48px; color: #2e7d32; display:block; margin-bottom:10px;">check_circle</span>
                    <h2 style="color: #2e7d32; margin: 0; font-size: 1.2rem;">Jornada Finalizada</h2>
                    <p style="color: #1b5e20; margin-top: 5px;">Has completado todos tus turnos de hoy.</p>
                </div>
            </c:when>

            <%-- Caso 4: Entrada (o Espera) --%>
            <c:otherwise>
                <%-- Mensaje de éxito discreto si ya marcó alguna vez hoy --%>
                <c:if test="${not empty listaAsistencia and listaAsistencia[0].fecha == java.time.LocalDate.now()}">
                     <div style="text-align:center; color: #2e7d32; margin-bottom:10px; font-weight:bold;">
                        <span class="material-symbols-outlined" style="vertical-align:bottom;">check</span> Actividad anterior registrada.
                     </div>
                </c:if>

                <div class="action-grid">
                    <div class="action-btn" onclick="prepararMarca('UBICACION')">
                        <span class="material-symbols-outlined" style="font-size: 32px; color: #006A6A;">location_on</span>
                        <label>Entrada (Foto)</label>
                    </div>
                    
                    <div class="action-btn" onclick="window.location.href='${pageContext.request.contextPath}/empleado/escanear'">
                        <span class="material-symbols-outlined" style="font-size: 32px; color: #006A6A;">qr_code_scanner</span>
                        <label>Escanear QR</label>
                    </div>

                    <div class="action-btn" onclick="window.location.href='${pageContext.request.contextPath}/justificaciones'">
                        <span class="material-symbols-outlined" style="font-size: 32px; color: #d32f2f;">assignment_late</span>
                        <label>Justificar Falta</label>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
        <br>
        <md-list style="background: white; border-radius: 16px; overflow: hidden; margin-top:20px;">
            <md-list-item type="button" onclick="window.location.href='${pageContext.request.contextPath}/asistencias?rol=empleado'">
                <md-icon slot="start">history</md-icon>
                <div slot="headline">Ver Historial Completo</div>
                <md-icon slot="end">chevron_right</md-icon>
            </md-list-item>
        </md-list>

    </div>
    </div>

    <%-- MODAL DE CAMARA --%>
    <dialog id="camera-modal" style="border:none; border-radius:16px; padding:0; width:90%; max-width:400px; box-shadow: 0 4px 20px rgba(0,0,0,0.2);">
        <div style="padding: 20px; text-align: center;">
            <h3 style="margin-top:0;">Evidencia Requerida</h3>
            <p>Toma una foto de tu entorno.</p>
            <div style="background:black; width:100%; height:250px; border-radius:12px; overflow:hidden; position:relative;">
                <video id="camera-stream" autoplay playsinline style="width:100%; height:100%; object-fit:cover;"></video>
                <canvas id="camera-canvas" style="display:none;"></canvas>
            </div>
            <div style="margin-top:20px; display:flex; gap:10px; justify-content:center;">
                <button onclick="cerrarCamara()" style="padding:10px 20px; border-radius:8px; border:1px solid #ccc; background:white;">Cancelar</button>
                <button onclick="tomarFoto()" style="padding:10px 20px; border-radius:8px; border:none; background:#006A6A; color:white;">Capturar y Marcar</button>
            </div>
        </div>
    </dialog>

    <form id="form-asistencia" action="${pageContext.request.contextPath}/asistencias/marcar" method="post" enctype="multipart/form-data" style="display:none;">
        <input type="hidden" name="accion" value="marcar">
        <input type="hidden" name="modo" id="input-modo">
        <input type="hidden" name="latitud" id="input-lat">
        <input type="hidden" name="longitud" id="input-lon">
        <input type="hidden" name="observacion" id="input-obs">
        <input type="file" name="foto" id="input-foto">
    </form>

    <div id="toast" class="toast ${sessionScope.tipoMensaje}">
        ${sessionScope.mensaje}
    </div>

    <script>
        // --- 1. Reloj ---
        function actualizarReloj() {
            const ahora = new Date();
            document.getElementById('reloj').innerText = ahora.toLocaleTimeString();
            document.getElementById('fecha').innerText = ahora.toLocaleDateString('es-PE', { weekday: 'long', day: 'numeric', month: 'long' });
        }
        setInterval(actualizarReloj, 1000);
        actualizarReloj(); 

        let capturedBlob = null;
        let pendingModo = null;
        const modal = document.getElementById('camera-modal');
        const video = document.getElementById('camera-stream');

        // --- 2. Lógica de Cámara ---
        function prepararMarca(modo) {
            pendingModo = modo;
            // 1. Abrir modal
            modal.showModal();
            // 2. Iniciar Stream
            activarCamara();
        }

        async function activarCamara() {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } });
                video.srcObject = stream;
            } catch (err) {
                alert("No se pudo acceder a la cámara: " + err);
                modal.close();
            }
        }

        function cerrarCamara() {
            const stream = video.srcObject;
            if (stream) {
                stream.getTracks().forEach(track => track.stop());
            }
            video.srcObject = null;
            modal.close();
        }

        function tomarFoto() {
            const canvas = document.getElementById('camera-canvas');
            const context = canvas.getContext('2d');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            
            canvas.toBlob(blob => {
                capturedBlob = blob;
                cerrarCamara(); // Cierra y detiene stream
                iniciarProcesoMarca(pendingModo); // Continua con GPS
            }, 'image/jpeg', 0.8);
        }

        // --- 3. Lógica de Marca con Ubicación ---
        function iniciarProcesoMarca(modo) {
             // LOGICA DE OBSERVACION
            const turnosPendientes = document.querySelectorAll('.turno-pendiente');
            let turnoObjetivo = null;
            if (turnosPendientes.length > 0) turnoObjetivo = turnosPendientes[0]; 

            let observacionCalculada = "Entrada Regular";
            if (turnoObjetivo) {
                // ... logica de tiempo ...
                // Simplificamos por brevedad, el backend valida tambien.
                observacionCalculada = "Asistencia con Foto"; // Placeholder
            }

            document.getElementById('input-obs').value = observacionCalculada;
            obtenerUbicacionYEnviar(modo);
        }

        function obtenerUbicacionYEnviar(modo) {
            if (modo === 'UBICACION') {
                if (navigator.geolocation) {
                    document.body.style.cursor = 'wait';
                    
                    navigator.geolocation.getCurrentPosition(
                        (position) => {
                            // Llenar datos
                            document.getElementById('input-modo').value = modo;
                            document.getElementById('input-lat').value = position.coords.latitude;
                            document.getElementById('input-lon').value = position.coords.longitude;
                            
                            // Adjuntar Foto al Input File
                            if (capturedBlob) {
                                const fileInput = document.getElementById('input-foto');
                                const dataTransfer = new DataTransfer();
                                const file = new File([capturedBlob], "evidencia_" + Date.now() + ".jpg", { type: "image/jpeg" });
                                dataTransfer.items.add(file);
                                fileInput.files = dataTransfer.files;
                            }

                            document.getElementById('form-asistencia').submit();
                        },
                        (error) => {
                            alert("Error: Debes activar el GPS para marcar asistencia.");
                            document.body.style.cursor = 'default';
                        }
                    );
                } else {
                    alert("Navegador no soporta GPS.");
                }
            }
        }

        window.onload = function() {
            var msg = "${sessionScope.mensaje}";
            if (msg && msg.trim() !== "") {
                var x = document.getElementById("toast");
                x.className = "toast show " + "${sessionScope.tipoMensaje}";
                setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3500);
                <% session.removeAttribute("mensaje"); session.removeAttribute("tipoMensaje"); %>
            }

            // --- Lógica de Sugerencia de Proxima Actividad ---
            <c:if test="${promptNextActivity == true}">
                setTimeout(function() {
                    if (confirm("Has finalizado tu actividad actual. La siguiente actividad comienza pronto. ¿Deseas marcar su entrada ahora?")) {
                        prepararMarca('UBICACION'); // Usa la funcion nueva
                    }
                }, 500);
            </c:if>
        };
    </script>
</body>
</html>