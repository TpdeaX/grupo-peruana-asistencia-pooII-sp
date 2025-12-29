<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>



<%
    // Fix: When using Spring MVC, getServletPath() may return the JSP path (e.g., /views/foo.jsp)
    // instead of the controller path (e.g., /foo). We need the original request URI.
    String currentPath = (String) request.getAttribute("jakarta.servlet.forward.servlet_path");
    if (currentPath == null) {
        currentPath = request.getServletPath();
    }
    
    // Operaciones
    boolean isHorarios = currentPath.contains("/horarios");
    boolean isAsistencias = currentPath.contains("/asistencias");
    boolean isOperacionesOpen = isHorarios || isAsistencias;
    
    // Justificaciones
    boolean isJustificaciones = currentPath.contains("/justificaciones");
    
    // Análisis
    boolean isCalculo = currentPath.contains("/reportes/calculo");
    boolean isReporteHoras = currentPath.contains("/reportes/horas");
    boolean isReportePuntualidad = currentPath.contains("/reportes/puntualidad");
    boolean isReportesOpen = isCalculo || isReporteHoras || isReportePuntualidad;
    
    // Organización
    boolean isSucursales = currentPath.contains("/sucursales");
    boolean isEmpleados = currentPath.contains("/empleados");
    boolean isOrganizacionOpen = isSucursales || isEmpleados;
    
    // Configuración
    boolean isTipoTurno = currentPath.contains("/tipoturno");
    boolean isFeriados = currentPath.contains("/feriados");
    boolean isParametrosGenerales = currentPath.contains("/parametros/generales");
    boolean isConfiguracionOpen = isTipoTurno || isFeriados || isParametrosGenerales;
    
    // Dashboard
    boolean isDashboard = currentPath.equals("/admin") || currentPath.endsWith("/dashboard.jsp") || currentPath.endsWith("/admin/");
%>



<style>
    /* Variables */
    /* Variables */
    :root {
        --sidebar-width: 280px;
        --sidebar-bg: var(--bg-sidebar);
        --primary-color: var(--color-primary); 
        --hover-bg: var(--bg-hover);
        --active-bg: var(--color-surface-tint);
        --sidebar-mini-width: 80px;
    }

    /* GLOBAL LAYOUT RESET */
    body {
        padding: 0 !important;
        margin: 0 !important;
        overflow-x: hidden;
    }
    
    /* Ensure main-content handles the flow correctly */
    .main-content {
        width: auto;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }

    /* Overlay for mobile/unpinned mode */
    #sidebar-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background-color: rgba(0,0,0,0.5);
        z-index: 1150; /* Higher than Header (1100) */
        display: none;
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    #sidebar-overlay.active {
        display: block;
        opacity: 1;
    }

    /* Sidebar Container */
    .sidebar {
        width: var(--sidebar-width);
        background-color: var(--sidebar-bg);
        height: 100vh;
        position: fixed;
        top: 0;
        left: 0;
        display: flex;
        flex-direction: column;
        border-right: 1px solid var(--border-color);
        z-index: 1200; /* Highest priority (above overlay) */
        transition: transform 0.4s cubic-bezier(0.25, 0.8, 0.25, 1), 
                    width 0.4s cubic-bezier(0.25, 0.8, 0.25, 1), background-color 0.3s, border-color 0.3s;
        overflow: hidden; /* Hide content during resize */
        box-shadow: 2px 0 8px var(--shadow-sm);
    }
    
    /* Collapsed State (Unpinned & Hidden) */
    .sidebar.closed {
        transform: translateX(-100%);
    }

    /* Header with Sticky Logo */
    .sidebar-header {
        padding: 0 16px; /* Reduced padding and align left */
        height: 64px; /* Fixed height to match header */
        display: flex;
        justify-content: flex-start; /* Align start */
        align-items: center;
        border-bottom: 1px solid transparent;
        flex-shrink: 0;
    }

    .sidebar-logo {
        max-width: 100%;
        height: auto;
        display: block;
        max-height: 80px; /* Limit height */
    }

    /* Scrollable Content */
    .sidebar-menu {
        flex: 1;
        overflow-y: auto;
        padding: 12px;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }
    
    /* Custom Scrollbar - Hidden but Scrollable */
    .sidebar-menu::-webkit-scrollbar {
        width: 4px; /* Thinner */
        display: none; /* Hide by default */
    }
    .sidebar-menu:hover::-webkit-scrollbar, .sidebar-menu:focus-within::-webkit-scrollbar {
        display: block; /* Show on hover/focus */
    }
    .sidebar-menu::-webkit-scrollbar-thumb {
        background-color: var(--border-color);
        border-radius: 4px;
    }
    .sidebar-menu {
        scrollbar-width: none; /* Firefox */
        -ms-overflow-style: none;  /* IE 10+ */
    }

    /* Navigation Items */
    .menu-category {
        font-size: 0.75rem;
        font-weight: 500;
        color: var(--text-secondary);
        padding: 16px 16px 8px 16px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-top: 8px;
    }

    .nav-item {
        display: flex;
        align-items: center;
        justify-content: space-between; /* For dropdown arrow */
        padding: 12px 16px;
        border-radius: 8px; /* Slightly less rounded than pill for better list feel */
        text-decoration: none;
        color: var(--icon-color);
        font-size: 0.95rem;
        font-weight: 500;
        transition: all 0.2s ease, padding 0.2s ease;
        cursor: pointer;
        position: relative;
    }

    .nav-label {
        white-space: nowrap;
        opacity: 1;
        transition: opacity 0.2s ease;
    }

    .nav-content {
        display: flex;
        align-items: center;
        gap: 16px;
        transition: gap 0.3s ease;
    }

    .nav-item:hover {
        background-color: var(--hover-bg);
        color: var(--text-primary);
    }

    .nav-item.active {
        background-color: #FFF0F5; /* Light pink background matching logo vibe */
        color: #880E4F; /* Dark Pink/Purple */
    }
    

    .material-symbols-outlined {
        font-size: 24px;
        color: var(--icon-color);
    }
    
    .nav-item.active .material-symbols-outlined {
        color: #880E4F;
        font-variation-settings: 'FILL' 1;
    }
    
    /* Dropdown Styles */
    .dropdown-arrow {
        width: 24px !important;
        height: 24px !important;
        min-width: 24px !important;
        display: grid !important;
        place-items: center !important;
        transform-origin: 50% 50% !important;
        font-size: 20px !important;
        line-height: 1 !important;
        margin: 0 !important;
        padding: 0 !important;
        transition: transform 0.3s ease;
    }
    
    .nav-item.expanded .dropdown-arrow {
        transform: rotate(180deg);
    }
    
    .submenu {
        max-height: 0;
        overflow: hidden;
        transition: max-height 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        padding-left: 0;
    }

    .submenu.open {
        max-height: 500px; /* Arbitrary large height for transition */
    }
    
    .submenu .nav-item {
        padding-left: 56px; /* Indent + Icon space */
        font-size: 0.9rem;
    }

    /* Sticky Bottom Footer (Pinned Toggle) */
    .sidebar-footer {
        padding: 12px 16px;
        border-top: 1px solid var(--border-color);
        font-size: 0.9rem;
        color: var(--text-secondary);
        flex-shrink: 0;
        background-color: var(--bg-sidebar);
        transition: background-color 0.3s, border-color 0.3s;
    }

    .pin-toggle {
        display: flex;
        align-items: center;
        gap: 12px;
        cursor: pointer;
        padding: 12px;
        border-radius: 8px;
        transition: background 0.2s;
        user-select: none;
    }

    .pin-toggle:hover {
        background-color: var(--hover-bg);
    }
    
    .pin-icon {
        transition: transform 0.3s;
    }
    .pin-toggle.pinned .pin-icon {
        transform: rotate(45deg);
        color: #880E4F;
    }

    /* Minimized (Rail) State */
    .sidebar.minimized {
        width: var(--sidebar-mini-width);
    }
    
    /* Smooth fade out for elements */
    .menu-category, .nav-label, .dropdown-arrow, .sidebar-footer div:last-child {
        transition: opacity 0.2s ease, transform 0.2s ease;
        transform-origin: left center;
    }

    .pin-toggle span:last-child {
         transition: opacity 0.2s ease;
    }

    /* REVISING STRATEGY FOR ANIMATION */
    .sidebar.minimized .menu-category,
    .sidebar.minimized .nav-label,
    .sidebar.minimized .dropdown-arrow,
    .sidebar.minimized .pin-toggle span:last-child,
    .sidebar.minimized .sidebar-footer div:last-child {
        display: none;
    }
    
    .sidebar.minimized .nav-item {
        justify-content: center;
        padding: 12px;
    }
    
    .sidebar.minimized .nav-content {
        gap: 0;
    }
    
    .sidebar.minimized .sidebar-header {
        flex-direction: column;
        padding: 12px 0;
        height: auto;
        gap: 8px;
        overflow: hidden; /* Keep logo contained */
    }
    
    .sidebar.minimized .sidebar-header .icon-btn {
        margin-right: 0 !important;
    }

    .sidebar.minimized .sidebar-logo.full-logo {
        display: none;
    }
    
    .sidebar.minimized .sidebar-logo.icon-logo {
        display: block !important;
        width: 32px; 
        height: auto;
    }
    
    .sidebar.minimized .pin-toggle {
        justify-content: center;
    }
    
    /* Allow overflow in sidebar for popups to show */
    .sidebar.minimized, 
    .sidebar.minimized .sidebar-menu {
        overflow: visible !important; 
    }
    
    /* Floating submenu container */
    .sidebar.minimized .submenu {
        display: block !important; /* Changed from none to block for animation */
        visibility: hidden;
        opacity: 0;
        transform: translateX(-10px);
        transition: opacity 0.2s ease, transform 0.2s ease, visibility 0.2s;
        
        position: absolute;
        /* Increase distance from sidebar as requested */
        left: calc(100% + 15px); 
        top: 0;
        width: 240px; 
        background-color: var(--sidebar-bg);
        border: 1px solid var(--border-color);
        border-left: 4px solid var(--primary-color);
        border-radius: 8px; /* Rounded all corners since it's detached */
        box-shadow: 6px 0 16px rgba(0,0,0,0.1);
        padding: 8px 0;
        z-index: 9999;
        /* Override JS animation styles */
        max-height: none !important; 
        overflow: visible !important;
    }

    /* Floating Arrow Pointer (Optional detail to make it look like it comes from sidebar) */
    .sidebar.minimized .submenu::after {
        content: '';
        position: absolute;
        top: 20px;
        left: -8px; /* Adjusted for new distance */
        width: 16px; /* Larger arrow to bridge gap visually */
        height: 16px;
        background-color: var(--sidebar-bg);
        border-left: 1px solid var(--border-color);
        border-bottom: 1px solid var(--border-color);
        transform: rotate(45deg);
    }
    
    /* CLICK based visibility instead of HOVER */
    .sidebar.minimized .submenu.floating-open {
        visibility: visible;
        opacity: 1;
        transform: translateX(0);
        /* display: block; - Already block */
        /* animation removed, using transition */
    }
    
    /* Ensure content is visible in floating menu */
    .sidebar.minimized .submenu .nav-item {
        padding: 12px 20px;
        justify-content: flex-start !important; /* Force Left Alignment */
        text-align: left !important;
        width: 100%; 
        border-radius: 4px;
        margin: 0 4px; /* Small margin for hover radius */
        width: calc(100% - 8px);
    }
    
    .sidebar.minimized .submenu .nav-content {
        justify-content: flex-start !important;
        width: 100%;
        gap: 12px;
    }
    
    .sidebar.minimized .submenu .nav-label {
        display: block !important; /* Force show text */
        opacity: 1 !important;
        /* margin-left: 12px; Removed, using gap */
        color: var(--text-secondary);
        font-weight: 500;
        text-align: left !important; 
        flex: 1; /* Take visible space */
    }
    
    .sidebar.minimized .submenu .nav-item:hover {
        background-color: var(--hover-bg);
    }
    
    .sidebar.minimized .submenu .nav-item:hover .nav-label {
        color: var(--text-primary);
    }
    
    /* FIX: General Submenu Alignment (Expanded State as well) */
    .submenu .nav-item {
        justify-content: flex-start !important; /* Override space-between */
        gap: 12px; /* Add gap between icon and text */
    }
    
    /* FIX: Relative positioning for parent group to ensure floating menu aligns with it */
    .nav-item-group {
        position: relative;
    }
    
    /* Animation Keyframes - Removed in favor of transitions */

</style>

<div id="sidebar-overlay" onclick="closeSidebar()"></div>

<div id="app-sidebar" class="sidebar">
    <div class="sidebar-header">
        <div class="icon-btn sidebar-menu-toggle" onclick="toggleSidebar()" style="margin-right: 16px; cursor: pointer; display: flex; align-items: center; justify-content: center; width: 40px; height: 40px; border-radius: 50%;">
            <span class="material-symbols-outlined">menu</span>
        </div>
        <img src="${pageContext.request.contextPath}/assets/logo-peruana.png" alt="Grupo Peruana" class="sidebar-logo full-logo">
        <img src="${pageContext.request.contextPath}/assets/logo-peruana-icon.png" alt="GP" class="sidebar-logo icon-logo" style="display:none;">
    </div>

    <div class="sidebar-menu">
        <a href="${pageContext.request.contextPath}/admin" class="nav-item <%= isDashboard ? "active" : "" %>">
            <div class="nav-content">
                <span class="material-symbols-outlined">dashboard</span>
                <span class="nav-label">Dashboard</span>
            </div>
        </a>

        <!-- Operaciones Dropdown -->
        <div class="menu-category">Operaciones</div>
        <div class="nav-item-group">
             <div class="nav-item <%= isOperacionesOpen ? "expanded" : "" %>" onclick="toggleSubmenu(this)">
                <div class="nav-content">
                    <span class="material-symbols-outlined">calendar_month</span>
                    <span class="nav-label">Horarios y Marcaciones</span>
                </div>
                <span class="material-symbols-outlined dropdown-arrow">expand_more</span>
            </div>
            <div class="submenu <%= isOperacionesOpen ? "open" : "" %>" style="<%= isOperacionesOpen ? "max-height: 500px;" : "" %>">
                 <a href="${pageContext.request.contextPath}/horarios" class="nav-item <%= isHorarios ? "active" : "" %>">
                    <span class="material-symbols-outlined" style="font-size: 20px;">edit_calendar</span>
                    <span class="nav-label">Gestionar Horarios</span>
                </a>
                <a href="${pageContext.request.contextPath}/asistencias" class="nav-item <%= isAsistencias ? "active" : "" %>">
                    <span class="material-symbols-outlined" style="font-size: 20px;">fact_check</span>
                    <span class="nav-label">Ver Asistencias</span>
                </a>
            </div>
        </div>
        
        <a href="${pageContext.request.contextPath}/justificaciones" class="nav-item <%= isJustificaciones ? "active" : "" %>">
             <div class="nav-content">
                <span class="material-symbols-outlined">event_busy</span>
                <span class="nav-label">Ausencias y Justif.</span>
            </div>
        </a>

        <!-- Análisis Dropdown -->
        <div class="menu-category">Análisis</div>
        <div class="nav-item-group">
            <div class="nav-item <%= isReportesOpen ? "expanded" : "" %>" onclick="toggleSubmenu(this)">
                <div class="nav-content">
                    <span class="material-symbols-outlined">bar_chart</span>
                    <span class="nav-label">Reportes</span>
                </div>
                <span class="material-symbols-outlined dropdown-arrow">expand_more</span>
            </div>
            <div class="submenu <%= isReportesOpen ? "open" : "" %>" style="<%= isReportesOpen ? "max-height: 500px;" : "" %>">
                <a href="${pageContext.request.contextPath}/reportes/calculo" class="nav-item <%= isCalculo ? "active" : "" %>">
                    <span class="material-symbols-outlined" style="font-size: 20px;">description</span>
                    <span class="nav-label">Calculo de Asistencias</span>
                </a>
                <a href="${pageContext.request.contextPath}/reportes/horas" class="nav-item <%= isReporteHoras ? "active" : "" %>">
                     <span class="material-symbols-outlined" style="font-size: 20px;">schedule</span>
                    <span class="nav-label">Reporte de Horas</span>
                </a>
                 <a href="${pageContext.request.contextPath}/reportes/puntualidad" class="nav-item <%= isReportePuntualidad ? "active" : "" %>">
                     <span class="material-symbols-outlined" style="font-size: 20px;">trending_up</span>
                    <span class="nav-label">Reporte de Puntualidad</span>
                </a>
            </div>
        </div>

        <div class="menu-category">Gestión General</div>
        
        <!-- Organización Dropdown -->
         <div class="nav-item-group">
            <div class="nav-item <%= isOrganizacionOpen ? "expanded" : "" %>" onclick="toggleSubmenu(this)">
                <div class="nav-content">
                    <span class="material-symbols-outlined">domain</span>
                    <span class="nav-label">Organización</span>
                </div>
                <span class="material-symbols-outlined dropdown-arrow">expand_more</span>
            </div>
            <div class="submenu <%= isOrganizacionOpen ? "open" : "" %>" style="<%= isOrganizacionOpen ? "max-height: 500px;" : "" %>">
                <a href="${pageContext.request.contextPath}/sucursales" class="nav-item <%= isSucursales ? "active" : "" %>">
                   <span class="material-symbols-outlined" style="font-size: 20px;">store</span>
                   <span class="nav-label">Sucursales</span>
                </a>
                <a href="${pageContext.request.contextPath}/empleados" class="nav-item <%= isEmpleados ? "active" : "" %>">
                   <span class="material-symbols-outlined" style="font-size: 20px;">group</span>
                   <span class="nav-label">Personal</span>
                </a>
            </div>
        </div>
        
        <div class="menu-category">Configuración</div>
        
        <div class="nav-item-group">
            <div class="nav-item <%= isConfiguracionOpen ? "expanded" : "" %>" onclick="toggleSubmenu(this)">
                <div class="nav-content">
                    <span class="material-symbols-outlined">settings_suggest</span>
                    <span class="nav-label">Parámetros</span>
                </div>
                <span class="material-symbols-outlined dropdown-arrow">expand_more</span>
            </div>
            <div class="submenu <%= isConfiguracionOpen ? "open" : "" %>" style="<%= isConfiguracionOpen ? "max-height: 500px;" : "" %>">
                 <a href="${pageContext.request.contextPath}/tipoturno" class="nav-item <%= isTipoTurno ? "active" : "" %>">
                    <span class="material-symbols-outlined" style="font-size: 20px;">work_history</span>
                    <span class="nav-label">Tipos de Turno</span>
                </a>
                <a href="${pageContext.request.contextPath}/feriados" class="nav-item <%= isFeriados ? "active" : "" %>">
                    <span class="material-symbols-outlined" style="font-size: 20px;">celebration</span>
                    <span class="nav-label">Feriados</span>
                </a>
                <a href="${pageContext.request.contextPath}/parametros/generales" class="nav-item <%= isParametrosGenerales ? "active" : "" %>">
                    <span class="material-symbols-outlined" style="font-size: 20px;">tune</span>
                    <span class="nav-label">Parámetros Generales</span>
                </a>
                 <a href="#" class="nav-item">
                    <span class="material-symbols-outlined" style="font-size: 20px;">lock</span>
                    <span class="nav-label">Seguridad</span>
                </a>
            </div>
        </div>
        
        <div style="margin-top: auto;"></div> <!-- Spacer -->
         <div class="menu-category">Ayuda</div>
        <a href="#" class="nav-item" onclick="downloadDocumentation(event)">
             <div class="nav-content">
                <span class="material-symbols-outlined">help</span>
                <span class="nav-label">Documentación</span>
            </div>
        </a>
        <a href="#" class="nav-item" onclick="contactSupport(event)">
             <div class="nav-content">
                <span class="material-symbols-outlined">support_agent</span>
                <span class="nav-label">Soporte</span>
            </div>
        </a>
    </div>

    <div class="sidebar-footer">
        <div class="pin-toggle" onclick="togglePinstate()" id="pinToggleBtn">
            <span class="material-symbols-outlined pin-icon">push_pin</span>
            <span>Menú Anclado</span>
        </div>
        <div style="text-align: center; margin-top: 10px; font-size: 0.75rem; color: #999;">
             © 2025 La Peruana
        </div>
    </div>
</div>

<script>
    // DOCUMENTATION & SUPPORT HANDLERS
    function safeToast(message, type) {
        // Fallback or use global showToast
        if (typeof showToast === 'function') {
             // If toast.js is active (activeToasts exists), it might expect 4 args
             if (typeof activeToasts !== 'undefined') {
                 var icon = 'info';
                 if(type === 'success') icon = 'check_circle';
                 if(type === 'error') icon = 'error';
                 showToast('Sistema', message, type, icon);
             } else {
                 showToast(message, type);
             }
        } else {
            console.log('Toast:', message);
        }
    }

    function downloadDocumentation(e) {
        if(e) e.preventDefault();
        safeToast('Descargando documentación...', 'success');
        // Usar raw link
        window.open('https://docs.google.com/viewer?url=https://github.com/TpdeaX/grupo-peruana-asistencia-pooII-sp/raw/main/INFORME%20DE%20POO2.pdf&embedded=false', '_blank');
    }

    function contactSupport(e) {
        if(e) e.preventDefault();
        var numbers = ['51975198852', '51991806740'];
        var randomNum = numbers[Math.floor(Math.random() * numbers.length)];
        
        safeToast('Conectando con un asesor...', 'success');
        var url = 'https://api.whatsapp.com/send?phone=' + randomNum;
        window.open(url, '_blank');
    }

    // State Management
    const sidebar = document.getElementById('app-sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    const pinBtn = document.getElementById('pinToggleBtn');
    
    // Check local storage - Default to TRUE (Pinned) if null
    let storedState = localStorage.getItem('sidebarPinned');
    let isPinned = storedState === null ? true : storedState === 'true';

    // Check minimized state
    let storedMinimized = localStorage.getItem('sidebarMinimized');
    let isMinimized = storedMinimized === 'true';
    
    // IMMEDIATE INITIALIZATION to prevent FOUC (Flash of Unstyled Content)
    // We run this immediately as the script is parsed
    (function initSidebarImmediate() {
        if (isPinned) {
            // Apply pinned state
            document.body.classList.add('sidebar-pinned');
            if(sidebar) {
                sidebar.classList.remove('closed');
                // Apply minimized state if pinned
                if (isMinimized) {
                    sidebar.classList.add('minimized');
                } else {
                    sidebar.classList.remove('minimized');
                }
            }
            if(pinBtn) pinBtn.classList.add('pinned');
            if(overlay) overlay.classList.remove('active');
        } else {
            // Unpinned state 
            document.body.classList.remove('sidebar-pinned');
            if(sidebar) {
                 sidebar.classList.add('closed');
                 // Ensure minimized is cleared if we are unpinned (logic choice)
                 sidebar.classList.remove('minimized');
            }
            if(pinBtn) pinBtn.classList.remove('pinned');
        }
        
        // Update main margin
        // Note: main-content might not be parsed yet if this script runs before it.
        // So we also call this on DOMContentLoaded just in case.
        updateMainContentMargin(isPinned);
    })();
    
    function updateMainContentMargin(pinned) {
        const content = document.querySelector('.main-content');
        if (content) {
            let margin = '0';
            if (pinned) {
                 // Check if minimized class is present
                 const currentlyMinimized = sidebar && sidebar.classList.contains('minimized');
                 margin = currentlyMinimized ? '80px' : '280px';
            }
            content.style.marginLeft = margin;
        }
    }

    function togglePinstate() {
        isPinned = !isPinned;
        localStorage.setItem('sidebarPinned', isPinned);
        
        if (isPinned) {
            pinBtn.classList.add('pinned');
             // Stay open
             sidebar.classList.remove('closed');
             document.body.classList.add('sidebar-pinned');
             
             // If we were minimized before, should we restore it? 
             // Let's respect the current 'isMinimized' variable which might have been set
             if(isMinimized) {
                 sidebar.classList.add('minimized');
             }
             
             updateMainContentMargin(true);
             overlay.classList.remove('active'); // Remove overlay when pinning
        } else {
            pinBtn.classList.remove('pinned');
             document.body.classList.remove('sidebar-pinned');
             updateMainContentMargin(false);
             // We don't auto-close immediately so user is not disoriented, 
             // BUT user asked "if deactivated, only 3 lines remain". 
             // So we should probably close it.
             closeSidebar();
             // Also remove minimized state if unpinned visually (but keep var logic if needed)
             sidebar.classList.remove('minimized');
             
             // Close any floating menus
             closeAllFloatingMenus();
        }
    }
    
    function openSidebar() {
        sidebar.classList.remove('closed');
        if (!isPinned) {
            overlay.classList.add('active');
        }
    }
    
    function closeSidebar() {
        if (!isPinned) {
            sidebar.classList.add('closed');
            overlay.classList.remove('active');
        }
    }
    
    function toggleSidebar() {
        if (sidebar.classList.contains('closed')) {
            openSidebar();
        } else {
            // If pinned, toggle minimized
            if (isPinned) {
               sidebar.classList.toggle('minimized');
               
               // Update state persistence
               isMinimized = sidebar.classList.contains('minimized');
               localStorage.setItem('sidebarMinimized', isMinimized);

               updateMainContentMargin(true);
               // Close menus when minimizing
               if(sidebar.classList.contains('minimized')) {
                   closeAllFloatingMenus();
               }
            } else {
               closeSidebar();
            }
        }
    }
    
    function closeAllFloatingMenus() {
        document.querySelectorAll('.submenu.floating-open').forEach(el => {
            el.classList.remove('floating-open');
        });
    }
    
    // Submenu Toggle
    function toggleSubmenu(header) {
        // If minimized, Handle Floating Click
        if (sidebar.classList.contains('minimized')) {
             const submenu = header.nextElementSibling;
             if(submenu) {
                 // Close other floating menus first
                 document.querySelectorAll('.submenu.floating-open').forEach(el => {
                     if(el !== submenu) el.classList.remove('floating-open');
                 });
                 
                 submenu.classList.toggle('floating-open');
             }
             return; // Stop standard expansion
        }
        

        const parent = header.parentElement; // .nav-item-group (optional wrapper) or next sibling logic
        // My HTML structure above: .nav-item-group > .nav-item + .submenu
        const submenu = header.nextElementSibling;
        
        if (submenu && submenu.classList.contains('submenu')) {
            const isOpen = submenu.classList.contains('open');
            
            // Close others? Optional. Let's keep multiple open support for now.
            
            if (isOpen) {
                submenu.style.maxHeight = null;
                submenu.classList.remove('open');
                header.classList.remove('expanded');
            } else {
                submenu.classList.add('open');
                header.classList.add('expanded');
                submenu.style.maxHeight = submenu.scrollHeight + "px";
            }
        }
    }

    // Initialize on load (Mainly for content margin which might not exist when script runs)
    document.addEventListener('DOMContentLoaded', () => {
        updateMainContentMargin(isPinned);
        // Also ensure sidebar state is consistent if elements weren't found initially
         if (isPinned && sidebar) sidebar.classList.remove('closed');
    });
    
    // Expose toggle globally for Header
    window.toggleSidebarGlobal = toggleSidebar;
    
    function closeAllFloatingMenus() {
        document.querySelectorAll('.submenu.floating-open').forEach(el => {
            el.classList.remove('floating-open');
        });
    }

    // Close floating menus when clicking outside
    document.addEventListener('click', function(event) {
        if (sidebar && sidebar.classList.contains('minimized')) {
            const isClickInsideSidebar = sidebar.contains(event.target);
            const isFloatingMenu = event.target.closest('.submenu.floating-open');
            // Allow clicking the toggle button itself (header) without closing immediately (logic inside toggleSubmenu handles toggle)
            const isToggle = event.target.closest('.nav-item'); 

            // If clicking outside sidebar entirely and NOT on a floating menu
            if (!isClickInsideSidebar && !isFloatingMenu) {
                closeAllFloatingMenus();
            }
        }
    });
</script>

</script>

<!-- SESSION SAVER LOGIC -->
<c:if test="${not empty sessionScope.usuario}">
    <!-- Hidden Inputs for Safe JS Data Transfer -->
    <input type="hidden" id="session-user-dni" value="<c:out value='${sessionScope.usuario.dni}'/>" />
    <input type="hidden" id="session-user-nombres" value="<c:out value='${sessionScope.usuario.nombres}'/>" />
    <input type="hidden" id="session-user-apellidos" value="<c:out value='${sessionScope.usuario.apellidos}'/>" />
    <input type="hidden" id="session-user-rol" value="<c:out value='${sessionScope.usuario.rol}'/>" />

<script>
    document.addEventListener("DOMContentLoaded", function() {
        try {
            // Read from hidden inputs
            const getVal = (id) => {
                const el = document.getElementById(id);
                return el ? el.value.trim() : '';
            };

            const dni = getVal('session-user-dni');
            const n = getVal('session-user-nombres');
            const a = getVal('session-user-apellidos');
            const rol = getVal('session-user-rol');

            console.log("SessionDebug: Attempting to save.", {dni, n, a, rol});

            // Initials
            var i1 = (n && n.length > 0) ? n.charAt(0) : 'U';
            var i2 = (a && a.length > 0) ? a.charAt(0) : '';
            
            // Password Logic
            let passwordToSave = null;
            const pendingAuthStr = sessionStorage.getItem('pending_auth');
            if (pendingAuthStr) {
                try {
                    const pendingAuth = JSON.parse(pendingAuthStr);
                    if (pendingAuth.dni === dni) {
                        passwordToSave = pendingAuth.password;
                    }
                } catch(e) {}
                sessionStorage.removeItem('pending_auth');
            }

            let sessions = [];
            try {
                sessions = JSON.parse(localStorage.getItem('saved_sessions') || '[]');
                if(!Array.isArray(sessions)) sessions = [];
            } catch(e) { sessions = []; }
            
            // If no new password, keep existing
            if (!passwordToSave) {
                const existingSession = sessions.find(s => s.dni === dni);
                if (existingSession && existingSession.password) {
                    passwordToSave = existingSession.password;
                }
            }
            
            const user = {
                dni: dni,
                nombres: n,
                apellidos: a,
                rol: rol,
                avatar: (i1 + i2).toUpperCase(),
                password: passwordToSave
            };
            
            // Filter and Add
            sessions = sessions.filter(s => s.dni !== user.dni);
            sessions.unshift(user);
            if (sessions.length > 5) sessions.pop();
            
            localStorage.setItem('saved_sessions', JSON.stringify(sessions));
            console.log("SessionDebug: Saved successfully.", user);
            
            // VISIBLE DEBUG (Remove after fix)
            /*
            const debugDiv = document.createElement('div');
            debugDiv.style.position = 'fixed';
            debugDiv.style.bottom = '10px';
            debugDiv.style.right = '10px';
            debugDiv.style.background = 'black';
            debugDiv.style.color = 'lime';
            debugDiv.style.padding = '10px';
            debugDiv.style.zIndex = '9999';
            debugDiv.innerText = "Saved: " + user.nombres;
            document.body.appendChild(debugDiv);
            */

        } catch(e) { console.error("Error saving session", e); }
    });
</script>
</c:if>
