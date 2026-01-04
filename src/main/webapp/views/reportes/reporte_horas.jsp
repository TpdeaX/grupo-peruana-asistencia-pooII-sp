<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Horas | Grupo Peruana</title>
    
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

        @keyframes fade-in-down {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .compact-table th, .compact-table td {
            padding: 12px 12px !important;
            font-size: 0.9rem;
        }
        
        /* Specific coloring for stats */
        .stat-positive { color: #2e7d32; font-weight: 500; }
        .stat-negative { color: #c62828; font-weight: 500; }
        .stat-neutral { color: var(--md-sys-color-on-surface); }
        .stat-warning { color: #ef6c00; font-weight: 500; }

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
                            <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem; margin: 0;">Reporte de Horas</h1>
                            <p style="color: var(--md-sys-color-secondary); margin-top: 4px; margin-bottom: 0;">Resumen de horas trabajadas por empleado</p>
                        </div>
                    </div>
                </div>
                
                <div style="display: flex; gap: 8px; align-items: center;">
                    <md-filled-tonal-button onclick="window.print()">
                        <md-icon slot="icon">print</md-icon>
                        Imprimir
                    </md-filled-tonal-button>
                </div>
            </div>

            <!-- Filters Card -->
            <div class="card" style="margin-bottom: 24px; padding: 24px;">
                <form id="filterForm" action="${pageContext.request.contextPath}/reportes/horas" method="post">
                    <input type="hidden" name="page" id="pageInput" value="${pagina != null ? pagina.number : 0}">
                    <input type="hidden" name="size" id="sizeInput" value="${size}">
                    
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
                            <md-filled-button type="submit">
                                <md-icon slot="icon">filter_list</md-icon>
                                Generar
                            </md-filled-button>
                        </div>
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
                                    <th style="text-align: left;">Empleado</th>
                                    <th style="text-align: center;">Horas Prog.</th>
                                    <th style="text-align: center;">Horas Trab.</th>
                                    <th style="text-align: center;">Diferencia</th>
                                    <th style="text-align: center;">Tardanza (min)</th>
                                    <th style="text-align: center;">Días Asist.</th>
                                    <th style="text-align: center;">Días Falta</th>
                                    <th style="text-align: center;">Feriados Lab.</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="row" items="${reporte}">
                                    <tr style="border-bottom: 1px solid var(--md-sys-color-outline-variant);">
                                        <td>
                                            <div style="font-weight: 500;">${row.nombreEmpleado}</div>
                                            <div style="font-size: 0.8rem; color: var(--md-sys-color-secondary);">${row.sucursal}</div>
                                        </td>
                                        
                                        <td style="text-align: center;">
                                            <fmt:formatNumber value="${row.totalHorasProgramadas}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                        </td>
                                        
                                        <td style="text-align: center;">
                                            <fmt:formatNumber value="${row.totalHorasTrabajadas}" type="number" minFractionDigits="2" maxFractionDigits="2"/>
                                        </td>
                                        
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${row.totalHorasExtras > 0}">
                                                    <span class="stat-positive">+<fmt:formatNumber value="${row.totalHorasExtras}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                                </c:when>
                                                <c:when test="${row.totalHorasDeuda > 0}">
                                                    <span class="stat-negative">-<fmt:formatNumber value="${row.totalHorasDeuda}" minFractionDigits="2" maxFractionDigits="2"/></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="stat-neutral">0.00</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        
                                        <td style="text-align: center;">
                                            <c:if test="${row.totalMinutosTardanza > 0}">
                                                <span class="stat-warning">${row.totalMinutosTardanza}</span>
                                            </c:if>
                                            <c:if test="${row.totalMinutosTardanza == 0}">-</c:if>
                                        </td>
                                        
                                        <td style="text-align: center;">${row.diasAsistidos}</td>
                                        
                                        <td style="text-align: center;">
                                            <c:if test="${row.diasFaltas > 0}">
                                                <span class="stat-negative">${row.diasFaltas}</span>
                                            </c:if>
                                            <c:if test="${row.diasFaltas == 0}">-</c:if>
                                        </td>

                                        <td style="text-align: center;">${row.diasFeriadosLaborados}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${not empty pagina}">
                        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; padding: 16px 24px; border-top: 1px solid var(--md-sys-color-outline-variant); gap: 16px;">
                            <div style="display: flex; align-items: center; gap: 24px;">
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); font-weight: 500;">Filas:</span>
                                    <md-outlined-select onchange="changeSize(this.value)" style="min-width: 80px;">
                                        <md-select-option value="10" ${size == 10 ? 'selected' : ''}><div slot="headline">10</div></md-select-option>
                                        <md-select-option value="25" ${size == 25 ? 'selected' : ''}><div slot="headline">25</div></md-select-option>
                                        <md-select-option value="50" ${size == 50 ? 'selected' : ''}><div slot="headline">50</div></md-select-option>
                                    </md-outlined-select>
                                </div>
                                <div style="font-size: 0.9rem; color: var(--md-sys-color-on-surface); font-weight: 500;">
                                    ${pagina.number + 1} - ${size > pagina.totalElements ? pagina.totalElements : (pagina.number * size) + reporte.size()} de ${pagina.totalElements}
                                </div>
                            </div>
                            <div style="display: flex; align-items: center; gap: 16px;">
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <md-icon-button ${pagina.first ? 'disabled' : ''} onclick="changePage(${pagina.number - 1})">
                                        <md-icon>chevron_left</md-icon>
                                    </md-icon-button>
                                    <md-icon-button ${pagina.last ? 'disabled' : ''} onclick="changePage(${pagina.number + 1})">
                                        <md-icon>chevron_right</md-icon>
                                    </md-icon-button>
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
                </div>
            </c:if>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
             const msg = "${not empty error ? error : ''}";
             if(msg) showToast('Error', msg, 'error', 'error');
        });

        function limpiarFiltros() {
            document.querySelector('[name="sucursalId"]').value = "";
            document.querySelector('[name="fechaInicio"]').value = "";
            document.querySelector('[name="fechaFin"]').value = "";
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
    </script>
</body>
</html>
