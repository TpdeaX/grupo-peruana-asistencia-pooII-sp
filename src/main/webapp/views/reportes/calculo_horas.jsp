<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Asistencia | Grupo Peruana</title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    
    <!-- Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    
    <!-- Material Web Components -->
    <script type="importmap">
    {
      "imports": {
        "@material/web/": "https://esm.run/@material/web/"
      }
    }
    </script>
    <script type="module">
        import '@material/web/all.js';
        import {styles as typescaleStyles} from '@material/web/typography/md-typescale-styles.js';
        document.adoptedStyleSheets.push(typescaleStyles.styleSheet);
    </script>

    <style>
        .page-header {
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            margin-bottom: 24px;
        }

        .card {
            border: 1px solid var(--md-sys-color-outline-variant);
            box-shadow: var(--md-sys-elevation-1);
            border-radius: 20px;
            overflow: hidden;
            background: var(--md-sys-color-surface);
            animation: fade-in-down 0.5s ease-out;
        }

        /* Status colors */
        .status-asistio, .status-extra { color: var(--md-sys-color-on-success-container); font-weight: 500; background: var(--md-sys-color-success-container); padding: 4px 12px; border-radius: 8px; display: inline-flex; align-items: center; gap: 4px; }
        .status-falta { color: var(--md-sys-color-on-error-container); font-weight: 500; background: var(--md-sys-color-error-container); padding: 4px 12px; border-radius: 8px; display: inline-flex; align-items: center; gap: 4px; }
        .status-tardanza, .status-inconsistente { color: #e65100; font-weight: 500; background: #ffe0b2; padding: 4px 12px; border-radius: 8px; display: inline-flex; align-items: center; gap: 4px; border: 1px solid #ffcc80; }
        .status-feriado { color: #0d47a1; font-weight: 500; background: #e3f2fd; padding: 4px 12px; border-radius: 8px; display: inline-flex; align-items: center; gap: 4px; border: 1px solid #bbdefb; }

        .text-tardanza { color: #d32f2f; font-weight: bold; }
        .text-extra { color: #1976d2; font-weight: bold; }
        .text-money-neg { color: #d32f2f; }
        .text-money-pos { color: #2e7d32; }

        @keyframes fade-in-down {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .compact-table th, .compact-table td {
            padding: 12px 12px !important;
            font-size: 0.9rem;
        }
        
        .img-cell {
            width: 40px; height: 40px; 
            object-fit: cover; 
            border-radius: 8px; 
            border: 1px solid var(--md-sys-color-outline-variant);
            cursor: pointer;
            transition: transform 0.2s;
        }
        .img-cell:hover { transform: scale(1.1); }
        
        /* Modal Photo Style */
        .modal-photo-container {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 16px;
            background: rgba(0,0,0,0.05); /* Slight box background inside modal */
            border-radius: 12px;
        }
        
        /* Clickable headers */
        .sortable-header {
            cursor: pointer;
            user-select: none;
            transition: background-color 0.2s;
        }
        .sortable-header:hover {
            background-color: var(--md-sys-color-surface-container-high);
        }
        .sort-icon {
            font-size: 16px;
            vertical-align: middle;
            margin-left: 4px;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
        
        <div class="container">
            <!-- Header Section -->
            <div class="page-header" style="flex-wrap: wrap; gap: 16px;">
                <div style="flex: 1;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div>
                            <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem; margin: 0;">Reporte de Asistencia</h1>
                            <p style="color: var(--md-sys-color-secondary); margin-top: 4px; margin-bottom: 0;">Cálculo de horas, tardanzas y bonificaciones</p>
                        </div>
                    </div>
                </div>
                
                <div style="display: flex; gap: 8px; align-items: center;">
                    <md-filled-tonal-button onclick="window.print()">
                        <md-icon slot="icon">print</md-icon>
                        Imprimir
                    </md-filled-tonal-button>

                    <md-outlined-button onclick="exportarExcel()">
                        <md-icon slot="icon">table_view</md-icon>
                        Excel
                    </md-outlined-button>

                    <md-filled-button onclick="exportarPdf()">
                        <md-icon slot="icon">picture_as_pdf</md-icon>
                        PDF
                    </md-filled-button>
                </div>
            </div>

            <!-- Filters Card -->
            <div class="card" style="margin-bottom: 24px; padding: 24px;">
                <form id="filterForm" action="${pageContext.request.contextPath}/reportes/calculo" method="get">
                    <input type="hidden" name="page" id="pageInput" value="${pagina != null ? pagina.number : 0}">
                    <input type="hidden" name="size" id="sizeInput" value="${size}">
                    <!-- Hidden sort input, manipulated by JS -->
                    <input type="hidden" name="sort" id="sortInput" value="${sort != null ? sort : 'fecha_desc'}">

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; align-items: center;">
                        
                        <!-- Sucursal Select -->
                        <div style="min-width: 200px;">
                            <md-outlined-select label="Sucursal" name="sucursalId" style="width: 100%;">
                                <md-select-option value="" ${empty sucursalId ? 'selected' : ''}>
                                    <div slot="headline">-- Todas las Sucursales --</div>
                                </md-select-option>
                                <c:forEach var="s" items="${sucursales}">
                                    <md-select-option value="${s.id}" ${s.id == sucursalId ? 'selected' : ''}>
                                        <div slot="headline">${s.nombre}</div>
                                    </md-select-option>
                                </c:forEach>
                            </md-outlined-select>
                        </div>

                        <!-- Empleado Select -->
                        <div style="min-width: 200px;">
                            <md-outlined-select label="Empleado" name="empleadoId" style="width: 100%;">
                                <md-select-option value="" ${empty empleadoId ? 'selected' : ''}>
                                    <div slot="headline">-- Todos los Empleados --</div>
                                </md-select-option>
                                <c:forEach var="e" items="${empleados}">
                                    <md-select-option value="${e.id}" ${e.id == empleadoId ? 'selected' : ''}>
                                        <div slot="headline">${e.apellidos}, ${e.nombreCompleto}</div>
                                    </md-select-option>
                                </c:forEach>
                            </md-outlined-select>
                        </div>

                        <!-- Date Range -->
                        <md-outlined-text-field 
                            type="date"
                            label="Desde" 
                            name="fechaInicio" 
                            value="${fechaInicio}"
                            required>
                        </md-outlined-text-field>

                        <md-outlined-text-field 
                            type="date"
                            label="Hasta" 
                            name="fechaFin" 
                            value="${fechaFin}"
                            required>
                        </md-outlined-text-field>

                        <!-- Submit Button -->
                        <div style="display: flex; gap: 8px; justify-self: end;">
                            <md-outlined-button type="button" onclick="limpiarFiltros()">
                                Limpiar
                            </md-outlined-button>
                            <md-filled-button type="button" onclick="submitFilter()">
                                <md-icon slot="icon">filter_list</md-icon>
                                Generar
                            </md-filled-button>
                        </div>
                    </div>
                    
                    <!-- Sorting Controls Visual -->
                    <div style="margin-top: 16px; display: flex; align-items: center; gap: 12px; font-size: 0.9rem; color: var(--md-sys-color-secondary);">
                        <span>Ordenar por:</span>
                        <md-chip-set>
                            <md-filter-chip label="Fecha" ${sort == 'fecha_desc' ? 'selected' : ''} onclick="applySort('fecha_desc')"></md-filter-chip>
                            <md-filter-chip label="Nombre" ${sort == 'nombre_asc' ? 'selected' : ''} onclick="applySort('nombre_asc')"></md-filter-chip>
                            <md-filter-chip label="Tardanza" ${sort == 'tardanza_desc' ? 'selected' : ''} onclick="applySort('tardanza_desc')"></md-filter-chip>
                        </md-chip-set>
                    </div>
                </form>
            </div>

            <!-- Results Table -->
            <c:if test="${not empty reporte}">
                <div class="card" style="width: 100%;">
                    <div class="table-container" style="overflow-x: auto; width: 100%;">
                        <table class="compact-table" style="width: 100%; border-collapse: collapse;">
                            <thead>
                                <tr style="background: var(--md-sys-color-surface-container-low); border-bottom: 1px solid var(--md-sys-color-outline-variant);">
                                    <th class="sortable-header" onclick="toggleSort('fecha')">
                                        Fecha
                                        <span class="material-symbols-outlined sort-icon">${sort == 'fecha_asc' ? 'arrow_upward' : (sort == 'fecha_desc' ? 'arrow_downward' : 'sort')}</span>
                                    </th>
                                    <th class="sortable-header" onclick="toggleSort('nombre')">
                                        Empleado
                                        <span class="material-symbols-outlined sort-icon">${sort == 'nombre_asc' ? 'arrow_upward' : (sort == 'nombre_desc' ? 'arrow_downward' : 'sort')}</span>
                                    </th>
                                    <th>Horario</th>
                                    <th>Marcaciones</th>
                                    <th style="text-align: center;">Fotos</th>
                                    <th style="text-align: center;">Prog.</th>
                                    <th style="text-align: center;">Trab.</th>
                                    <th style="text-align: center;" class="sortable-header" onclick="toggleSort('tardanza')">
                                        Tard.
                                        <span class="material-symbols-outlined sort-icon">${sort == 'tardanza_desc' ? 'arrow_downward' : 'sort'}</span>
                                    </th>
                                    <th style="text-align: center;">Ext.</th>
                                    <th>Desc.</th>
                                    <th>Bonif.</th>
                                    <th>Modo</th>
                                    <th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="row" items="${reporte}">
                                    <tr style="border-bottom: 1px solid var(--md-sys-color-outline-variant);">
                                        <td>${row.fecha}</td>
                                        <td>
                                            <div style="font-weight: 500;">${row.nombreEmpleado}</div>
                                            <div style="font-size: 0.8rem; color: var(--md-sys-color-secondary);">${row.sucursal}</div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty row.horarioEntrada}">
                                                    <div style="font-size: 0.85rem;">${row.horarioEntrada} - ${row.horarioSalida}</div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--md-sys-color-outline);">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty row.asistenciaEntrada}">
                                                    <div style="font-size: 0.85rem;">
                                                        <span style="color: green;">Ent:</span> ${row.asistenciaEntrada}<br>
                                                        <span style="color: red;">Sal:</span> ${row.asistenciaSalida}
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--md-sys-color-outline);">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;">
                                            <div style="display: flex; gap: 4px; justify-content: center;">
                                                <c:choose>
                                                    <c:when test="${not empty row.fotoUrl}">
                                                        <img src="${pageContext.request.contextPath}/${row.fotoUrl}" 
                                                             class="img-cell" 
                                                             onclick="verFoto('${pageContext.request.contextPath}/${row.fotoUrl}', '${row.nombreEmpleado} - Entrada')" 
                                                             title="Entrada"
                                                             onerror="this.style.display='none'">
                                                    </c:when>
                                                    <c:otherwise><span style="color: var(--md-sys-color-outline);">-</span></c:otherwise>
                                                </c:choose>
                                                
                                                <c:choose>
                                                    <c:when test="${not empty row.fotoUrlSalida}">
                                                        <img src="${pageContext.request.contextPath}/${row.fotoUrlSalida}" 
                                                             class="img-cell" 
                                                             onclick="verFoto('${pageContext.request.contextPath}/${row.fotoUrlSalida}', '${row.nombreEmpleado} - Salida')" 
                                                             title="Salida"
                                                             onerror="this.style.display='none'">
                                                    </c:when>
                                                    <c:otherwise><!-- Space holder --></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                        <td style="text-align: center;">${row.horasProgramadas > 0 ? row.horasProgramadas : '-'}</td>
                                        <td style="text-align: center;">${row.horasTrabajadas > 0 ? row.horasTrabajadas : '-'}</td>
                                        
                                        <!-- Tardanza -->
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${row.minutosTardanza > 0}">
                                                     <span class="text-tardanza">${row.minutosTardanza}</span>
                                                </c:when>
                                                <c:otherwise><span style="color: var(--md-sys-color-outline);">-</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        
                                        <!-- Extras -->
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${row.minutosExtras > 0}">
                                                     <span class="text-extra">${row.minutosExtras}</span>
                                                </c:when>
                                                <c:otherwise><span style="color: var(--md-sys-color-outline);">-</span></c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Descuento -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${row.dineroDescuento > 0}">
                                                    <span class="text-money-neg">- S/. ${row.dineroDescuento}</span>
                                                </c:when>
                                                <c:otherwise><span style="color: var(--md-sys-color-outline);">-</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        
                                        <!-- Bonificacion -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${row.dineroBonificacion > 0}">
                                                    <span class="text-money-pos">+ S/. ${row.dineroBonificacion}</span>
                                                </c:when>
                                                <c:otherwise><span style="color: var(--md-sys-color-outline);">-</span></c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Modo -->
                                        <td>
                                            <span style="font-size: 0.8rem; padding: 2px 6px; background: var(--md-sys-color-surface-variant); border-radius: 4px;">
                                                ${row.modo != null ? row.modo : '-'}
                                            </span>
                                        </td>

                                        <!-- Estado -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${row.estado == 'ASISTIO'}">
                                                    <span class="status-asistio"><md-icon style="font-size: 16px;">check</md-icon> Asistió</span>
                                                </c:when>
                                                <c:when test="${row.estado == 'FALTA'}">
                                                    <span class="status-falta"><md-icon style="font-size: 16px;">close</md-icon> Falta</span>
                                                </c:when>
                                                <c:when test="${row.estado == 'TARDANZA'}">
                                                    <span class="status-tardanza"><md-icon style="font-size: 16px;">schedule</md-icon> Tardanza</span>
                                                </c:when>
                                                <c:when test="${row.estado == 'FERIADO'}">
                                                    <span class="status-feriado"><md-icon style="font-size: 16px;">celebration</md-icon> Feriado</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-inconsistente">${row.estado}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination Controls -->
                    <c:if test="${not empty pagina}">
                        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; padding: 16px 24px; border-top: 1px solid var(--md-sys-color-outline-variant); gap: 16px;">
                            
                             <!-- Items per page & Info -->
                            <div style="display: flex; align-items: center; gap: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); font-weight: 500;">Filas:</span>
                                    <md-outlined-select onchange="changeSize(this.value)" style="min-width: 80px;">
                                        <md-select-option value="10" ${size == 10 ? 'selected' : ''}><div slot="headline">10</div></md-select-option>
                                        <md-select-option value="25" ${size == 25 ? 'selected' : ''}><div slot="headline">25</div></md-select-option>
                                        <md-select-option value="50" ${size == 50 ? 'selected' : ''}><div slot="headline">50</div></md-select-option>
                                        <md-select-option value="100" ${size == 100 ? 'selected' : ''}><div slot="headline">100</div></md-select-option>
                                    </md-outlined-select>
                                </div>
                                <div style="font-size: 0.9rem; color: var(--md-sys-color-on-surface); font-weight: 500;">
                                    ${pagina.number + 1} - ${size > pagina.totalElements ? pagina.totalElements : (pagina.number * size) + reporte.size()} de ${pagina.totalElements}
                                </div>
                            </div>

                            <!-- Right Controls: Nav + Go To -->
                            <div style="display: flex; align-items: center; gap: 16px;">
                                
                                <!-- Navigation -->
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <md-icon-button ${pagina.first ? 'disabled' : ''} onclick="changePage(${pagina.number - 1})">
                                        <md-icon>chevron_left</md-icon>
                                    </md-icon-button>
                                    <md-icon-button ${pagina.last ? 'disabled' : ''} onclick="changePage(${pagina.number + 1})">
                                        <md-icon>chevron_right</md-icon>
                                    </md-icon-button>
                                </div>

                                <!-- Go To Page -->
                                <div style="display: flex; align-items: center; gap: 12px; padding-left: 16px; border-left: 1px solid var(--md-sys-color-outline-variant);">
                                    <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); white-space: nowrap;">Ir a página</span>
                                    <md-outlined-text-field 
                                        type="number" 
                                        min="1" 
                                        max="${pagina.totalPages}" 
                                        value="${pagina.number + 1}"
                                        onkeydown="if(event.key === 'Enter') { event.preventDefault(); changePage(this.value - 1); }"
                                        style="width: 80px;">
                                    </md-outlined-text-field>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </div>
            </c:if>

            <c:if test="${empty reporte && not empty param.fechaInicio}">
                <div style="text-align: center; margin-top: 40px; padding: 40px;">
                    <span class="material-symbols-outlined" style="font-size: 64px; color: var(--md-sys-color-outline);">content_paste_off</span>
                    <h3 style="color: var(--md-sys-color-secondary);">No se encontraron registros</h3>
                    <p>Intenta cambiar los filtros de búsqueda.</p>
                </div>
            </c:if>
        </div>
    </div>

    <!-- STANDARD PHOTO MODAL -->
    <md-dialog id="modal-foto" style="max-width: 90vw; max-height: 90vh;">
        <md-icon slot="icon">image</md-icon>
        <div slot="headline" id="modal-title">Evidencia Fotográfica</div>
        
        <form slot="content" id="form-foto" method="dialog">
            <div class="modal-photo-container">
                <img id="modal-img-src" src="" style="max-width: 100%; max-height: 60vh; border-radius: 8px; box-shadow: var(--md-sys-elevation-2);">
            </div>
            <div style="text-align: center; margin-top: 8px; color: var(--md-sys-color-on-surface-variant);">
                <span id="modal-caption" style="font-size: 0.9rem;"></span>
            </div>
        </form>

        <div slot="actions">
            <md-filled-button onclick="document.getElementById('modal-foto').close()">Cerrar</md-filled-button>
        </div>
    </md-dialog>

    <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
             // Check for Server-Side Messages
             const msg = "${not empty error ? error : ''}";
             if(msg) {
                 showToast('Error', msg, 'error', 'error');
             }

             // Handle implicit success/status if any (though this page is mostly read-only, filters trigger reload)
             // We could show "Reporte generado" toast if needed, but it might be annoying on every filter.
             // Let's keep it simple or check param 'status' if we implement actions later.
             
             // Fix dialog scrims
             if (typeof fixDialogScrim === 'function') {
                fixDialogScrim(['modal-foto']);
             }
        });

        function submitFilter() {
            document.getElementById('pageInput').value = 0; 
            document.getElementById('filterForm').submit();
        }

        function limpiarFiltros() {
            // Reset fields
            document.querySelector('[name="sucursalId"]').value = "";
            document.querySelector('[name="empleadoId"]').value = "";
            document.querySelector('[name="fechaInicio"]').value = ""; // Or reset to default?
            document.querySelector('[name="fechaFin"]').value = "";
            
            // Default dates logic could be here, or just let backend set them if null
            // For now, let's just clear and submit to see what defaults controller gives (likely current month)
            document.getElementById('filterForm').submit();
        }

        function changePage(page) {
            document.getElementById('pageInput').value = page;
            document.getElementById('filterForm').submit();
        }

        function changeSize(size) {
            document.getElementById('sizeInput').value = size;
            document.getElementById('pageInput').value = 0;
            document.getElementById('filterForm').submit();
        }

        function applySort(sortValue) {
            document.getElementById('sortInput').value = sortValue;
            submitFilter();
        }

        function toggleSort(field) {
            let currentSort = document.getElementById('sortInput').value;
            let newSort = field + '_desc'; // Default toggle

            if (currentSort === field + '_desc') {
                newSort = field + '_asc';
            } else if (currentSort === field + '_asc') {
                newSort = field + '_desc';
            }

            // Specific cases if needed (e.g. name defaults to asc)
            if (field === 'nombre' && !currentSort.startsWith('nombre')) {
                newSort = 'nombre_asc';
            }

            applySort(newSort);
        }

        function exportarExcel() {
            const form = document.getElementById('filterForm');
            const originalAction = form.action;
            form.action = '${pageContext.request.contextPath}/reportes/exportar/excel';
            form.submit();
            setTimeout(() => { form.action = originalAction; }, 500);
            showToast('Exportando', 'El archivo Excel se está descargando...', 'info', 'download');
        }

        function exportarPdf() {
            const form = document.getElementById('filterForm');
            const originalAction = form.action;
            form.action = '${pageContext.request.contextPath}/reportes/exportar/pdf';
            form.submit();
            setTimeout(() => { form.action = originalAction; }, 500);
            showToast('Exportando', 'El archivo PDF se está descargando...', 'info', 'download');
        }

        function verFoto(url, caption) {
            document.getElementById('modal-img-src').src = url;
            document.getElementById('modal-caption').innerText = caption || '';
            document.getElementById('modal-foto').show();
        }
    </script>
</body>
</html>
