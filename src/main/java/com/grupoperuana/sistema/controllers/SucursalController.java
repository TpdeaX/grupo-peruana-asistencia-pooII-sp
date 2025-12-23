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

@Controller
@RequestMapping("/sucursales")
public class SucursalController {

    @Autowired
    private SucursalService sucursalService;

    @GetMapping
    public String listar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(required = false) String keyword,
            Model model) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("id").descending());
        Page<Sucursal> pagina = sucursalService.listarPagina(keyword, pageable);

        model.addAttribute("sucursales", pagina.getContent());
        model.addAttribute("pagina", pagina);
        model.addAttribute("keyword", keyword);
        model.addAttribute("size", size);

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
