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

<link
	href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap"
	rel="stylesheet">
<link
	href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined"
	rel="stylesheet">
<script type="importmap">{"imports": {"@material/web/": "https://esm.run/@material/web/"}}</script>
<script type="module">import '@material/web/all.js';</script>

<style>
:root {
	--md-sys-color-primary: #006A6A;
	--md-sys-color-surface: #F4FBF9;
	--md-sys-color-surface-container: #EBF3F1;
}

body {
	margin: 0;
	font-family: 'Roboto', sans-serif;
	background-color: var(--md-sys-color-surface);
}

.container {
	max-width: 1200px;
	margin: 30px auto;
	padding: 0 20px;
}

/* Grid de Tarjetas */
.dashboard-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	gap: 24px;
	margin-top: 20px;
}

/* Tarjeta estilo Material 3 Manual (Ya que md-card es experimental) */
.card {
	background-color: white;
	border-radius: 16px;
	padding: 24px;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
	transition: transform 0.2s;
}

.card:hover {
	transform: translateY(-5px);
}

.card-icon {
	font-size: 48px;
	color: var(--md-sys-color-primary);
	margin-bottom: 16px;
}

.card-title {
	font-size: 1.25rem;
	font-weight: 500;
	margin: 0 0 8px 0;
}

.card-desc {
	color: #666;
	margin-bottom: 20px;
	line-height: 1.5;
}
</style>
</head>
<body>

	<jsp:include page="../shared/navbar.jsp" />

	<div class="container">
		<h1 style="font-weight: 400; color: #333;">Panel de Control</h1>

		<div class="dashboard-grid">

			<div class="card">
				<span class="material-symbols-outlined card-icon">qr_code_2</span>
				<h3 class="card-title">Modo Asistencia QR</h3>
				<p class="card-desc">Genera el código QR dinámico para que los
					empleados marquen su entrada en la pantalla de recepción.</p>
				<md-filled-button
					onclick="window.location.href='${pageContext.request.contextPath}/ver-qr'">
				Abrir Pantalla QR </md-filled-button>
			</div>

			<div class="card">
				<span class="material-symbols-outlined card-icon">group</span>
				<h3 class="card-title">Gestión de Personal</h3>
				<p class="card-desc">Registra nuevos empleados, edita sus datos
					o cambia sus contraseñas.</p>

				<md-outlined-button
					onclick="window.location.href='${pageContext.request.contextPath}/empleados?accion=listar'">
				Gestionar </md-outlined-button>
			</div>

			<div class="card">
				<span class="material-symbols-outlined card-icon">bar_chart</span>
				<h3 class="card-title">Reportes y Asistencia</h3>
				<p class="card-desc">Visualiza quién asistió hoy, tardanzas y
					exporta el reporte mensual en Excel.</p>

				<md-filled-tonal-button
					onclick="window.location.href='${pageContext.request.contextPath}/asistencias'">
				Ver Historial Completo <md-icon slot="icon">history</md-icon> </md-filled-tonal-button>
			</div>

		</div>
	</div>

</body>
</html>