<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Mis Asistencias | Grupo Peruana</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <style>
        .page-header { margin-bottom: 24px; animation: fadeIn 0.4s ease-out; }
    </style>
</head>
<body>

    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />

        <div class="container">
            <div class="page-header">
                <h1>Mi Historial</h1>
                <p style="color: var(--md-sys-color-secondary);">Registro detallado de tus asistencias</p>
            </div>

            <div class="card">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Entrada</th>
                                <th>Salida</th>
                                <th>Método</th>
                                <th>Cargo</th>
                                <th>Ubicación</th>
                                <th>Evidencia</th>
                                <th>Tardanza/Extra</th>
                                <th>Observación</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${listaAsistencia}" var="a">
                                <tr>
                                    <td>
                                        <div style="font-weight: 500;">${a.fecha}</div>
                                    </td>
                                    <td style="color: var(--md-sys-color-success); font-weight: 500;">
                                        ${a.horaEntrada}
                                    </td>
                                    <td>
                                        <c:if test="${not empty a.horaSalida}">${a.horaSalida}</c:if>
                                        <c:if test="${empty a.horaSalida}"><span style="color: var(--md-sys-color-outline);">--:--</span></c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${a.modo == 'QR' || a.modo == 'QR_DINAMICO'}">
                                                <span class="chip chip-success" style="height: 24px; font-size: 0.75rem;">
                                                    <span class="material-symbols-outlined" style="font-size: 14px; margin-right: 4px;">qr_code</span> QR
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="chip chip-info" style="height: 24px; font-size: 0.75rem;">
                                                    <span class="material-symbols-outlined" style="font-size: 14px; margin-right: 4px;">pin_drop</span> GPS
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${a.empleado.rol}</td>
                                    <td>
                                        <c:if test="${not empty a.latitud}">
                                            <a href="https://www.google.com/maps?q=${a.latitud},${a.longitud}" target="_blank" class="btn-secondary" style="display: inline-flex; width: 32px; height: 32px; border-radius: 50%; padding: 0; align-items: center; justify-content: center; text-decoration: none; border: 1px solid var(--md-sys-color-outline-variant);">
                                                <span class="material-symbols-outlined" style="font-size: 18px;">map</span>
                                            </a>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 8px;">
                                            <c:if test="${not empty a.fotoUrl}">
                                                 <a href="${a.fotoUrl}" target="_blank" title="Foto Entrada" 
                                                    style="color: var(--md-sys-color-primary); transition: transform 0.2s; display: inline-block;">
                                                    <span class="material-symbols-outlined">photo_camera</span>
                                                 </a>
                                            </c:if>
                                            <c:if test="${not empty a.fotoUrlSalida}">
                                                 <a href="${a.fotoUrlSalida}" target="_blank" title="Foto Salida" 
                                                    style="color: var(--md-sys-color-secondary); transition: transform 0.2s; display: inline-block;">
                                                    <span class="material-symbols-outlined">photo_camera</span>
                                                 </a>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-size: 0.85rem;">
                                            <c:if test="${not empty a.minutosTardanza && a.minutosTardanza > 0}">
                                                <div style="color: var(--md-sys-color-error); font-weight: 500;">
                                                    +${a.minutosTardanza}m tard.
                                                </div>
                                            </c:if>
                                            <c:if test="${not empty a.minutosExtras && a.minutosExtras > 0}">
                                                 <div style="color: var(--md-sys-color-success); font-weight: 500;">
                                                    +${a.minutosExtras}m extra
                                                 </div>
                                            </c:if>
                                            <c:if test="${(empty a.minutosTardanza || a.minutosTardanza == 0) && (empty a.minutosExtras || a.minutosExtras == 0)}">
                                                <span style="color: var(--md-sys-color-outline);">-</span>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td style="color: var(--md-sys-color-secondary); max-width: 200px; white-space: normal; font-size: 0.9em;">
                                        ${a.observacion}
                                    </td>
                                </tr>
                            </c:forEach>
                            
                            <c:if test="${empty listaAsistencia}">
                                <tr>
                                    <td colspan="9" style="text-align:center; padding: 60px;">
                                        <span class="material-symbols-outlined" style="font-size: 48px; color: var(--md-sys-color-outline-variant);">event_busy</span>
                                        <div style="margin-top: 8px; color: var(--md-sys-color-secondary);">No tienes registros de asistencia todavía.</div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</body>
</html>