package com.grupoperuana.sistema.controllers;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.beans.Horario;
import com.grupoperuana.sistema.services.EmpleadoService;
import com.grupoperuana.sistema.services.HorarioService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/horarios")
public class HorarioController {

    private final HorarioService horarioService;
    private final EmpleadoService empleadoService;

    public HorarioController(HorarioService horarioService, EmpleadoService empleadoService) {
        this.horarioService = horarioService;
        this.empleadoService = empleadoService;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    private boolean isAdmin(HttpSession session) {
        Empleado usuario = (Empleado) session.getAttribute("usuario");
        return usuario != null && "ADMIN".equals(usuario.getRol());
    }

    @GetMapping
    public String listar(@RequestParam(value = "fecha", required = false) String fechaStr,
            Model model, HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        LocalDate fecha = (fechaStr != null && !fechaStr.isEmpty()) ? LocalDate.parse(fechaStr) : LocalDate.now();

        List<Horario> horarios = horarioService.listarPorFecha(fecha);
        List<Empleado> empleados = empleadoService.listarEmpleados();

        model.addAttribute("horarios", horarios);
        model.addAttribute("empleados", empleados);
        model.addAttribute("fechaSeleccionada", fecha);

        model.addAttribute("isAdmin", isAdmin(session));

        return "views/admin/gestion_horarios";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/horarios";

        model.addAttribute("empleados", empleadoService.listarEmpleados());
        return "views/admin/formulario_horario";
    }

    @GetMapping("/editar")
    public String editar(@RequestParam("id") int id, Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/horarios";

        Horario horario = horarioService.obtenerPorId(id);
        if (horario != null) {
            model.addAttribute("horario", horario);
            model.addAttribute("empleados", empleadoService.listarEmpleados());
            return "views/admin/formulario_horario";
        }
        return "redirect:/horarios";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(value = "id", required = false) Integer id,
            @RequestParam("empleadoId") int empleadoId,
            @RequestParam("fecha") String fechaStr,
            @RequestParam("horaInicio") String horaInicioStr,
            @RequestParam("horaFin") String horaFinStr,
            @RequestParam("tipoTurno") String tipoTurno,
            Model model, HttpSession session) {

        if (!isAdmin(session))
            return "redirect:/horarios";

        try {
            Horario h = (id != null) ? horarioService.obtenerPorId(id) : new Horario();
            if (h == null)
                h = new Horario();

            Empleado e = empleadoService.obtenerPorId(empleadoId);
            h.setEmpleado(e);
            h.setFecha(LocalDate.parse(fechaStr));
            h.setHoraInicio(LocalTime.parse(horaInicioStr));
            h.setHoraFin(LocalTime.parse(horaFinStr));
            h.setTipoTurno(tipoTurno);

            horarioService.guardar(h);
            return "redirect:/horarios?fecha=" + fechaStr;
        } catch (Exception e) {
            model.addAttribute("error", "Error al guardar: " + e.getMessage());
            model.addAttribute("empleados", empleadoService.listarEmpleados());
            return "views/admin/formulario_horario";
        }
    }

    @PostMapping("/eliminar")
    public String eliminar(@RequestParam("id") int id, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/horarios";

        Horario h = horarioService.obtenerPorId(id);
        String fecha = (h != null) ? h.getFecha().toString() : "";

        horarioService.eliminar(id);
        return "redirect:/horarios?fecha=" + fecha;
    }
}
