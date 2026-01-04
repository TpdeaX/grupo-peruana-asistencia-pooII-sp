package com.grupoperuana.sistema.controllers;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.grupoperuana.sistema.beans.Empleado;

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

    @PostMapping("/filter")
    public String filtrar(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(required = false) String rol,
            @RequestParam(required = false) String modalidad,
            @RequestParam(required = false) Integer sucursalId,
            HttpSession session) {

        session.setAttribute("emp_page", page);
        session.setAttribute("emp_size", size);
        session.setAttribute("emp_keyword", keyword);
        session.setAttribute("emp_rol", rol);
        session.setAttribute("emp_modalidad", modalidad);
        session.setAttribute("emp_sucursalId", sucursalId);

        return "redirect:/empleados";
    }

    @GetMapping
    public String manejarVistas(@RequestParam(value = "accion", defaultValue = "listar") String accion,
            @RequestParam(value = "id", required = false) Integer id,
            // Legacy/Direct params support (optional, can be saved to session if present)
            @RequestParam(value = "keyword", required = false) String keywordParam,
            @RequestParam(value = "rol", required = false) String rolParam,
            @RequestParam(value = "modalidad", required = false) String modalidadParam,
            @RequestParam(value = "sucursalId", required = false) Integer sucursalIdParam,
            Model model, HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        switch (accion) {
            case "dashboard":
                return "redirect:/dashboard";

            case "nuevo":
            case "editar":
            default:
                // 1. Recover from Session
                Integer pageObj = (Integer) session.getAttribute("emp_page");
                int page = (pageObj != null) ? pageObj : 0;

                Integer sizeObj = (Integer) session.getAttribute("emp_size");
                int size = (sizeObj != null) ? sizeObj : 10;
                if (size < 1)
                    size = 10;
                if (size > 100)
                    size = 100;

                // If distinct params provided in URL (e.g. bookmarks), override session
                // But generally we prefer session. Logic: If URL param exists, use & save it.
                // For simplicity and strict PRG compliance requested, we mostly rely on session
                // unless it's the first load.

                String keyword = (String) session.getAttribute("emp_keyword");
                if (keyword == null)
                    keyword = "";

                String rol = (String) session.getAttribute("emp_rol");
                String modalidad = (String) session.getAttribute("emp_modalidad");
                Integer sucursalId = (Integer) session.getAttribute("emp_sucursalId");

                // 2. Call Service
                Page<Empleado> pageRes = empleadoService.listarAvanzado(keyword, rol, modalidad, sucursalId, page,
                        size);

                model.addAttribute("listaEmpleados", pageRes.getContent());
                model.addAttribute("pagina", pageRes);

                // 3. Pass back to View
                model.addAttribute("keyword", keyword);
                model.addAttribute("rol", rol);
                model.addAttribute("modalidad", modalidad);
                model.addAttribute("sucursalId", sucursalId);
                model.addAttribute("size", size);

                model.addAttribute("listaSucursales", sucursalService.listarTodas());
                model.addAttribute("listaTodosPermisos", permisoRepository.findAll());

                if (!model.containsAttribute("empleado")) {
                    model.addAttribute("empleado", new Empleado());
                }

                return "views/admin/gestion_empleados";
        }
    }

    @GetMapping("/export/excel")
    public ResponseEntity<byte[]> exportarExcel(HttpSession session) {

        if (!checkSession(session))
            return ResponseEntity.status(401).build();

        String keyword = (String) session.getAttribute("emp_keyword");
        if (keyword == null)
            keyword = "";
        String rol = (String) session.getAttribute("emp_rol");
        String modalidad = (String) session.getAttribute("emp_modalidad");
        Integer sucursalId = (Integer) session.getAttribute("emp_sucursalId");

        List<Empleado> list = empleadoService.listarAvanzadoSinPaginacion(keyword, rol, modalidad, sucursalId);

        try {
            byte[] bytes = exportService.generateEmpleadosExcel(list);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=empleados.xlsx")
                    .contentType(MediaType
                            .parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/export/pdf")
    public ResponseEntity<byte[]> exportarPdf(HttpSession session) {

        if (!checkSession(session))
            return ResponseEntity.status(401).build();

        String keyword = (String) session.getAttribute("emp_keyword");
        if (keyword == null)
            keyword = "";
        String rol = (String) session.getAttribute("emp_rol");
        String modalidad = (String) session.getAttribute("emp_modalidad");
        Integer sucursalId = (Integer) session.getAttribute("emp_sucursalId");

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
            @RequestParam(value = "permisosSeleccionados", required = false) List<String> permisosSeleccionados,
            RedirectAttributes flash,
            HttpSession session,
            Model model) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        // --- LOGICA DE ELIMINAR ---
        if ("eliminar".equals(accion)) {
            if (id != null)
                empleadoService.eliminarEmpleado(id);
            return "redirect:/empleados?status=deleted";
        }

        // --- LOGICA DE GUARDAR / ACTUALIZAR ---
        if ("guardar".equals(accion)) {

            if (result.hasErrors()) {

                flash.addFlashAttribute("error", "Verifica los campos obligatorios.");
                flash.addFlashAttribute("org.springframework.validation.BindingResult.empleado", result);
                flash.addFlashAttribute("empleado", empleado);
                flash.addFlashAttribute("abrirModal", true);
                // Preserve permissions selection if needed, although they might need special
                // handling in JSP if passed as list vs string
                return "redirect:/empleados";
            }

            int resultado;
            boolean isNew = empleado.getId() == 0;

            if (permisosSeleccionados == null) {
                permisosSeleccionados = new ArrayList<>();
            }

            try {
                if (!isNew) {
                    resultado = empleadoService.actualizarEmpleado(empleado, permisosSeleccionados);
                } else {
                    resultado = empleadoService.registrarEmpleado(empleado, permisosSeleccionados);
                }

                if (resultado > 0) {
                    return isNew ? "redirect:/empleados?status=created" : "redirect:/empleados?status=updated";
                } else {
                    flash.addFlashAttribute("error", "Error al guardar en base de datos (Posible duplicado)");
                    flash.addFlashAttribute("empleado", empleado);
                    flash.addFlashAttribute("abrirModal", true);
                    return "redirect:/empleados";
                }
            } catch (Exception e) {
                flash.addFlashAttribute("error", "Error inesperado: " + e.getMessage());
                flash.addFlashAttribute("empleado", empleado);
                flash.addFlashAttribute("abrirModal", true);
                return "redirect:/empleados";
            }
        }

        // --- LOGICA CAMBIAR PASSWORD ---
        else if ("cambiarPassword".equals(accion)) {
            if (id != null && empleado.getPassword() != null && !empleado.getPassword().trim().isEmpty()) {
                int res = empleadoService.actualizarPassword(id, empleado.getPassword());
                if (res > 0)
                    return "redirect:/empleados?status=password_updated";
            }
            flash.addFlashAttribute("error", "La contraseña no puede estar vacía");
            return "redirect:/empleados";
        }

        return "redirect:/empleados";
    }
}