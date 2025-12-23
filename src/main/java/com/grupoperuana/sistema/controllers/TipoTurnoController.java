package com.grupoperuana.sistema.controllers;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.grupoperuana.sistema.beans.TipoTurno;
import com.grupoperuana.sistema.services.TipoTurnoService;

@Controller
@RequestMapping("/tipoturno")
public class TipoTurnoController {

    private final TipoTurnoService tipoTurnoService;

    public TipoTurnoController(TipoTurnoService tipoTurnoService) {
        this.tipoTurnoService = tipoTurnoService;
    }

    @GetMapping
    public String listar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(required = false) String keyword,
            Model model) {
        Pageable pageable = PageRequest.of(page, size);
        Page<TipoTurno> pagina = tipoTurnoService.listarTipos(pageable, keyword);

        model.addAttribute("lista", pagina.getContent());
        model.addAttribute("pagina", pagina);
        model.addAttribute("keyword", keyword);
        model.addAttribute("size", size);
        model.addAttribute("tipos", pagina.getContent()); // Keep compatibility if needed, but lista is better
        return "views/admin/gestion_tipoturno";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute TipoTurno tipoTurno, RedirectAttributes redirectAttributes) {
        tipoTurnoService.guardarTipo(tipoTurno);
        redirectAttributes.addFlashAttribute("mensaje", "Tipo de turno guardado correctamente.");
        redirectAttributes.addFlashAttribute("tipoMensaje", "success");
        return "redirect:/tipoturno";
    }

    @PostMapping("/eliminar")
    public String eliminar(@RequestParam("id") int id, RedirectAttributes redirectAttributes) {
        tipoTurnoService.eliminarTipo(id);
        redirectAttributes.addFlashAttribute("mensaje", "Tipo de turno eliminado correctamente.");
        redirectAttributes.addFlashAttribute("tipoMensaje", "success");
        return "redirect:/tipoturno";
    }
}
