<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<c:if test="${sessionScope.usuario.rol != 'ADMIN'}">
	<c:redirect url="/index.jsp" />
</c:if>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard - Grupo Peruana</title>

<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
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
	--md-sys-color-primary: #9C27B0; /* Purple/Pinkish as per image suggestion or similar */
	--md-sys-color-on-primary: #FFFFFF;
	--md-sys-color-secondary: #7B1FA2;
	--md-sys-color-surface: var(--bg-body);
	--md-sys-color-surface-container: var(--bg-surface-container);
	--md-sys-color-outline: var(--border-color);
}

body {
	margin: 0;
	font-family: 'Roboto', sans-serif;
	background-color: var(--md-sys-color-surface);
	display: flex;
}

/* Main Content Layout */
.main-content {
	margin-left: 280px; /* Sidebar width */
	flex: 1;
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	transition: margin-left 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
}

.content-wrapper {
	padding: 32px;
	max-width: 1400px;
	margin: 0;
}

.page-header {
	margin-bottom: 32px;
}

.page-title {
	font-size: 1.75rem;
	font-weight: 500;
	color: var(--text-primary);
	margin: 0 0 8px 0;
}

.page-subtitle {
	color: var(--text-secondary);
	font-size: 0.95rem;
}

/* Dashboard Grid */
.dashboard-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
	gap: 24px;
}

/* Material 3 Card Style */
.smart-card {
	background-color: var(--bg-card);
	border-radius: 20px;
	padding: 24px;
	border: 1px solid var(--border-color); /* Subtle border */
	box-shadow: var(--shadow-sm);
	transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1), background-color 0.3s, border-color 0.3s;
	position: relative;
	overflow: hidden;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.smart-card:hover {
	transform: translateY(-4px);
	box-shadow: 0 12px 24px rgba(0,0,0,0.08);
	border-color: rgba(0,0,0,0.0);
}

.card-header {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
	margin-bottom: 16px;
}

.icon-container {
	width: 56px;
	height: 56px;
	border-radius: 16px;
	background-color: #F3E5F5; /* Light purple generic background */
	color: #7B1FA2;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 28px;
}

/* Specific colors for cards */
.card-qr .icon-container { background-color: #E3F2FD; color: #1565C0; }
.card-users .icon-container { background-color: #E8F5E9; color: #2E7D32; }
.card-just .icon-container { background-color: #FFF3E0; color: #EF6C00; }
.card-report .icon-container { background-color: #FCE4EC; color: #C2185B; }

.smart-card h3 {
	font-size: 1.25rem;
	font-weight: 600;
	color: var(--text-primary);
	margin: 0;
}

.smart-card p {
	color: var(--text-secondary);
	font-size: 0.95rem;
	line-height: 1.5;
	margin: 12px 0 24px 0;
	flex-grow: 1;
}

.card-action {
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	padding: 10px 20px;
	background-color: #000;
	color: white;
	border-radius: 100px;
	font-weight: 500;
	font-size: 0.9rem;
	transition: background 0.2s;
	border: none;
	cursor: pointer;
	width: fit-content;
}

.card-action:hover {
	background-color: #333;
	box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

.card-action.secondary {
	background-color: var(--bg-surface);
	color: var(--text-primary);
	border: 1px solid var(--border-color);
}

.card-action.secondary:hover {
	background-color: var(--bg-hover);
}

</style>
</head>
<body>

	<!-- Sidebar -->
	<jsp:include page="../shared/sidebar.jsp" />

	<div class="main-content">
		<!-- Header -->
		<jsp:include page="../shared/header.jsp" />

		<div class="content-wrapper">
			<div class="page-header">
				<h2 class="page-title">Bienvenido, ${sessionScope.usuario.nombres}</h2>
				<span class="page-subtitle">Panel de Control General</span>
			</div>

			<div class="dashboard-grid">
				<!-- Card QR -->
				<div class="smart-card card-qr">
					<div class="card-header">
						<div class="icon-container">
							<span class="material-symbols-outlined">qr_code_2</span>
						</div>
					</div>
					<h3>Modo Asistencia QR</h3>
					<p>Genera el código QR dinámico para el control de asistencia en recepción.</p>
					<button class="card-action" onclick="window.location.href='${pageContext.request.contextPath}/ver-qr'">
						Abrir Pantalla QR
					</button>
				</div>

				<!-- Card Personal -->
				<div class="smart-card card-users">
					<div class="card-header">
						<div class="icon-container">
							<span class="material-symbols-outlined">group</span>
						</div>
					</div>
					<h3>Gestión de Personal</h3>
					<p>Administra el directorio de empleados, roles y credenciales de acceso.</p>
					<button class="card-action" onclick="window.location.href='${pageContext.request.contextPath}/empleados?accion=listar'">
						Gestionar Empleados
					</button>
				</div>

				<!-- Card Justificaciones -->
				<div class="smart-card card-just">
					<div class="card-header">
						<div class="icon-container">
							<span class="material-symbols-outlined">assignment_ind</span>
						</div>
					</div>
					<h3>Justificaciones</h3>
					<p>Revisa y aprueba las solicitudes de inasistencia pendientes.</p>
					<button class="card-action secondary" onclick="window.location.href='${pageContext.request.contextPath}/justificaciones'">
						Ver Solicitudes
					</button>
				</div>

				<!-- Card Reportes -->
				<div class="smart-card card-report">
					<div class="card-header">
						<div class="icon-container">
							<span class="material-symbols-outlined">bar_chart</span>
						</div>
					</div>
					<h3>Reportes y Asistencia</h3>
					<p>Consulta el historial de asistencia, retardos y exporta a Excel.</p>
					<button class="card-action secondary" onclick="window.location.href='${pageContext.request.contextPath}/asistencias'">
						Ver Historial
					</button>
				</div>
			</div>
		</div>
	</div>

</body>
</html>
