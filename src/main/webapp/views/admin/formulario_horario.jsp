<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${horario != null ? 'Editar' : 'Nuevo'} Turno</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/views/shared/navbar.jsp" />
    
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h4>${horario != null ? 'Editar' : 'Nuevo'} Turno</h4>
                    </div>
                    <div class="card-body">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">${error}</div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/horarios/guardar" method="post">
                            <input type="hidden" name="id" value="${horario.id}">
                            
                            <div class="mb-3">
                                <label for="empleadoId" class="form-label">Empleado</label>
                                <select class="form-select" id="empleadoId" name="empleadoId" required>
                                    <c:forEach items="${empleados}" var="emp">
                                        <option value="${emp.id}" ${horario.empleado.id == emp.id ? 'selected' : ''}>
                                            ${emp.nombres} ${emp.apellidos}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label for="fecha" class="form-label">Fecha</label>
                                <input type="date" class="form-control" id="fecha" name="fecha" 
                                       value="${horario != null ? horario.fecha : param.fecha}" required>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="horaInicio" class="form-label">Hora Inicio</label>
                                    <input type="time" class="form-control" id="horaInicio" name="horaInicio" 
                                           value="${horario.horaInicio}" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="horaFin" class="form-label">Hora Fin</label>
                                    <input type="time" class="form-control" id="horaFin" name="horaFin" 
                                           value="${horario.horaFin}" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="tipoTurno" class="form-label">Tipo de Turno</label>
                                <select class="form-select" id="tipoTurno" name="tipoTurno" required>
                                    <option value="">Seleccione un turno</option>
                                    <c:forEach items="${tiposTurno}" var="t">
                                        <option value="${t.nombre}" ${horario.tipoTurno == t.nombre ? 'selected' : ''}>${t.nombre}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary">Guardar</button>
                                <a href="${pageContext.request.contextPath}/horarios" class="btn btn-secondary">Cancelar</a>
                            </div>
                        </form>
                        
                        <c:if test="${horario != null}">
                            <form action="${pageContext.request.contextPath}/horarios/eliminar" method="post" class="mt-3" onsubmit="return confirm('¿Estás seguro de eliminar este turno?');">
                                <input type="hidden" name="id" value="${horario.id}">
                                <button type="submit" class="btn btn-danger w-100">Eliminar Turno</button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
