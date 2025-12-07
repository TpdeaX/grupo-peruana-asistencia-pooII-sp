<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <title>Mis Asistencias</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />

    <script type="importmap">
      { "imports": { "@material/web/": "https://esm.run/@material/web/" } }
    </script>
    <script type="module">import '@material/web/all.js';</script>

    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #f0f2f5; margin: 0; padding: 20px; }
        
        .header { margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        h1 { margin: 0; color: #1f1f1f; font-size: 24px; }

        /* Tarjeta de la tabla */
        .card-table {
            background: white;
            border-radius: 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
            overflow: hidden;
            padding-bottom: 10px;
        }

        table { width: 100%; border-collapse: collapse; }
        
        th { text-align: left; padding: 16px; color: #444746; font-size: 14px; background: #fafafa; border-bottom: 1px solid #e0e0e0; }
        td { padding: 16px; border-bottom: 1px solid #f0f0f0; color: #1f1f1f; font-size: 14px; }
        
        /* Badges de estado */
        .badge { padding: 4px 12px; border-radius: 8px; font-size: 12px; font-weight: 500; display: inline-block;}
        .bdg-qr { background: #e8f5e9; color: #1b5e20; border: 1px solid #c8e6c9; }
        .bdg-gps { background: #e3f2fd; color: #0d47a1; border: 1px solid #bbdefb; }

    </style>
</head>
<body>

    <div class="header">
        <md-icon-button href="${pageContext.request.contextPath}/empleado">
            <span class="material-symbols-outlined">arrow_back</span>
        </md-icon-button>
        <h1>Mi Historial de Asistencias</h1>
    </div>

    <div class="card-table">
        <table>
            <thead>
                <tr>
                    <th>Fecha</th>
                    <th>Entrada</th>
                    <th>Salida</th>
                    <th>Método</th>
                    <th>Detalle</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${listaAsistencia}" var="a">
                    <tr>
                        <td style="font-weight: 500;">${a.fecha}</td>
                        <td style="color: #006C4C;">${a.horaEntrada}</td>
                        <td>
                            <c:if test="${not empty a.horaSalida}">${a.horaSalida}</c:if>
                            <c:if test="${empty a.horaSalida}"><span style="color:#999">--:--</span></c:if>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${a.modo == 'QR' || a.modo == 'QR_DINAMICO'}">
                                    <span class="badge bdg-qr">QR Code</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bdg-gps">Ubicación</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td style="color:#666;">${a.observacion}</td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty listaAsistencia}">
                    <tr>
                        <td colspan="5" style="text-align:center; padding: 40px; color: #757575;">
                            No tienes registros de asistencia todavía.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

</body>
</html>