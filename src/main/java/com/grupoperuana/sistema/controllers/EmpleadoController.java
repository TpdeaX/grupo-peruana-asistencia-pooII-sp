package com.grupoperuana.sistema.controllers;

import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes; 

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
    public String manejarVistas(@RequestParam(value = "accion", defaultValue = "listar") String accion,
                                @RequestParam(value = "id", required = false) Integer id,
                                Model model, HttpSession session) {

        if (!checkSession(session)) return "redirect:/index.jsp";

        switch (accion) {
            case "nuevo":
                model.addAttribute("empleado", new Empleado()); // Objeto vacío para el form
                return "views/admin/formulario_empleado";
                
            case "editar":
                if (id != null) {
                    Empleado emp = empleadoService.obtenerPorId(id);
                    model.addAttribute("empleado", emp);
                    return "views/admin/formulario_empleado";
                }
                return "redirect:/empleados"; 
                
            default: 
                List<Empleado> lista = empleadoService.listarEmpleados();
                model.addAttribute("listaEmpleados", lista);
                return "views/admin/gestion_empleados";
        }
    }

  
    @PostMapping
    public String procesarAccion(@RequestParam("accion") String accion,
                                 Empleado empleado, 
                                 @RequestParam(value = "id", required = false) Integer id,
                                 RedirectAttributes flash, HttpSession session) {

        if (!checkSession(session)) return "redirect:/index.jsp";

        if ("guardar".equals(accion)) {
            int resultado;
            if (empleado.getId() != 0 && empleado.getId() > 0) {
                resultado = empleadoService.actualizarEmpleado(empleado);
            } else {
                resultado = empleadoService.registrarEmpleado(empleado);
            }

            if (resultado > 0) {
           
                return "redirect:/empleados?status=success"; 
            } else {
                flash.addFlashAttribute("error", "Error al guardar");
                return "redirect:/empleados?accion=nuevo";
            }
        } 
        else if ("eliminar".equals(accion)) {
            if (id != null) empleadoService.eliminarEmpleado(id);
            return "redirect:/empleados?status=deleted";
        }

        return "redirect:/empleados";
    }
}