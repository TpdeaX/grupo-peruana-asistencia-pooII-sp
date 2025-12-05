package com.grupoperuana.sistema.controllers;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.grupoperuana.sistema.beans.Asistencia;
import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.dto.TurnoDTO;
import com.grupoperuana.sistema.services.AsistenciaService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
public class AsistenciaController {

    private final AsistenciaService asistenciaService;

    public AsistenciaController(AsistenciaService asistenciaService) {
        this.asistenciaService = asistenciaService;
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
                // Dashboard del empleado: Mostrar reporte diario con todos los turnos
                List<TurnoDTO> reporteDiario = asistenciaService.obtenerReporteDiario(usuario.getId());
                model.addAttribute("reporteDiario", reporteDiario);
                return "views/empleado/dashboard";
            }
        }
    }

    @PostMapping("/asistencias/marcar")
    public String marcar(@RequestParam("accion") String accion,
            @RequestParam("modo") String modo,
            @RequestParam("latitud") double lat,
            @RequestParam("longitud") double lon,
            @RequestParam(value = "observacion", required = false) String observacion,
            HttpSession session) {

        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        if ("marcar".equals(accion)) {
            try {
                Empleado usuario = (Empleado) session.getAttribute("usuario");
                String resultado = asistenciaService.marcarAsistencia(usuario.getId(), modo, lat, lon, observacion);

                if ("ERROR".equals(resultado)) {
                    session.setAttribute("mensaje", "Error al procesar la marca.");
                    session.setAttribute("tipoMensaje", "error");
                } else {
                    session.setAttribute("mensaje", "¡Marca de " + resultado + " registrada!");
                    session.setAttribute("tipoMensaje", "success");
                }
            } catch (Exception e) {
                session.setAttribute("mensaje", "Error: " + e.getMessage());
                session.setAttribute("tipoMensaje", "error");
            }
        }
        return "redirect:/empleado";
    }
}