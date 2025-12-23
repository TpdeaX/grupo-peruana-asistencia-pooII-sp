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

    <jsp:include page="../shared/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="../shared/header.jsp" />
    <div class="card">
        <h2>${not empty empleado ? 'Editar Empleado' : 'Registrar Empleado'}</h2>
        
        <form action="empleados" method="post">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="id" value="${empleado.id}">

            <div class="form-group">
                <md-outlined-text-field label="Nombres" name="nombres" id="nombresInput" value="${empleado.nombres}" required></md-outlined-text-field>
            </div>

            <div class="form-group">
                <md-outlined-text-field label="Apellidos" name="apellidos" id="apellidosInput" value="${empleado.apellidos}" required></md-outlined-text-field>
            </div>

            <div class="form-group">
                <div style="display: flex; gap: 10px; align-items: flex-end;">
                    <div style="flex-grow: 1;">
                        <md-outlined-text-field label="DNI" name="dni" id="dniInput" value="${empleado.dni}" type="number" maxlength="8" required></md-outlined-text-field>
                    </div>
                    <md-filled-tonal-button type="button" id="btnConsultarDni" style="height: 56px; margin-bottom: 4px;">
                        Consultar
                        <md-icon slot="icon">search</md-icon>
                    </md-filled-tonal-button>
                </div>
                <span id="dniError" style="color: #b71c1c; font-size: 0.85rem; display: none;"></span>
            </div>

            <div class="form-group">
                <md-outlined-text-field label="Sueldo Base (S/.)" name="sueldoBase" value="${empleado.sueldoBase}" type="number" step="0.01"></md-outlined-text-field>
            </div>

            <div class="form-group">
                <label style="color:#555; font-size:0.9rem; margin-left:4px;">Rol del usuario</label>
                <select name="rol" style="padding: 15px; border-radius: 4px; border: 1px solid #ccc; font-size: 1rem;">
                    <option value="EMPLEADO" ${empleado.rol == 'EMPLEADO' ? 'selected' : ''}>EMPLEADO</option>
                    <option value="ADMIN" ${empleado.rol == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                </select>
            </div>

            <div class="form-group">
                <label style="color:#555; font-size:0.9rem; margin-left:4px;">Modalidad de Trabajo</label>
                <select name="tipoModalidad" style="padding: 15px; border-radius: 4px; border: 1px solid #ccc; font-size: 1rem;">
                    <option value="OBLIGADO" ${empleado.tipoModalidad == 'OBLIGADO' ? 'selected' : ''}>OBLIGADO (Horario Rotativo)</option>
                    <option value="FIJO" ${empleado.tipoModalidad == 'FIJO' ? 'selected' : ''}>FIJO (Rol Fijo)</option>
                    <option value="LIBRE" ${empleado.tipoModalidad == 'LIBRE' ? 'selected' : ''}>LIBRE (Asistencia Libre)</option>
                </select>
            </div>

            <div class="form-group">
                <label style="color:#555; font-size:0.9rem; margin-left:4px;">Sucursal Asignada</label>
                <select name="sucursal.id" style="padding: 15px; border-radius: 4px; border: 1px solid #ccc; font-size: 1rem;">
                    <option value="">-- Sin asignar --</option>
                    <c:forEach var="sucursal" items="${listaSucursales}">
                        <option value="${sucursal.id}" ${empleado.sucursal != null && empleado.sucursal.id == sucursal.id ? 'selected' : ''}>
                            ${sucursal.nombre}
                        </option>
                    </c:forEach>
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
    </div>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const dniInput = document.getElementById('dniInput');
            const btnConsultar = document.getElementById('btnConsultarDni');
            const nombresInput = document.getElementById('nombresInput');
            const apellidosInput = document.getElementById('apellidosInput');
            const dniError = document.getElementById('dniError');
            const submitBtn = document.querySelector('md-filled-button[type="submit"]');

            // Autocomplete DNI
            btnConsultar.addEventListener('click', async () => {
                const dni = dniInput.value;
                if (!dni || dni.length !== 8) {
                    alert('Por favor ingrese un DNI válido de 8 dígitos.');
                    return;
                }

                btnConsultar.disabled = true;
                try {
                    const response = await fetch(`${pageContext.request.contextPath}/api/dni/\${dni}`);
                    const data = await response.json();

                    if (data.ok) {
                        const persona = data.datos;
                        nombresInput.value = persona.nombres || '';
                        apellidosInput.value = (persona.apePaterno || '') + ' ' + (persona.apeMaterno || '');
                        dniError.style.display = 'none';
                    } else {
                        alert(data.mensaje || 'No se encontraron datos.');
                    }
                } catch (error) {
                    console.error(error);
                    alert('Error al consultar el servicio de DNI.');
                } finally {
                    btnConsultar.disabled = false;
                }
            });

            // Duplicate Check
            let originalDni = '${empleado.dni}';
            
            dniInput.addEventListener('blur', async () => {
                const dni = dniInput.value;
                if (dni && dni.length === 8 && dni !== originalDni) {
                    try {
                        const response = await fetch(`${pageContext.request.contextPath}/api/dni/check/\${dni}`);
                        const data = await response.json();
                        
                        if (data.exists) {
                            dniError.textContent = 'Este DNI ya está registrado en el sistema.';
                            dniError.style.display = 'block';
                            submitBtn.disabled = true;
                        } else {
                            dniError.style.display = 'none';
                            submitBtn.disabled = false;
                        }
                    } catch (e) {
                        console.error('Error checking duplicate DNI', e);
                    }
                } else {
                     dniError.style.display = 'none';
                     submitBtn.disabled = false;
                }
            });
        });
    </script>
</body>
</html>