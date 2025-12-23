package com.grupoperuana.sistema.controllers;

import com.grupoperuana.sistema.dto.ReporteAsistenciaDTO;
import com.grupoperuana.sistema.services.EmpleadoService;
import com.grupoperuana.sistema.services.ReporteService;
import com.grupoperuana.sistema.services.SucursalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.util.List;

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

    @GetMapping("/calculo")
    public String verReporte(@RequestParam(value = "fechaInicio", required = false) LocalDate fechaInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate fechaFin,
            @RequestParam(value = "empleadoId", required = false) Integer empleadoId,
            @RequestParam(value = "sucursalId", required = false) Integer sucursalId,
            @RequestParam(value = "sort", required = false, defaultValue = "fecha_desc") String sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        // Cargar listas para filtros
        try {
            model.addAttribute("empleados", empleadoService.listarEmpleados());
            model.addAttribute("sucursales", sucursalService.listarTodas());
        } catch (Throwable e) {
            System.out.println("ERROR DEBUG: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "Error cargando filtros: " + e.getMessage());
            model.addAttribute("empleados", List.of());
            model.addAttribute("sucursales", List.of());
        }

        try {
            if (fechaInicio != null && fechaFin != null) {
                // Fetch FULL list (service filtered and sorted)
                List<ReporteAsistenciaDTO> fullReporte = reporteService.generarReporte(fechaInicio, fechaFin,
                        empleadoId, sucursalId, sort);

                // Pagination Logic (In-Memory Slicing)
                int start = Math.min((int) org.springframework.data.domain.PageRequest.of(page, size).getOffset(),
                        fullReporte.size());
                int end = Math.min((start + size), fullReporte.size());

                List<ReporteAsistenciaDTO> pageContent = fullReporte.subList(start, end);

                org.springframework.data.domain.Page<ReporteAsistenciaDTO> pageResponse = new org.springframework.data.domain.PageImpl<>(
                        pageContent, org.springframework.data.domain.PageRequest.of(page, size), fullReporte.size());

                model.addAttribute("reporte", pageContent);
                model.addAttribute("pagina", pageResponse);

                model.addAttribute("fechaInicio", fechaInicio);
                model.addAttribute("fechaFin", fechaFin);
                model.addAttribute("empleadoId", empleadoId);
                model.addAttribute("sucursalId", sucursalId);
                model.addAttribute("sort", sort);
                model.addAttribute("size", size);

            } else {
                // Default values for form: today (start of month to now)
                model.addAttribute("fechaInicio", LocalDate.now().withDayOfMonth(1));
                model.addAttribute("fechaFin", LocalDate.now());
                model.addAttribute("size", size);
                model.addAttribute("sort", "fecha_desc");
            }
        } catch (Throwable e) {
            System.out.println("ERROR DEBUG: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "Error generando reporte: " + e.getMessage());
        }

        return "views/reportes/calculo_horas";
    }

    @GetMapping("/exportar/excel")
    public ResponseEntity<InputStreamResource> exportarExcel(
            @RequestParam(value = "fechaInicio", required = false) LocalDate fechaInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate fechaFin,
            @RequestParam(value = "empleadoId", required = false) Integer empleadoId) {

        if (fechaInicio == null)
            fechaInicio = LocalDate.now().withDayOfMonth(1);
        if (fechaFin == null)
            fechaFin = LocalDate.now();

        List<ReporteAsistenciaDTO> reporte = reporteService.generarReporte(fechaInicio, fechaFin, empleadoId, null,
                null);
        ByteArrayInputStream in = reporteService.generarReporteExcel(reporte);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=reporte_asistencia.xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("application/vnd.ms-excel"))
                .body(new InputStreamResource(in));
    }

    @GetMapping("/exportar/pdf")
    public ResponseEntity<InputStreamResource> exportarPDF(
            @RequestParam(value = "fechaInicio", required = false) LocalDate fechaInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate fechaFin,
            @RequestParam(value = "empleadoId", required = false) Integer empleadoId) {

        if (fechaInicio == null)
            fechaInicio = LocalDate.now().withDayOfMonth(1);
        if (fechaFin == null)
            fechaFin = LocalDate.now();

        List<ReporteAsistenciaDTO> reporte = reporteService.generarReporte(fechaInicio, fechaFin, empleadoId, null,
                null);
        ByteArrayInputStream in = reporteService.generarReportePDF(reporte);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=reporte_asistencia.pdf");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.APPLICATION_PDF)
                .body(new InputStreamResource(in));
    }

    @GetMapping("/horas")
    public String verReporteHoras(@RequestParam(value = "fechaInicio", required = false) LocalDate fechaInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate fechaFin,
            @RequestParam(value = "sucursalId", required = false) Integer sucursalId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        // Cargar listas para filtros
        try {
            model.addAttribute("sucursales", sucursalService.listarTodas());
        } catch (Throwable e) {
            model.addAttribute("sucursales", List.of());
        }

        try {
            if (fechaInicio != null && fechaFin != null) {
                // Fetch daily report for all employees (filtered by sucursal if needed)
                List<ReporteAsistenciaDTO> dailyReport = reporteService.generarReporte(fechaInicio, fechaFin, null,
                        sucursalId, null);

                // Aggregate by Employee
                java.util.Map<String, com.grupoperuana.sistema.dto.ReporteResumenDTO> resumenMap = new java.util.HashMap<>();

                for (ReporteAsistenciaDTO row : dailyReport) {
                    String dni = row.getDniEmpleado();
                    if (dni == null)
                        continue;

                    com.grupoperuana.sistema.dto.ReporteResumenDTO res = resumenMap.get(dni);
                    if (res == null) {
                        res = new com.grupoperuana.sistema.dto.ReporteResumenDTO();
                        res.setDniEmpleado(dni);
                        res.setNombreEmpleado(row.getNombreEmpleado());
                        res.setSucursal(row.getSucursal());
                        resumenMap.put(dni, res);
                    }

                    // Accumulate
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

                    if ("FERIADO LABORADO".equals(estado)) {
                        res.setDiasFeriadosLaborados(res.getDiasFeriadosLaborados() + 1);
                    }
                }

                List<com.grupoperuana.sistema.dto.ReporteResumenDTO> fullList = new java.util.ArrayList<>(
                        resumenMap.values());

                // Sort by name
                fullList.sort((a, b) -> a.getNombreEmpleado().compareToIgnoreCase(b.getNombreEmpleado()));

                // Pagination
                int start = Math.min((int) org.springframework.data.domain.PageRequest.of(page, size).getOffset(),
                        fullList.size());
                int end = Math.min((start + size), fullList.size());

                List<com.grupoperuana.sistema.dto.ReporteResumenDTO> pageContent = fullList.subList(start, end);

                org.springframework.data.domain.Page<com.grupoperuana.sistema.dto.ReporteResumenDTO> pageResponse = new org.springframework.data.domain.PageImpl<>(
                        pageContent, org.springframework.data.domain.PageRequest.of(page, size), fullList.size());

                model.addAttribute("reporte", pageContent);
                model.addAttribute("pagina", pageResponse);
                model.addAttribute("fechaInicio", fechaInicio);
                model.addAttribute("fechaFin", fechaFin);
                model.addAttribute("sucursalId", sucursalId);
                model.addAttribute("size", size);

            } else {
                model.addAttribute("fechaInicio", LocalDate.now().withDayOfMonth(1));
                model.addAttribute("fechaFin", LocalDate.now());
                model.addAttribute("size", size);
            }

        } catch (Throwable e) {
            e.printStackTrace();
            model.addAttribute("error", "Error generando reporte de horas: " + e.getMessage());
        }

        return "views/reportes/reporte_horas";
    }

    @GetMapping("/puntualidad")
    public String verReportePuntualidad(@RequestParam(value = "fechaInicio", required = false) LocalDate fechaInicio,
            @RequestParam(value = "fechaFin", required = false) LocalDate fechaFin,
            @RequestParam(value = "sucursalId", required = false) Integer sucursalId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            Model model) {

        // Cargar listas para filtros
        try {
            model.addAttribute("sucursales", sucursalService.listarTodas());
        } catch (Throwable e) {
            model.addAttribute("sucursales", List.of());
        }

        try {
            if (fechaInicio != null && fechaFin != null) {
                // Fetch daily report for all employees (filtered by sucursal if needed)
                List<ReporteAsistenciaDTO> dailyReport = reporteService.generarReporte(fechaInicio, fechaFin, null,
                        sucursalId, null);

                // Aggregate by Employee
                java.util.Map<String, com.grupoperuana.sistema.dto.ReporteResumenDTO> resumenMap = new java.util.HashMap<>();

                for (ReporteAsistenciaDTO row : dailyReport) {
                    String dni = row.getDniEmpleado();
                    if (dni == null)
                        continue;

                    com.grupoperuana.sistema.dto.ReporteResumenDTO res = resumenMap.get(dni);
                    if (res == null) {
                        res = new com.grupoperuana.sistema.dto.ReporteResumenDTO();
                        res.setDniEmpleado(dni);
                        res.setNombreEmpleado(row.getNombreEmpleado());
                        res.setSucursal(row.getSucursal());
                        resumenMap.put(dni, res);
                    }

                    // Accumulate
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

                List<com.grupoperuana.sistema.dto.ReporteResumenDTO> fullList = new java.util.ArrayList<>(
                        resumenMap.values());

                // Sort by name
                fullList.sort((a, b) -> a.getNombreEmpleado().compareToIgnoreCase(b.getNombreEmpleado()));

                // Pagination
                int start = Math.min((int) org.springframework.data.domain.PageRequest.of(page, size).getOffset(),
                        fullList.size());
                int end = Math.min((start + size), fullList.size());

                List<com.grupoperuana.sistema.dto.ReporteResumenDTO> pageContent = fullList.subList(start, end);

                org.springframework.data.domain.Page<com.grupoperuana.sistema.dto.ReporteResumenDTO> pageResponse = new org.springframework.data.domain.PageImpl<>(
                        pageContent, org.springframework.data.domain.PageRequest.of(page, size), fullList.size());

                model.addAttribute("reporte", pageContent);
                model.addAttribute("pagina", pageResponse);
                model.addAttribute("fechaInicio", fechaInicio);
                model.addAttribute("fechaFin", fechaFin);
                model.addAttribute("sucursalId", sucursalId);
                model.addAttribute("size", size);

            } else {
                model.addAttribute("fechaInicio", LocalDate.now().withDayOfMonth(1));
                model.addAttribute("fechaFin", LocalDate.now());
                model.addAttribute("size", size);
            }

        } catch (Throwable e) {
            e.printStackTrace();
            model.addAttribute("error", "Error generando reporte de puntualidad: " + e.getMessage());
        }

        return "views/reportes/reporte_puntualidad";
    }
}
