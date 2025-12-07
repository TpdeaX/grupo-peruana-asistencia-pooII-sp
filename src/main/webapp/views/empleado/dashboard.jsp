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

    <jsp:include page="../shared/navbar.jsp" />

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
                        <div style="margin-top: 8px; font-size: 0.9rem; color: #006A6A;">
                            <span class="material-symbols-outlined" style="font-size: 16px; vertical-align: middle;">check_circle</span>
                            Marcado: ${turno.asistencia.horaEntrada}
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </div>

        <h3 style="text-align: left;">Marcar Asistencia</h3>

        <c:choose>
        
            <c:when test="${yaMarcoHoy == true}">
                <div class="card-success">
                    <span class="material-symbols-outlined" style="font-size: 48px; color: #1b5e20; display:block; margin-bottom:10px;">check_circle</span>
                    <h2 style="color: #1b5e20; margin: 0; font-size: 1.2rem;">¡Asistencia Registrada!</h2>
                    <p style="color: #2e7d32; margin-top: 5px;">Ya has marcado tu entrada el día de hoy.</p>
                </div>
            </c:when>

          
            <c:otherwise>
                <div class="action-grid">
                    <div class="action-btn" onclick="iniciarProcesoMarca('UBICACION')">
                        <span class="material-symbols-outlined" style="font-size: 32px; color: #006A6A;">location_on</span>
                        <label>Marcar GPS</label>
                    </div>
                    
                    <div class="action-btn" onclick="window.location.href='${pageContext.request.contextPath}/empleado/escanear'">
                        <span class="material-symbols-outlined" style="font-size: 32px; color: #006A6A;">qr_code_scanner</span>
                        <label>Escanear QR</label>
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

    <form id="form-asistencia" action="${pageContext.request.contextPath}/asistencias/marcar" method="post" style="display:none;">
        <input type="hidden" name="accion" value="marcar">
        <input type="hidden" name="modo" id="input-modo">
        <input type="hidden" name="latitud" id="input-lat">
        <input type="hidden" name="longitud" id="input-lon">
        <input type="hidden" name="observacion" id="input-obs">
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
        actualizarReloj(); // Ejecutar al inicio

        // --- 2. Lógica Inteligente de Asistencia ---
        function iniciarProcesoMarca(modo) {
            
            const turnosPendientes = document.querySelectorAll('.turno-pendiente');
            let turnoObjetivo = null;
            
            if (turnosPendientes.length > 0) {
                turnoObjetivo = turnosPendientes[0]; 
            }

            let observacionCalculada = "Entrada Regular";
            
            if (turnoObjetivo) {
                const horaInicioStr = turnoObjetivo.getAttribute('data-inicio'); 
                const [horas, minutos, segundos] = horaInicioStr.split(':');
                const fechaTurno = new Date();
                fechaTurno.setHours(horas, minutos, segundos || 0);
                
                const diferenciaMinutos = (new Date() - fechaTurno) / 1000 / 60;
                
                if (diferenciaMinutos < -30) {
                    if (!confirm("¡Es muy temprano! Faltan más de 30 minutos. ¿Marcar igual?")) return;
                    observacionCalculada = "Ingreso Temprano";
                } else if (diferenciaMinutos < -2) {
                    observacionCalculada = "Ingreso Temprano";
                } else if (diferenciaMinutos >= -2 && diferenciaMinutos <= 2) {
                    observacionCalculada = "Puntual";
                } else {
                    observacionCalculada = "Llegada Tardía";
                }
                
            } else {
                observacionCalculada = "Sin turno asignado / Extra";
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
                            document.getElementById('input-modo').value = modo;
                            document.getElementById('input-lat').value = position.coords.latitude;
                            document.getElementById('input-lon').value = position.coords.longitude;
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
        };
    </script>
</body>
</html>