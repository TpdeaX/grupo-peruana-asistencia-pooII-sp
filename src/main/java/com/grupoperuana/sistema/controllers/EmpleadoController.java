package com.grupoperuana.sistema.controllers;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.services.EmpleadoService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/empleados")
public class EmpleadoController {

    private final EmpleadoService empleadoService;

    public EmpleadoController(EmpleadoService empleadoService) {
        this.empleadoService = empleadoService;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @GetMapping
    public String listar(@RequestParam(value = "accion", required = false, defaultValue = "listar") String accion,
            @RequestParam(value = "id", required = false) Integer id,
            Model model, HttpSession session) {

        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        switch (accion) {
            case "listar":
                List<Empleado> lista = empleadoService.listarEmpleados();
                model.addAttribute("listaEmpleados", lista);
                return "views/admin/gestion_empleados"; // View resolver will add .jsp

            case "nuevo":
                return "views/admin/formulario_empleado";

            case "editar":
                if (id != null) {
                    Empleado emp = empleadoService.obtenerPorId(id);
                    model.addAttribute("empleado", emp);
                    return "views/admin/formulario_empleado";
                }
                return "redirect:/empleados";

            default:
                return "redirect:/empleados";
        }
    }

    @PostMapping
    public String guardar(@RequestParam("accion") String accion,
            @RequestParam(value = "id", required = false) Integer id,
            @RequestParam(value = "nombres", required = false) String nombres,
            @RequestParam(value = "apellidos", required = false) String apellidos,
            @RequestParam(value = "dni", required = false) String dni,
            @RequestParam(value = "rol", required = false) String rol,
            @RequestParam(value = "password", required = false) String password,
            Model model, HttpSession session) {

        if (!checkSession(session)) {
            return "redirect:/index.jsp";
        }

        if ("guardar".equals(accion)) {
            Empleado e = new Empleado();
            e.setNombres(nombres);
            e.setApellidos(apellidos);
            e.setDni(dni);
            e.setRol(rol);

            int resultado = 0;

            if (id != null) {
                e.setId(id);
                resultado = empleadoService.actualizarEmpleado(e);
            } else {
                e.setPassword(password);
                resultado = empleadoService.registrarEmpleado(e);
            }

            if (resultado > 0) {
                return "redirect:/empleados?accion=listar&status=success";
            } else {
                model.addAttribute("error", "Error al guardar en base de datos.");
                return "views/admin/formulario_empleado";
            }
        } else if ("eliminar".equals(accion)) {
            if (id != null) {
                empleadoService.eliminarEmpleado(id);
            }
            return "redirect:/empleados?accion=listar&status=deleted";
        }

        return "redirect:/empleados";
    }
}