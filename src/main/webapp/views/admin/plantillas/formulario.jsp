<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${plantilla != null ? 'Editar' : 'Nueva'} Plantilla Semanal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .day-row { background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 15px; border: 1px solid #dee2e6; }
        .day-label { font-weight: bold; font-size: 1.1em; }
    </style>
</head>
<body>
    <jsp:include page="/views/shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/shared/header.jsp" />
    
    <div class="container mt-4 mb-5">
        <div class="card shadow">
            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                <h4 class="mb-0">${plantilla != null ? 'Editar' : 'Nueva'} Plantilla Semanal</h4>
                <div>
                     <button type="button" class="btn btn-light btn-sm" onclick="copiarLunes()">Copiar Lunes a Todo</button>
                     <button type="button" class="btn btn-light btn-sm" onclick="limpiarTodo()">Limpiar Todo</button>
                </div>
            </div>
            <div class="card-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/plantillas/guardar" method="post" id="templateForm">
                    <input type="hidden" name="id" value="${plantilla.id}">
                    
                    <div class="mb-4">
                        <label for="nombre" class="form-label">Nombre de la Plantilla</label>
                        <input type="text" class="form-control form-control-lg" id="nombre" name="nombre" 
                               placeholder="Ej: Horario Oficina Completo"
                               value="${plantilla.nombre}" required>
                    </div>

                    <div class="d-grid gap-3">
                        <c:set var="dias" value="${['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']}" />
                        
                        <c:forEach begin="0" end="6" var="i">
                            <!-- Find detail for this day if editing -->
                            <c:set var="detalle" value="${null}" />
                            <c:if test="${plantilla != null}">
                                <c:forEach items="${plantilla.detalles}" var="d">
                                    <c:if test="${d.diaSemana == (i + 1)}">
                                        <c:set var="detalle" value="${d}" />
                                    </c:if>
                                </c:forEach>
                            </c:if>

                            <div class="day-row" id="day-${i}">
                                <div class="row align-items-center">
                                    <div class="col-md-2">
                                        <div class="day-label">${dias[i]}</div>
                                        <small class="text-muted">Día ${i + 1}</small>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label small">Inicio</label>
                                        <input type="time" class="form-control" name="horaInicio" value="${detalle != null && !detalle.esDescanso ? detalle.horaInicio : ''}">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label small">Fin</label>
                                        <input type="time" class="form-control" name="horaFin" value="${detalle != null && !detalle.esDescanso ? detalle.horaFin : ''}">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label small">Turno</label>
                                        <select class="form-select" name="tipoTurno">
                                            <option value="">(Descanso)</option>
                                            <c:forEach items="${tiposTurno}" var="t">
                                                <option value="${t.nombre}" ${detalle != null && detalle.tipoTurno == t.nombre ? 'selected' : ''}>${t.nombre}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-1 text-end">
                                        <c:if test="${i > 0}">
                                            <button type="button" class="btn btn-outline-secondary btn-sm" title="Copiar del día anterior" onclick="copiarAnterior(${i})">
                                                <i class="bi bi-arrow-up"></i> ^
                                            </button>
                                        </c:if>
                                        <button type="button" class="btn btn-outline-danger btn-sm mt-1" title="Limpiar" onclick="limpiarDia(${i})">
                                            X
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="d-grid gap-2 mt-4">
                        <button type="submit" class="btn btn-primary btn-lg">Guardar Plantilla Completa</button>
                        <a href="${pageContext.request.contextPath}/plantillas" class="btn btn-secondary">Cancelar</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function copiarAnterior(index) {
            if (index <= 0) return;
            const prevRow = document.getElementById('day-' + (index - 1));
            const currentRow = document.getElementById('day-' + index);
            
            const prevInputs = prevRow.querySelectorAll('input, select');
            const currentInputs = currentRow.querySelectorAll('input, select');
            
            for (let i = 0; i < prevInputs.length; i++) {
                currentInputs[i].value = prevInputs[i].value;
            }
        }

        function limpiarDia(index) {
            const row = document.getElementById('day-' + index);
            const inputs = row.querySelectorAll('input, select');
            inputs.forEach(input => input.value = '');
        }

        function limpiarTodo() {
            for(let i=0; i<7; i++) limpiarDia(i);
        }

        function copiarLunes() {
            const lunesRow = document.getElementById('day-0');
            const lunesInputs = lunesRow.querySelectorAll('input, select');
            
            for(let i=1; i<7; i++) { // Apply to Tue-Sun
                const row = document.getElementById('day-' + i);
                const inputs = row.querySelectorAll('input, select');
                for (let k = 0; k < inputs.length; k++) {
                    inputs[k].value = lunesInputs[k].value;
                }
            }
        }
    </script>
</body>
</html>
