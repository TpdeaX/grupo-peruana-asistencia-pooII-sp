<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Tipos de Turno</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>

    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #F4FBF9; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); }
        
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        h2 { margin: 0; color: #006A6A; }

        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid #eee; }
        th { background-color: #f8f9fa; color: #555; font-weight: 500; }
        
        .actions { display: flex; gap: 10px; }
        .btn-icon { text-decoration: none; color: #555; display: flex; align-items: center; justify-content: center; }
        .btn-icon:hover { color: #006A6A; }
        .btn-delete:hover { color: #d32f2f; }
        
        .color-sample { width: 24px; height: 24px; border-radius: 50%; border: 1px solid #ccc; display: inline-block; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div style="display:flex; align-items:center; gap:10px;">
                <md-icon-button onclick="window.location.href='${pageContext.request.contextPath}/admin'"> <!-- Assuming admin home is here, but navbar might be better -->
                    <md-icon>arrow_back</md-icon>
                </md-icon-button>
                <h2>Tipos de Turno</h2>
            </div>
            <md-filled-button onclick="window.location.href='${pageContext.request.contextPath}/tipoturno/nuevo'">
                <md-icon slot="icon">add</md-icon>
                Nuevo Tipo
            </md-filled-button>
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Color</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="t" items="${tipos}">
                    <tr>
                        <td>${t.id}</td>
                        <td>${t.nombre}</td>
                        <td>
                            <div class="color-sample" style="background-color: ${t.color};"></div>
                            <span style="vertical-align: super; margin-left: 5px;">${t.color}</span>
                        </td>
                        <td class="actions">
                            <a href="${pageContext.request.contextPath}/tipoturno/editar?id=${t.id}" class="btn-icon" title="Editar">
                                <span class="material-symbols-outlined">edit</span>
                            </a>
                            
                            <form action="${pageContext.request.contextPath}/tipoturno/eliminar" method="post" style="display:inline;" onsubmit="return confirm('¿Eliminar este tipo de turno?');">
                                <input type="hidden" name="id" value="${t.id}">
                                <button type="submit" style="background:none; border:none; cursor:pointer;" class="btn-icon btn-delete" title="Eliminar">
                                    <span class="material-symbols-outlined">delete</span>
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        
        <c:if test="${empty tipos}">
            <p style="text-align:center; margin-top:30px; color:#777;">No hay tipos de turno registrados.</p>
        </c:if>
    </div>
</body>
</html>
