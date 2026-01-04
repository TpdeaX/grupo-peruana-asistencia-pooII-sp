package com.grupoperuana.sistema.controllers;

import com.grupoperuana.sistema.dto.ReporteAsistenciaDTO;
import com.grupoperuana.sistema.dto.ReporteResumenDTO;
import com.grupoperuana.sistema.services.EmpleadoService;
import com.grupoperuana.sistema.services.ReporteService;
import com.grupoperuana.sistema.services.SucursalService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

@Controller
@RequestMapping("/reportes")
public class ReporteController {

    @Autowired
    private ReporteService reporteService;

    @Autowired
    private EmpleadoService empleadoService;

    @Autowired
    private SucursalService sucursalService;

    // --- 1. REPORTE DE CÁLCULO (ASISTENCIA DETALLADA) ---

    @PostMapping("/calculo")
    public String filtrarCalculo(
            @RequestParam(value = "fechaInicio", required = false) LocalDate fechaInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate fechaFin,
            @RequestParam(value = "empleadoId", required = false) Integer empleadoId,
            @RequestParam(value = "sucursalId", required = false) Integer sucursalId,
            @RequestParam(value = "sort", required = false, defaultValue = "fecha_desc") String sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpSession session) {

        session.setAttribute("rep_calc_fechaInicio", fechaInicio);
        session.setAttribute("rep_calc_fechaFin", fechaFin);
        session.setAttribute("rep_calc_empleadoId", empleadoId);
        session.setAttribute("rep_calc_sucursalId", sucursalId);
        session.setAttribute("rep_calc_sort", sort);
        session.setAttribute("rep_calc_page", page);
        session.setAttribute("rep_calc_size", size);

        return "redirect:/reportes/calculo";
    }

    @GetMapping("/calculo")
    public String verReporte(
            @RequestParam(value = "fechaInicio", required = false) LocalDate reqInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate reqFin,
            Model model, HttpSession session) {

        // Legacy/Direct Link Support: If params in URL, save and redirect
        if (reqInicio != null || reqFin != null) {
            if (reqInicio != null)
                session.setAttribute("rep_calc_fechaInicio", reqInicio);
            if (reqFin != null)
                session.setAttribute("rep_calc_fechaFin", reqFin);
            return "redirect:/reportes/calculo";
        }

        // Recover from Session or Default
        LocalDate fechaInicio = (LocalDate) session.getAttribute("rep_calc_fechaInicio");
        LocalDate fechaFin = (LocalDate) session.getAttribute("rep_calc_fechaFin");
        Integer empleadoId = (Integer) session.getAttribute("rep_calc_empleadoId");
        Integer sucursalId = (Integer) session.getAttribute("rep_calc_sucursalId");
        String sort = (String) session.getAttribute("rep_calc_sort");
        if (sort == null)
            sort = "fecha_desc";

        Integer pageObj = (Integer) session.getAttribute("rep_calc_page");
        int page = (pageObj != null) ? pageObj : 0;

        Integer sizeObj = (Integer) session.getAttribute("rep_calc_size");
        int size = (sizeObj != null) ? sizeObj : 10;

        // Load Filters
        try {
            model.addAttribute("empleados", empleadoService.listarEmpleados());
            model.addAttribute("sucursales", sucursalService.listarTodas());
        } catch (Throwable e) {
            model.addAttribute("error", "Error cargando filtros: " + e.getMessage());
        }

        // Defaults if still null
        if (fechaInicio == null)
            fechaInicio = LocalDate.now().withDayOfMonth(1);
        if (fechaFin == null)
            fechaFin = LocalDate.now();

        // Save back defaults to session to be consistent
        session.setAttribute("rep_calc_fechaInicio", fechaInicio);
        session.setAttribute("rep_calc_fechaFin", fechaFin);

        try {
            List<ReporteAsistenciaDTO> fullReporte = reporteService.generarReporte(fechaInicio, fechaFin,
                    empleadoId, sucursalId, sort);

            // Pagination
            int start = Math.min(page * size, fullReporte.size());
            int end = Math.min((start + size), fullReporte.size());
            List<ReporteAsistenciaDTO> pageContent = fullReporte.subList(start, end);

            org.springframework.data.domain.Page<ReporteAsistenciaDTO> pageResponse = new org.springframework.data.domain.PageImpl<>(
                    pageContent, org.springframework.data.domain.PageRequest.of(page, size), fullReporte.size());

            model.addAttribute("reporte", pageContent);
            model.addAttribute("pagina", pageResponse);

            // Pass vars to view
            model.addAttribute("fechaInicio", fechaInicio);
            model.addAttribute("fechaFin", fechaFin);
            model.addAttribute("empleadoId", empleadoId);
            model.addAttribute("sucursalId", sucursalId);
            model.addAttribute("sort", sort);
            model.addAttribute("size", size);

        } catch (Throwable e) {
            e.printStackTrace();
            model.addAttribute("error", "Error generando reporte: " + e.getMessage());
        }

        return "views/reportes/calculo_horas";
    }

    @GetMapping("/exportar/excel")
    public ResponseEntity<InputStreamResource> exportarExcel(HttpSession session) {
        LocalDate fechaInicio = (LocalDate) session.getAttribute("rep_calc_fechaInicio");
        LocalDate fechaFin = (LocalDate) session.getAttribute("rep_calc_fechaFin");
        Integer empleadoId = (Integer) session.getAttribute("rep_calc_empleadoId");
        Integer sucursalId = (Integer) session.getAttribute("rep_calc_sucursalId");

        if (fechaInicio == null)
            fechaInicio = LocalDate.now().withDayOfMonth(1);
        if (fechaFin == null)
            fechaFin = LocalDate.now();

        List<ReporteAsistenciaDTO> reporte = reporteService.generarReporte(fechaInicio, fechaFin, empleadoId,
                sucursalId, null);
        ByteArrayInputStream in = reporteService.generarReporteExcel(reporte);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=reporte_asistencia.xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("application/vnd.ms-excel"))
                .body(new InputStreamResource(in));
    }

    @GetMapping("/exportar/pdf")
    public ResponseEntity<InputStreamResource> exportarPDF(HttpSession session) {
        LocalDate fechaInicio = (LocalDate) session.getAttribute("rep_calc_fechaInicio");
        LocalDate fechaFin = (LocalDate) session.getAttribute("rep_calc_fechaFin");
        Integer empleadoId = (Integer) session.getAttribute("rep_calc_empleadoId");
        Integer sucursalId = (Integer) session.getAttribute("rep_calc_sucursalId");

        if (fechaInicio == null)
            fechaInicio = LocalDate.now().withDayOfMonth(1);
        if (fechaFin == null)
            fechaFin = LocalDate.now();

        List<ReporteAsistenciaDTO> reporte = reporteService.generarReporte(fechaInicio, fechaFin, empleadoId,
                sucursalId, null);
        ByteArrayInputStream in = reporteService.generarReportePDF(reporte);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=reporte_asistencia.pdf");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.APPLICATION_PDF)
                .body(new InputStreamResource(in));
    }

    // --- 2. REPORTE DE HORAS (RESUMEN) ---

    @PostMapping("/horas")
    public String filtrarHoras(
            @RequestParam(value = "fechaInicio", required = false) LocalDate fechaInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate fechaFin,
            @RequestParam(value = "sucursalId", required = false) Integer sucursalId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpSession session) {

        session.setAttribute("rep_hrs_fechaInicio", fechaInicio);
        session.setAttribute("rep_hrs_fechaFin", fechaFin);
        session.setAttribute("rep_hrs_sucursalId", sucursalId);
        session.setAttribute("rep_hrs_page", page);
        session.setAttribute("rep_hrs_size", size);

        return "redirect:/reportes/horas";
    }

    @GetMapping("/horas")
    public String verReporteHoras(
            @RequestParam(value = "fechaInicio", required = false) LocalDate reqInicio,
            Model model, HttpSession session) {

        if (reqInicio != null) {
            session.setAttribute("rep_hrs_fechaInicio", reqInicio);
            return "redirect:/reportes/horas";
        }

        LocalDate fechaInicio = (LocalDate) session.getAttribute("rep_hrs_fechaInicio");
        LocalDate fechaFin = (LocalDate) session.getAttribute("rep_hrs_fechaFin");
        Integer sucursalId = (Integer) session.getAttribute("rep_hrs_sucursalId");
        Integer pageObj = (Integer) session.getAttribute("rep_hrs_page");
        int page = (pageObj != null) ? pageObj : 0;
        Integer sizeObj = (Integer) session.getAttribute("rep_hrs_size");
        int size = (sizeObj != null) ? sizeObj : 10;

        try {
            model.addAttribute("sucursales", sucursalService.listarTodas());
        } catch (Throwable e) {
            model.addAttribute("sucursales", List.of());
        }

        if (fechaInicio == null)
            fechaInicio = LocalDate.now().withDayOfMonth(1);
        if (fechaFin == null)
            fechaFin = LocalDate.now();

        // Save defaults
        session.setAttribute("rep_hrs_fechaInicio", fechaInicio);
        session.setAttribute("rep_hrs_fechaFin", fechaFin);

        try {
            List<ReporteAsistenciaDTO> dailyReport = reporteService.generarReporte(fechaInicio, fechaFin, null,
                    sucursalId, null);
            List<ReporteResumenDTO> resumen = agruparResumen(dailyReport);

            // Pagination
            int start = Math.min(page * size, resumen.size());
            int end = Math.min((start + size), resumen.size());
            List<ReporteResumenDTO> pageContent = resumen.subList(start, end);

            org.springframework.data.domain.Page<ReporteResumenDTO> pageResponse = new org.springframework.data.domain.PageImpl<>(
                    pageContent, org.springframework.data.domain.PageRequest.of(page, size), resumen.size());

            model.addAttribute("reporte", pageContent);
            model.addAttribute("pagina", pageResponse);
            model.addAttribute("fechaInicio", fechaInicio);
            model.addAttribute("fechaFin", fechaFin);
            model.addAttribute("sucursalId", sucursalId);
            model.addAttribute("size", size);

        } catch (Throwable e) {
            e.printStackTrace();
            model.addAttribute("error", "Error generando reporte de horas: " + e.getMessage());
        }

        return "views/reportes/reporte_horas";
    }

    // --- 3. REPORTE DE PUNTUALIDAD ---

    @PostMapping("/puntualidad")
    public String filtrarPuntualidad(
            @RequestParam(value = "fechaInicio", required = false) LocalDate fechaInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate fechaFin,
            @RequestParam(value = "sucursalId", required = false) Integer sucursalId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            HttpSession session) {

        session.setAttribute("rep_pun_fechaInicio", fechaInicio);
        session.setAttribute("rep_pun_fechaFin", fechaFin);
        session.setAttribute("rep_pun_sucursalId", sucursalId);
        session.setAttribute("rep_pun_page", page);
        session.setAttribute("rep_pun_size", size);

        return "redirect:/reportes/puntualidad";
    }

    @GetMapping("/puntualidad")
    public String verReportePuntualidad(
            @RequestParam(value = "fechaInicio", required = false) LocalDate reqInicio,
            Model model, HttpSession session) {

        if (reqInicio != null) {
            session.setAttribute("rep_pun_fechaInicio", reqInicio);
            return "redirect:/reportes/puntualidad";
        }

        LocalDate fechaInicio = (LocalDate) session.getAttribute("rep_pun_fechaInicio");
        LocalDate fechaFin = (LocalDate) session.getAttribute("rep_pun_fechaFin");
        Integer sucursalId = (Integer) session.getAttribute("rep_pun_sucursalId");
        Integer pageObj = (Integer) session.getAttribute("rep_pun_page");
        int page = (pageObj != null) ? pageObj : 0;
        Integer sizeObj = (Integer) session.getAttribute("rep_pun_size");
        int size = (sizeObj != null) ? sizeObj : 10;

        try {
            model.addAttribute("sucursales", sucursalService.listarTodas());
        } catch (Throwable e) {
            model.addAttribute("sucursales", List.of());
        }

        if (fechaInicio == null)
            fechaInicio = LocalDate.now().withDayOfMonth(1);
        if (fechaFin == null)
            fechaFin = LocalDate.now();

        // Save defaults
        session.setAttribute("rep_pun_fechaInicio", fechaInicio);
        session.setAttribute("rep_pun_fechaFin", fechaFin);

        try {
            List<ReporteAsistenciaDTO> dailyReport = reporteService.generarReporte(fechaInicio, fechaFin, null,
                    sucursalId, null);
            List<ReporteResumenDTO> resumen = agruparResumen(dailyReport);

            // Pagination
            int start = Math.min(page * size, resumen.size());
            int end = Math.min((start + size), resumen.size());
            List<ReporteResumenDTO> pageContent = resumen.subList(start, end);

            org.springframework.data.domain.Page<ReporteResumenDTO> pageResponse = new org.springframework.data.domain.PageImpl<>(
                    pageContent, org.springframework.data.domain.PageRequest.of(page, size), resumen.size());

            model.addAttribute("reporte", pageContent);
            model.addAttribute("pagina", pageResponse);
            model.addAttribute("fechaInicio", fechaInicio);
            model.addAttribute("fechaFin", fechaFin);
            model.addAttribute("sucursalId", sucursalId);
            model.addAttribute("size", size);

        } catch (Throwable e) {
            e.printStackTrace();
            model.addAttribute("error", "Error generando reporte de puntualidad: " + e.getMessage());
        }

        return "views/reportes/reporte_puntualidad";
    }

    // Helper logic extracted from previous controller for aggregation
    private List<ReporteResumenDTO> agruparResumen(List<ReporteAsistenciaDTO> dailyReport) {
        Map<String, ReporteResumenDTO> resumenMap = new HashMap<>();

        for (ReporteAsistenciaDTO row : dailyReport) {
            String dni = row.getDniEmpleado();
            if (dni == null)
                continue;

            ReporteResumenDTO res = resumenMap.get(dni);
            if (res == null) {
                res = new ReporteResumenDTO();
                res.setDniEmpleado(dni);
                res.setNombreEmpleado(row.getNombreEmpleado());
                res.setSucursal(row.getSucursal());
                resumenMap.put(dni, res);
            }

            res.setTotalHorasProgramadas(res.getTotalHorasProgramadas() + row.getHorasProgramadas());
            res.setTotalHorasTrabajadas(res.getTotalHorasTrabajadas() + row.getHorasTrabajadas());

            double diff = row.getDiferenciaHoras();
            if (diff > 0) {
                res.setTotalHorasExtras(res.getTotalHorasExtras() + diff);
            } else {
                res.setTotalHorasDeuda(res.getTotalHorasDeuda() + Math.abs(diff));
            }

            res.setTotalMinutosTardanza(res.getTotalMinutosTardanza() + row.getMinutosTardanza());

            String estado = row.getEstado();
            if ("ASISTIO".equals(estado) || "TARDANZA".equals(estado) || "EXTRA".equals(estado)
                    || "FERIADO LABORADO".equals(estado)) {
                res.setDiasAsistidos(res.getDiasAsistidos() + 1);
            } else if ("FALTA".equals(estado)) {
                res.setDiasFaltas(res.getDiasFaltas() + 1);
            }

            if ("TARDANZA".equals(estado)) {
                res.setCantidadTardanzas(res.getCantidadTardanzas() + 1);
            }
            if ("FERIADO LABORADO".equals(estado)) {
                res.setDiasFeriadosLaborados(res.getDiasFeriadosLaborados() + 1);
            }
        }

        List<ReporteResumenDTO> fullList = new ArrayList<>(resumenMap.values());
        fullList.sort((a, b) -> a.getNombreEmpleado().compareToIgnoreCase(b.getNombreEmpleado()));
        return fullList;
    }
}
