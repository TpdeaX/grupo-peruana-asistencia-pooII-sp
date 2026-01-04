<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Refreshed: Fix ClassNotFound --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${sessionScope.usuario == null}">
    <c:redirect url="/index.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta name="theme-color" content="#EC407A">
<title>Mi Asistencia | Grupo Peruana</title>

<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" rel="stylesheet">

<!-- Material Web 3 Components -->
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

<style>
/* ========================================
   EMPLOYEE DASHBOARD - Premium Mobile Design
   ======================================== */

:root {
    --primary: #EC407A;
    --primary-soft: rgba(236, 64, 122, 0.12);
    --primary-container: #FCE4EC;
    --on-primary: #FFFFFF;
    --gradient-start: #FF6B9D;
    --gradient-end: #C7396D;
    
    --success: #4CAF50;
    --success-soft: rgba(76, 175, 80, 0.12);
    --warning: #FF9800;
    --warning-soft: rgba(255, 152, 0, 0.12);
    --error: #F44336;
    --error-soft: rgba(244, 67, 54, 0.12);
    --info: #2196F3;
    --info-soft: rgba(33, 150, 243, 0.12);
    
    --surface: #FFFFFF;
    --surface-container: #F8F9FA;
    --background: #FAFBFC;
    --text-primary: #1C1B1F;
    --text-secondary: #49454F;
    --outline: #CAC4D0;

    --card-shadow: 0 2px 8px rgba(0,0,0,0.08);
    --card-shadow-hover: 0 8px 24px rgba(236, 64, 122, 0.15);
    --radius-lg: 24px;
    --radius-md: 16px;
    --radius-sm: 12px;
    
    --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
    --ease-smooth: cubic-bezier(0.25, 0.8, 0.25, 1);
}

[data-theme="dark"] {
    --surface: #1E1E1E;
    --surface-container: #2C2C2C;
    --background: #121212;
    --text-primary: #E6E1E5;
    --text-secondary: #CAC4D0;
    --outline: #49454F;
    --card-shadow: 0 2px 8px rgba(0,0,0,0.3);
    --primary-container: rgba(236, 64, 122, 0.2);
}

/* Force MD3 Icons to use correct font */
md-icon {
    font-family: 'Material Symbols Rounded';
    font-weight: normal;
    font-style: normal;
    font-size: 24px;
    line-height: 1;
    letter-spacing: normal;
    text-transform: none;
    display: inline-block;
    white-space: nowrap;
    word-wrap: normal;
    direction: ltr;
    -webkit-font-feature-settings: 'liga';
    -webkit-font-smoothing: antialiased;
}

/* ===== ANIMATIONS ===== */
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

@keyframes scaleIn {
    from { opacity: 0; transform: scale(0.9); }
    to { opacity: 1; transform: scale(1); }
}

@keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.05); }
}

@keyframes shimmer {
    0% { background-position: -200% 0; }
    100% { background-position: 200% 0; }
}

@keyframes float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-6px); }
}

@keyframes gradientBG {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
}

/* ===== WELCOME HERO CARD ===== */
.welcome-hero {
    background: linear-gradient(135deg, var(--gradient-start) 0%, var(--gradient-end) 100%);
    background-size: 200% 200%;
    animation: gradientBG 8s ease infinite, fadeInUp 0.5s var(--ease-smooth);
    border-radius: var(--radius-lg);
    padding: 28px 24px;
    color: white;
    position: relative;
    overflow: hidden;
    margin-bottom: 20px;
    box-shadow: 0 8px 32px rgba(236, 64, 122, 0.3);
}

.welcome-hero::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -20%;
    width: 200px;
    height: 200px;
    background: radial-gradient(circle, rgba(255,255,255,0.2) 0%, transparent 70%);
    border-radius: 50%;
    animation: float 6s ease-in-out infinite;
}

.welcome-hero::after {
    content: '';
    position: absolute;
    bottom: -30%;
    left: -10%;
    width: 150px;
    height: 150px;
    background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
    border-radius: 50%;
    animation: float 8s ease-in-out infinite reverse;
}

.welcome-greeting {
    font-size: 1rem;
    opacity: 0.9;
    margin-bottom: 4px;
    position: relative;
    z-index: 1;
}

.welcome-name {
    font-size: 1.6rem;
    font-weight: 700;
    margin-bottom: 16px;
    position: relative;
    z-index: 1;
    letter-spacing: -0.5px;
}

.welcome-clock {
    display: flex;
    align-items: baseline;
    gap: 8px;
    position: relative;
    z-index: 1;
}

.welcome-time {
    font-size: 3rem;
    font-weight: 700;
    letter-spacing: -2px;
    line-height: 1;
    text-shadow: 0 4px 20px rgba(0,0,0,0.2);
}

.welcome-date {
    font-size: 0.9rem;
    opacity: 0.85;
    text-transform: capitalize;
}

/* ===== SECTION TITLE ===== */
.section-title {
    font-size: 1.1rem;
    font-weight: 600;
    color: var(--text-primary);
    margin: 24px 0 12px 0;
    display: flex;
    align-items: center;
    gap: 8px;
}

.section-title .material-symbols-rounded {
    font-size: 20px;
    color: var(--primary);
}

/* ===== SHIFT CARDS ===== */
.shifts-container {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-bottom: 20px;
}

.shift-card {
    background: var(--surface);
    border-radius: var(--radius-md);
    padding: 16px;
    box-shadow: var(--card-shadow);
    border-left: 4px solid var(--outline);
    display: flex;
    justify-content: space-between;
    align-items: center;
    animation: fadeInUp 0.5s var(--ease-smooth) backwards;
    transition: all 0.3s var(--ease-smooth);
}

.shift-card:nth-child(1) { animation-delay: 0.1s; }
.shift-card:nth-child(2) { animation-delay: 0.2s; }
.shift-card:nth-child(3) { animation-delay: 0.3s; }

.shift-card:active {
    transform: scale(0.98);
}

.shift-card.pending {
    border-left-color: var(--warning);
}

.shift-card.completed {
    border-left-color: var(--success);
}

.shift-card.late {
    border-left-color: var(--error);
}

.shift-card.early {
    border-left-color: var(--info);
}

.shift-info {
    flex: 1;
}

.shift-type {
    font-size: 1rem;
    font-weight: 600;
    color: var(--text-primary);
    margin-bottom: 4px;
}

.shift-time {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 0.85rem;
    color: var(--text-secondary);
}

.shift-time .material-symbols-rounded {
    font-size: 16px;
}

.shift-status {
    display: inline-flex;
    align-items: center;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}

.shift-status.pending {
    background: var(--warning-soft);
    color: #E65100;
}

.shift-status.completed {
    background: var(--success-soft);
    color: #2E7D32;
}

.shift-status.late {
    background: var(--error-soft);
    color: #C62828;
}

.shift-status.early {
    background: var(--info-soft);
    color: #1565C0;
}

/* Empty Shifts */
.empty-shifts {
    background: var(--warning-soft);
    border-radius: var(--radius-md);
    padding: 20px;
    text-align: center;
    color: #E65100;
    animation: fadeInUp 0.5s var(--ease-smooth);
}

.empty-shifts .material-symbols-rounded {
    font-size: 40px;
    margin-bottom: 8px;
    animation: float 3s ease-in-out infinite;
}

/* ===== ACTIVE SHIFT BANNER ===== */
.active-shift-banner {
    background: linear-gradient(135deg, #FFB74D 0%, #FF9800 100%);
    border-radius: var(--radius-lg);
    padding: 24px;
    color: white;
    text-align: center;
    margin-bottom: 20px;
    animation: scaleIn 0.5s var(--ease-spring);
    box-shadow: 0 8px 24px rgba(255, 152, 0, 0.3);
}

.active-shift-banner .material-symbols-rounded {
    font-size: 48px;
    margin-bottom: 12px;
    animation: pulse 2s ease-in-out infinite;
}

.active-shift-banner h2 {
    margin: 0 0 8px 0;
    font-size: 1.4rem;
    font-weight: 700;
}

.active-shift-banner p {
    margin: 0 0 16px 0;
    opacity: 0.9;
}

/* ===== ACTION BUTTONS GRID ===== */
.actions-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
    margin-bottom: 24px;
}

.action-btn {
    background: var(--surface);
    border-radius: var(--radius-md);
    padding: 20px 12px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 10px;
    text-decoration: none;
    box-shadow: var(--card-shadow);
    border: 2px solid transparent;
    cursor: pointer;
    transition: all 0.3s var(--ease-spring);
    animation: scaleIn 0.5s var(--ease-spring) backwards;
    position: relative;
    overflow: hidden;
}

.action-btn:nth-child(1) { animation-delay: 0.2s; }
.action-btn:nth-child(2) { animation-delay: 0.3s; }
.action-btn:nth-child(3) { animation-delay: 0.4s; }

.action-btn::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(135deg, var(--primary-soft) 0%, transparent 100%);
    opacity: 0;
    transition: opacity 0.3s;
}

.action-btn:active {
    transform: scale(0.95);
    border-color: var(--primary);
}

.action-btn:active::before {
    opacity: 1;
}

.action-icon {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s var(--ease-spring);
    position: relative;
    z-index: 1;
}

.action-icon .material-symbols-rounded {
    font-size: 26px;
}

/* Action Button Variants */
.action-btn.location .action-icon {
    background: linear-gradient(135deg, #4DD0E1 0%, #00BCD4 100%);
    color: white;
    box-shadow: 0 4px 16px rgba(0, 188, 212, 0.3);
}

.action-btn.qr .action-icon {
    background: linear-gradient(135deg, #81C784 0%, #4CAF50 100%);
    color: white;
    box-shadow: 0 4px 16px rgba(76, 175, 80, 0.3);
}

.action-btn.justify .action-icon {
    background: linear-gradient(135deg, #FFB74D 0%, #FF9800 100%);
    color: white;
    box-shadow: 0 4px 16px rgba(255, 152, 0, 0.3);
}

.action-btn.exit .action-icon {
    background: linear-gradient(135deg, #E57373 0%, #F44336 100%);
    color: white;
    box-shadow: 0 4px 16px rgba(244, 67, 54, 0.3);
}

.action-btn:active .action-icon {
    transform: scale(1.1) rotate(5deg);
}

.action-label {
    font-size: 0.8rem;
    font-weight: 600;
    color: var(--text-primary);
    text-align: center;
    line-height: 1.2;
    position: relative;
    z-index: 1;
}

/* Exit Button Full Width */
.action-btn.exit.full-width {
    grid-column: span 3;
    flex-direction: row;
    gap: 16px;
    padding: 16px 24px;
}

.action-btn.exit.full-width .action-icon {
    width: 48px;
    height: 48px;
}

.action-btn.exit.full-width .action-label {
    font-size: 1rem;
}

/* ===== TOAST NOTIFICATION ===== */
.mobile-toast {
    position: fixed;
    bottom: 80px;
    left: 50%;
    transform: translateX(-50%) translateY(100px);
    background: var(--surface);
    color: var(--text-primary);
    padding: 14px 24px;
    border-radius: 28px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.15);
    z-index: 2000;
    display: flex;
    align-items: center;
    gap: 12px;
    font-weight: 500;
    opacity: 0;
    transition: all 0.5s var(--ease-spring);
}

.mobile-toast.show {
    opacity: 1;
    transform: translateX(-50%) translateY(0);
}

.mobile-toast.success {
    border-left: 4px solid var(--success);
}

.mobile-toast.error {
    border-left: 4px solid var(--error);
}

.mobile-toast .material-symbols-rounded {
    font-size: 24px;
}

.mobile-toast.success .material-symbols-rounded {
    color: var(--success);
}

.mobile-toast.error .material-symbols-rounded {
    color: var(--error);
}
</style>
</head>
<body>

<jsp:include page="../shared/session-saver.jsp"/>

<jsp:include page="../shared/loading-screen.jsp"/>
<jsp:include page="../shared/mobile-layout.jsp"/>

<main class="mobile-content">
    <!-- Welcome Hero -->
    <div class="welcome-hero">
        <div class="welcome-greeting">¡Hola!</div>
        <div class="welcome-name">${sessionScope.usuario.nombres}</div>
        <div class="welcome-clock">
            <span class="welcome-time" id="heroTime">00:00</span>
            <span class="welcome-date" id="heroDate">---</span>
        </div>
    </div>

    <!-- My Shifts Today -->
    <div class="section-title">
        <span class="material-symbols-rounded">schedule</span>
        Mis Turnos de Hoy
    </div>

    <c:choose>
        <c:when test="${empty reporteDiario}">
            <div class="empty-shifts">
                <span class="material-symbols-rounded">event_busy</span>
                <div><strong>Sin turnos programados</strong></div>
                <div style="font-size: 0.9rem; opacity: 0.8; margin-top: 4px;">No tienes turnos asignados para hoy</div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="shifts-container">
                <c:forEach var="turno" items="${reporteDiario}">
                    <div class="shift-card ${turno.estado == 'PENDIENTE' ? 'pending' : ''} ${turno.claseCss}">
                        <div class="shift-info">
                            <div class="shift-type">${turno.horario.tipoTurno}</div>
                            <div class="shift-time">
                                <span class="material-symbols-rounded">schedule</span>
                                ${turno.horario.horaInicio} - ${turno.horario.horaFin}
                            </div>
                        </div>
                        <div class="shift-status ${turno.estado == 'PENDIENTE' ? 'pending' : turno.claseCss}">
                            ${turno.mensajeEstado}
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- Mark Attendance Section -->
    <div class="section-title">
        <span class="material-symbols-rounded">touch_app</span>
        Marcar Asistencia
    </div>

    <c:choose>
        <c:when test="${hayTurnoAbierto == true}">
            <div class="active-shift-banner">
                <span class="material-symbols-rounded">timelapse</span>
                <h2>Turno en Curso</h2>
                <p>Tienes una actividad activa</p>
            </div>
            
            <div class="actions-grid">
                <div class="action-btn exit full-width" onclick="abrirModalAsistencia('SALIDA')">
                    <div class="action-icon">
                        <span class="material-symbols-rounded">logout</span>
                    </div>
                    <span class="action-label">Marcar Salida</span>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="actions-grid">
                <div class="action-btn location" onclick="abrirModalAsistencia('ENTRADA')">
                    <div class="action-icon">
                        <span class="material-symbols-rounded">location_on</span>
                    </div>
                    <span class="action-label">Entrada (Foto)</span>
                </div>
                <a href="${pageContext.request.contextPath}/empleado/escanear" class="action-btn qr">
                    <div class="action-icon">
                        <span class="material-symbols-rounded">qr_code_scanner</span>
                    </div>
                    <span class="action-label">Escanear QR</span>
                </a>
                <a href="${pageContext.request.contextPath}/justificaciones" class="action-btn justify">
                    <div class="action-icon">
                        <span class="material-symbols-rounded">assignment_late</span>
                    </div>
                    <span class="action-label">Justificar</span>
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<!-- MODAL: Marcar Asistencia (Mobile Optimized) -->
<md-dialog id="modal-asistencia" style="min-width: 320px; width: 96%; max-width: 480px; background: transparent; --md-dialog-container-color: transparent; box-shadow: none;">
    <div slot="content" style="padding: 0; background: var(--surface); border-radius: 28px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);">
        
        <!-- Header Gradient -->
        <div style="background: linear-gradient(135deg, var(--primary) 0%, var(--gradient-end) 100%); padding: 20px 20px 36px 20px; color: white; text-align: center; position: relative;">
            <div style="font-size: 1.15rem; font-weight: 700; margin-bottom: 2px; display: flex; align-items: center; justify-content: center; gap: 8px;">
                <md-icon id="modal-icon" style="color: white; font-size: 22px;">photo_camera</md-icon>
                <span id="modal-title">Marcar Asistencia</span>
            </div>
            <p style="margin: 0; opacity: 0.9; font-size: 0.85rem;">Verifica tu identidad y ubicación</p>
            
            <!-- Close Button Absolute -->
            <md-icon-button onclick="cerrarModalAsistencia()" style="position: absolute; top: 8px; right: 8px; --md-icon-button-icon-color: white;">
                <md-icon>close</md-icon>
            </md-icon-button>
        </div>

        <form id="form-asistencia" method="post" action="${pageContext.request.contextPath}/asistencias/marcar" enctype="multipart/form-data" style="padding: 0 20px 24px 20px; margin-top: -28px; position: relative; z-index: 2;">
            <input type="hidden" name="accion" value="marcar">
            <input type="hidden" name="modo" id="input-modo">
            <input type="hidden" name="latitud" id="input-lat">
            <input type="hidden" name="longitud" id="input-lng">
            <input type="hidden" name="sospechosa" id="input-sospechosa" value="false">
            
            <!-- Camera Container (Optimized for Mobile Portrait) -->
            <div style="background: #000; border-radius: 24px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.2); position: relative; aspect-ratio: 3/4; width: 100%; margin: 0 auto 20px auto;">
                <video id="camera-video" autoplay playsinline style="width: 100%; height: 100%; object-fit: cover;"></video>
                <canvas id="camera-canvas" style="display: none;"></canvas>
                <img id="camera-preview" style="display: none; width: 100%; height: 100%; object-fit: cover;">
                
                <!-- Overlay Gradient Bottom -->
                <div style="position: absolute; bottom: 0; left: 0; right: 0; height: 100px; background: linear-gradient(to top, rgba(0,0,0,0.8), transparent); pointer-events: none;"></div>

                <!-- Camera Controls -->
                <div style="position: absolute; bottom: 16px; left: 0; right: 0; display: flex; justify-content: center; align-items: center; gap: 24px; z-index: 10;">
                    
                     <!-- Refresh/Retake Button -->
                    <md-filled-tonal-icon-button id="btn-retake" type="button" onclick="reiniciarCamara()" style="display: none; width: 44px; height: 44px; --md-filled-tonal-icon-button-container-color: rgba(255,255,255,0.2); --md-filled-tonal-icon-button-icon-color: white;">
                        <md-icon>refresh</md-icon>
                    </md-filled-tonal-icon-button>

                    <!-- Capture Button -->
                    <button id="btn-capture" type="button" onclick="tomarFoto()" style="background: white; border: 4px solid rgba(255,255,255,0.3); width: 64px; height: 64px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1); box-shadow: 0 4px 20px rgba(0,0,0,0.3); -webkit-tap-highlight-color: transparent;">
                        <div style="width: 50px; height: 50px; background: white; border-radius: 50%; border: 2px solid #000;"></div>
                    </button>
                </div>
                
                <!-- Location Status Badge -->
                <div id="location-status" style="position: absolute; top: 12px; left: 12px; right: 12px; background: rgba(0,0,0,0.6); backdrop-filter: blur(8px); padding: 6px 10px; border-radius: 10px; display: flex; align-items: center; gap: 8px; color: white; font-size: 0.75rem; border: 1px solid rgba(255,255,255,0.1);">
                    <md-circular-progress indeterminate style="--md-circular-progress-size: 14px; --md-circular-progress-active-indicator-color: white;"></md-circular-progress>
                    <span style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Ubicando...</span>
                </div>
            </div>

            <!-- Error Messages Container -->
             <div id="distance-error" style="display: none; margin-bottom: 8px;"></div>

            <!-- Warning: Asistencia Sospechosa -->
            <div id="suspicious-warning" style="display: none; background: #FFF3E0; border: 1px solid #FFE0B2; border-radius: 16px; padding: 12px; margin-bottom: 20px;">
                <div style="display: flex; gap: 12px; align-items: flex-start;">
                    <div style="background: #FFE0B2; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 2px;">
                        <md-icon style="font-size: 16px; color: #F57C00;">warning</md-icon>
                    </div>
                    <div>
                        <div style="color: #E65100; font-weight: 700; font-size: 0.85rem; margin-bottom: 2px;">Ubicación Irregular</div>
                        <div style="color: #EF6C00; font-size: 0.75rem; line-height: 1.3;">Estás lejos del rango. Se marcará como sospechosa.</div>
                    </div>
                </div>
            </div>
            
            <md-outlined-text-field label="Nota (Opcional)" name="observacion" type="textarea" rows="2" style="width: 100%; margin-bottom: 20px; --md-outlined-text-field-container-shape: 16px;"></md-outlined-text-field>
            
            <!-- Input file oculto para enviar la foto -->
            <input type="file" name="foto" id="input-foto" style="display: none;">

            <!-- Main Action Button -->
            <md-filled-button id="btn-submit-asistencia" onclick="enviarAsistencia()" disabled style="width: 100%; height: 52px; font-size: 1rem; --md-filled-button-container-shape: 16px; --md-sys-color-primary: var(--primary);">
                Registrar
                <md-icon slot="trailing-icon">check</md-icon>
            </md-filled-button>
        </form>
    </div>
</md-dialog>

<!-- Toast -->
<div id="mobileToast" class="mobile-toast ${sessionScope.tipoMensaje}">
    <span class="material-symbols-rounded">${sessionScope.tipoMensaje == 'success' ? 'check_circle' : 'error'}</span>
    <span>${sessionScope.mensaje}</span>
</div>

<script>
// Hero Clock
function updateHeroClock() {
    const now = new Date();
    const timeStr = now.toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    const dateStr = now.toLocaleDateString('es-PE', { weekday: 'long', day: 'numeric', month: 'long' });
    
    const timeEl = document.getElementById('heroTime');
    const dateEl = document.getElementById('heroDate');
    
    if (timeEl) timeEl.textContent = timeStr.substring(0, 5);
    if (dateEl) dateEl.textContent = dateStr;
}

updateHeroClock();
setInterval(updateHeroClock, 1000);

// Toast Notification
window.onload = function() {
    var msg = "${sessionScope.mensaje}";
    if (msg && msg.trim() !== "") {
        var toast = document.getElementById('mobileToast');
        setTimeout(() => {
            toast.classList.add('show');
        }, 300);
        setTimeout(() => {
            toast.classList.remove('show');
        }, 4000);
        <% session.removeAttribute("mensaje"); session.removeAttribute("tipoMensaje"); %>
    }
};

// --- ASISTENCIA MODAL LOGIC ---
let stream = null;
let currentLat = null;
let currentLng = null;
const SUCURSAL_LAT = ${sessionScope.usuario.sucursal.latitud != null ? sessionScope.usuario.sucursal.latitud : 0};
const SUCURSAL_LNG = ${sessionScope.usuario.sucursal.longitud != null ? sessionScope.usuario.sucursal.longitud : 0};
const TOLERANCIA = ${sessionScope.usuario.sucursal.toleranciaMetros != null ? sessionScope.usuario.sucursal.toleranciaMetros : 100};

function abrirModalAsistencia(modo) {
    const modal = document.getElementById('modal-asistencia');
    const inputModo = document.getElementById('input-modo');
    const title = document.getElementById('modal-title');
    const btnSubmit = document.getElementById('btn-submit-asistencia');
    
    inputModo.value = modo;
    title.innerText = modo === 'ENTRADA' ? 'Marcar Entrada' : 'Marcar Salida';
    btnSubmit.innerText = modo === 'ENTRADA' ? 'Registrar Entrada' : 'Registrar Salida';
    
    modal.show();
    iniciarCamara();
    obtenerUbicacion();
}

function cerrarModalAsistencia() {
    const modal = document.getElementById('modal-asistencia');
    modal.close();
    detenerCamara();
}

// Camera Functions
async function iniciarCamara() {
    try {
        stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' }, audio: false });
        const video = document.getElementById('camera-video');
        video.srcObject = stream;
        
        // Reset states
        document.getElementById('camera-video').style.display = 'block';
        document.getElementById('camera-preview').style.display = 'none';
        document.getElementById('btn-capture').style.display = 'flex';
        document.getElementById('btn-retake').style.display = 'none';
    } catch (err) {
        console.error("Error accessing camera: ", err);
        alert("No se pudo acceder a la cámara. Asegúrate de dar permisos.");
    }
}

function detenerCamara() {
    if (stream) {
        stream.getTracks().forEach(track => track.stop());
        stream = null;
    }
}

function reiniciarCamara() {
    document.getElementById('camera-video').style.display = 'block';
    document.getElementById('camera-preview').style.display = 'none';
    document.getElementById('btn-capture').style.display = 'flex';
    document.getElementById('btn-retake').style.display = 'none';
    document.getElementById('btn-submit-asistencia').disabled = true;
    
    // Clear file input
    document.getElementById('input-foto').value = '';
}

function tomarFoto() {
    const video = document.getElementById('camera-video');
    const canvas = document.getElementById('camera-canvas');
    const preview = document.getElementById('camera-preview');
    
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d').drawImage(video, 0, 0);
    
    // Show preview
    preview.src = canvas.toDataURL('image/jpeg');
    video.style.display = 'none';
    preview.style.display = 'block';
    
    // Toggle buttons
    document.getElementById('btn-capture').style.display = 'none';
    document.getElementById('btn-retake').style.display = 'flex';
    
    // Check if location is ready to enable submit
    validarEstado();

    // Create file object for submission
    canvas.toBlob(blob => {
        const file = new File([blob], "asistencia.jpg", { type: "image/jpeg" });
        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        document.getElementById('input-foto').files = dataTransfer.files;
    }, 'image/jpeg', 0.8);
}

// Location Functions
function obtenerUbicacion() {
    const statusDiv = document.getElementById('location-status');
    statusDiv.innerHTML = '<md-circular-progress indeterminate style="--md-circular-progress-size: 24px;"></md-circular-progress><span>Obteniendo ubicación...</span>';
    statusDiv.style.backgroundColor = 'var(--surface-container)';
    statusDiv.style.color = 'var(--text-primary)';
    
    if (!navigator.geolocation) {
        statusDiv.innerHTML = '<md-icon style="color: var(--error);">location_off</md-icon><span>Geolocalización no soportada</span>';
        return;
    }
    
    navigator.geolocation.getCurrentPosition(
        (position) => {
            currentLat = position.coords.latitude;
            currentLng = position.coords.longitude;
            
            document.getElementById('input-lat').value = currentLat;
            document.getElementById('input-lng').value = currentLng;
            
            const dist = calcularDistancia(currentLat, currentLng, SUCURSAL_LAT, SUCURSAL_LNG);
            console.log("Distancia: " + dist + "m, Tolerancia: " + TOLERANCIA + "m");
            
            if (dist <= TOLERANCIA) {
                statusDiv.innerHTML = '<md-icon style="color: var(--success);">my_location</md-icon><span>Ubicación verificada (' + Math.round(dist) + 'm)</span>';
                statusDiv.style.backgroundColor = 'var(--success-soft)';
                statusDiv.style.color = '#1b5e20'; // Dark green
                document.getElementById('distance-error').style.display = 'none';
            } else {
                statusDiv.innerHTML = '<md-icon style="color: var(--error);">wrong_location</md-icon><span>Fuera de rango (' + Math.round(dist) + 'm)</span>';
                statusDiv.style.backgroundColor = 'var(--error-soft)';
                statusDiv.style.color = '#b71c1c'; // Dark red
                document.getElementById('distance-error').style.display = 'flex';
            }
            validarEstado();
        },
        (error) => {
             console.warn("Error Geolocation:", error);
             statusDiv.innerHTML = '<md-icon style="color: var(--error);">location_disabled</md-icon><span>Error de ubicación. Active el GPS.</span>';
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    );
}

function calcularDistancia(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // metres
    const φ1 = lat1 * Math.PI/180; // φ, λ in radians
    const φ2 = lat2 * Math.PI/180;
    const Δφ = (lat2-lat1) * Math.PI/180;
    const Δλ = (lon2-lon1) * Math.PI/180;

    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c; // in metres
}

function validarEstado() {
    const cameraPreview = document.getElementById('camera-preview');
    const hasPhoto = cameraPreview && cameraPreview.style.display === 'block';
    
    // Verify coordinates exist
    const hasLocation = currentLat !== null && currentLng !== null;
    
    // Check if out of range
    let isOutOfRange = false;
    if(hasLocation) {
        const dist = calcularDistancia(currentLat, currentLng, SUCURSAL_LAT, SUCURSAL_LNG);
        isOutOfRange = dist > TOLERANCIA;
    }
    
    // Set suspicious flag based on location (with null check)
    const sospechosaInput = document.getElementById('input-sospechosa');
    if (sospechosaInput) {
        sospechosaInput.value = isOutOfRange ? 'true' : 'false';
    }
    
    // Show/hide suspicious warning (with null check)
    const warningDiv = document.getElementById('suspicious-warning');
    if (warningDiv) {
        warningDiv.style.display = isOutOfRange ? 'block' : 'none';
    }
    
    // Update button text and style based on suspicious status
    const btn = document.getElementById('btn-submit-asistencia');
    const modoInput = document.getElementById('input-modo');
    const modo = modoInput ? modoInput.value : 'ENTRADA';
    
    if (btn) {
        if (isOutOfRange) {
            btn.innerText = modo === 'ENTRADA' ? '⚠️ Registrar (Sospechosa)' : '⚠️ Registrar Salida';
            btn.style.setProperty('--md-filled-button-container-color', '#ff9800');
        } else {
            btn.innerText = modo === 'ENTRADA' ? 'Registrar Entrada' : 'Registrar Salida';
            btn.style.removeProperty('--md-filled-button-container-color');
        }
        
        // Enable if photo taken AND location acquired (regardless of range)
        btn.disabled = !(hasPhoto && hasLocation);
    }
}

function enviarAsistencia() {
    document.getElementById('form-asistencia').submit();
}
</script>

</body>
</html>
