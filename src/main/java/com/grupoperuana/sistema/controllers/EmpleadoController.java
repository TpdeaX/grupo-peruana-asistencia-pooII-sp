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
import com.grupoperuana.sistema.services.SucursalService;
import com.grupoperuana.sistema.services.ExportService;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/empleados")
public class EmpleadoController {

    private final EmpleadoService empleadoService;
    private final SucursalService sucursalService;
    private final ExportService exportService;

    public EmpleadoController(EmpleadoService empleadoService, SucursalService sucursalService,
            ExportService exportService) {
        this.empleadoService = empleadoService;
        this.sucursalService = sucursalService;
        this.exportService = exportService;
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
                return "views/admin/formulario_empleado";

            case "editar":
                if (id != null) {
                    Empleado emp = empleadoService.obtenerPorId(id);
                    model.addAttribute("empleado", emp);
                    model.addAttribute("listaSucursales", sucursalService.listarTodas());
                    return "views/admin/formulario_empleado";
                }
                return "redirect:/empleados";

            default:
                if (size < 1)
                    size = 10;
                if (size > 100)
                    size = 100;

                Page<Empleado> pageRes = empleadoService.listarAvanzado(keyword, rol, modalidad, sucursalId, page,
                        size);

                model.addAttribute("listaEmpleados", pageRes.getContent());
                model.addAttribute("pagina", pageRes);
                model.addAttribute("keyword", keyword);
                model.addAttribute("rol", rol);
                model.addAttribute("modalidad", modalidad);
                model.addAttribute("sucursalId", sucursalId);
                model.addAttribute("size", size);

                model.addAttribute("listaSucursales", sucursalService.listarTodas()); // For filters too?
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
                    .contentType(MediaType
                            .parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
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
    public String procesarAccion(@RequestParam("accion") String accion,
            Empleado empleado,
            @RequestParam(value = "id", required = false) Integer id,
            RedirectAttributes flash, HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        if ("guardar".equals(accion)) {
            int resultado;
            boolean isNew = empleado.getId() == 0;

            if (!isNew) {
                resultado = empleadoService.actualizarEmpleado(empleado);
            } else {
                resultado = empleadoService.registrarEmpleado(empleado);
            }

            if (resultado > 0) {
                return isNew ? "redirect:/empleados?status=created" : "redirect:/empleados?status=updated";
            } else {
                flash.addFlashAttribute("error", "Error al guardar");
                return "redirect:/empleados?accion=nuevo";
            }
        } else if ("eliminar".equals(accion)) {
            if (id != null)
                empleadoService.eliminarEmpleado(id);
            return "redirect:/empleados?status=deleted";
        } else if ("cambiarPassword".equals(accion)) {
            if (id != null && empleado.getPassword() != null && !empleado.getPassword().trim().isEmpty()) {
                int result = empleadoService.actualizarPassword(id, empleado.getPassword());
                if (result > 0) {
                    return "redirect:/empleados?status=password_updated";
                }
            }
            flash.addFlashAttribute("error", "Error al cambiar contraseña");
            return "redirect:/empleados";
        }

        return "redirect:/empleados";
    }
}