package com.grupoperuana.sistema.controllers;

import com.grupoperuana.sistema.beans.Feriado;
import com.grupoperuana.sistema.services.FeriadoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/feriados")
public class FeriadoController {

    @Autowired
    private FeriadoService feriadoService;

    @GetMapping
    public String listar(Model model,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "") String keyword) {

        if (size < 1)
            size = 10;
        if (size > 100)
            size = 100;

        Page<Feriado> pageRes = feriadoService.listar(keyword, page, size);

        model.addAttribute("feriados", pageRes.getContent());
        model.addAttribute("pagina", pageRes);
        model.addAttribute("keyword", keyword);
        model.addAttribute("size", size);
        return "views/feriados/lista";
    }

    @GetMapping("/nuevo")
    public String formularioNuevo(Model model) {
        model.addAttribute("feriado", new Feriado());
        model.addAttribute("titulo", "Nuevo Feriado");
        return "views/feriados/formulario";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute Feriado feriado, RedirectAttributes flash) {
        feriadoService.guardar(feriado);
        flash.addFlashAttribute("mensaje", "Feriado guardado correctamente.");
        flash.addFlashAttribute("tipoMensaje", "success");
        return "redirect:/feriados";
    }

    @GetMapping("/editar/{id}")
    public String formularioEditar(@PathVariable int id, Model model, RedirectAttributes flash) {
        try {
            Feriado feriado = feriadoService.obtenerPorId(id)
                    .orElseThrow(() -> new IllegalArgumentException("Feriado inválido Id:" + id));
            model.addAttribute("feriado", feriado);
            model.addAttribute("titulo", "Editar Feriado");
            return "views/feriados/formulario";
        } catch (Exception e) {
            flash.addFlashAttribute("mensaje", "Feriado no encontrado.");
            flash.addFlashAttribute("tipoMensaje", "error");
            return "redirect:/feriados";
        }
    }

    @PostMapping("/eliminar")
    public String eliminar(@RequestParam int id, RedirectAttributes flash) {
        try {
            feriadoService.eliminar(id);
            flash.addFlashAttribute("mensaje", "Feriado eliminado correctamente.");
            flash.addFlashAttribute("tipoMensaje", "success");
        } catch (Exception e) {
            flash.addFlashAttribute("mensaje", "Error al eliminar feriado.");
            flash.addFlashAttribute("tipoMensaje", "error");
        }
        return "redirect:/feriados";
    }
}
