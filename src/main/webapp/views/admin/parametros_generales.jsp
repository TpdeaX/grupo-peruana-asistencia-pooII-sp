<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parámetros Generales | Sistema Gestión</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet" />
    
    <!-- Theme -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

    <style>
        :root {
            --primary-color: #880E4F;
            --primary-hover: #6A0B3D;
            --bg-color: #F8F9FA;
            --card-bg: #FFFFFF;
            --text-primary: #1F2937;
            --text-secondary: #6B7280;
            --border-color: #E5E7EB;
            --success-color: #10B981;
            --warning-color: #F59E0B;
            --danger-color: #EF4444;
            --input-bg: #F9FAFB;
            --input-border: #E5E7EB;
            --slider-bg: #E2E8F0;
            --slider-knob: #FFFFFF;
        }

        [data-theme="dark"] {
            --bg-color: #121212;
            --card-bg: #1E1E1E;
            --text-primary: #E0E0E0;
            --text-secondary: #A0A0A0;
            --border-color: #333333;
            --input-bg: #2C2C2C;
            --input-border: #444444;
            --slider-bg: #444444;
            --slider-knob: #E0E0E0;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            margin: 0;
            padding: 0;
            color: var(--text-primary);
        }

        .main-content {
            margin-left: 280px; /* Sidebar width */
            padding-bottom: 24px;
            transition: margin-left 0.3s ease;
        }
        
        .container {
            padding: 24px;
        }

        .header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .page-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 0;
        }

        .card {
            background-color: var(--card-bg);
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            padding: 24px;
            margin-bottom: 24px;
            border: 1px solid var(--border-color);
        }
        
        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 20px;
            padding-bottom: 8px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 24px;
        }

        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group.switch-group {
            display: flex;
            align-items: center;
            justify-content: space-between;
            min-height: 42px; /* Align with inputs */
        }
        
        .form-label {
            font-weight: 500;
            color: var(--text-primary);
            display: block;
            margin-bottom: 6px;
        }
        
        .form-description {
            font-size: 0.85rem;
            color: var(--text-secondary);
            line-height: 1.4;
        }

        /* Inputs */
        .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid var(--input-border);
            border-radius: 8px;
            font-family: inherit;
            font-size: 0.95rem;
            color: var(--text-primary);
            transition: all 0.2s ease;
            box-sizing: border-box;
            background-color: var(--input-bg);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            background-color: var(--card-bg);
            box-shadow: 0 0 0 4px rgba(136, 14, 79, 0.05); /* Softer shadow */
        }
        
        /* Dark Mode Input Autofill fix */
        input:-webkit-autofill,
        input:-webkit-autofill:hover, 
        input:-webkit-autofill:focus, 
        input:-webkit-autofill:active{
            -webkit-box-shadow: 0 0 0 30px var(--input-bg) inset !important;
            -webkit-text-fill-color: var(--text-primary) !important;
            transition: background-color 5000s ease-in-out 0s;
        }

        /* Toggle Switch */
        .switch {
            position: relative;
            display: inline-block;
            width: 50px;
            height: 26px;
            flex-shrink: 0;
        }

        .switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: var(--slider-bg);
            transition: .3s ease;
            border-radius: 24px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 20px;
            width: 20px;
            left: 3px;
            bottom: 3px;
            background-color: var(--slider-knob);
            transition: .3s cubic-bezier(0.4, 0.0, 0.2, 1);
            border-radius: 50%;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1); /* Softer shadow */
        }

        input:checked + .slider {
            background-color: var(--primary-color);
        }

        input:focus + .slider {
            box-shadow: 0 0 0 2px rgba(136, 14, 79, 0.1);
        }

        input:checked + .slider:before {
            transform: translateX(24px);
        }


        .btn-primary {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background-color 0.2s;
            font-size: 0.95rem;
        }

        .btn-primary:hover {
            background-color: var(--primary-hover);
        }
        
        .section-icon {
            color: var(--primary-color);
        }
    </style>
</head>
<body>
    <jsp:include page="../shared/sidebar.jsp" />

    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
        
        <div class="container">
            <div class="header-container">
                <h1 class="page-title">
                    <span class="material-symbols-outlined" style="font-size: 32px; color: var(--primary-color);">tune</span>
                    Parámetros Generales
                </h1>
            </div>
    
            <form action="${pageContext.request.contextPath}/parametros/generales/guardar" method="POST">
                
                <!-- Asistencia y Cálculos -->
                <div class="card">
                    <div class="section-title">
                        <span class="material-symbols-outlined section-icon">schedule</span>
                        Cálculos y Asistencia
                    </div>
                    
                    <div class="form-grid">
                        <div class="form-group">
                             <label class="form-label">Hora de Entrada (Defecto)</label>
                             <input type="time" class="form-control" name="asistencia_hora_entrada" value="${configs['asistencia_hora_entrada']}">
                        </div>
                        
                        <div class="form-group">
                             <label class="form-label">Tolerancia (Minutos)</label>
                             <input type="number" class="form-control" name="asistencia_tolerancia" value="${configs['asistencia_tolerancia']}" min="0">
                        </div>
                    </div>
    
                    <div style="margin-top: 16px; border-top: 1px solid var(--border-color); padding-top: 16px;">
                        <div class="form-group switch-group">
                            <div>
                                <span class="form-label" style="margin-bottom: 0;">Descuento por Faltas</span>
                                <div class="form-description">Aplicar descuentos automáticos por inasistencias.</div>
                            </div>
                            <label class="switch">
                                <input type="checkbox" name="descuento_falta_enabled" value="true" ${configs['descuento_falta_enabled'] == 'true' ? 'checked' : ''}>
                                <span class="slider"></span>
                            </label>
                        </div>
    
                        <div class="form-group switch-group">
                            <div>
                                <span class="form-label" style="margin-bottom: 0;">Descuento por Tardanzas</span>
                                <div class="form-description">Aplicar descuentos por minutos de tardanza.</div>
                            </div>
                            <label class="switch">
                                <input type="checkbox" name="descuento_tardanza_enabled" value="true" ${configs['descuento_tardanza_enabled'] == 'true' ? 'checked' : ''}>
                                <span class="slider"></span>
                            </label>
                        </div>
                        
                        <div class="form-group switch-group">
                            <div>
                                <span class="form-label" style="margin-bottom: 0;">Permitir Horas Extras</span>
                                <div class="form-description">Habilitar el cálculo y registro de horas extras.</div>
                            </div>
                            <label class="switch">
                                <input type="checkbox" name="asistencia_permitir_extras" value="true" ${configs['asistencia_permitir_extras'] == 'true' ? 'checked' : ''}>
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>
                </div>
    
                <!-- Sistema e Interfaz -->
                <div class="card">
                    <div class="section-title">
                        <span class="material-symbols-outlined section-icon">monitor</span>
                        Sistema e Interfaz
                    </div>
                    
                    <div style="margin-top: 8px;">
                        <div class="form-group switch-group">
                            <div>
                                <span class="form-label" style="margin-bottom: 0;">Efecto Blur en Modales</span>
                                <div class="form-description">Mejora visual al abrir ventanas emergentes.</div>
                            </div>
                            <label class="switch">
                                <input type="checkbox" name="ui_blur_modal" value="true" ${configs['ui_blur_modal'] == 'true' ? 'checked' : ''}>
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>
                </div>
    
                <div style="text-align: right; margin-bottom: 40px;">
                    <button type="submit" class="btn-primary">
                        <span class="material-symbols-outlined">save</span>
                        Guardar Cambios
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Toast Mount Point -->
    <div id="toast-mount-point" style="display:none;"></div>

    <!-- Scripts -->
    <script src="${pageContext.request.contextPath}/assets/js/utils.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/toast.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', () => {
             // Show toast from server params if exists
            <c:if test="${not empty mensaje}">
                // Using the universal showToast(title, message, type, icon)
                // Mapping old types: success -> success, error -> error
                const type = "${tipoMensaje}" === 'error' ? 'error' : 'success';
                const icon = type === 'success' ? 'check_circle' : 'error';
                const title = type === 'success' ? 'Éxito' : 'Error';
                
                if (typeof showToast === 'function') {
                     showToast(title, "${mensaje}", type, icon);
                }
            </c:if>
        });
    </script>
</body>
</html>
