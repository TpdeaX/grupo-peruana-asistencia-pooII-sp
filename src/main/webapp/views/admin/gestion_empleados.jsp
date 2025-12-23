<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Empleados | La Peruana</title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    
    <!-- Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    
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
        /* Shared Styles from Justificaciones */
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        
        .card {
            border: 1px solid var(--md-sys-color-outline-variant);
            box-shadow: var(--md-sys-elevation-1);
            border-radius: 20px;
            overflow: hidden;
            background: var(--md-sys-color-surface);
        }

        .compact-table th, .compact-table td { padding: 12px 16px !important; }
        .actions-cell { display: flex; gap: 4px; }

        /* Badge Styles */
        .badge { padding: 4px 12px; border-radius: 8px; font-size: 0.8rem; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; }
        .badge-admin { background-color: #e3f2fd; color: #1565c0; border: 1px solid #bbdefb; }
        .badge-emp { background-color: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }

        /* Form Styles inside Modal */
        .modal-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 8px; }
        .full-width { grid-column: span 2; }
        
        md-outlined-text-field, md-outlined-select { width: 100%; }
        
        /* DNI Input Group with Button */
        .dni-group { display: flex; gap: 8px; align-items: flex-start; }
        .dni-group md-outlined-text-field { flex-grow: 1; }
        
        #dniError { color: var(--md-sys-color-error); font-size: 0.8rem; margin-top: 4px; display: none; margin-left: 4px; }

        /* Animations */
        @keyframes fade-in-down {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes slide-in-up {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Staggered Animation for Table Rows */
        tbody tr {
            animation: slide-in-up 0.4s ease-out forwards;
        }
        
        tbody tr:nth-child(1) { animation-delay: 0.05s; }
        tbody tr:nth-child(2) { animation-delay: 0.1s; }
        tbody tr:nth-child(3) { animation-delay: 0.15s; }
        tbody tr:nth-child(4) { animation-delay: 0.2s; }
        tbody tr:nth-child(5) { animation-delay: 0.25s; }
        tbody tr:nth-child(6) { animation-delay: 0.3s; }
        tbody tr:nth-child(7) { animation-delay: 0.35s; }
        tbody tr:nth-child(8) { animation-delay: 0.4s; }
        tbody tr:nth-child(9) { animation-delay: 0.45s; }
        tbody tr:nth-child(10) { animation-delay: 0.5s; }
    </style>
</head>
<body>
    <div id="toast-mount-point" style="display:none;"></div>
    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
        
        <div class="container">
            <!-- Header -->
            <div class="page-header" style="gap: 16px; flex-wrap: wrap;">
                <div style="flex: 1;">
                    <h1 style="font-family: 'Inter', sans-serif; font-weight: 600; font-size: 2rem;">Lista de Personal</h1>
                    <p style="color: var(--md-sys-color-secondary); margin-top: 4px;">Administra los empleados y sus roles</p>
                </div>
                <div style="display: flex; gap: 8px; align-items: center;">
                    <md-outlined-button onclick="exportarExcel()">
                        <md-icon slot="icon">grid_on</md-icon>
                        Exportar a Excel
                    </md-outlined-button>
                    <md-filled-tonal-button onclick="exportarPdf()">
                        <md-icon slot="icon">picture_as_pdf</md-icon>
                        Exportar a PDF
                    </md-filled-tonal-button>
                    <md-filled-button onclick="abrirModalNuevo()">
                        <md-icon slot="icon">person_add</md-icon>
                        Nuevo Empleado
                    </md-filled-button>
                </div>
            </div>

            <!-- Advanced Filter Form -->
            <div class="card" style="margin-bottom: 24px; padding: 24px; background-color: var(--md-sys-color-surface); animation: fade-in-down 0.5s ease-out;">
                <form id="filterForm" action="${pageContext.request.contextPath}/empleados" method="get">
                    <input type="hidden" name="page" id="pageInput" value="${pagina.number}">
                    
                    <div style="display: grid; grid-template-columns: repeat(6, 1fr); gap: 16px; align-items: start;">
                        
                        <!-- Search -->
                        <div style="grid-column: span 4;">
                            <md-outlined-text-field 
                                label="Buscar" 
                                name="keyword" 
                                value="${keyword}"
                                placeholder="Nombre, DNI..." 
                                style="width: 100%;"
                                onkeydown="if(event.key === 'Enter') { event.preventDefault(); submitFilter(); }">
                                <md-icon slot="leading-icon">search</md-icon>
                            </md-outlined-text-field>
                        </div>

                        <!-- Rol -->
                        <div style="grid-column: span 2;">
                            <md-outlined-select label="Rol" name="rol" style="width: 100%;">
                                <md-select-option value="" ${empty rol ? 'selected' : ''}>
                                    <div slot="headline">Todos</div>
                                </md-select-option>
                                <md-select-option value="ADMIN" ${rol == 'ADMIN' ? 'selected' : ''}>
                                    <div slot="headline">ADMIN</div>
                                </md-select-option>
                                <md-select-option value="EMPLEADO" ${rol == 'EMPLEADO' ? 'selected' : ''}>
                                    <div slot="headline">EMPLEADO</div>
                                </md-select-option>
                            </md-outlined-select>
                        </div>

                        <!-- Modalidad -->
                        <div style="grid-column: span 3;">
                            <md-outlined-select label="Modalidad" name="modalidad" style="width: 100%;">
                                <md-select-option value="" ${empty modalidad ? 'selected' : ''}>
                                    <div slot="headline">Todas</div>
                                </md-select-option>
                                <md-select-option value="FIJO" ${modalidad == 'FIJO' ? 'selected' : ''}>
                                    <div slot="headline">FIJO</div>
                                </md-select-option>
                                <md-select-option value="OBLIGADO" ${modalidad == 'OBLIGADO' ? 'selected' : ''}>
                                    <div slot="headline">OBLIGADO</div>
                                </md-select-option>
                                <md-select-option value="LIBRE" ${modalidad == 'LIBRE' ? 'selected' : ''}>
                                    <div slot="headline">LIBRE</div>
                                </md-select-option>
                            </md-outlined-select>
                        </div>
                        
                        <!-- Sucursal -->
                        <div style="grid-column: span 3;">
                            <md-outlined-select label="Sucursal" name="sucursalId" style="width: 100%;">
                                <md-select-option value="" ${empty sucursalId ? 'selected' : ''}>
                                    <div slot="headline">Todas</div>
                                </md-select-option>
                                <c:forEach var="s" items="${listaSucursales}">
                                    <md-select-option value="${s.id}" ${sucursalId == s.id ? 'selected' : ''}>
                                        <div slot="headline">${s.nombre}</div>
                                    </md-select-option>
                                </c:forEach>
                            </md-outlined-select>
                        </div>

                        <!-- Botones de Acción -->
                        <div style="grid-column: span 6; display: flex; gap: 8px; justify-content: flex-end; align-items: center; margin-top: 24px;">
                             <md-outlined-button type="button" onclick="limpiarFiltros()" style="flex: 1;">
                                Limpiar
                            </md-outlined-button>
                            <md-filled-button type="button" onclick="submitFilter()" style="flex: 1;">
                                <md-icon slot="icon">filter_list</md-icon>
                                Filtrar
                            </md-filled-button>
                        </div>

                    </div>

                    <input type="hidden" name="size" id="sizeInput" value="${size}">
                </form>
            </div>

            <!-- Table Card -->
            <div class="card" style="animation: fade-in-down 0.6s ease-out;">
                <div class="table-container">
                    <table class="compact-table" style="width: 100%;">
                        <thead>
                            <tr>
                                <th style="width: 100px;">ID</th>
                                <th>Apellidos y Nombres</th>
                                <th style="width: 150px;">DNI</th>
                                <th style="width: 150px;">Rol</th>
                                <th style="width: 140px; text-align: center;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${listaEmpleados}">
                                <tr>
                                    <td>${e.id}</td>
                                    <td>
                                        <div style="font-weight: 500;">${e.apellidos}, ${e.nombres}</div>
                                    </td>
                                    <td style="font-family: monospace; font-size: 0.95rem;">${e.dni}</td>
                                    <td>
                                        <span class="badge ${e.rol == 'ADMIN' ? 'badge-admin' : 'badge-emp'}">
                                            <span class="material-symbols-outlined" style="font-size: 16px;">
                                                ${e.rol == 'ADMIN' ? 'admin_panel_settings' : 'badge'}
                                            </span>
                                            ${e.rol}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="actions-cell" style="justify-content: center;">
                                            <md-icon-button title="Editar"
                                                onclick="abrirModalEditar(this)"
                                                data-id="${e.id}"
                                                data-nombres="${e.nombres}"
                                                data-apellidos="${e.apellidos}"
                                                data-dni="${e.dni}"
                                                data-sueldo="${e.sueldoBase}"
                                                data-rol="${e.rol}"
                                                data-modalidad="${e.tipoModalidad}"
                                                data-sucursal="${e.sucursal != null ? e.sucursal.id : ''}">
                                                <md-icon>edit</md-icon>
                                            </md-icon-button>
                                            
                                            <md-icon-button title="Eliminar" style="--md-icon-button-icon-color: var(--md-sys-color-error);"
                                                onclick="abrirModalEliminar('${e.id}')">
                                                <md-icon>delete</md-icon>
                                            </md-icon-button>

                                            <md-icon-button title="Cambiar Contraseña" 
                                                onclick="abrirModalPassword('${e.id}', '${e.nombres}')">
                                                <md-icon>key</md-icon>
                                            </md-icon-button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty listaEmpleados}">
                                <tr>
                                    <td colspan="5" style="text-align: center; padding: 40px; color: var(--md-sys-color-secondary);">
                                        No hay empleados registrados.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
                
                 <!-- Pagination -->
                 <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; padding: 16px 24px; border-top: 1px solid var(--md-sys-color-outline-variant); gap: 16px;">
                    <div style="display: flex; align-items: center; gap: 24px;">
                        <div style="display: flex; align-items: center; gap: 12px;">
                            <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); font-weight: 500;">Filas por página:</span>
                            <md-outlined-select onchange="changeSize(this.value)" style="min-width: 80px;">
                                <md-select-option value="5" ${size == 5 ? 'selected' : ''}><div slot="headline">5</div></md-select-option>
                                <md-select-option value="10" ${size == 10 ? 'selected' : ''}><div slot="headline">10</div></md-select-option>
                                <md-select-option value="25" ${size == 25 ? 'selected' : ''}><div slot="headline">25</div></md-select-option>
                                <md-select-option value="50" ${size == 50 ? 'selected' : ''}><div slot="headline">50</div></md-select-option>
                                <md-select-option value="100" ${size == 100 ? 'selected' : ''}><div slot="headline">100</div></md-select-option>
                            </md-outlined-select>
                        </div>
                        <div style="font-size: 0.9rem; color: var(--md-sys-color-on-surface); font-weight: 500;">
                            ${pagina.number + 1} - ${size > pagina.totalElements ? pagina.totalElements : (pagina.number + 1) * size} de ${pagina.totalElements}
                        </div>
                    </div>
                    
                    <div style="display: flex; align-items: center; gap: 16px;">
                        
                        <!-- Navigation Buttons -->
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <md-icon-button ${pagina.first ? 'disabled' : ''} onclick="changePage(${pagina.number - 1})">
                                <md-icon>chevron_left</md-icon>
                            </md-icon-button>
                            <md-icon-button ${pagina.last ? 'disabled' : ''} onclick="changePage(${pagina.number + 1})">
                                <md-icon>chevron_right</md-icon>
                            </md-icon-button>
                        </div>

                        <!-- Go to Page Input -->
                         <div style="display: flex; align-items: center; gap: 12px; padding-left: 16px; border-left: 1px solid var(--md-sys-color-outline-variant);">
                            <span style="font-size: 0.9rem; color: var(--md-sys-color-on-surface-variant); white-space: nowrap;">Ir a página</span>
                            <md-outlined-text-field 
                                type="number" 
                                min="1" 
                                max="${pagina.totalPages}" 
                                onkeydown="if(event.key === 'Enter') changePage(this.value - 1)"
                                placeholder="${pagina.number + 1}" 
                                style="width: 80px;">
                            </md-outlined-text-field>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL: Nuevo / Editar Empleado -->
        <md-dialog id="modal-empleado" style="min-width: 500px; max-width: 800px;">
            <md-icon slot="icon">person_add</md-icon>
            <div slot="headline" id="modal-title">Nuevo Empleado</div>
            
            <form slot="content" id="form-empleado" method="post" action="empleados">
                <input type="hidden" name="accion" id="form-accion" value="guardar">
                <input type="hidden" name="id" id="empleado-id" value="">

                <div class="modal-form-grid">
                    <!-- DNI Section -->
                    <div class="full-width">
                        <div class="dni-group">
                            <md-outlined-text-field label="DNI" name="dni" id="input-dni" type="number" maxlength="8" required>
                            </md-outlined-text-field>
                            <md-filled-tonal-button type="button" id="btn-consultar-dni" style="height: 56px;">
                                <md-icon>search</md-icon>
                            </md-filled-tonal-button>
                        </div>
                        <div id="dniError">Este DNI ya está registrado.</div>
                    </div>

                    <!-- Names -->
                    <md-outlined-text-field label="Nombres" name="nombres" id="input-nombres" required></md-outlined-text-field>
                    <md-outlined-text-field label="Apellidos" name="apellidos" id="input-apellidos" required></md-outlined-text-field>

                    <!-- Work Info -->
                    <md-outlined-text-field label="Sueldo Base (S/.)" name="sueldoBase" id="input-sueldo" type="number" step="0.01"></md-outlined-text-field>
                    
                    <div>
                        <md-outlined-select label="Rol" name="rol" id="input-rol">
                            <md-select-option value="EMPLEADO">
                                <div slot="headline">EMPLEADO</div>
                            </md-select-option>
                            <md-select-option value="ADMIN">
                                <div slot="headline">ADMIN</div>
                            </md-select-option>
                        </md-outlined-select>
                    </div>

                    <div>
                        <md-outlined-select label="Modalidad" name="tipoModalidad" id="input-modalidad">
                            <md-select-option value="OBLIGADO">
                                <div slot="headline">OBLIGADO (Horario Rotativo)</div>
                            </md-select-option>
                            <md-select-option value="FIJO">
                                <div slot="headline">FIJO (Rol Fijo)</div>
                            </md-select-option>
                            <md-select-option value="LIBRE">
                                <div slot="headline">LIBRE (Asistencia Libre)</div>
                            </md-select-option>
                        </md-outlined-select>
                    </div>

                    <div>
                        <md-outlined-select label="Sucursal" name="sucursal.id" id="input-sucursal">
                            <md-select-option value="">
                                <div slot="headline">-- Seleccionar --</div>
                            </md-select-option>
                            <c:forEach var="s" items="${listaSucursales}">
                                <md-select-option value="${s.id}">
                                    <div slot="headline">${s.nombre}</div>
                                </md-select-option>
                            </c:forEach>
                        </md-outlined-select>
                        <p style="margin: 4px 0 0 4px; font-size: 0.75rem; color: var(--md-sys-color-secondary);">* Opcional</p>
                    </div>

                    <!-- Password (Only for New) -->
                    <div class="full-width" id="password-container">
                        <md-outlined-text-field label="Contraseña" name="password" id="input-password" type="password"></md-outlined-text-field>
                    </div>
                </div>
            </form>

            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-empleado').close()">Cancelar</md-text-button>
                <md-filled-button onclick="submitFormEmpleado()">Guardar</md-filled-button>
            </div>
        </md-dialog>

        <!-- MODAL: Eliminar -->
        <md-dialog id="modal-eliminar" style="max-width: 400px;">
            <md-icon slot="icon" style="color: var(--md-sys-color-error);">warning</md-icon>
            <div slot="headline">¿Eliminar Empleado?</div>
            <div slot="content">Esta acción no se puede deshacer. El empleado será eliminado permanentemente del sistema.</div>
            
            <form id="form-eliminar" method="post" action="empleados">
                <input type="hidden" name="accion" value="eliminar">
                <input type="hidden" name="id" id="id-eliminar">
            </form>

            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-eliminar').close()">Cancelar</md-text-button>
                <md-filled-button onclick="document.getElementById('form-eliminar').submit()" 
                    style="--md-filled-button-container-color: var(--md-sys-color-error);">
                    Eliminar
                </md-filled-button>
            </div>
        </md-dialog>

        <!-- MODAL: Cambiar Contraseña -->
        <md-dialog id="modal-password" style="max-width: 400px;">
            <md-icon slot="icon">lock_reset</md-icon>
            <div slot="headline">Cambiar Contraseña</div>
            
            <form slot="content" id="form-password" method="post" action="empleados">
                <input type="hidden" name="accion" value="cambiarPassword">
                <input type="hidden" name="id" id="id-password">
                <p style="margin-bottom: 16px; color: var(--md-sys-color-secondary);">
                    Ingresa la nueva contraseña para <strong id="nombre-empleado-pwd"></strong>.
                </p>
                <md-outlined-text-field label="Nueva Contraseña" name="password" id="input-new-password" type="password" required class="full-width">
                </md-outlined-text-field>
            </form>

            <div slot="actions">
                <md-text-button onclick="document.getElementById('modal-password').close()">Cancelar</md-text-button>
                <md-filled-button onclick="submitFormPassword()">Actualizar</md-filled-button>
            </div>
        </md-dialog>

        <script>
            // --- Modal Logic ---
            const modalEmpleado = document.getElementById('modal-empleado');
            const formEmpleado = document.getElementById('form-empleado');
            
            function abrirModalNuevo() {
                // Reset styling and content
                document.getElementById('modal-title').innerText = "Nuevo Empleado";
                document.querySelector('#modal-empleado md-icon[slot="icon"]').innerText = "person_add";
                document.getElementById('form-accion').value = "guardar";
                document.getElementById('empleado-id').value = "0";
                
                // Clear fields
                formEmpleado.reset();
                
                // Show Password and Enable it
                const passContainer = document.getElementById('password-container');
                const passInput = document.getElementById('input-password');
                if(passContainer && passInput){
                    passContainer.style.display = 'block';
                    passInput.required = true;
                    passInput.setAttribute('name', 'password');
                }

                modalEmpleado.show();
            }

            function submitFilter() {
                document.getElementById('pageInput').value = 0; 
                document.getElementById('filterForm').submit();
            }

            function limpiarFiltros() {
                // Reset text fields
                document.getElementById('filterForm').reset();
                
                // Clear search input manually if form reset doesn't catch web components sometimes
                const search = document.querySelector('md-outlined-text-field[name="keyword"]');
                if(search) search.value = '';

                 // Selects need explicit reset in MD3 if not standard selects
                 const selects = document.querySelectorAll('md-outlined-select');
                 selects.forEach(s => s.selectIndex(0));

                submitFilter();
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
            
            function exportarExcel() {
                const form = document.getElementById('filterForm');
                const originalAction = form.action;
                form.action = '${pageContext.request.contextPath}/empleados/export/excel';
                form.submit();
                setTimeout(() => { form.action = originalAction; }, 500);
            }

            function exportarPdf() {
                const form = document.getElementById('filterForm');
                const originalAction = form.action;
                form.action = '${pageContext.request.contextPath}/empleados/export/pdf';
                form.submit();
                setTimeout(() => { form.action = originalAction; }, 500);
            }

            function abrirModalEditar(btn) {
                const data = btn.dataset;
                
                document.getElementById('modal-title').innerText = "Editar Empleado";
                document.querySelector('#modal-empleado md-icon[slot="icon"]').innerText = "edit";
                document.getElementById('form-accion').value = "guardar";
                document.getElementById('empleado-id').value = data.id;
                
                // Fill fields
                document.getElementById('input-nombres').value = data.nombres;
                document.getElementById('input-apellidos').value = data.apellidos;
                document.getElementById('input-dni').value = data.dni;
                document.getElementById('input-sueldo').value = data.sueldo;
                
                // Selects
                document.getElementById('input-rol').value = data.rol;
                document.getElementById('input-modalidad').value = data.modalidad;
                document.getElementById('input-sucursal').value = data.sucursal;

                // Hide Password and Disable it (prevent overwrite)
                const passContainer = document.getElementById('password-container');
                const passInput = document.getElementById('input-password');
                passContainer.style.display = 'none';
                passInput.required = false;
                passInput.removeAttribute('name'); // Prevent submission

                modalEmpleado.show();
            }

            function submitFormEmpleado() {
                // Manual validation check could go here
                // Check required fields
                const required = ['input-nombres', 'input-apellidos', 'input-dni'];
                let valid = true;
                required.forEach(id => {
                    const el = document.getElementById(id);
                    if(!el.value) { el.error = true; valid = false; }
                    else { el.error = false; }
                });
                
                if(document.getElementById('password-container').style.display !== 'none') {
                    const pass = document.getElementById('input-password');
                    if(!pass.value) { pass.error = true; valid = false; }
                    else { pass.error = false; }
                }

                if(valid) formEmpleado.submit();
            }

            function abrirModalEliminar(id) {
                document.getElementById('id-eliminar').value = id;
                document.getElementById('modal-eliminar').show();
            }

            function abrirModalPassword(id, nombres) {
                document.getElementById('id-password').value = id;
                document.getElementById('nombre-empleado-pwd').innerText = nombres;
                document.getElementById('input-new-password').value = '';
                document.getElementById('input-new-password').error = false;
                document.getElementById('modal-password').show();
            }
            
            function submitFormPassword() {
                const pass = document.getElementById('input-new-password');
                if(!pass.value || pass.value.trim() === '') {
                     pass.error = true; 
                     return;
                }
                document.getElementById('form-password').submit();
            }

            // --- DNI Service Logic ---
            document.addEventListener('DOMContentLoaded', () => {
                const btnConsultar = document.getElementById('btn-consultar-dni');
                const dniInput = document.getElementById('input-dni');

                btnConsultar.addEventListener('click', async () => {
                    const dni = dniInput.value;
                    if (!dni || dni.length !== 8) {
                        showToast('DNI Inválido', 'Ingrese un DNI de 8 dígitos.', 'warning', 'warning');
                        return;
                    }

                    // Loading State
                    const originalIcon = btnConsultar.innerHTML;
                    btnConsultar.disabled = true;
                    btnConsultar.innerHTML = '<md-circular-progress indeterminate style="--md-circular-progress-size: 24px;"></md-circular-progress>';

                    try {
                        const response = await fetch(`${pageContext.request.contextPath}/api/dni/\${dni}`);
                        const data = await response.json();

                        if (data.ok) {
                            const p = data.datos;
                            document.getElementById('input-nombres').value = p.nombres || '';
                            document.getElementById('input-apellidos').value = (p.apePaterno || '') + ' ' + (p.apeMaterno || '');
                            document.getElementById('dniError').style.display = 'none';
                        } else {
                            showToast('No encontrado', data.mensaje || 'No se encontró información para este DNI.', 'error', 'error');
                        }
                    } catch (e) {
                         console.error(e);
                         showToast('Error de Conexión', 'No se pudo consultar el DNI.', 'error', 'cloud_off');
                    } finally {
                        btnConsultar.disabled = false;
                        btnConsultar.innerHTML = originalIcon;
                    }
                });

                // Duplicate Check logic? 
                // Porting simple check.
                dniInput.addEventListener('blur', async () => {
                     // Only check if it differs from original? 
                     // For Edit mode, we need to know original DNI. 
                     // Can store it in a var when opening modal.
                });
                
                fixDialogScrim(['modal-empleado', 'modal-eliminar', 'modal-password']);
                handleParams();
            });

            function handleParams() {
                const params = new URLSearchParams(window.location.search);
                const status = params.get('status');
                
                if (status) {
                    let title, message, type, icon;
                    
                    switch(status) {
                        case 'created':
                            title = 'Empleado Creado';
                            message = 'El empleado ha sido registrado exitosamente.';
                            type = 'success';
                            icon = 'check_circle';
                            break;
                        case 'updated':
                            title = 'Empleado Actualizado';
                            message = 'Los datos del empleado han sido guardados.';
                            type = 'success';
                            icon = 'save';
                            break;
                        case 'password_updated':
                            title = 'Contraseña Actualizada';
                            message = 'La nueva contraseña se ha establecido correctamente.';
                            type = 'success';
                            icon = 'lock_reset'; // Special icon for this
                            break;
                        case 'deleted':
                            title = 'Empleado Eliminado';
                            message = 'El registro ha sido eliminado del sistema.';
                            type = 'success'; // Or distinct style? User said "toasteds para diferentes estados"
                            icon = 'delete';
                            break;
                        default: // Generic success logic from before or fallback
                             if(status === 'success') {
                                title = 'Acción Exitosa';
                                message = 'La operación se completó correctamente.';
                                type = 'success';
                                icon = 'check';
                             }
                             break;
                    }

                    if (title) {
                        showToast(title, message, type, icon);
                    }
                    
                    // Clean URL
                    window.history.replaceState({}, document.title, window.location.pathname);
                }
            }
        </script>
        
        <!-- Shared Scripts -->
        <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
        </script>
    </div>
</body>
</html>