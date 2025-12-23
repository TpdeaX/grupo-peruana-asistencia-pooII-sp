<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Horarios - Material Design</title>
    
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">

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
        :root {
            /* Excel-like Grid Dimensions */
            --cell-height: 48px;
            --cell-width: 140px;
            --header-height: 60px;
            --time-col-width: 80px;
            
            /* Colors mapped to Theme */
            --grid-border: var(--border-color);
            --header-bg: var(--bg-surface-container); /* Slight contrast */
            --surface-bg: var(--bg-surface);
            
            /* Shift Colors (Pastels/Vibrant) */
            --shift-caja: #FFCDD2; 
            --shift-preventa: #E1BEE7; 
            --shift-atencion: #C8E6C9; 
            --shift-refri: #FFF9C4; 
            --shift-pesado: #D1C4E9; 
            --shift-despacho: #BBDEFB; 
            --shift-default: var(--bg-hover);
        }
        
        [data-theme="dark"] {
             /* Adjust shift colors for Dark Mode to be less bright or more opaque? */
             --shift-caja: #E57373; 
             --shift-preventa: #BA68C8; 
             --shift-atencion: #81C784; 
             --shift-refri: #FFF176; 
             --shift-pesado: #9575CD; 
             --shift-despacho: #64B5F6; 
             --shift-default: #424242;
        }
        
        body {
            font-family: 'Roboto', 'Inter', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-primary);
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            overflow: hidden;
        }

        /* Layout Structure */
        .main-content {
            flex: 1;
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            /* Sidebar margin handled by sidebar.jsp JS */
            background-color: var(--bg-body);
        }

        /* Toolbar */
        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            background: var(--bg-surface);
            border-bottom: 1px solid var(--grid-border);
            z-index: 10;
        }

        .toolbar-title h2 {
            margin: 0;
            font-size: 1.5rem;
            font-weight: 500;
            color: var(--text-primary);
        }

        .toolbar-actions {
            display: flex;
            gap: 16px;
            align-items: center;
        }

        /* Scheduler Viewport */
        #scheduler-viewport {
            flex: 1;
            overflow: auto;
            position: relative;
            background: var(--bg-surface);
            /* Custom Scrollbar */
            scrollbar-width: thin;
            scrollbar-color: var(--text-secondary) var(--bg-surface);
        }

        /* Sticky Headers */
        .header-row {
            position: sticky;
            top: 0;
            z-index: 10;
            display: flex;
            background: var(--header-bg);
            border-bottom: 2px solid var(--grid-border); 
            box-shadow: var(--shadow-sm);
        }

        .corner-header {
            position: sticky;
            left: 0;
            z-index: 11;
            width: var(--time-col-width);
            min-width: var(--time-col-width);
            height: var(--header-height);
            background: var(--header-bg);
            border-right: 2px solid var(--grid-border);
            border-bottom: 2px solid var(--grid-border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: var(--text-secondary);
            font-size: 0.8rem;
            box-sizing: border-box;
        }

        .employee-header {
            width: var(--cell-width);
            min-width: var(--cell-width);
            height: var(--header-height);
            border-right: 1px solid var(--grid-border);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 4px;
            box-sizing: border-box;
            background: var(--header-bg);
        }

        .emp-name {
            font-weight: 700;
            font-size: 0.9rem;
            text-transform: uppercase;
            color: var(--text-primary);
        }
        .emp-role {
            font-size: 0.75rem;
            color: var(--text-secondary);
        }

        /* Time Column */
        .time-col {
            position: absolute;
            left: 0;
            top: var(--header-height);
            width: var(--time-col-width);
            z-index: 9;
            background: var(--header-bg);
            border-right: 2px solid var(--grid-border);
            box-sizing: border-box;
        }

        .time-slot {
            height: var(--cell-height);
            border-bottom: 1px solid var(--grid-border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            color: var(--text-secondary);
            font-weight: 500;
            box-sizing: border-box;
        }

        /* Grid Body */
        .grid-canvas {
            position: absolute;
            left: var(--time-col-width);
            top: var(--header-height);
            background: var(--bg-surface);
        }

        .grid-row {
            display: flex;
        }

        .grid-cell {
            width: var(--cell-width);
            min-width: var(--cell-width);
            height: var(--cell-height);
            border-right: 1px solid var(--grid-border);
            border-bottom: 1px solid var(--grid-border);
            box-sizing: border-box;
            position: relative;
            transition: background-color 0.1s;
        }
        
        .grid-cell:hover {
            background-color: var(--bg-hover);
        }

        /* Shift Events */
        .shift-event {
            position: absolute;
            width: calc(var(--cell-width) - 8px);
            border-radius: 4px;
            padding: 4px 6px;
            font-size: 0.75rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
            cursor: pointer;
            z-index: 5;
            overflow: hidden;
            display: flex;
            box-sizing: border-box;
            flex-direction: column;
            justify-content: center;
            border-left: 4px solid rgba(0,0,0,0.1); /* Left accent */
            transition: transform 0.1s, box-shadow 0.1s;
            user-select: none;
        }

        .shift-event:hover {
            z-index: 8;
            box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        }
        
        .shift-event.dragging {
            opacity: 0.7;
            pointer-events: none;
            z-index: 100;
            transform: scale(1.02);
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        }

        .resize-handle {
            position: absolute;
            bottom: 0px;
            left: 0;
            right: 0;
            height: 6px;
            cursor: ns-resize;
            /* background: rgba(0,0,0,0.05); */
        }
        .resize-handle:hover {
            background: rgba(0,0,0,0.1);
        }

        /* Context Menu (Material Style) */
        #context-menu {
            position: fixed;
            display: none;
            background: var(--surface-bg);
            border-radius: 4px;
            box-shadow: 0 2px 4px -1px rgba(0,0,0,0.2), 0 4px 5px 0 rgba(0,0,0,0.14), 0 1px 10px 0 rgba(0,0,0,0.12);
            z-index: 9999;
            min-width: 160px;
            padding: 8px 0;
        }
        
        .ctx-item {
            padding: 0 16px;
            height: 40px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.9rem;
            cursor: pointer;
            color: var(--text-primary);
        }
        
        .ctx-item:hover {
            background-color: rgba(0,0,0,0.05);
        }
        
        .ctx-item span {
            font-size: 20px;
            color: var(--text-secondary);
        }
        
        .ctx-item.danger {
            color: #B3261E;
        }
        .ctx-item.danger span {
            color: #B3261E;
        }

        /* Dialog Styles */
        .dialog-content {
            display: flex;
            flex-direction: column;
            gap: 16px;
            width: 300px; /* Or min-width */
            padding-top: 8px;
        }
        
        .row-inputs {
            display: flex;
            gap: 12px;
        }
        
        .row-inputs > * {
            flex: 1;
        }
        

    </style>
</head>
<body>

    <!-- Sidebar -->
    <jsp:include page="/views/shared/sidebar.jsp" />

    <div class="main-content">
        <!-- Header -->
        <jsp:include page="/views/shared/header.jsp" />

        <!-- Toolbar -->
        <div class="toolbar">
            <div class="toolbar-title">
                <h2>Programación de Turnos</h2>
            </div>
            <div class="toolbar-actions">
                <!-- Date Picker disguised as text field for now, or native -->
                <md-outlined-text-field 
                    type="date" 
                    id="date-picker" 
                    label="Fecha" 
                    value="${fechaSeleccionada}">
                </md-outlined-text-field>

                <md-outlined-button id="btn-refresh">
                    <md-icon slot="icon">refresh</md-icon>
                    Actualizar
                </md-outlined-button>
                
                <c:if test="${isAdmin}">
                    <md-filled-button id="btn-new-shift">
                        <md-icon slot="icon">add</md-icon>
                        Nuevo Turno
                    </md-filled-button>
                </c:if>
                
                <div style="font-size: 0.8rem; color: var(--text-secondary); margin-left: 8px;">
                     <strong>Ctrl + Drag</strong> para duplicar
                </div>
            </div>
        </div>

        <!-- Main Scheduler Grid -->
        <div id="scheduler-viewport">
            <div id="scheduler-grid">
                <!-- Generated by JS -->
            </div>
        </div>
    </div>

    </div>

    <!-- Edit/Create Modal (Standard Custom Modal) -->
    <md-dialog id="shift-dialog" style="min-width: 320px;">
        <md-icon slot="icon">calendar_add_on</md-icon>
        <div slot="headline">Nuevo Turno</div>
        
        <form slot="content" id="shift-form" method="dialog">
            <div class="dialog-content">
                <input type="hidden" id="shift-id">
                
                <md-outlined-select label="Empleado" id="shift-employee" required class="full-width-field">
                     <md-icon slot="leading-icon">person</md-icon>
                     <!-- Options injected by JS -->
                </md-outlined-select>
    
                <div class="row-inputs">
                    <md-outlined-text-field 
                        type="time" 
                        label="Inicio" 
                        id="shift-start" 
                        required
                        class="time-field">
                        <md-icon slot="leading-icon">schedule</md-icon>
                    </md-outlined-text-field>
                    
                    <md-outlined-text-field 
                        type="time" 
                        label="Fin" 
                        id="shift-end" 
                        required
                        class="time-field">
                        <md-icon slot="leading-icon">update</md-icon>
                    </md-outlined-text-field>
                </div>
                
                <md-outlined-select label="Tipo de Turno" id="shift-type" required class="full-width-field">
                    <md-icon slot="leading-icon">work</md-icon>
                    <md-select-option value="Caja">
                        <div slot="headline">Caja</div>
                    </md-select-option>
                    <md-select-option value="Preventa">
                        <div slot="headline">Preventa</div>
                    </md-select-option>
                    <md-select-option value="Refrigerio">
                         <div slot="headline">Refrigerio</div>
                    </md-select-option>
                    <md-select-option value="Atencion">
                         <div slot="headline">Atención</div>
                    </md-select-option>
                    <md-select-option value="Pesado">
                         <div slot="headline">Pesado</div>
                    </md-select-option>
                    <md-select-option value="Despacho">
                         <div slot="headline">Despacho</div>
                    </md-select-option>
                    <md-select-option value="Caja 2do Nivel">
                         <div slot="headline">Caja 2do Nivel</div>
                    </md-select-option>
                </md-outlined-select>
            </div>
        </form>

        <div slot="actions">
             <md-icon-button id="btn-delete-dialog" style="margin-right: auto; display: none; --md-icon-button-icon-color: var(--md-sys-color-error);">
                <md-icon>delete</md-icon>
             </md-icon-button>
            
            <md-text-button value="cancel">Cancelar</md-text-button>
            <md-filled-button id="btn-save-dialog">
                <md-icon slot="icon">save</md-icon>
                Guardar
            </md-filled-button>
        </div>
    </md-dialog>

    <!-- Context Menu -->
    <div id="context-menu">
        <div class="ctx-item" id="ctx-edit">
            <span class="material-symbols-outlined">edit</span>
            Editar
        </div>
        <div class="ctx-item" id="ctx-duplicate">
             <span class="material-symbols-outlined">content_copy</span>
            Duplicar
        </div>
        <div class="separator" style="height:1px; background:#eee; margin:4px 0;"></div>
        <div class="ctx-item danger" id="ctx-delete">
             <span class="material-symbols-outlined">delete</span>
            Eliminar
        </div>
    </div>

    <!-- Logic -->
    <script>
        const CTX = "${pageContext.request.contextPath}";
        const IS_ADMIN = ${isAdmin};
        const INITIAL_DATE = "${fechaSeleccionada}";
        
        // Data injected from Server
        const EMPLOYEES = [
            <c:forEach items="${empleados}" var="e" varStatus="loop">
                { 
                    id: ${e.id}, 
                    nombres: "<c:out value='${e.nombres}' escapeXml='true'/>",
                    apellidos: "<c:out value='${e.apellidos}' escapeXml='true'/>",
                    role: "<c:out value='${e.rol}' escapeXml='true'/>", 
                    dni: "<c:out value='${e.dni}' escapeXml='true'/>" 
                }${!loop.last ? ',' : ''}
            </c:forEach>
        ];
        
        // --- State ---
        let shifts = [];
        // Configuration
        const START_HOUR = 6; // 6 AM
        const END_HOUR = 24;  // 12 AM next day
        const CELL_HEIGHT = 48; // px, Must match CSS
        
        // --- Initialization ---
        function init() {
            renderGrid();
            loadShifts(INITIAL_DATE);
            
            // Pre-populate Employee Select (Static List)
            const sel = document.getElementById('shift-employee');
            if(sel && EMPLOYEES) {
                sel.innerHTML = '';
                EMPLOYEES.forEach(e => {
                    const opt = document.createElement('md-select-option');
                    opt.value = e.id.toString();
                    opt.innerHTML = '<div slot="headline">' + e.nombres.split(' ')[0] + ' ' + e.apellidos.split(' ')[0] + '</div>';
                    sel.appendChild(opt);
                });
            }

            // Event Listeners
            const btnRefresh = document.getElementById('btn-refresh');
            if(btnRefresh) btnRefresh.addEventListener('click', () => loadShifts(document.getElementById('date-picker').value));
            
            const datePicker = document.getElementById('date-picker');
            if(datePicker) datePicker.addEventListener('change', (e) => loadShifts(e.target.value));
            
            // Sidebar Interaction (Fix Z-Index) is handled by CSS now with .modal class
            
            if(IS_ADMIN) {
                const btnNew = document.getElementById('btn-new-shift');
                if(btnNew) {
                    btnNew.addEventListener('click', () => openDialog());
                }
                
                const btnSave = document.getElementById('btn-save-dialog');
                if(btnSave) btnSave.addEventListener('click', saveFromDialog);
                
                const btnDelete = document.getElementById('btn-delete-dialog');
                if(btnDelete) btnDelete.addEventListener('click', deleteFromDialog);
            }
        }
        
        function renderGrid() {
            const grid = document.getElementById('scheduler-grid');
            if(!grid) return;
            grid.innerHTML = '';
            
            // 1. Header Row (Corner + Employees)
            const headerRow = document.createElement('div');
            headerRow.className = 'header-row';
            
            const corner = document.createElement('div');
            corner.className = 'corner-header';
            corner.textContent = 'HORA / EMP';
            headerRow.appendChild(corner);
            
            EMPLOYEES.forEach(emp => {
                const cell = document.createElement('div');
                cell.className = 'employee-header';
                // Short Name: First Name + First Surname
                const shortName = emp.nombres.split(' ')[0] + ' ' + emp.apellidos.split(' ')[0];
                cell.innerHTML = '<div class="emp-name">' + shortName + '</div><div class="emp-role">' + emp.role + '</div>';
                headerRow.appendChild(cell);
            });
            
            grid.appendChild(headerRow);
            
            // 2. Time Column
            const timeCol = document.createElement('div');
            timeCol.className = 'time-col';
            
            for(let h = START_HOUR; h < END_HOUR; h++) {
                const hourSlot = document.createElement('div');
                hourSlot.className = 'time-slot';
                hourSlot.textContent = h.toString().padStart(2, '0') + ':00';
                timeCol.appendChild(hourSlot);
            }
            grid.appendChild(timeCol);
            
            // 3. Grid Canvas
            const canvas = document.createElement('div');
            canvas.className = 'grid-canvas';
            
            // Rows for each hour
            for(let h = START_HOUR; h < END_HOUR; h++) {
                const row = document.createElement('div');
                row.className = 'grid-row';
                
                EMPLOYEES.forEach(emp => {
                    const cell = document.createElement('div');
                    cell.className = 'grid-cell';
                    cell.dataset.empId = emp.id;
                    cell.dataset.hour = h;
                    
                    // Interaction (Click to create)
                    if(IS_ADMIN) {
                        cell.addEventListener('dblclick', () => openDialog(null, emp.id, h.toString().padStart(2,'0') + ':00', (h+4).toString().padStart(2,'0') + ':00'));
                    }
                    
                    row.appendChild(cell);
                });
                
                canvas.appendChild(row);
            }
            
            grid.appendChild(canvas);
        }
        
        async function loadShifts(date) {
             // Update URL without reload (optional cosmetic)
             try {
                const url = new URL(window.location);
                url.searchParams.set('fecha', date);
                window.history.pushState({}, '', url);
             } catch(e) {}
             
             try {
                 const res = await fetch(CTX + '/horarios/api/list?fecha=' + date);
                 if(res.ok) {
                     shifts = await res.json();
                     renderShifts();
                 }
             } catch(e) { console.error(e); }
        }
        
        function renderShifts() {
            // clear existing events only
            document.querySelectorAll('.shift-event').forEach(e => e.remove());
            
            const canvas = document.querySelector('.grid-canvas');
            if(!canvas) return;
            
            // We assume consistent column width from CSS
            const colWidth = 140; 
            
            shifts.forEach(shift => {
                const empIndex = EMPLOYEES.findIndex(e => e.id == shift.empleadoId);
                if(empIndex === -1) return;
                
                const startDec = textToDecimal(shift.horaInicio);
                const endDec = textToDecimal(shift.horaFin);
                
                // If shift is completely before start hour, skip
                if(endDec <= START_HOUR) return;
                
                // Effective start for visual placement
                const effectiveStart = Math.max(startDec, START_HOUR);
                
                // Calculate position based on hours relative to START_HOUR
                const top = (effectiveStart - START_HOUR) * CELL_HEIGHT;
                const duration = endDec - effectiveStart;
                const height = duration * CELL_HEIGHT;
                
                const left = empIndex * colWidth;
                
                const el = document.createElement('div');
                el.className = 'shift-event';
                el.style.top = (top + 1) + 'px'; // +1px for top gap
                el.style.height = (height - 2) + 'px'; // -2px for 1px gap top/bottom
                el.style.left = (left + 4) + 'px'; // +4px for left gap
                el.style.backgroundColor = shift.color || 'var(--shift-default)';
                
                // Determine text color based on background darkness?
                // For now, assume dark text on light pastels
                el.style.color = '#222'; 
                
                // Content
                el.innerHTML = '<strong>' + shift.horaInicio + ' - ' + shift.horaFin + '</strong><div>' + shift.tipoTurno + '</div>';
                
                if(IS_ADMIN) {
                    el.addEventListener('click', (e) => {
                         e.stopPropagation();
                         openDialog(shift);
                    });
                }
                
                canvas.appendChild(el);
            });
        }
        
        // --- Logic: Dialogs ---
        function openDialog(shift, empId, startStr, endStr) {
            const d = document.getElementById('shift-dialog');
            
            // Select already populated in init
            const sel = document.getElementById('shift-employee');

            if(shift) {
                 sel.value = shift.empleadoId.toString();
            } else if(empId) {
                 sel.value = empId.toString();
            } else {
                 sel.value = "";
            }

            if(shift) {
                // document.getElementById('dialog-title').textContent = "Editar Turno"; // Slot handling if needed, or just specific text
                // MD Dialog usually handles title via slot="headline" text content
                d.querySelector('[slot="headline"]').textContent = "Editar Turno";
                
                document.getElementById('shift-id').value = shift.id;
                document.getElementById('shift-start').value = shift.horaInicio;
                document.getElementById('shift-end').value = shift.horaFin;
                document.getElementById('shift-type').value = shift.tipoTurno;
                const btnDel = document.getElementById('btn-delete-dialog');
                if(btnDel) btnDel.style.display = 'inline-flex';
            } else {
                d.querySelector('[slot="headline"]').textContent = "Nuevo Turno";
                document.getElementById('shift-id').value = "";
                document.getElementById('shift-start').value = startStr || "08:00";
                document.getElementById('shift-end').value = endStr || "17:00";
                document.getElementById('shift-type').value = "Atencion"; // Default
                const btnDel = document.getElementById('btn-delete-dialog');
                if(btnDel) btnDel.style.display = 'none';
            }
            
            // Try standard show() for modal behavior if supported, otherwise normal show()
            // Material Web 1.0+ often uses show() for modal if configured, or just open=true
            // But to guarantee backdrop, we ensure it's treated as modal
            d.show();
            // Force backdrop manually if component doesn't? No, let's trust theme.css fixes.
        }
        
        function closeDialog() {
            document.getElementById('shift-dialog').close();
        }
        
        function saveFromDialog() {
             const idNode = document.getElementById('shift-id');
             const empNode = document.getElementById('shift-employee');
             const startNode = document.getElementById('shift-start');
             const endNode = document.getElementById('shift-end');
             const typeNode = document.getElementById('shift-type');
             
             saveShiftElement(idNode.value, empNode.value, startNode.value, endNode.value, typeNode.value);
             closeDialog();
        }

        function deleteFromDialog() {
            const id = document.getElementById('shift-id').value;
             if(id && confirm("¿Eliminar turno?")) {
                 fetch(CTX + '/horarios/api/eliminar', {
                     method: 'POST',
                     headers: {'Content-Type': 'application/json'},
                     body: JSON.stringify({id: id})
                 }).then(res => {
                      if(res.ok) {
                          closeDialog();
                          loadShifts(document.getElementById('date-picker').value);
                      } else {
                          alert("Error al eliminar");
                      }
                 });
             }
        }
        
        // --- API & Helpers ---
        async function saveShiftElement(id, empId, start, end, type) {
            console.log("saveShiftElement called with:", {id, empId, start, end, type});

            if (!empId) {
                alert("Por favor selecciona un empleado");
                return;
            }
            
            const timePattern = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
            
            if (!start || !end || !timePattern.test(start) || !timePattern.test(end)) {
                alert("Horas inválidas. Formato requerido: HH:MM");
                return;
            }
            
            // Format HH:mm
            if(start.length === 4 && start.indexOf(':')===1) start = "0" + start;
            if(end.length === 4 && end.indexOf(':')===1) end = "0" + end;
            
            const date = document.getElementById('date-picker').value;
            const payload = {
                id: id,
                empleadoId: empId,
                fecha: date,
                horaInicio: start,
                horaFin: end,
                tipoTurno: type
            };
            
            try {
                const res = await fetch(CTX + '/horarios/api/guardar', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(payload)
                });
                
                if(!res.ok) {
                    const txt = await res.text();
                    alert("Error al guardar: " + txt);
                } else {
                    loadShifts(date);
                }
            } catch (e) {
                console.error(e);
                alert("Error de conexión");
            }
        }

        function textToDecimal(timeStr) {
            if(!timeStr || !timeStr.includes(':')) return 0;
            const parts = timeStr.split(':');
            return parseFloat(parts[0]) + (parseFloat(parts[1])/60);
        }
        
        function decimalToText(decimal) {
             if(isNaN(decimal)) return "00:00";
             let h = Math.floor(decimal);
             let m = Math.round((decimal - h) * 60);
             if(m === 60) { h++; m=0; }
             if(h >= 24) { return "23:59"; }
             return h.toString().padStart(2,'0') + ':' + m.toString().padStart(2,'0');
        }
        
        // --- Styles Patch (Final Robust Fix + Animations) ---
        function fixDialogScrim() {
            customElements.whenDefined('md-dialog').then(() => {
                const d = document.getElementById('shift-dialog');
                if (d && d.shadowRoot) {
                    // Inject styles into shadow DOM to force overflow visible on the internal container if needed
                    // and perfect the scrim animation
                    const style = document.createElement('style');
                    style.textContent = `
                        /* Base Scrim State (Closed) */
                        .scrim { 
                            z-index: -1 !important; 
                            opacity: 0 !important; 
                            pointer-events: none !important;
                            background-color: rgba(0,0,0,0.4) !important;
                            backdrop-filter: blur(8px) !important; /* Smooth blur */
                            display: flex !important;
                            inset: 0 !important;
                            position: fixed !important;
                            transition: opacity 0.3s ease, z-index 0s 0.3s; 
                        }
                        
                        /* Open State */
                        :host([open]) .scrim {
                            z-index: inherit !important; 
                            opacity: 1 !important; 
                            pointer-events: auto !important;
                            transition: opacity 0.4s ease, z-index 0s;
                        }

                        /* Ensure Internal Dialog Container allows Overflow for Icon */
                        .container {
                            overflow: visible !important;
                            border-radius: 28px !important;
                        }
                        
                        /* Ensure the host itself allows overflow */
                        :host {
                            overflow: visible !important;
                        }
                        
                        dialog {
                            overflow: visible !important;
                        }
                    `;
                    d.shadowRoot.appendChild(style);
                    console.log("Scrim and Overflow styles patched via Shadow DOM");
                }
            });
        }
        
        // Init
        document.addEventListener('DOMContentLoaded', () => {
             init();
             fixDialogScrim();
             
             // Fix Cancel Button explicitly
             const btnCancel = document.querySelector('md-text-button[value="cancel"]');
             if(btnCancel) {
                 btnCancel.addEventListener('click', (e) => {
                     e.preventDefault(); // active listener
                     closeDialog();
                 });
             }
        });
    </script>
</body>
</html>
