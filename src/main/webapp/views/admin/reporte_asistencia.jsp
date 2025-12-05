<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reporte de Asistencias</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>
    
    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #F4FBF9; margin: 0; }
        .container { max-width: 1000px; margin: 30px auto; padding: 20px; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        th { background-color: #006A6A; color: white; font-weight: 500; }
    </style>
</head>
<body>
    <jsp:include page="../shared/navbar.jsp" />
    
    <div class="container">
        <h2>Bitácora de Asistencia Global</h2>
        <table>
            <thead>
                <tr>
                    <th>Empleado</th>
                    <th>Fecha</th>
                    <th>Entrada</th>
                    <th>Salida</th>
                    <th>Modo</th>
                    <th>Estado</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="a" items="${listaAsistencia}">
                    <tr>
                        <td><b>${a.nombreEmpleado}</b></td>
                        <td>${a.fecha}</td>
                        <td>${a.horaEntrada}</td>
                        <td>${a.horaSalida != null ? a.horaSalida : '--:--'}</td>
                        <td>
                            <md-icon style="font-size:18px; vertical-align:middle;">
                                ${a.modo == 'QR' ? 'qr_code' : 'location_on'}
                            </md-icon> 
                            ${a.modo}
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${a.horaSalida != null}">
                                    <span style="color:green">Completado</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color:orange; font-weight:bold;">Laborando</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        <br>
        <md-filled-tonal-button onclick="window.history.back()">Volver</md-filled-tonal-button>
    </div>
</body>
</html>