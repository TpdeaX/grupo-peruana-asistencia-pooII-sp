<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- 
    Componente: config-vars.jsp
    Propósito: Inyectar configuraciones del sistema como variables JavaScript globales
    para que puedan ser consumidas por scripts del frontend.
    
    Uso: Incluir este archivo en cualquier JSP que necesite acceso a las configuraciones:
    <jsp:include page="../shared/config-vars.jsp" />
    
    Luego en JavaScript:
    if (window.SYSTEM_CONFIG.ui_blur_modal) { ... }
--%>
<script>
    // Configuración del Sistema - Variables Globales
    window.SYSTEM_CONFIG = window.SYSTEM_CONFIG || {};
    
    // UI Settings
    <c:choose>
        <c:when test="${configs['ui_blur_modal'] == 'true'}">
            window.SYSTEM_CONFIG.ui_blur_modal = true;
        </c:when>
        <c:otherwise>
            window.SYSTEM_CONFIG.ui_blur_modal = false;
        </c:otherwise>
    </c:choose>
    
    // Asistencia Settings
    window.SYSTEM_CONFIG.asistencia_tolerancia = ${not empty configs['asistencia_tolerancia'] ? configs['asistencia_tolerancia'] : 15};
    window.SYSTEM_CONFIG.asistencia_hora_entrada = '${not empty configs["asistencia_hora_entrada"] ? configs["asistencia_hora_entrada"] : "08:00"}';
    
    <c:choose>
        <c:when test="${configs['asistencia_permitir_extras'] == 'true'}">
            window.SYSTEM_CONFIG.asistencia_permitir_extras = true;
        </c:when>
        <c:otherwise>
            window.SYSTEM_CONFIG.asistencia_permitir_extras = false;
        </c:otherwise>
    </c:choose>
    
    // Descuentos Settings
    <c:choose>
        <c:when test="${configs['descuento_falta_enabled'] == 'true'}">
            window.SYSTEM_CONFIG.descuento_falta_enabled = true;
        </c:when>
        <c:otherwise>
            window.SYSTEM_CONFIG.descuento_falta_enabled = false;
        </c:otherwise>
    </c:choose>
    
    <c:choose>
        <c:when test="${configs['descuento_tardanza_enabled'] == 'true'}">
            window.SYSTEM_CONFIG.descuento_tardanza_enabled = true;
        </c:when>
        <c:otherwise>
            window.SYSTEM_CONFIG.descuento_tardanza_enabled = false;
        </c:otherwise>
    </c:choose>
</script>
