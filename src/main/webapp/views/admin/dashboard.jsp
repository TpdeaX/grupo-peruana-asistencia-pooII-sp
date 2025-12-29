<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<c:if test="${sessionScope.usuario.rol != 'ADMIN'}">
  <c:redirect url="/index.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Dashboard Admin - Luxcar</title>

<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
:root{
  --bg-body:#f4f6fb;
  --bg-card:#ffffff;
  --border:#e5e7eb;
  --text:#111827;
  --muted:#6b7280;
}

*{box-sizing:border-box}

body{
  margin:0;
  font-family:'Roboto',sans-serif;
  background:var(--bg-body);
  display:flex;
}

.main-content{
  margin-left:280px;
  flex:1;
  min-height:100vh;
}

.content-wrapper{
  padding:32px;
  max-width:1400px;
}

.page-title{
  font-size:1.9rem;
  font-weight:700;
}

.page-subtitle{
  color:var(--muted);
}

.kpi-grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
  gap:22px;
  margin:32px 0;
}

.kpi-card{
  padding:22px;
  border-radius:22px;
  color:#fff;
  transition:.4s;
}

.kpi-card:hover{
  transform:translateY(-8px);
  box-shadow:0 22px 45px rgba(0,0,0,.35);
}

.kpi-icon{
  width:52px;
  height:52px;
  border-radius:16px;
  background:rgba(255,255,255,.25);
  display:flex;
  align-items:center;
  justify-content:center;
  font-size:28px;
  margin-bottom:14px;
}

.kpi-title{font-size:.9rem}
.kpi-number{font-size:2.4rem;font-weight:800}

.kpi-solicitudes{background:linear-gradient(135deg,#ff9800,#ff5722)}
.kpi-pendientes{background:linear-gradient(135deg,#f44336,#d32f2f)}
.kpi-empleados{background:linear-gradient(135deg,#4caf50,#2e7d32)}
.kpi-asistencia{background:linear-gradient(135deg,#2196f3,#1e88e5)}

.chart-grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(380px,1fr));
  gap:26px;
  margin:40px 0;
}

.chart-card{
  background:linear-gradient(180deg,#ffffff,#f5f7ff);
  border-radius:22px;
  padding:22px;
  border:1px solid var(--border);
  transition:.35s;
}

.chart-card:hover{
  transform:translateY(-6px);
  box-shadow:0 18px 38px rgba(0,0,0,.18);
}

.chart-card h3{
  margin-bottom:12px;
  font-size:1.05rem;
  font-weight:600;
}


.chart-container{
  position:relative;
  width:100%;
  height:190px;
}

.dashboard-grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
  gap:18px;
}

.smart-card{
  background:#fff;
  border-radius:18px;
  padding:16px;
  border:1px solid var(--border);
  transition:.3s;
}

.smart-card:hover{
  transform:translateY(-6px);
  box-shadow:0 18px 40px rgba(0,0,0,.14);
}

.icon-container{
  width:46px;
  height:46px;
  border-radius:14px;
  display:flex;
  align-items:center;
  justify-content:center;
  margin-bottom:10px;
  background:#eef2ff;
}

.smart-card h3{margin:4px 0}
.smart-card p{font-size:.85rem;color:var(--muted)}

.card-action{
  margin-top:10px;
  padding:8px 18px;
  border-radius:100px;
  border:none;
  color:#fff;
  background:#1e88e5;
}

.smart-card{
  position:relative;
  background:linear-gradient(135deg,#ffffff,#f4f6ff);
  border-radius:20px;
  padding:18px;
  border:1px solid var(--border);
  cursor:pointer;
  overflow:hidden;
  transition:.45s cubic-bezier(.25,.8,.25,1);
}

.smart-card::after{
  content:"";
  position:absolute;
  inset:0;
  background:radial-gradient(circle at top left,rgba(255,255,255,.35),transparent 60%);
  opacity:.8;
}

.smart-card:hover{
  transform:translateY(-10px) scale(1.04);
  box-shadow:0 28px 60px rgba(0,0,0,.25);
}


.icon-container{
  width:52px;
  height:52px;
  border-radius:16px;
  display:flex;
  align-items:center;
  justify-content:center;
  font-size:28px;
  margin-bottom:12px;
  transition:.45s;
}

.smart-card:hover .icon-container{
  transform:rotate(-10deg) scale(1.2);
}


.welcome-box{
  display:flex;
  justify-content:space-between;
  align-items:center;
  padding:28px 34px;
  border-radius:28px;
  background:linear-gradient(135deg,#2b2d6e,#1a237e,#0d47a1);
  color:#fff;
  box-shadow:0 30px 65px rgba(13,71,161,.45);
  position:relative;
  overflow:hidden;
  margin-bottom:36px;
}


.welcome-box::after{
  content:"";
  position:absolute;
  inset:0;
  background:
    radial-gradient(circle at top left,rgba(255,255,255,.35),transparent 60%),
    radial-gradient(circle at bottom right,rgba(255,255,255,.15),transparent 55%);
}


.welcome-text h2{
  margin:0;
  font-size:2.4rem;
  font-weight:900;
  letter-spacing:-.8px;
  color:#ffffff;
}


.user-name{
  display:block;
  font-size:1.7rem;
  font-weight:800;
  background:linear-gradient(90deg,#ffcc80,#ff8a65,#f06292);
  -webkit-background-clip:text;
  -webkit-text-fill-color:transparent;
  margin-top:2px;
}


.welcome-text p{
  margin-top:8px;
  font-size:1rem;
  font-weight:500;
  color:rgba(255,255,255,.75);
  letter-spacing:.4px;
}

.welcome-icon{
  width:76px;
  height:76px;
  border-radius:24px;
  background:linear-gradient(135deg,rgba(255,255,255,.35),rgba(255,255,255,.1));
  backdrop-filter:blur(8px);
  display:flex;
  align-items:center;
  justify-content:center;
  font-size:42px;
  transition:.45s;
  box-shadow:0 15px 35px rgba(0,0,0,.35);
}

.welcome-icon span{
  color:#fff;
}


.welcome-box:hover .welcome-icon{
  transform:rotate(-12deg) scale(1.18);
}

.card-footer{
  margin-top:10px;
  display:flex;
  justify-content:flex-end;
  color:rgba(255,255,255,.8);
  transition:.35s;
}

.smart-card:hover .card-footer{
  transform:translateX(8px);
  color:#fff;
}

.card-qr{
  background:linear-gradient(135deg,#2196f3,#21cbf3);
  color:#fff;
}

.card-users{
  background:linear-gradient(135deg,#4caf50,#2e7d32);
  color:#fff;
}

.card-just{
  background:linear-gradient(135deg,#ff9800,#f57c00);
  color:#fff;
}

.card-report{
  background:linear-gradient(135deg,#ec407a,#c2185b);
  color:#fff;
}

.page-header{
  margin-bottom:28px;
}

.page-title{
  font-size:2.1rem;
  font-weight:800;
  letter-spacing:-.5px;
  color:#111827;
}

.highlight-name{
  background:linear-gradient(90deg,#2196f3,#21cbf3);
  -webkit-background-clip:text;
  -webkit-text-fill-color:transparent;
}

.page-subtitle{
  margin-top:6px;
  font-size:.95rem;
  font-weight:500;
  color:#6b7280;
  letter-spacing:.3px;
}

.card-qr .icon-container,
.card-users .icon-container,
.card-just .icon-container,
.card-report .icon-container{
  background:rgba(255,255,255,.25);
  color:#fff;
}


@media(max-width:768px){
  .dashboard-grid{grid-template-columns:repeat(2,1fr)}
}
</style>
</head>

<body>



<jsp:include page="../shared/sidebar.jsp"/>

<div class="main-content">
<jsp:include page="../shared/header.jsp"/>

<div class="content-wrapper">

<div class="welcome-box">
  <div class="welcome-text">
    <h2>
      Bienvenido,
      <span class="user-name">${sessionScope.usuario.nombres}</span>
    </h2>
    <p>Panel de control administrativo</p>
  </div>

  <div class="welcome-icon">
    <span class="material-symbols-outlined">dashboard</span>
  </div>
</div>


<div class="kpi-grid">
  <div class="kpi-card kpi-solicitudes">
    <div class="kpi-icon"><span class="material-symbols-outlined">event_busy</span></div>
    <div class="kpi-title">Inasistencias de hoy</div>
    <div class="kpi-number">${inasistenciasHoy}</div>
  </div>

  <div class="kpi-card kpi-pendientes">
    <div class="kpi-icon"><span class="material-symbols-outlined">assignment_late</span></div>
    <div class="kpi-title">Justificaciones de hoy</div>
    <div class="kpi-number">${justificacionesHoy}</div>
  </div>


  <div class="kpi-card kpi-asistencia">
    <div class="kpi-icon"><span class="material-symbols-outlined">timer_off</span></div>
    <div class="kpi-title">Tardanzas</div>
    <div class="kpi-number">${tardanzasHoy}</div>
  </div>
  
   <div class="kpi-card kpi-empleados">
    <div class="kpi-icon"><span class="material-symbols-outlined">group</span></div>
    <div class="kpi-title">Empleados</div>
    <div class="kpi-number">${totalEmpleados}</div>
  </div>
</div>

<div class="chart-grid">
  <div class="chart-card">
    <h3>Solicitudes por estado</h3>
    <div class="chart-container"><canvas id="estadoChart"></canvas></div>
  </div>

  <div class="chart-card">
    <h3>Asistencia semanal</h3>
    <div class="chart-container"><canvas id="asistenciaChart"></canvas></div>
  </div>
</div>

<div class="dashboard-grid">


  <div class="smart-card card-qr" onclick="location.href='${pageContext.request.contextPath}/ver-qr'">
    <div class="icon-container">
      <span class="material-symbols-outlined">qr_code_2</span>
    </div>
    <div class="card-content">
      <h3>Asistencia QR</h3>
      <p>Control rápido de ingreso</p>
    </div>
    <div class="card-footer">
      <span class="material-symbols-outlined">arrow_forward</span>
    </div>
  </div>


  <div class="smart-card card-users" onclick="location.href='${pageContext.request.contextPath}/empleados?accion=listar'">
    <div class="icon-container">
      <span class="material-symbols-outlined">group</span>
    </div>
    <div class="card-content">
      <h3>Personal</h3>
      <p>Gestión de empleados</p>
    </div>
    <div class="card-footer">
      <span class="material-symbols-outlined">arrow_forward</span>
    </div>
  </div>

  <div class="smart-card card-just" onclick="location.href='${pageContext.request.contextPath}/justificaciones'">
    <div class="icon-container">
      <span class="material-symbols-outlined">assignment_ind</span>
    </div>
    <div class="card-content">
      <h3>Justificaciones</h3>
      <p>Solicitudes pendientes</p>
    </div>
    <div class="card-footer">
      <span class="material-symbols-outlined">arrow_forward</span>
    </div>
  </div>


  <div class="smart-card card-report" onclick="location.href='${pageContext.request.contextPath}/asistencias'">
    <div class="icon-container">
      <span class="material-symbols-outlined">bar_chart</span>
    </div>
    <div class="card-content">
      <h3>Reportes</h3>
      <p>Asistencia y exportación</p>
    </div>
    <div class="card-footer">
      <span class="material-symbols-outlined">arrow_forward</span>
    </div>
  </div>

</div>


</div>
</div>

<script>
const ctx1 = document.getElementById('estadoChart').getContext('2d');
const grad1 = ctx1.createLinearGradient(0,0,0,200);
grad1.addColorStop(0,'#ff9800');
grad1.addColorStop(1,'#ff5722');

const grad2 = ctx1.createLinearGradient(0,0,0,200);
grad2.addColorStop(0,'#2196f3');
grad2.addColorStop(1,'#1e88e5');

const grad3 = ctx1.createLinearGradient(0,0,0,200);
grad3.addColorStop(0,'#4caf50');
grad3.addColorStop(1,'#2e7d32');

new Chart(ctx1,{
  type:'doughnut',
  data:{
    labels:['Pendiente','Proceso','Cerrado'],
    datasets:[{
      data:[5,7,12],
      backgroundColor:[grad1,grad2,grad3],
      borderWidth:0
    }]
  },
  options:{
    maintainAspectRatio:false,
    animation:{animateRotate:true,duration:1400},
    plugins:{
      legend:{position:'bottom'},
      tooltip:{backgroundColor:'#111827'}
    }
  }
});

const ctx2 = document.getElementById('asistenciaChart').getContext('2d');
const lineGrad = ctx2.createLinearGradient(0,0,0,200);
lineGrad.addColorStop(0,'rgba(30,136,229,.45)');
lineGrad.addColorStop(1,'rgba(30,136,229,.05)');

new Chart(ctx2,{
  type:'line',
  data:{
    labels:['Lun','Mar','Mié','Jue','Vie'],
    datasets:[{
      data:[40,42,38,45,44],
      borderColor:'#1e88e5',
      backgroundColor:lineGrad,
      fill:true,
      tension:.45,
      pointRadius:4
    }]
  },
  options:{
    maintainAspectRatio:false,
    animation:{duration:1200},
    scales:{y:{beginAtZero:true}}
  }
});
</script>

</body>
</html>
