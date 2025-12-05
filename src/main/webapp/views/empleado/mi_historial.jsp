<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Historial</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>
    
    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #F4FBF9; margin: 0; }
        .container { padding: 20px; max-width: 600px; margin: 0 auto; }
        .history-card { background: white; border-radius: 16px; padding: 15px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .date-col { display: flex; flex-direction: column; }
        .day { font-weight: bold; font-size: 1.1rem; color: #333; }
        .full-date { font-size: 0.85rem; color: #666; }
        .time-col { text-align: right; }
        .time-entry { color: #006A6A; font-weight: 500; }
        .time-exit { color: #B00020; font-size: 0.9rem; }
    </style>
</head>
<body>
    <jsp:include page="../shared/navbar.jsp" />
    
    <div class="container">
        <h3>Mis Marcaciones Recientes</h3>
        
        <c:forEach var="a" items="${listaAsistencia}">
            <div class="history-card">
                <div class="date-col">
                    <span class="day">Asistencia</span>
                    <span class="full-date">${a.fecha}</span>
                    <span style="font-size: 0.8rem; margin-top: 5px; display:flex; align-items:center; gap:4px;">
                        <md-icon style="font-size:16px;">${a.modo == 'QR' ? 'qr_code' : 'location_on'}</md-icon> 
                        ${a.modo}
                    </span>
                </div>
                <div class="time-col">
                    <div class="time-entry">IN: ${a.horaEntrada}</div>
                    <div class="time-exit">OUT: ${a.horaSalida != null ? a.horaSalida : '--:--'}</div>
                </div>
            </div>
        </c:forEach>
        
        <md-outlined-button onclick="window.history.back()" style="width:100%">Regresar</md-outlined-button>
    </div>
</body>
</html>