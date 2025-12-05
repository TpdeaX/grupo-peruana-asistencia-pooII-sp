<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Empleados</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
    <script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
    <script type="module">import '@material/web/all.js';</script>

    <style>
        body { font-family: 'Roboto', sans-serif; background-color: #F4FBF9; padding: 20px; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); }
        
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        h2 { margin: 0; color: #006A6A; }

        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid #eee; }
        th { background-color: #f8f9fa; color: #555; font-weight: 500; }
        
        .actions { display: flex; gap: 10px; }
        .btn-icon { text-decoration: none; color: #555; display: flex; align-items: center; justify-content: center; }
        .btn-icon:hover { color: #006A6A; }
        .btn-delete:hover { color: #d32f2f; }
        
        .badge { padding: 4px 8px; border-radius: 12px; font-size: 0.8rem; font-weight: bold; }
        .badge-admin { background-color: #e3f2fd; color: #1565c0; }
        .badge-emp { background-color: #e8f5e9; color: #2e7d32; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div style="display:flex; align-items:center; gap:10px;">
                <md-icon-button onclick="window.location.href='${pageContext.request.contextPath}/admin'">
                    <md-icon>arrow_back</md-icon>
                </md-icon-button>
                <h2>Lista de Personal</h2>
            </div>
            <md-filled-button onclick="window.location.href='empleados?accion=nuevo'">
                <md-icon slot="icon">add</md-icon>
                Nuevo Empleado
            </md-filled-button>
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Apellidos y Nombres</th>
                    <th>DNI</th>
                    <th>Rol</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="e" items="${listaEmpleados}">
                    <tr>
                        <td>${e.id}</td>
                        <td>${e.apellidos}, ${e.nombres}</td>
                        <td>${e.dni}</td>
                        <td>
                            <span class="badge ${e.rol == 'ADMIN' ? 'badge-admin' : 'badge-emp'}">
                                ${e.rol}
                            </span>
                        </td>
                        <td class="actions">
                            <a href="empleados?accion=editar&id=${e.id}" class="btn-icon" title="Editar">
                                <span class="material-symbols-outlined">edit</span>
                            </a>
                            
                            <form action="empleados" method="post" style="display:inline;" onsubmit="return confirm('¿Eliminar a este empleado?');">
                                <input type="hidden" name="accion" value="eliminar">
                                <input type="hidden" name="id" value="${e.id}">
                                <button type="submit" style="background:none; border:none; cursor:pointer;" class="btn-icon btn-delete" title="Eliminar">
                                    <span class="material-symbols-outlined">delete</span>
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        
        <c:if test="${empty listaEmpleados}">
            <p style="text-align:center; margin-top:30px; color:#777;">No hay empleados registrados.</p>
        </c:if>
    </div>
</body>
</html>