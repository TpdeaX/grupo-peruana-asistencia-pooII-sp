<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${not empty empleado ? 'Editar' : 'Nuevo'} Empleado</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>

    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #F4FBF9; padding: 20px; display: flex; justify-content: center; }
        .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); width: 100%; max-width: 500px; }
        h2 { color: #006A6A; text-align: center; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; display: flex; flex-direction: column; gap: 5px; }
        
        /* Ajuste para inputs de Material Web */
        md-outlined-text-field, md-outlined-select { width: 100%; }
        
        .buttons { display: flex; gap: 15px; justify-content: flex-end; margin-top: 20px; }
    </style>
</head>
<body>

    <div class="card">
        <h2>${not empty empleado ? 'Editar Empleado' : 'Registrar Empleado'}</h2>
        
        <form action="empleados" method="post">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="id" value="${empleado.id}">

            <div class="form-group">
                <md-outlined-text-field label="Nombres" name="nombres" value="${empleado.nombres}" required></md-outlined-text-field>
            </div>

            <div class="form-group">
                <md-outlined-text-field label="Apellidos" name="apellidos" value="${empleado.apellidos}" required></md-outlined-text-field>
            </div>

            <div class="form-group">
                <md-outlined-text-field label="DNI" name="dni" value="${empleado.dni}" type="number" maxlength="8" required></md-outlined-text-field>
            </div>

            <div class="form-group">
                <label style="color:#555; font-size:0.9rem; margin-left:4px;">Rol del usuario</label>
                <select name="rol" style="padding: 15px; border-radius: 4px; border: 1px solid #ccc; font-size: 1rem;">
                    <option value="EMPLEADO" ${empleado.rol == 'EMPLEADO' ? 'selected' : ''}>EMPLEADO</option>
                    <option value="ADMIN" ${empleado.rol == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                </select>
            </div>

            <c:if test="${empty empleado}">
                <div class="form-group">
                    <md-outlined-text-field label="Contraseña" name="password" type="password" required></md-outlined-text-field>
                </div>
            </c:if>

            <div class="buttons">
                <md-text-button type="button" onclick="window.location.href='empleados?accion=listar'">Cancelar</md-text-button>
                <md-filled-button type="submit">Guardar Datos</md-filled-button>
            </div>
        </form>
    </div>

</body>
</html>