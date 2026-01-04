package com.grupoperuana.sistema.controllers;

import com.grupoperuana.sistema.beans.Sucursal;
import com.grupoperuana.sistema.services.SucursalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/sucursales")
public class SucursalController {

    @Autowired
    private SucursalService sucursalService;

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @PostMapping("/filter")
    public String filtrar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(required = false) String keyword,
            HttpSession session) {

        session.setAttribute("suc_page", page);
        session.setAttribute("suc_size", size);
        session.setAttribute("suc_keyword", keyword);
        return "redirect:/sucursales";
    }

    @GetMapping
    public String listar(@RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String keywordParam,
            Model model, HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        // Recover from session
        Integer sessionPage = (Integer) session.getAttribute("suc_page");
        int p = (sessionPage != null) ? sessionPage : 0;

        Integer sessionSize = (Integer) session.getAttribute("suc_size");
        int s = (sessionSize != null) ? sessionSize : 5;
        if (s < 1)
            s = 5;
        if (s > 100)
            s = 100;

        String k = (String) session.getAttribute("suc_keyword");
        if (k == null)
            k = "";

        Pageable pageable = PageRequest.of(p, s, Sort.by("id").descending());
        Page<Sucursal> pagina = sucursalService.listarPagina(k, pageable);

        model.addAttribute("sucursales", pagina.getContent());
        model.addAttribute("pagina", pagina);
        model.addAttribute("keyword", k);
        model.addAttribute("size", s);

        return "views/sucursales/lista";
    }

    @GetMapping("/nuevo")
    public String formularioNuevo(Model model) {
        model.addAttribute("sucursal", new Sucursal());
        model.addAttribute("titulo", "Nueva Sucursal");
        return "views/sucursales/formulario";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Sucursal sucursal) {
        boolean isNew = sucursal.getId() == 0; // Assuming 0 is default for new
        sucursalService.guardar(sucursal);
        return "redirect:/sucursales?status=" + (isNew ? "created" : "updated");
    }

    @GetMapping("/eliminar/{id}")
    public String eliminar(@PathVariable int id) {
        sucursalService.eliminar(id);
        return "redirect:/sucursales?status=deleted";
    }

    @PostMapping("/eliminar")
    public String eliminarPost(@RequestParam("id") int id) {
        sucursalService.eliminar(id);
        return "redirect:/sucursales?status=deleted";
    }
}
