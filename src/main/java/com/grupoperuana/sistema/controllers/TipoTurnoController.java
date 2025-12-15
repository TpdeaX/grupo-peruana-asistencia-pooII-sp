package com.grupoperuana.sistema.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
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
    public String listar(Model model) {
        model.addAttribute("tipos", tipoTurnoService.listarTipos());
        return "views/admin/gestion_tipoturno";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        model.addAttribute("tipoTurno", new TipoTurno());
        return "views/admin/formulario_tipoturno";
    }

    @GetMapping("/editar")
    public String editar(@RequestParam("id") int id, Model model) {
        TipoTurno tipo = tipoTurnoService.obtenerPorId(id);
        if (tipo == null) {
            return "redirect:/tipoturno";
        }
        model.addAttribute("tipoTurno", tipo);
        return "views/admin/formulario_tipoturno";
    }

    @PostMapping("/guardar")
    public String guardar(@ModelAttribute TipoTurno tipoTurno) {
        tipoTurnoService.guardarTipo(tipoTurno);
        return "redirect:/tipoturno";
    }

    @PostMapping("/eliminar")
    public String eliminar(@RequestParam("id") int id) {
        tipoTurnoService.eliminarTipo(id);
        return "redirect:/tipoturno";
    }
}
