package com.grupoperuana.sistema.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.grupoperuana.sistema.beans.Asistencia;
import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.dto.AsistenciaDetalleDTO;
import com.grupoperuana.sistema.dto.DashboardDTO;
import com.grupoperuana.sistema.dto.EmpleadoRankingDTO;
import com.grupoperuana.sistema.services.AsistenciaService;
import com.grupoperuana.sistema.services.EmpleadoService;
import com.grupoperuana.sistema.services.JustificacionService;

import jakarta.servlet.http.HttpSession;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/dashboard")
public class DashboardController {

    private final EmpleadoService empleadoService;
    private final AsistenciaService asistenciaService;
    private final JustificacionService justificacionService;

    public DashboardController(EmpleadoService empleadoService,
            AsistenciaService asistenciaService,
            JustificacionService justificacionService) {
        this.empleadoService = empleadoService;
        this.asistenciaService = asistenciaService;
        this.justificacionService = justificacionService;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @GetMapping
    public String dashboard(Model model, HttpSession session) {
        if (!checkSession(session))
            return "redirect:/index.jsp";

        LocalDate hoy = LocalDate.now();
        ObjectMapper mapper = new ObjectMapper();

        List<Empleado> empleados = empleadoService.listarAvanzadoSinPaginacion("", null, null, null);
        int total = empleados.size();
        long asistencias = asistenciaService.contarAsistenciasFecha(hoy);
        long inasistencias = total - asistencias;
        if (inasistencias < 0)
            inasistencias = 0;

        model.addAttribute("totalEmpleados", total);
        model.addAttribute("inasistenciasHoy", inasistencias);
        model.addAttribute("justificacionesHoy", justificacionService.contarPendientes());
        model.addAttribute("tardanzasHoy", asistenciaService.contarTardanzasFecha(hoy));
        model.addAttribute("tasaPuntualidad", asistenciaService.calcularTasaPuntualidad(hoy));

        // Charts Data - Serialize to JSON to avoid JavaScript errors
        try {
            model.addAttribute("chartAsistencia",
                    mapper.writeValueAsString(asistenciaService.obtenerAsistenciasUltimos7Dias()));
            model.addAttribute("chartTardanzas",
                    mapper.writeValueAsString(asistenciaService.obtenerTardanzasUltimos7Dias()));
            model.addAttribute("chartLabels", mapper.writeValueAsString(asistenciaService.obtenerLabelsUltimos7Dias()));
            model.addAttribute("chartSolicitudes",
                    mapper.writeValueAsString(justificacionService.obtenerEstadisticasSolicitudes()));
            model.addAttribute("chartModos",
                    mapper.writeValueAsString(asistenciaService.obtenerDistribucionModos(hoy)));
        } catch (JsonProcessingException e) {
            model.addAttribute("chartAsistencia", "[0,0,0,0,0,0,0]");
            model.addAttribute("chartTardanzas", "[0,0,0,0,0,0,0]");
            model.addAttribute("chartLabels", "[\"Lun\",\"Mar\",\"Mie\",\"Jue\",\"Vie\",\"Sab\",\"Dom\"]");
            model.addAttribute("chartSolicitudes", "[0,0,0]");
            model.addAttribute("chartModos", "{}");
        }

        // Mejor empleado del día
        EmpleadoRankingDTO mejorEmpleado = asistenciaService.obtenerMejorEmpleadoRango(hoy, hoy);
        model.addAttribute("mejorEmpleado", mejorEmpleado);

        // Lista de empleados
        model.addAttribute("listaEmpleados", empleados);

        return "views/admin/dashboard";
    }

    // === API ENDPOINTS ===

    @GetMapping("/api/stats")
    @ResponseBody
    public DashboardDTO getStats(
            @RequestParam(required = false) String tipo,
            @RequestParam(required = false) String fechaInicio,
            @RequestParam(required = false) String fechaFin,
            HttpSession session) {

        if (!checkSession(session))
            return null;

        LocalDate inicio;
        LocalDate fin;
        LocalDate hoy = LocalDate.now();

        // Parse date range based on tipo
        if (tipo == null)
            tipo = "HOY";

        switch (tipo.toUpperCase()) {
            case "SEMANA":
                inicio = hoy.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
                fin = hoy.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));
                break;
            case "MES":
                inicio = hoy.withDayOfMonth(1);
                fin = hoy.withDayOfMonth(hoy.lengthOfMonth());
                break;
            case "AÑO":
            case "ANO":
                inicio = hoy.withDayOfYear(1);
                fin = hoy.withDayOfYear(hoy.lengthOfYear());
                break;
            case "PERSONALIZADO":
                try {
                    inicio = LocalDate.parse(fechaInicio);
                    fin = LocalDate.parse(fechaFin);
                } catch (Exception e) {
                    inicio = hoy;
                    fin = hoy;
                }
                break;
            default: // HOY
                inicio = hoy;
                fin = hoy;
        }

        DashboardDTO dto = new DashboardDTO();
        dto.setTipoRango(tipo);
        dto.setRangoFechaInicio(inicio.toString());
        dto.setRangoFechaFin(fin.toString());

        // Calculate KPIs for the date range
        List<Empleado> empleados = empleadoService.listarAvanzadoSinPaginacion("", null, null, null);
        dto.setTotalEmpleados(empleados.size());

        // For single day, use specific counts
        // For ranges, we need aggregated logic
        if (inicio.equals(fin)) {
            long asist = asistenciaService.contarAsistenciasFecha(inicio);
            dto.setAsistenciasHoy(asist);
            dto.setInasistenciasHoy(Math.max(0, empleados.size() - asist));
            dto.setTardanzasHoy(asistenciaService.contarTardanzasFecha(inicio));
            dto.setTasaPuntualidad(asistenciaService.calcularTasaPuntualidad(inicio));
        } else {
            // Range stats - simpler aggregation (sum of all days) - for demo use last day
            long asist = asistenciaService.contarAsistenciasFecha(fin);
            dto.setAsistenciasHoy(asist);
            dto.setInasistenciasHoy(Math.max(0, empleados.size() - asist));
            dto.setTardanzasHoy(asistenciaService.contarTardanzasFecha(fin));
            dto.setTasaPuntualidad(asistenciaService.calcularTasaPuntualidad(fin));
        }

        dto.setJustificacionesPendientes(justificacionService.contarPendientes());

        // Chart data
        dto.setChartAsistenciaSemanal(asistenciaService.obtenerAsistenciasUltimos7Dias());
        dto.setChartTardanzasSemanal(asistenciaService.obtenerTardanzasUltimos7Dias());
        dto.setChartLabels(asistenciaService.obtenerLabelsUltimos7Dias());
        dto.setChartDistribucionModos(asistenciaService.obtenerDistribucionModos(fin));
        dto.setChartSolicitudes(justificacionService.obtenerEstadisticasSolicitudes());

        // Best employee
        dto.setMejorEmpleado(asistenciaService.obtenerMejorEmpleadoRango(inicio, fin));

        return dto;
    }

    @GetMapping("/api/detalle/asistencias")
    @ResponseBody
    public List<AsistenciaDetalleDTO> getDetalleAsistencias(
            @RequestParam(required = false, defaultValue = "") String fecha,
            HttpSession session) {
        if (!checkSession(session))
            return new ArrayList<>();

        LocalDate targetDate = fecha.isEmpty() ? LocalDate.now() : LocalDate.parse(fecha);
        List<Asistencia> asistencias = asistenciaService.listarAsistenciasFecha(targetDate);
        return asistenciaService.convertirAsistenciasADetalle(asistencias);
    }

    @GetMapping("/api/detalle/tardanzas")
    @ResponseBody
    public List<AsistenciaDetalleDTO> getDetalleTardanzas(
            @RequestParam(required = false, defaultValue = "") String fecha,
            HttpSession session) {
        if (!checkSession(session))
            return new ArrayList<>();

        LocalDate targetDate = fecha.isEmpty() ? LocalDate.now() : LocalDate.parse(fecha);
        List<Asistencia> tardanzas = asistenciaService.listarTardanzasFecha(targetDate);
        return asistenciaService.convertirAsistenciasADetalle(tardanzas);
    }

    @GetMapping("/api/detalle/inasistencias")
    @ResponseBody
    public List<EmpleadoRankingDTO> getDetalleInasistencias(
            @RequestParam(required = false, defaultValue = "") String fecha,
            HttpSession session) {
        if (!checkSession(session))
            return new ArrayList<>();

        LocalDate targetDate = fecha.isEmpty() ? LocalDate.now() : LocalDate.parse(fecha);

        // Get all employees
        List<Empleado> todos = empleadoService.listarAvanzadoSinPaginacion("", null, null, null);

        // Get employees who marked attendance
        List<Asistencia> asistencias = asistenciaService.listarAsistenciasFecha(targetDate);
        Set<Integer> presentesIds = asistencias.stream()
                .map(a -> a.getEmpleado().getId())
                .collect(Collectors.toSet());

        // Filter absent employees
        List<EmpleadoRankingDTO> inasistentes = new ArrayList<>();
        for (Empleado e : todos) {
            if (!presentesIds.contains(e.getId())) {
                EmpleadoRankingDTO dto = new EmpleadoRankingDTO();
                dto.setId(e.getId());
                dto.setNombres(e.getNombres());
                dto.setApellidos(e.getApellidos());
                dto.setDni(e.getDni());
                inasistentes.add(dto);
            }
        }

        return inasistentes;
    }

    @GetMapping("/api/detalle/mejor-empleado")
    @ResponseBody
    public EmpleadoRankingDTO getDetalleMejorEmpleado(
            @RequestParam(required = false, defaultValue = "") String fechaInicio,
            @RequestParam(required = false, defaultValue = "") String fechaFin,
            HttpSession session) {
        if (!checkSession(session))
            return null;

        LocalDate inicio = fechaInicio.isEmpty() ? LocalDate.now() : LocalDate.parse(fechaInicio);
        LocalDate fin = fechaFin.isEmpty() ? LocalDate.now() : LocalDate.parse(fechaFin);

        return asistenciaService.obtenerMejorEmpleadoRango(inicio, fin);
    }
}
