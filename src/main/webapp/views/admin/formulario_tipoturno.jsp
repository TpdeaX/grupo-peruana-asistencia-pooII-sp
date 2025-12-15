<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${not empty tipoTurno.id && tipoTurno.id > 0 ? 'Editar' : 'Nuevo'} Tipo de Turno</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>

    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #F4FBF9; padding: 20px; display: flex; justify-content: center; }
        .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); width: 100%; max-width: 500px; }
        h2 { color: #006A6A; text-align: center; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; display: flex; flex-direction: column; gap: 5px; }
        
        md-outlined-text-field { width: 100%; }
        
        /* Custom style for color input since MD doesn't have a specific color picker component widely supported yet in this version style */
        .color-input-container {
            display: flex;
            align-items: center;
            gap: 10px;
            border: 1px solid #79747E; /* MD outline color roughly */
            padding: 8px 16px;
            border-radius: 4px;
            position: relative;
        }
        .color-input-container:hover { border-color: #1D192B; }
        
        input[type="color"] {
            border: none;
            width: 40px;
            height: 40px;
            cursor: pointer;
            background: none;
        }
        
        .buttons { display: flex; gap: 15px; justify-content: flex-end; margin-top: 20px; }
    </style>
</head>
<body>

    <div class="card">
        <h2>${not empty tipoTurno.id && tipoTurno.id > 0 ? 'Editar Tipo de Turno' : 'Nuevo Tipo de Turno'}</h2>
        
        <form action="${pageContext.request.contextPath}/tipoturno/guardar" method="post">
            <input type="hidden" name="id" value="${tipoTurno.id}">

            <div class="form-group">
                <md-outlined-text-field label="Nombre del Turno" name="nombre" value="${tipoTurno.nombre}" required></md-outlined-text-field>
            </div>

            <div class="form-group">
                <label style="color:#555; font-size:0.9rem; margin-left:4px;">Color Identificativo</label>
                <div class="color-input-container">
                    <input type="color" name="color" value="${tipoTurno.color != null ? tipoTurno.color : '#000000'}">
                    <span style="color: #666; font-size: 0.9rem;">Selecciona un color para el calendario</span>
                </div>
            </div>

            <div class="buttons">
                <md-text-button type="button" onclick="window.location.href='${pageContext.request.contextPath}/tipoturno'">Cancelar</md-text-button>
                <md-filled-button type="submit">Guardar Datos</md-filled-button>
            </div>
        </form>
    </div>

</body>
</html>
