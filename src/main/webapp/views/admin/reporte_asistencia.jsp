<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <title>Reporte de Asistencias</title>
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
        
        .header-container { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
        h1 { color: #1f1f1f; margin: 0; font-size: 24px; }

        .table-card {
            background: white;
            border-radius: 16px;
            overflow: hidden; 
            box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
        }

        table { width: 100%; border-collapse: collapse; }
        
        th { background-color: #f5f5f5; color: #444746; font-weight: 500; text-align: left; padding: 16px; font-size: 14px; }
        td { padding: 16px; border-bottom: 1px solid #e0e0e0; color: #1f1f1f; font-size: 14px; vertical-align: middle;}
        tr:last-child td { border-bottom: none; }
        tr:hover { background-color: #f9f9f9; }

   
        .badge { padding: 4px 12px; border-radius: 16px; font-size: 12px; font-weight: 500; }
        .badge-qr { background-color: #e8f5e9; color: #1b5e20; }
        .badge-gps { background-color: #e3f2fd; color: #0d47a1; } 
        
        .hora-null { color: #9e9e9e; font-style: italic; }
    </style>
</head>
<body>

  <div class="header-container">
        <div style="display:flex; align-items:center; gap:10px;">
            <md-icon-button href="${pageContext.request.contextPath}/admin">
                <span class="material-symbols-outlined">arrow_back</span>
            </md-icon-button>
            <h1>Reporte General de Asistencias</h1>
        </div>
        
        <div style="display:flex; gap: 10px;">
            <md-outlined-button onclick="window.location.href='${pageContext.request.contextPath}/admin/exportar/excel'">
                <span class="material-symbols-outlined" slot="icon">table_view</span>
                Excel
            </md-outlined-button>

            <md-filled-button onclick="window.location.href='${pageContext.request.contextPath}/admin/exportar/pdf'">
                <span class="material-symbols-outlined" slot="icon">picture_as_pdf</span>
                PDF
            </md-filled-button>
        </div>
        
    </div>

    <div class="table-card">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Empleado</th>
                    <th>Fecha</th>
                    <th>Hora Entrada</th>
                    <th>Hora Salida</th>
                    <th>Método</th>
                    <th>Estado/Obs</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${listaAsistencia}" var="a">
                    <tr>
                        <td>#${a.id}</td>
                        <td>
                            <strong>${a.empleado.nombres} ${a.empleado.apellidos}</strong><br>
                            <small style="color:#757575;">DNI: ${a.empleado.dni}</small>
                        </td>
                        <td>${a.fecha}</td>
                        
                        <td style="font-weight: 500; color: #006C4C;">
                            ${a.horaEntrada}
                        </td>

                        <td>
                            <c:if test="${not empty a.horaSalida}">
                                ${a.horaSalida}
                            </c:if>
                            <c:if test="${empty a.horaSalida}">
                                <span class="hora-null">--:--</span>
                            </c:if>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${a.modo == 'QR' || a.modo == 'QR_DINAMICO'}">
                                    <span class="badge badge-qr">QR Code</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-gps">GPS / Otro</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td>${a.observacion}</td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty listaAsistencia}">
                    <tr>
                        <td colspan="7" style="text-align:center; padding: 40px;">
                            <span class="material-symbols-outlined" style="font-size:48px; color:#bdbdbd;">inbox</span>
                            <p style="color:#757575;">No hay registros de asistencia aún.</p>
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

</body>
</html>