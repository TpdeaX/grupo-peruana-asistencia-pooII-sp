package com.grupoperuana.sistema.controllers;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.HashMap;
import java.util.ArrayList;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.beans.Horario;
import com.grupoperuana.sistema.beans.TipoTurno;
import com.grupoperuana.sistema.services.EmpleadoService;
import com.grupoperuana.sistema.services.HorarioService;
import com.grupoperuana.sistema.services.TipoTurnoService;
import com.grupoperuana.sistema.services.PlantillaHorarioService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/horarios")
public class HorarioController {

    private final HorarioService horarioService;
    private final EmpleadoService empleadoService;
    private final TipoTurnoService tipoTurnoService;
    private final PlantillaHorarioService plantillaService;

    public HorarioController(HorarioService horarioService, EmpleadoService empleadoService,
            TipoTurnoService tipoTurnoService, PlantillaHorarioService plantillaService) {
        this.horarioService = horarioService;
        this.empleadoService = empleadoService;
        this.tipoTurnoService = tipoTurnoService;
        this.plantillaService = plantillaService;
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
        List<TipoTurno> tiposTurno = tipoTurnoService.listarTipos();

        Map<String, String> turnoColors = tiposTurno.stream()
                .collect(Collectors.toMap(TipoTurno::getNombre, TipoTurno::getColor));

        model.addAttribute("horarios", horarios);
        model.addAttribute("empleados", empleados);
        model.addAttribute("fechaSeleccionada", fecha);
        model.addAttribute("turnoColors", turnoColors); // Pass colors to view

        model.addAttribute("isAdmin", isAdmin(session));

        return "views/admin/gestion_horarios";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model, HttpSession session) {
        if (!isAdmin(session))
            return "redirect:/horarios";

        model.addAttribute("empleados", empleadoService.listarEmpleados());
        model.addAttribute("tiposTurno", tipoTurnoService.listarTipos()); // From DB
        model.addAttribute("plantillas", plantillaService.listarTodos());
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
            model.addAttribute("tiposTurno", tipoTurnoService.listarTipos()); // From DB
            model.addAttribute("plantillas", plantillaService.listarTodos());
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
            model.addAttribute("tiposTurno", tipoTurnoService.listarTipos()); // Also here on error
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

    @GetMapping("/api/list")
    @ResponseBody
    public List<Map<String, Object>> listarApi(@RequestParam(value = "fecha", required = false) String fechaStr) {
        LocalDate fecha = (fechaStr != null && !fechaStr.isEmpty()) ? LocalDate.parse(fechaStr) : LocalDate.now();
        List<Horario> horarios = horarioService.listarPorFecha(fecha);
        List<TipoTurno> tiposTurno = tipoTurnoService.listarTipos();
        Map<String, String> turnoColors = tiposTurno.stream()
                .collect(Collectors.toMap(TipoTurno::getNombre, TipoTurno::getColor));

        return horarios.stream().map(h -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", h.getId());
            map.put("empleadoId", h.getEmpleado().getId());
            map.put("empleadoNombre", h.getEmpleado().getNombres()); // Assuming Nombres is sufficient for display
            map.put("fecha", h.getFecha().toString());
            map.put("horaInicio", h.getHoraInicio().toString());
            map.put("horaFin", h.getHoraFin().toString());
            map.put("tipoTurno", h.getTipoTurno());
            map.put("color", turnoColors.getOrDefault(h.getTipoTurno(), "#cccccc"));
            return map;
        }).collect(Collectors.toList());
    }

    @PostMapping("/api/guardar")
    @ResponseBody
    public ResponseEntity<?> guardarApi(@RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("id");
            Integer id = null;
            if (idObj != null && !idObj.toString().isEmpty()) {
                try {
                    id = Integer.parseInt(idObj.toString());
                } catch (NumberFormatException e) {
                    // ignore, implies new record
                }
            }

            int empleadoId = Integer.parseInt(payload.get("empleadoId").toString());
            String fechaStr = (String) payload.get("fecha");
            String horaInicioStr = (String) payload.get("horaInicio");
            String horaFinStr = (String) payload.get("horaFin");
            String tipoTurno = (String) payload.get("tipoTurno");

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

            // Return the saved object structure
            Map<String, Object> response = new HashMap<>();
            response.put("status", "ok");
            response.put("id", h.getId());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/api/eliminar")
    @ResponseBody
    public ResponseEntity<?> eliminarApi(@RequestBody Map<String, Object> payload) {
        try {
            Integer id = Integer.parseInt(payload.get("id").toString());
            horarioService.eliminar(id);
            return ResponseEntity.ok(Map.of("status", "ok"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
}
