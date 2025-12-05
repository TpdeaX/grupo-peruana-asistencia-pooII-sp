<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
    .top-app-bar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 24px;
        background-color: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface);
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    .app-title {
        font-size: 1.375rem;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .user-info {
        display: flex;
        align-items: center;
        gap: 16px;
    }
</style>

<nav class="top-app-bar">
    <div class="app-title">
        <span class="material-symbols-outlined">encrypted</span>
        Grupo Peruana
    </div>
    
    <div class="user-info">
        <span>Hola, <b>${sessionScope.usuario.nombres}</b></span>
        <li class="nav-item" style="list-style: none;">
            <a class="nav-link" href="${pageContext.request.contextPath}/empleados">Empleados</a>
        </li>
        <li class="nav-item" style="list-style: none;">
            <a class="nav-link" href="${pageContext.request.contextPath}/horarios">Horarios</a>
        </li>
        <md-text-button onclick="window.location.href='${pageContext.request.contextPath}/auth?accion=logout'">
            Cerrar Sesión
            <span slot="icon" class="material-symbols-outlined">logout</span>
        </md-text-button>
    </div>
</nav>