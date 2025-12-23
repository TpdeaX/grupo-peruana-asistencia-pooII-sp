<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Solicitud de Justificación | Grupo Peruana</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <style>
        .page-container {
            max-width: 700px;
            margin: 40px auto;
            padding: 0 20px;
            animation: fadeIn 0.4s ease-out;
        }

        /* Custom Radio Selector */
        .radio-group {
            display: flex; gap: 16px; margin-bottom: 24px;
        }
        .radio-card {
            flex: 1;
            position: relative;
            border: 1px solid var(--md-sys-color-outline);
            border-radius: 8px;
            padding: 16px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px;
            text-align: center;
        }
        .radio-card:hover { background-color: rgba(103, 80, 164, 0.04); }
        .radio-card.selected {
            background-color: var(--md-sys-color-secondary-container);
            border-color: var(--md-sys-color-primary);
            color: var(--md-sys-color-on-secondary-container);
        }
        .radio-card input { display: none; }
        .radio-card .icon { font-size: 24px; color: var(--md-sys-color-primary); }
        
        /* File Upload */
        .file-upload-area {
            border: 2px dashed var(--md-sys-color-outline-variant);
            border-radius: 12px;
            padding: 32px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s;
        }
        .file-upload-area:hover {
            border-color: var(--md-sys-color-primary);
            background-color: rgba(103, 80, 164, 0.02);
        }
        .file-upload-area.has-file {
            border-color: var(--md-sys-color-success);
            background-color: var(--md-sys-color-success-container);
        }
        
        /* Grid */
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }

        /* Detail Table */
        .detail-table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
        .detail-table td { background: var(--md-sys-color-surface); padding: 8px; border: 1px solid var(--md-sys-color-outline-variant); border-radius: 4px; }
        .detail-table input { border: none; width: 100%; outline: none; background: transparent; font-family: inherit; }
    </style>
</head>
<body>

    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />

    <div class="page-container">
        <div class="card">
            <div class="card-header" style="text-align: center;">
                <h2>${justificacion.id == 0 ? 'Nueva Solicitud' : 'Editar Solicitud'}</h2>
                <div style="color: var(--md-sys-color-secondary);">Ingresa los detalles de tu justificación</div>
            </div>

            <form action="${pageContext.request.contextPath}/justificaciones/guardar" method="post" enctype="multipart/form-data" class="card-body">
                <input type="hidden" name="id" value="${justificacion.id}">

                <div class="grid-2">
                    <div class="md-input-group">
                        <input type="date" id="fechaInicio" name="fechaInicio" class="md-input" required value="${justificacion.fechaInicio}" placeholder=" ">
                        <label class="md-label">Fecha Inicio</label>
                    </div>
                    <div class="md-input-group">
                        <input type="date" id="fechaFin" name="fechaFin" class="md-input" required value="${justificacion.fechaFin}" placeholder=" ">
                        <label class="md-label">Fecha Fin</label>
                    </div>
                </div>

                <label style="display: block; margin-bottom: 12px; font-size: 0.9rem; font-weight: 500; color: var(--md-sys-color-on-surface-variant);">Tipo de Justificación</label>
                <div class="radio-group">
                    <label class="radio-card" onclick="selectMode(this)">
                        <input type="radio" name="modeSelector" value="DIARIA" onchange="changeMode()" checked>
                        <span class="material-symbols-outlined icon">calendar_view_day</span>
                        <span style="font-size: 0.9rem; font-weight: 500;">Días Completos</span>
                    </label>
                    <label class="radio-card" onclick="selectMode(this)">
                        <input type="radio" name="modeSelector" value="HORAS_FIJAS" onchange="changeMode()">
                        <span class="material-symbols-outlined icon">schedule</span>
                        <span style="font-size: 0.9rem; font-weight: 500;">Horas (Fijo)</span>
                    </label>
                    <label class="radio-card" onclick="selectMode(this)">
                        <input type="radio" name="modeSelector" value="HORAS_CUSTOM" onchange="changeMode()">
                        <span class="material-symbols-outlined icon">edit_calendar</span>
                        <span style="font-size: 0.9rem; font-weight: 500;">Horas (Detalle)</span>
                    </label>
                </div>
                
                <input type="checkbox" id="esPorHoras" name="esPorHoras" style="display: none;">
                <input type="hidden" id="hasDetails" value="${not empty justificacion.detalles}">
                <input type="hidden" id="isHours" value="${justificacion.esPorHoras}">

                <!-- Fixed Hours -->
                <div id="horasContainer" class="grid-2" style="display: none; animation: slideInUp 0.3s ease;">
                    <div class="md-input-group">
                        <input type="time" id="horaInicio" name="horaInicio" class="md-input" value="${justificacion.horaInicio}" placeholder=" ">
                        <label class="md-label">Hora Inicio</label>
                    </div>
                    <div class="md-input-group">
                        <input type="time" id="horaFin" name="horaFin" class="md-input" value="${justificacion.horaFin}" placeholder=" ">
                        <label class="md-label">Hora Fin</label>
                    </div>
                </div>

                <!-- Custom Details -->
                <div id="detallesContainer" style="display: none; margin-bottom: 24px; animation: slideInUp 0.3s ease;">
                     <div style="background: var(--md-sys-color-surface-variant); padding: 16px; border-radius: 8px;">
                         <div style="margin-bottom: 8px; font-weight: 500;">Detalle de Horarios</div>
                         <table class="detail-table" id="tablaDetalles">
                             <tbody id="tbodyDetalles">
                                 <c:forEach items="${justificacion.detalles}" var="det" varStatus="status">
                                     <tr>
                                         <td><input type="date" name="detalles[${status.index}].fecha" value="${det.fecha}" required></td>
                                         <td><input type="time" name="detalles[${status.index}].horaInicio" value="${det.horaInicio}" required></td>
                                         <td><input type="time" name="detalles[${status.index}].horaFin" value="${det.horaFin}" required></td>
                                         <td style="border:none; background: transparent; width: 40px;">
                                             <button type="button" class="btn-icon btn-danger" onclick="removeRow(this)">
                                                <span class="material-symbols-outlined">delete</span>
                                             </button>
                                         </td>
                                     </tr>
                                 </c:forEach>
                             </tbody>
                         </table>
                         <button type="button" class="btn btn-secondary" style="width: 100%; margin-top: 8px;" onclick="addDetalleRow()">
                            <span class="material-symbols-outlined">add</span> Agregar Día
                         </button>
                     </div>
                </div>

                <div class="md-input-group">
                    <textarea id="motivo" name="motivo" class="md-input" style="height: 120px; resize: none;" required placeholder=" ">${justificacion.motivo}</textarea>
                    <label class="md-label">Motivo de la justificación</label>
                </div>

                <div style="margin-bottom: 24px;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 500; color: var(--md-sys-color-on-surface-variant);">Evidencia (Opcional)</label>
                    <label class="file-upload-area" id="dropzone">
                        <input type="file" name="evidencia" id="evidencia" style="display: none;" onchange="updateFileName(this)" ${justificacion.id == 0 ? 'required' : ''}>
                        <span class="material-symbols-outlined" style="font-size: 40px; color: var(--md-sys-color-primary);">cloud_upload</span>
                        <div style="margin-top: 8px; color: var(--md-sys-color-on-surface);">
                            <span id="fileNameText">Click para subir archivo</span>
                        </div>
                        <div style="font-size: 0.8em; color: var(--md-sys-color-secondary);">PDF, JPG, PNG</div>
                    </label>
                    <c:if test="${not empty justificacion.evidenciaUrl}">
                        <div style="margin-top: 8px; font-size: 0.85em; color: var(--md-sys-color-primary);">
                            <span class="material-symbols-outlined" style="vertical-align: middle; font-size: 16px;">check_circle</span> 
                            Archivo actual ya adjuntado
                        </div>
                    </c:if>
                </div>

                <div style="display: flex; gap: 16px; margin-top: 32px;">
                    <a href="${pageContext.request.contextPath}/justificaciones" class="btn btn-secondary" style="flex: 1;">Cancelar</a>
                    <button type="submit" class="btn btn-primary" style="flex: 1;">Guardar Solicitud</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        let detalleIndex = ${justificacion.detalles != null ? justificacion.detalles.size() : 0};

        function selectMode(element) {
            // Visual selection
            document.querySelectorAll('.radio-card').forEach(c => c.classList.remove('selected'));
            element.classList.add('selected');
            // Trigger radio click
            const radio = element.querySelector('input[type="radio"]');
            radio.checked = true;
            changeMode();
        }

        function changeMode() {
            const mode = document.querySelector('input[name="modeSelector"]:checked').value;
            const esPorHorasCheck = document.getElementById('esPorHoras');
            const fixedContainer = document.getElementById('horasContainer');
            const customContainer = document.getElementById('detallesContainer');
            const hInicio = document.getElementById('horaInicio');
            const hFin = document.getElementById('horaFin');

            if (mode === 'DIARIA') {
                esPorHorasCheck.checked = false;
                fixedContainer.style.display = 'none';
                customContainer.style.display = 'none';
                hInicio.disabled = true; hFin.disabled = true;
                disableDetalles(true);
            } else if (mode === 'HORAS_FIJAS') {
                esPorHorasCheck.checked = true;
                fixedContainer.style.display = 'grid'; // Grid for layout
                customContainer.style.display = 'none';
                hInicio.disabled = false; hFin.disabled = false;
                hInicio.required = true; hFin.required = true;
                disableDetalles(true);
            } else if (mode === 'HORAS_CUSTOM') {
                esPorHorasCheck.checked = true;
                fixedContainer.style.display = 'none';
                customContainer.style.display = 'block';
                hInicio.disabled = true; hFin.disabled = true;
                hInicio.required = false; hFin.required = false;
                disableDetalles(false);
                if (detalleIndex === 0 && document.querySelectorAll('#tbodyDetalles tr').length === 0) {
                     addDetalleRow(); 
                }
            }
        }

        function disableDetalles(disable) {
            const inputs = document.querySelectorAll('#tbodyDetalles input');
            inputs.forEach(inp => inp.disabled = disable);
        }

        function addDetalleRow() {
            const tbody = document.getElementById('tbodyDetalles');
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><input type="date" name="detalles[` + detalleIndex + `].fecha" required placeholder="Fecha"></td>
                <td><input type="time" name="detalles[` + detalleIndex + `].horaInicio" required></td>
                <td><input type="time" name="detalles[` + detalleIndex + `].horaFin" required></td>
                <td style="border:none; background:transparent;"><button type="button" class="btn-icon btn-danger" onclick="removeRow(this)"><span class="material-symbols-outlined">delete</span></button></td>
            `;
            tbody.appendChild(tr);
            detalleIndex++;
            
            const mainDate = document.getElementById('fechaInicio').value;
            if(mainDate) {
                 const inputs = tr.querySelectorAll('input[type="date"]');
                 if(inputs[0]) inputs[0].value = mainDate;
            }
        }

        function removeRow(btn) {
            const tr = btn.closest('tr');
            tr.remove();
            reIndexRows();
        }

        function reIndexRows() {
            const rows = document.querySelectorAll('#tbodyDetalles tr');
            rows.forEach((row, idx) => {
                row.querySelectorAll('input').forEach(input => {
                    const name = input.name;
                    const newName = name.replace(/detalles\[\d+\]/, 'detalles[' + idx + ']');
                    input.name = newName;
                });
            });
            detalleIndex = rows.length;
        }

        function init() {
            const hasDetails = document.getElementById('hasDetails').value === 'true';
            const isHours = document.getElementById('isHours').value === 'true';
            
            let val = 'DIARIA';
            if (hasDetails) {
                val = 'HORAS_CUSTOM';
            } else if (isHours) {
                val = 'HORAS_FIJAS';
            }
            
            // Set initial radio
            const radio = document.querySelector('input[value="' + val + '"]');
            if(radio) {
                radio.checked = true;
                radio.closest('.radio-card').classList.add('selected');
            }
            changeMode();
        }

        document.getElementById('fechaInicio').addEventListener('change', function() {
            const fin = document.getElementById('fechaFin');
            if (!fin.value) {
                fin.value = this.value;
            }
        });

        function updateFileName(input) {
            const text = document.getElementById('fileNameText');
            const zone = document.getElementById('dropzone');
            if (input.files && input.files.length > 0) {
                text.innerText = "Archivo: " + input.files[0].name;
                text.style.fontWeight = "bold";
                zone.classList.add('has-file');
            } else {
                text.innerText = "Click para subir archivo";
                zone.classList.remove('has-file');
            }
        }
        
        window.addEventListener('load', init);
    </script>

    </div>
</body>
</html>
