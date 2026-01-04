<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Mi Historial | Grupo Peruana</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="theme-color" content="#EC407A">
    
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" rel="stylesheet">
    
    <style>
    /* ========================================
       ATTENDANCE HISTORY - Premium Mobile Design
       ======================================== */
       
    :root {
        --primary: #EC407A;
        --primary-soft: rgba(236, 64, 122, 0.12);
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
        --text-primary: #1C1B1F;
        --text-secondary: #49454F;
        --outline: #CAC4D0;
        
        --radius-lg: 24px;
        --radius-md: 16px;
        --radius-sm: 12px;
        --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
        --ease-smooth: cubic-bezier(0.25, 0.8, 0.25, 1);
    }

    [data-theme="dark"] {
        --surface: #1E1E1E;
        --surface-container: #2C2C2C;
        --text-primary: #E6E1E5;
        --text-secondary: #CAC4D0;
        --outline: #49454F;
    }

    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* ===== PAGE HEADER ===== */
    .page-header {
        margin-bottom: 20px;
        animation: fadeInUp 0.5s var(--ease-smooth);
    }

    .page-header h1 {
        font-size: 1.6rem;
        font-weight: 700;
        color: var(--text-primary);
        margin: 0 0 4px 0;
    }

    .page-header p {
        font-size: 0.9rem;
        color: var(--text-secondary);
        margin: 0;
    }

    /* ===== ATTENDANCE CARDS ===== */
    .attendance-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .attendance-card {
        background: var(--surface);
        border-radius: var(--radius-md);
        padding: 16px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        animation: fadeInUp 0.5s var(--ease-smooth) backwards;
        border-left: 4px solid var(--success);
    }

    .attendance-card:nth-child(1) { animation-delay: 0.1s; }
    .attendance-card:nth-child(2) { animation-delay: 0.15s; }
    .attendance-card:nth-child(3) { animation-delay: 0.2s; }
    .attendance-card:nth-child(4) { animation-delay: 0.25s; }
    .attendance-card:nth-child(5) { animation-delay: 0.3s; }

    [data-theme="dark"] .attendance-card {
        box-shadow: 0 2px 8px rgba(0,0,0,0.3);
    }

    .attendance-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 12px;
    }

    .attendance-date {
        font-size: 1rem;
        font-weight: 600;
        color: var(--text-primary);
    }

    .attendance-method {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px 10px;
        border-radius: 16px;
        font-size: 0.7rem;
        font-weight: 600;
        text-transform: uppercase;
    }

    .attendance-method.qr {
        background: var(--success-soft);
        color: #2E7D32;
    }

    .attendance-method.gps {
        background: var(--info-soft);
        color: #1565C0;
    }

    .attendance-method .material-symbols-rounded {
        font-size: 14px;
    }

    .attendance-times {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
        margin-bottom: 12px;
    }

    .time-block {
        background: var(--surface-container);
        padding: 12px;
        border-radius: var(--radius-sm);
    }

    .time-label {
        font-size: 0.75rem;
        color: var(--text-secondary);
        margin-bottom: 4px;
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .time-label .material-symbols-rounded {
        font-size: 14px;
    }

    .time-value {
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--text-primary);
    }

    .time-value.entry {
        color: var(--success);
    }

    .time-value.exit {
        color: var(--primary);
    }

    .time-value.pending {
        color: var(--text-secondary);
        font-style: italic;
        font-weight: 400;
    }

    .attendance-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-top: 12px;
        border-top: 1px solid var(--outline);
    }

    .attendance-extras {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .extra-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        font-size: 0.8rem;
        font-weight: 600;
    }

    .extra-badge.late {
        color: var(--error);
    }

    .extra-badge.overtime {
        color: var(--success);
    }

    .attendance-actions {
        display: flex;
        gap: 8px;
    }

    .action-link {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: var(--surface-container);
        color: var(--text-secondary);
        text-decoration: none;
        transition: all 0.2s var(--ease-smooth);
    }

    .action-link:active {
        transform: scale(0.9);
        background: var(--primary-soft);
        color: var(--primary);
    }

    .action-link .material-symbols-rounded {
        font-size: 20px;
    }

    /* ===== EMPTY STATE ===== */
    .empty-state {
        text-align: center;
        padding: 48px 24px;
        animation: fadeInUp 0.5s var(--ease-smooth);
    }

    .empty-state .material-symbols-rounded {
        font-size: 64px;
        color: var(--outline);
        margin-bottom: 16px;
    }

    .empty-state h3 {
        font-size: 1.1rem;
        color: var(--text-primary);
        margin: 0 0 8px 0;
    }

    .empty-state p {
        font-size: 0.9rem;
        color: var(--text-secondary);
        margin: 0;
    }

    /* ===== OBSERVATION ===== */
    .attendance-observation {
        margin-top: 12px;
        padding: 10px 12px;
        background: var(--warning-soft);
        border-radius: var(--radius-sm);
        font-size: 0.85rem;
        color: #E65100;
    }

    .attendance-observation::before {
        content: "📝 ";
    }
    </style>
</head>
<body>

<jsp:include page="../shared/loading-screen.jsp"/>
<jsp:include page="../shared/mobile-layout.jsp"/>

<main class="mobile-content">
    <!-- Page Header -->
    <div class="page-header">
        <h1>Mi Historial</h1>
        <p>Registro de tus asistencias</p>
    </div>

    <!-- Attendance List -->
    <c:choose>
        <c:when test="${empty listaAsistencia}">
            <div class="empty-state">
                <span class="material-symbols-rounded">event_busy</span>
                <h3>Sin registros</h3>
                <p>No tienes asistencias registradas todavía</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="attendance-list">
                <c:forEach items="${listaAsistencia}" var="a">
                    <div class="attendance-card">
                        <div class="attendance-header">
                            <span class="attendance-date">${a.fecha}</span>
                            <c:choose>
                                <c:when test="${a.modo == 'QR' || a.modo == 'QR_DINAMICO'}">
                                    <span class="attendance-method qr">
                                        <span class="material-symbols-rounded">qr_code</span>
                                        QR
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="attendance-method gps">
                                        <span class="material-symbols-rounded">location_on</span>
                                        GPS
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="attendance-times">
                            <div class="time-block">
                                <div class="time-label">
                                    <span class="material-symbols-rounded">login</span>
                                    Entrada
                                </div>
                                <div class="time-value entry">${a.horaEntrada}</div>
                            </div>
                            <div class="time-block">
                                <div class="time-label">
                                    <span class="material-symbols-rounded">logout</span>
                                    Salida
                                </div>
                                <c:choose>
                                    <c:when test="${not empty a.horaSalida}">
                                        <div class="time-value exit">${a.horaSalida}</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="time-value pending">--:--</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <div class="attendance-footer">
                            <div class="attendance-extras">
                                <c:if test="${not empty a.minutosTardanza && a.minutosTardanza > 0}">
                                    <span class="extra-badge late">
                                        <span class="material-symbols-rounded" style="font-size: 16px;">schedule</span>
                                        +${a.minutosTardanza} min tardanza
                                    </span>
                                </c:if>
                                <c:if test="${not empty a.minutosExtras && a.minutosExtras > 0}">
                                    <span class="extra-badge overtime">
                                        <span class="material-symbols-rounded" style="font-size: 16px;">add_circle</span>
                                        +${a.minutosExtras} min extra
                                    </span>
                                </c:if>
                            </div>
                            
                            <div class="attendance-actions">
                                <c:if test="${not empty a.latitud}">
                                    <a href="https://www.google.com/maps?q=${a.latitud},${a.longitud}" 
                                       target="_blank" 
                                       class="action-link"
                                       title="Ver ubicación">
                                        <span class="material-symbols-rounded">map</span>
                                    </a>
                                </c:if>
                                <c:if test="${not empty a.fotoUrl}">
                                    <a href="${a.fotoUrl}" 
                                       target="_blank" 
                                       class="action-link"
                                       title="Ver foto">
                                        <span class="material-symbols-rounded">photo_camera</span>
                                    </a>
                                </c:if>
                            </div>
                        </div>
                        
                        <c:if test="${not empty a.observacion}">
                            <div class="attendance-observation">
                                ${a.observacion}
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</main>

</body>
</html>