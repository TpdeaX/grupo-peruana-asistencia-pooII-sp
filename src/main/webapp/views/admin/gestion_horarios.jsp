<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Horarios</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .schedule-grid {
            display: grid;
            /* grid-template-columns set inline */
            border: 1px solid #dee2e6;
        }
        .schedule-header {
            font-weight: bold;
            text-align: center;
            background-color: #343a40;
            color: white;
            padding: 10px;
            border: 1px solid #454d55;
        }
        .schedule-time {
            font-weight: bold;
            text-align: center;
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            padding: 10px;
        }
        .schedule-cell {
            border: 1px solid #dee2e6;
            padding: 5px;
            min-height: 50px;
            position: relative;
        }
        .shift-block {
            background-color: #007bff;
            color: white;
            padding: 5px;
            border-radius: 4px;
            font-size: 0.8em;
            text-align: center;
            cursor: pointer;
            display: block;
            text-decoration: none;
        }
        .shift-block:hover {
            background-color: #0056b3;
            color: white;
        }
    </style>
</head>
<body>
    <jsp:include page="/views/shared/navbar.jsp" />
    
    <div class="container-fluid mt-4">
        <h2>Programación de Turnos</h2>
        
        <form action="${pageContext.request.contextPath}/horarios" method="get" class="row g-3 mb-4 align-items-end">
            <div class="col-auto">
                <label for="fecha" class="form-label">Fecha</label>
                <input type="date" class="form-control" id="fecha" name="fecha" value="${fechaSeleccionada}">
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary">Ver Horario</button>
            </div>
            <c:if test="${isAdmin}">
                <div class="col-auto ms-auto">
                    <a href="${pageContext.request.contextPath}/horarios/nuevo" class="btn btn-success">Nuevo Turno</a>
                </div>
            </c:if>
        </form>

        <c:set var="empCount" value="${empty empleados ? 0 : empleados.size()}" />
        <c:set var="gridStyle" value="grid-template-columns: 100px;" />
        <c:if test="${empCount > 0}">
            <c:set var="gridStyle" value="grid-template-columns: 100px repeat(${empCount}, 1fr);" />
        </c:if>

        <div class="schedule-grid" style="${gridStyle}">
            <!-- Header Row -->
            <div class="schedule-header">HORA</div>
            <c:forEach items="${empleados}" var="emp">
                <div class="schedule-header">${emp.nombres}</div>
            </c:forEach>

            <!-- Time Rows (7:00 to 22:00) -->
            <c:forEach begin="7" end="22" var="hour">
                <div class="schedule-time">${hour}:00</div>
                
                <c:forEach items="${empleados}" var="emp">
                    <div class="schedule-cell">
                        <c:forEach items="${horarios}" var="h">
                            <c:if test="${h.empleado.id == emp.id}">
                                <!-- Check if this hour falls within the shift -->
                                <c:set var="hStart" value="${h.horaInicio.hour}" />
                                <c:set var="hEnd" value="${h.horaFin.hour}" />
                                
                                <c:if test="${hour >= hStart && hour < hEnd}">
                                    <c:choose>
                                        <c:when test="${isAdmin}">
                                            <a href="${pageContext.request.contextPath}/horarios/editar?id=${h.id}" class="shift-block" 
                                               style="background-color: ${h.tipoTurno == 'Caja' ? '#ffb6c1' : 
                                                                         (h.tipoTurno == 'Stock' ? '#ffc107' : 
                                                                         (h.tipoTurno == 'Atencion' ? '#90ee90' : 
                                                                         (h.tipoTurno == 'Pesado' ? '#dda0dd' : 
                                                                         (h.tipoTurno == 'Despacho' ? '#87ceeb' : 
                                                                         (h.tipoTurno == 'Refrigerio' ? '#f5f5dc; color: black;' : 
                                                                         (h.tipoTurno == 'Caja 2do Nivel' ? '#ff69b4' : 
                                                                         (h.tipoTurno == 'Despacho PreVenta' ? '#4682b4' : '#17a2b8')))))))}">
                                                ${h.tipoTurno}
                                                <c:if test="${hour == hStart}">
                                                    <br><small>${h.horaInicio} - ${h.horaFin}</small>
                                                </c:if>
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="shift-block" 
                                               style="background-color: ${h.tipoTurno == 'Caja' ? '#ffb6c1' : 
                                                                         (h.tipoTurno == 'Stock' ? '#ffc107' : 
                                                                         (h.tipoTurno == 'Atencion' ? '#90ee90' : 
                                                                         (h.tipoTurno == 'Pesado' ? '#dda0dd' : 
                                                                         (h.tipoTurno == 'Despacho' ? '#87ceeb' : 
                                                                         (h.tipoTurno == 'Refrigerio' ? '#f5f5dc; color: black;' : 
                                                                         (h.tipoTurno == 'Caja 2do Nivel' ? '#ff69b4' : 
                                                                         (h.tipoTurno == 'Despacho PreVenta' ? '#4682b4' : '#17a2b8')))))))}; cursor: default;">
                                                ${h.tipoTurno}
                                                <c:if test="${hour == hStart}">
                                                    <br><small>${h.horaInicio} - ${h.horaFin}</small>
                                                </c:if>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </c:if>
                        </c:forEach>
                    </div>
                </c:forEach>
            </c:forEach>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
