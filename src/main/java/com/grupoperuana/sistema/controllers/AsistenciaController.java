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

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
public class AsistenciaController {

    private final AsistenciaService asistenciaService;
    private final ReporteService reporteService;

    public AsistenciaController(AsistenciaService asistenciaService, ReporteService reporteService) {
        this.asistenciaService = asistenciaService;
        this.reporteService = reporteService;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @GetMapping({ "/asistencias", "/admin", "/empleado", "/admin/asistencias" })
    public String handleGet(HttpServletRequest request, HttpSession session, Model model) {
        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        Empleado usuario = (Empleado) session.getAttribute("usuario");
        String path = request.getServletPath();

        if ("ADMIN".equals(usuario.getRol())) {
            if (path.contains("/admin/asistencias") || path.contains("/asistencias")) {
                List<Asistencia> lista = asistenciaService.listarTodo();
                model.addAttribute("listaAsistencia", lista);
                return "views/admin/reporte_asistencia";
            } else {
                return "views/admin/dashboard";
            }
        } else {

            if (path.contains("/asistencias")) {
                List<Asistencia> lista = asistenciaService.listarPorEmpleado(usuario.getId());
                model.addAttribute("listaAsistencia", lista);
                return "views/empleado/mi_historial";
            } else {

                List<TurnoDTO> reporteDiario = asistenciaService.obtenerReporteDiario(usuario.getId());
                model.addAttribute("reporteDiario", reporteDiario);

                boolean hayTurnoAbierto = asistenciaService.listarPorEmpleado(usuario.getId()).stream()
                        .anyMatch(a -> a.getFecha().isEqual(java.time.LocalDate.now()) && a.getHoraSalida() == null);

                boolean finJornada = asistenciaService.verificarFinJornada(usuario.getId());

                model.addAttribute("hayTurnoAbierto", hayTurnoAbierto);
                model.addAttribute("finJornada", finJornada);

                return "views/empleado/dashboard";
            }
        }
    }

    @PostMapping("/asistencias/marcar")
    public String marcar(@RequestParam("accion") String accion, @RequestParam("modo") String modo,
            @RequestParam("latitud") double lat, @RequestParam("longitud") double lon,
            @RequestParam(value = "observacion", required = false) String observacion,
            @RequestParam(value = "foto", required = false) MultipartFile foto,
            HttpSession session,
            RedirectAttributes flash) {

        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        if ("marcar".equals(accion)) {
            try {
                Empleado usuario = (Empleado) session.getAttribute("usuario");
                String resultado = asistenciaService.marcarAsistencia(usuario.getId(), modo, lat, lon, observacion,
                        foto);

                if ("ERROR".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "Error al procesar la marca.");
                    flash.addFlashAttribute("tipoMensaje", "error");
                } else if ("SIN_TURNO".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "No hay turnos disponibles para marcar o ya pasaron.");
                    flash.addFlashAttribute("tipoMensaje", "warning");
                } else if ("SALIDA_CON_PROXIMO".equals(resultado)) {
                    flash.addFlashAttribute("mensaje", "¡Salida registrada!");
                    flash.addFlashAttribute("tipoMensaje", "success");
                    flash.addFlashAttribute("promptNextActivity", true); // Trigger modal
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

    @GetMapping("/ver-qr")
    public String mostrarPantallaQR(HttpSession session) {
        if (session.getAttribute("usuario") == null) {
            return "redirect:/index.jsp";
        }
        return "views/admin/pantalla_qr";
    }

    @GetMapping("/empleado/escanear")
    public String mostrarCamara(HttpSession session) {
        if (session.getAttribute("usuario") == null) {
            return "redirect:/index.jsp";
        }
        return "views/empleado/escanear";
    }

    @GetMapping("/admin/exportar/excel")
    public ResponseEntity<InputStreamResource> descargarExcel() throws IOException {
        List<Asistencia> lista = asistenciaService.listarTodo();
        ByteArrayInputStream in = reporteService.generarExcel(lista);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=asistencias.xlsx");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("application/vnd.ms-excel"))
                .body(new InputStreamResource(in));
    }

    @GetMapping("/admin/exportar/pdf")
    public ResponseEntity<InputStreamResource> descargarPDF() {
        List<Asistencia> lista = asistenciaService.listarTodo();
        ByteArrayInputStream in = reporteService.generarPDF(lista);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=asistencias.pdf");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.APPLICATION_PDF)
                .body(new InputStreamResource(in));
    }
}