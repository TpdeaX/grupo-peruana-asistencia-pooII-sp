package com.grupoperuana.sistema.controllers;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.List;

import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.multipart.MultipartFile;

import com.grupoperuana.sistema.beans.Asistencia;
import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.dto.TurnoDTO;
import com.grupoperuana.sistema.services.AsistenciaService;
import com.grupoperuana.sistema.services.ReporteService;
import com.grupoperuana.sistema.repositories.SucursalRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import java.time.LocalDate;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
public class AsistenciaController {

    private final AsistenciaService asistenciaService;
    private final ReporteService reporteService;
    private final SucursalRepository sucursalRepository;

    public AsistenciaController(AsistenciaService asistenciaService, ReporteService reporteService,
            SucursalRepository sucursalRepository) {
        this.asistenciaService = asistenciaService;
        this.reporteService = reporteService;
        this.sucursalRepository = sucursalRepository;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @PostMapping("/admin/asistencias/filter")
    public String filtrarAdmin(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer sucursalId,
            @RequestParam(required = false) LocalDate fechaInicio,
            @RequestParam(required = false) LocalDate fechaFin,
            HttpSession session) {

        session.setAttribute("asis_adm_page", page);
        session.setAttribute("asis_adm_size", size);
        session.setAttribute("asis_adm_keyword", keyword);
        session.setAttribute("asis_adm_sucursalId", sucursalId);
        session.setAttribute("asis_adm_fechaInicio", fechaInicio);
        session.setAttribute("asis_adm_fechaFin", fechaFin);

        return "redirect:/admin/asistencias";
    }

    @GetMapping({ "/asistencias", "/admin/asistencias", "/empleado/mi_historial", "/admin", "/empleado" })
    public String handleGet(HttpServletRequest request, HttpSession session, Model model,
            // Legacy params for direct links support can be captured here if needed,
            // but we'll prioritize session for Admin.
            @RequestParam(required = false) String keywordParam,
            @RequestParam(required = false) Integer sucursalIdParam) {

        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        String path = request.getServletPath();

        if ("ADMIN".equals(usuario.getRol())) {
            if (path.contains("/admin") && !path.contains("asistencias")) {
                return "redirect:/empleados?accion=dashboard";
            }

            // Logic for /asistencias or /admin/asistencias

            // 1. Recover params from Session
            Integer pageObj = (Integer) session.getAttribute("asis_adm_page");
            int page = (pageObj != null) ? pageObj : 0;

            Integer sizeObj = (Integer) session.getAttribute("asis_adm_size");
            int size = (sizeObj != null) ? sizeObj : 10;
            if (size < 1)
                size = 10;
            if (size > 100)
                size = 100;

            String keyword = (String) session.getAttribute("asis_adm_keyword");
            if (keyword == null)
                keyword = "";

            Integer sucursalId = (Integer) session.getAttribute("asis_adm_sucursalId");
            LocalDate fechaInicio = (LocalDate) session.getAttribute("asis_adm_fechaInicio");
            LocalDate fechaFin = (LocalDate) session.getAttribute("asis_adm_fechaFin");

            // 2. Call Service
            Page<Asistencia> pagina = asistenciaService.listarAsistenciasPaginado(
                    PageRequest.of(page, size, Sort.by("fecha").descending().and(Sort.by("horaEntrada").descending())),
                    keyword, sucursalId, fechaInicio, fechaFin);

            model.addAttribute("listaAsistencia", pagina.getContent());
            model.addAttribute("pagina", pagina);
            model.addAttribute("listaSucursales", sucursalRepository.findAll());

            // 3. Pass filters back to view
            model.addAttribute("keyword", keyword);
            model.addAttribute("sucursalId", sucursalId);
            model.addAttribute("fechaInicio", fechaInicio);
            model.addAttribute("fechaFin", fechaFin);
            model.addAttribute("size", size);

            return "views/admin/asistencias";
        } else {

            if (path.contains("/asistencias") || path.contains("mi_historial")) {
                List<Asistencia> lista = asistenciaService.listarPorEmpleado(usuario.getId());
                model.addAttribute("listaAsistencia", lista);
                return "views/empleado/mi_historial";
            } else {

                List<TurnoDTO> reporteDiario = asistenciaService.obtenerReporteDiario(usuario.getId());
                model.addAttribute("reporteDiario", reporteDiario);

                boolean hayTurnoAbierto = asistenciaService.listarPorEmpleado(usuario.getId()).stream()
                        .anyMatch(a -> a.getFecha().isEqual(java.time.LocalDate.now()) && a.getHoraSalida() == null);

                boolean finJornada = asistenciaService.verificarFinJornada(usuario.getId());
                boolean esDiaJustificado = !reporteDiario.isEmpty() && reporteDiario.stream()
                        .allMatch(t -> "JUSTIFICADA".equals(t.getEstado()));

                model.addAttribute("hayTurnoAbierto", hayTurnoAbierto);
                model.addAttribute("finJornada", finJornada);
                model.addAttribute("esDiaJustificado", esDiaJustificado);

                return "views/empleado/dashboard";
            }
        }
    }

    @PostMapping("/asistencias/marcar")
    public String marcar(@RequestParam("accion") String accion, @RequestParam("modo") String modo,
            @RequestParam("latitud") double lat, @RequestParam("longitud") double lon,
            @RequestParam(value = "observacion", required = false) String observacion,
            @RequestParam(value = "foto", required = false) MultipartFile foto,
            @RequestParam(value = "sospechosa", defaultValue = "false") boolean sospechosa,
            HttpSession session,
            RedirectAttributes flash) {

        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        if ("marcar".equals(accion)) {
            try {
                Empleado usuario = (Empleado) session.getAttribute("usuario");
                String resultado = asistenciaService.marcarAsistencia(usuario.getId(), modo, lat, lon, observacion,
                        foto, sospechosa);

                if ("ERROR".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "Error al procesar la marca.");
                    flash.addFlashAttribute("tipoMensaje", "error");
                } else if ("SIN_TURNO".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "No hay turnos disponibles para marcar o ya pasaron.");
                    flash.addFlashAttribute("tipoMensaje", "warning");
                } else if ("ENTRADA_LIBRE".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "¡Entrada registrada! (Empleado libre)");
                    flash.addFlashAttribute("tipoMensaje", "success");
                } else if ("SIN_TURNO_ADVERTENCIA".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "⚠️ Entrada registrada. No tienes turnos programados hoy.");
                    flash.addFlashAttribute("tipoMensaje", "warning");
                } else if ("TURNOS_PASADOS".equals(resultado)) {
                    flash.addFlashAttribute("mensaje",
                            "⚠️ Entrada registrada. Tus turnos ya terminaron (entrada tardía).");
                    flash.addFlashAttribute("tipoMensaje", "warning");
                } else if ("SALIDA_CON_PROXIMO".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "¡Salida registrada!");
                    flash.addFlashAttribute("tipoMensaje", "success");
                    flash.addFlashAttribute("promptNextActivity", true); // Trigger modal
                } else if ("ENTRADA_SOSPECHOSA".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "⚠️ Entrada registrada como SOSPECHOSA (fuera de rango)");
                    flash.addFlashAttribute("tipoMensaje", "warning");
                } else {
                    flash.addFlashAttribute("mensaje", "¡Marca de " + resultado + " registrada!");
                    flash.addFlashAttribute("tipoMensaje", "success");
                }
            } catch (Exception e) {
                flash.addFlashAttribute("mensaje", "Error: " + e.getMessage());
                flash.addFlashAttribute("tipoMensaje", "error");
            }
        }
        return "redirect:/empleado";
    }

    @PostMapping("/qr")
    public String marcarQr(@RequestParam("qrToken") String qrToken,
            @RequestParam(value = "foto", required = false) MultipartFile foto,
            HttpSession session, RedirectAttributes flash) {
        Empleado empleado = (Empleado) session.getAttribute("usuario");

        if (empleado == null)
            return "redirect:/login";

        String resultado = asistenciaService.procesarQrDinamico(empleado.getId(), qrToken, foto);

        if ("EXITO".equals(resultado) || "EXITO_SALIDA".equals(resultado)) {
            flash.addFlashAttribute("mensaje", "Asistencia registrada correctamente");
            return "redirect:/empleado/mi_historial";
        } else if ("EXITO_CON_PROXIMO".equals(resultado)) {
            flash.addFlashAttribute("mensaje", "Asistencia QR registrada.");
            flash.addFlashAttribute("promptNextActivity", true);
            return "redirect:/empleado";
        } else {
            flash.addFlashAttribute("error", resultado);
            return "redirect:/empleado/escanear";
        }
    }

    @GetMapping("/empleado/escanear")
    public String mostrarCamara(HttpSession session) {
        if (session.getAttribute("usuario") == null) {
            return "redirect:/index.jsp";
        }
        return "views/empleado/escanear";
    }

    @GetMapping("/admin/exportar/excel")
    public ResponseEntity<InputStreamResource> descargarExcel(HttpSession session) throws IOException {
        String keyword = (String) session.getAttribute("asis_adm_keyword");
        if (keyword == null)
            keyword = "";
        Integer sucursalId = (Integer) session.getAttribute("asis_adm_sucursalId");
        LocalDate fechaInicio = (LocalDate) session.getAttribute("asis_adm_fechaInicio");
        LocalDate fechaFin = (LocalDate) session.getAttribute("asis_adm_fechaFin");

        List<Asistencia> lista = asistenciaService.listarAsistenciasFiltradas(keyword, sucursalId, fechaInicio,
                fechaFin);
        ByteArrayInputStream in = reporteService.generarListadoExcel(lista);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=asistencias.xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("application/vnd.ms-excel"))
                .body(new InputStreamResource(in));
    }

    @GetMapping("/admin/exportar/pdf")
    public ResponseEntity<InputStreamResource> descargarPDF(HttpSession session) {
        String keyword = (String) session.getAttribute("asis_adm_keyword");
        if (keyword == null)
            keyword = "";
        Integer sucursalId = (Integer) session.getAttribute("asis_adm_sucursalId");
        LocalDate fechaInicio = (LocalDate) session.getAttribute("asis_adm_fechaInicio");
        LocalDate fechaFin = (LocalDate) session.getAttribute("asis_adm_fechaFin");

        List<Asistencia> lista = asistenciaService.listarAsistenciasFiltradas(keyword, sucursalId, fechaInicio,
                fechaFin);
        ByteArrayInputStream in = reporteService.generarListadoPDF(lista);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=asistencias.pdf");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.APPLICATION_PDF)
                .body(new InputStreamResource(in));
    }

    @GetMapping("/admin/api/ultima-asistencia")
    @org.springframework.web.bind.annotation.ResponseBody
    public java.util.Map<String, Object> getUltimaAsistencia(HttpSession session) {
        if (!checkSession(session)) {
            return null;
        }

        // Fetch the very last attendance (page 0, size 1, sort by ID desc)
        Page<Asistencia> page = asistenciaService.listarAsistenciasPaginado(
                PageRequest.of(0, 1, Sort.by("id").descending()),
                null, null, null, null // No filters
        );

        if (page.hasContent()) {
            Asistencia a = page.getContent().get(0);
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", a.getId());
            map.put("fecha", a.getFecha().toString());
            map.put("horaEntrada", a.getHoraEntrada() != null ? a.getHoraEntrada().toString() : "");
            map.put("horaSalida", a.getHoraSalida() != null ? a.getHoraSalida().toString() : "");
            map.put("modo", a.getModo());

            java.util.Map<String, Object> emp = new java.util.HashMap<>();
            emp.put("nombres", a.getEmpleado().getNombres());
            emp.put("apellidos", a.getEmpleado().getApellidos());
            emp.put("dni", a.getEmpleado().getDni());
            map.put("empleado", emp);

            return map;
        }
        return java.util.Collections.emptyMap();
    }
}