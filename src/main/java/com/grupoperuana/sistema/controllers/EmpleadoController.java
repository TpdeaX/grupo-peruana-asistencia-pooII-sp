package com.grupoperuana.sistema.controllers;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.beans.Permiso;
import com.grupoperuana.sistema.services.EmpleadoService;
import com.grupoperuana.sistema.services.SucursalService;
import com.grupoperuana.sistema.services.ExportService;
import com.grupoperuana.sistema.repositories.PermisoRepository; 

import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.ModelAttribute;

@Controller
@RequestMapping("/empleados")
public class EmpleadoController {

    private final EmpleadoService empleadoService;
    private final SucursalService sucursalService;
    private final ExportService exportService;
    
    // Mantenemos el repositorio solo para listar los permisos disponibles en el HTML
    private final PermisoRepository permisoRepository; 

    public EmpleadoController(EmpleadoService empleadoService, 
                              SucursalService sucursalService,
                              ExportService exportService,
                              PermisoRepository permisoRepository) {
        this.empleadoService = empleadoService;
        this.sucursalService = sucursalService;
        this.exportService = exportService;
        this.permisoRepository = permisoRepository;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @GetMapping
    public String manejarVistas(@RequestParam(value = "accion", defaultValue = "listar") String accion,
            @RequestParam(value = "id", required = false) Integer id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) String rol,
            @RequestParam(required = false) String modalidad,
            @RequestParam(required = false) Integer sucursalId,
            Model model, HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        switch (accion) {
            case "nuevo":
                model.addAttribute("empleado", new Empleado());
                model.addAttribute("listaSucursales", sucursalService.listarTodas());
                // Pasamos todos los permisos disponibles a la vista
                model.addAttribute("listaTodosPermisos", permisoRepository.findAll());
                return "views/admin/formulario_empleado"; // Asegúrate que esta ruta sea correcta o usa el modal del index

            case "editar": // NOTA: Si usas Modales en la misma página, este case quizás no se use, pero lo dejo por si acaso
                if (id != null) {
                    Empleado emp = empleadoService.obtenerPorId(id);
                    model.addAttribute("empleado", emp);
                    model.addAttribute("listaSucursales", sucursalService.listarTodas());
                    model.addAttribute("listaTodosPermisos", permisoRepository.findAll());
                    
                    // Extraemos los nombres de los permisos que ya tiene el empleado para marcarlos en la vista
                    List<String> permisosNombres = emp.getPermisos().stream()
                                                      .map(Permiso::getNombre)
                                                      .collect(Collectors.toList());
                    model.addAttribute("permisosActuales", permisosNombres);
                    
                    return "views/admin/formulario_empleado";
                }
                return "redirect:/empleados";
                
            case "dashboard":
                model.addAttribute("totalEmpleados",
                        empleadoService.listarAvanzadoSinPaginacion("", null, null, null).size());
                model.addAttribute("inasistenciasHoy", 3);
                model.addAttribute("justificacionesHoy", 5);
                model.addAttribute("tardanzasHoy", 7);
                return "views/admin/dashboard";

            default:
                if (size < 1) size = 10;
                if (size > 100) size = 100;

                Page<Empleado> pageRes = empleadoService.listarAvanzado(keyword, rol, modalidad, sucursalId, page, size);

                model.addAttribute("listaEmpleados", pageRes.getContent());
                model.addAttribute("pagina", pageRes);
                model.addAttribute("keyword", keyword);
                model.addAttribute("rol", rol);
                model.addAttribute("modalidad", modalidad);
                model.addAttribute("sucursalId", sucursalId);
                model.addAttribute("size", size);

                model.addAttribute("listaSucursales", sucursalService.listarTodas());
                // Para el modal de nuevo empleado en la misma vista:
                model.addAttribute("listaTodosPermisos", permisoRepository.findAll()); 
                model.addAttribute("empleado", new Empleado());
                
                return "views/admin/gestion_empleados";
        }
    }

    @GetMapping("/export/excel")
    public ResponseEntity<byte[]> exportarExcel(HttpSession session,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) String rol,
            @RequestParam(required = false) String modalidad,
            @RequestParam(required = false) Integer sucursalId) {

        if (!checkSession(session))
            return ResponseEntity.status(401).build();

        List<Empleado> list = empleadoService.listarAvanzadoSinPaginacion(keyword, rol, modalidad, sucursalId);

        try {
            byte[] bytes = exportService.generateEmpleadosExcel(list);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=empleados.xlsx")
                    .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/export/pdf")
    public ResponseEntity<byte[]> exportarPdf(HttpSession session,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) String rol,
            @RequestParam(required = false) String modalidad,
            @RequestParam(required = false) Integer sucursalId) {

        if (!checkSession(session))
            return ResponseEntity.status(401).build();

        List<Empleado> list = empleadoService.listarAvanzadoSinPaginacion(keyword, rol, modalidad, sucursalId);

        try {
            byte[] bytes = exportService.generateEmpleadosPdf(list);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=empleados.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping
    public String procesarAccion(
            @RequestParam("accion") String accion,
            @Valid @ModelAttribute Empleado empleado,
            BindingResult result,
            @RequestParam(value = "id", required = false) Integer id,
            
            // CORRECCIÓN CRÍTICA: Recibimos List<String> porque el HTML envía valores como "VER_REPORTES"
            // El name en el HTML es "permisos", así que lo mapeamos aquí.
            @RequestParam(value = "permisos", required = false) List<String> permisosSeleccionados, 
            
            RedirectAttributes flash, 
            HttpSession session,
            Model model) {

        if (!checkSession(session)) return "redirect:/index.jsp";

        // --- LOGICA DE ELIMINAR ---
        if ("eliminar".equals(accion)) {
            if (id != null) empleadoService.eliminarEmpleado(id);
            return "redirect:/empleados?status=deleted";
        }

        // --- LOGICA DE GUARDAR / ACTUALIZAR ---
        if ("guardar".equals(accion)) {
            
            if (result.hasErrors()) {
                flash.addFlashAttribute("error", "Verifica los campos obligatorios. Selecciona una sucursal válida.");
                return (empleado.getId() > 0) ? "redirect:/empleados?accion=editar&id=" + empleado.getId() 
                                              : "redirect:/empleados?accion=nuevo";
            }

            int resultado;
            boolean isNew = empleado.getId() == 0;
            
            // Nos aseguramos que la lista no sea null para evitar errores en el servicio
            if (permisosSeleccionados == null) {
                permisosSeleccionados = new ArrayList<>();
            }

            // AQUÍ LLAMAMOS A LOS MÉTODOS CORREGIDOS DEL SERVICE
            // Pasamos el empleado Y la lista de strings de permisos
            if (!isNew) {
                resultado = empleadoService.actualizarEmpleado(empleado, permisosSeleccionados);
            } else {
                resultado = empleadoService.registrarEmpleado(empleado, permisosSeleccionados);
            }

            if (resultado > 0) {
                // NOTA: Ya no llamamos a empleadoPermisoService.actualizarPermisosEmpleado
                // porque JPA ya lo hizo automáticamente dentro del servicio de arriba.
                
                return isNew ? "redirect:/empleados?status=created" : "redirect:/empleados?status=updated";
            } else {
                flash.addFlashAttribute("error", "Error al guardar en base de datos");
                return "redirect:/empleados?accion=nuevo";
            }
        } 
        
        // --- LOGICA CAMBIAR PASSWORD ---
        else if ("cambiarPassword".equals(accion)) {
            if (id != null && empleado.getPassword() != null && !empleado.getPassword().trim().isEmpty()) {
                int res = empleadoService.actualizarPassword(id, empleado.getPassword());
                if (res > 0) return "redirect:/empleados?status=password_updated";
            }
            flash.addFlashAttribute("error", "La contraseña no puede estar vacía");
            return "redirect:/empleados";
        }

        return "redirect:/empleados";
    }
}