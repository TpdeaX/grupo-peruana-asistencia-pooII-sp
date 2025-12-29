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

<style>
/* ===== BODY Y CONTENEDOR ===== */
body { 
    margin: 0; 
    font-family: 'Roboto', sans-serif; 
    background: linear-gradient(160deg, #f5f7fa, #c3cfe2);
    background-size: 400% 400%;
    animation: gradientBG 15s ease infinite;
    padding-bottom: 100px; 
}

@keyframes gradientBG {
    0% {background-position:0% 50%;}
    50% {background-position:100% 50%;}
    100% {background-position:0% 50%;}
}

.mobile-container { 
    padding: 15px; 
    max-width: 480px; 
    margin: auto; 
}

/* ===== WELCOME CARD ===== */
.welcome-card { 
    background: rgba(255,255,255,0.95); 
    border-radius: 24px; 
    padding: 25px 15px; 
    margin-bottom: 20px; 
    box-shadow: 0 8px 25px rgba(0,0,0,0.1); 
    text-align: center;
    animation: fadeInUp 0.5s ease-out;
}
.big-clock { 
    font-size: 2.8rem; 
    font-weight: bold; 
    color: #00796b; 
    margin: 10px 0; 
    text-shadow: 0 0 8px #4db6ac;
}
.date-display { 
    font-size: 1rem; 
    color: #555; 
}

/* ===== GRID DE ACCIONES ===== */
.action-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr); /* tres columnas iguales */
    gap: 10px;
}


.action-btn {
    background: linear-gradient(135deg, #4fc3f7, #81d4fa);
    border-radius: 20px;
    padding: 20px;
    cursor: pointer;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
    height: 120px; /* <-- fuerza todos los botones a la misma altura */
    color: white;
    font-weight: 500;
    box-shadow: 0 6px 15px rgba(0,0,0,0.1);
    min-width: 100px; /* opcional, para equilibrar ancho */
}
.action-btn:hover { 
    transform: translateY(-5px) scale(1.05); 
    background-position: right center;
    box-shadow: 0 12px 25px rgba(0,0,0,0.2);
}
.action-btn span { font-size: 32px; margin-bottom: 6px; text-shadow: 0 0 6px rgba(0,0,0,0.2); }

/* ===== TURNOS ===== */
.turno-card { 
    background: rgba(255,255,255,0.95); 
    border-radius: 18px; 
    padding: 15px; 
    margin-bottom: 15px; 
    box-shadow: 0 6px 20px rgba(0,0,0,0.08); 
    border-left: 6px solid #ccc; 
    transition: all 0.3s ease;
}
.turno-card:hover { 
    transform: translateY(-4px);
    box-shadow: 0 10px 28px rgba(0,0,0,0.15);
}
.turno-pendiente { border-left-color: #ff9800; }
.status-early { border-left-color: #2196f3; } 
.status-ontime { border-left-color: #4caf50; } 
.status-late { border-left-color: #f44336; }

/* ===== CARD ÉXITO ===== */
.card-success { 
    border-radius: 24px; 
    padding: 25px; 
    text-align: center; 
    color: #fff; 
    background: linear-gradient(135deg,#ffb74d,#ffa726); 
    box-shadow: 0 8px 25px rgba(0,0,0,0.15);
    animation: fadeInUp 0.5s ease-out;
}
.card-success span { font-size: 48px; margin-bottom: 10px; display:block; }

/* ===== TOAST ===== */
.toast {
    visibility: hidden; 
    min-width: 250px; 
    background-color: #333; 
    color: #fff;
    text-align: center; 
    border-radius: 12px; 
    padding: 16px; 
    position: fixed; 
    z-index: 1000; 
    left: 50%; 
    bottom: 30px; 
    transform: translateX(-50%);
    font-weight: 500;
}
.toast.show { visibility: visible; animation: fadeInOut 3s forwards; }
.toast.success { background-color: #2e7d32; }
.toast.error { background-color: #c62828; }

/* ===== HISTORIAL ===== */
.historial-card {
    margin-top: 20px;
    text-align: center; /* centra el botón */
}

.btn-historial {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    padding: 15px 20px;
    border: none;
    border-radius: 16px;
    background: linear-gradient(135deg, #4dd0e1, #26c6da);
    color: white;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    box-shadow: 0 6px 15px rgba(0,0,0,0.15);
    transition: all 0.3s ease;
    width: 100%; /* ocupa todo el ancho del contenedor */
    max-width: 400px;
}

.btn-historial span.material-symbols-outlined {
    font-size: 24px;
}

.btn-historial:hover {
    transform: translateY(-3px) scale(1.03);
    box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    background: linear-gradient(135deg, #26c6da, #00acc1);
}

@media (max-width: 400px) {
    .btn-historial {
        font-size: 0.9rem;
        padding: 12px 15px;
    }
    .btn-historial span.material-symbols-outlined {
        font-size: 20px;
    }
}


/* ===== ANIMACIONES ===== */
@keyframes fadeInUp { from {opacity:0; transform: translateY(20px);} to {opacity:1; transform: translateY(0);} }
@keyframes fadeInOut { 0% {opacity:0; bottom:0px;} 10% {opacity:1; bottom:30px;} 90% {opacity:1; bottom:30px;} 100% {opacity:0; bottom:0px;} }

/* ===== RESPONSIVE ===== */
@media (max-width: 480px) {
    .action-grid { flex-direction: column; gap: 12px; }
    .big-clock { font-size: 2.2rem; }
    .action-btn span { font-size: 28px; }
}

/* ===== AJUSTES ICONOS Y TEXTOS ===== */
.action-btn span {
    font-size: 28px; /* fuerza mismo tamaño de icono */
    margin-bottom: 6px;
}
.action-btn label {
    font-size: 15px; /* mismo tamaño de texto */
    text-align: center;
}

.historial-card md-list-item md-icon {
    font-size: 20px !important;
}

.historial-card md-list-item div[slot="headline"] {
    font-size: 15px; 
    font-weight: 500;
}

.historial-card md-list-item slot[end] md-icon {
    font-size: 20px !important;
}

</style>
</head>
<body>

<jsp:include page="../shared/sidebar.jsp" />
<div class="main-content">
<jsp:include page="../shared/header.jsp" />

<div class="mobile-container">

    <!-- WELCOME CARD -->
    <div class="welcome-card">
        <div>Hora Actual</div>
        <div class="big-clock" id="reloj">00:00:00</div>
        <div class="date-display" id="fecha">...</div>
    </div>

    <!-- MIS TURNOS -->
    <h3 style="text-align:left; margin-bottom:10px; color:#333;">Mis Turnos de Hoy</h3>
    <c:if test="${empty reporteDiario}">
        <div style="background: #fff3e0; border-radius: 16px; padding: 15px; margin-bottom: 20px; color:#ef6c00;">
            <strong>Sin turnos:</strong> No tienes turnos programados para hoy.
        </div>
    </c:if>

    <div id="lista-turnos">
        <c:forEach var="turno" items="${reporteDiario}">
            <div class="turno-card ${turno.estado == 'PENDIENTE' ? 'turno-pendiente' : ''} ${turno.claseCss}" 
                 data-inicio="${turno.horario.horaInicio}" 
                 data-fin="${turno.horario.horaFin}">
                
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:5px;">
                    <strong style="font-size: 1.1rem; color:#333;">${turno.horario.tipoTurno}</strong>
                    <span style="font-size: 0.8rem; padding: 4px 8px; border-radius: 12px; background: #eee; color: #555; font-weight: bold;">
                        ${turno.mensajeEstado}
                    </span>
                </div>
                <div style="color:#555;">
                    <span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">schedule</span>
                    ${turno.horario.horaInicio} - ${turno.horario.horaFin}
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- MARCAR ASISTENCIA -->
    <h3 style="text-align:left; color:#333;">Marcar Asistencia</h3>
    <c:choose>
        <c:when test="${hayTurnoAbierto == true}">
            <div class="card-success">
                <span class="material-symbols-outlined">timelapse</span>
                <h2>Turno en Curso</h2>
                <p>Tienes una actividad activa.</p>
                <button class="action-btn" onclick="prepararMarca('UBICACION')" style="width:100%; margin-top:10px;">
                    <span class="material-symbols-outlined">logout</span>
                    <label>Marcar Salida (Foto)</label>
                </button>
            </div>
        </c:when>
        <c:otherwise>
            <div class="action-grid">
                <div class="action-btn" onclick="prepararMarca('UBICACION')">
                    <span class="material-symbols-outlined">location_on</span>
                    <label>Entrada (Foto)</label>
                </div>
                <div class="action-btn" onclick="window.location.href='${pageContext.request.contextPath}/empleado/escanear'">
                    <span class="material-symbols-outlined">qr_code_scanner</span>
                    <label>Escanear QR</label>
                </div>
                <div class="action-btn" onclick="window.location.href='${pageContext.request.contextPath}/justificaciones'">
                    <span class="material-symbols-outlined">assignment_late</span>
                    <label>Justificar Falta</label>
                </div>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- HISTORIAL -->
<!-- HISTORIAL -->
<div class="historial-card">
    <button class="btn-historial" onclick="window.location.href='${pageContext.request.contextPath}/asistencias?rol=empleado'">
        <span class="material-symbols-outlined">history</span>
        <span>Ver Historial Completo</span>
    </button>
</div>



</div>
</div>

<!-- TOAST -->
<div id="toast" class="toast ${sessionScope.tipoMensaje}">${sessionScope.mensaje}</div>

<script>
function actualizarReloj() {
    const ahora = new Date();
    document.getElementById('reloj').innerText = ahora.toLocaleTimeString();
    document.getElementById('fecha').innerText = ahora.toLocaleDateString('es-PE', { weekday: 'long', day: 'numeric', month: 'long' });
}
setInterval(actualizarReloj, 1000);
actualizarReloj();

window.onload = function(){
    var msg = "${sessionScope.mensaje}";
    if(msg && msg.trim()!==""){
        var x=document.getElementById("toast");
        x.className="toast show ${sessionScope.tipoMensaje}";
        setTimeout(()=>{x.className=x.className.replace("show","");},3500);
        <% session.removeAttribute("mensaje"); session.removeAttribute("tipoMensaje"); %>
    }
};
</script>

</body>
</html>
