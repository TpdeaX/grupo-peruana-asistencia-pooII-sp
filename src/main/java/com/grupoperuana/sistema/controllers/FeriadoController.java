package com.grupoperuana.sistema.controllers;

import com.grupoperuana.sistema.beans.Feriado;
import com.grupoperuana.sistema.services.FeriadoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/feriados")
public class FeriadoController {

    @Autowired
    private FeriadoService feriadoService;

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @PostMapping("/filter")
    public String filtrar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "") String keyword,
            HttpSession session) {

        session.setAttribute("fer_page", page);
        session.setAttribute("fer_size", size);
        session.setAttribute("fer_keyword", keyword);
        return "redirect:/feriados";
    }

    @GetMapping
    public String listar(Model model,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String keywordParam,
            HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        Integer sessionPage = (Integer) session.getAttribute("fer_page");
        int p = (sessionPage != null) ? sessionPage : 0;

        Integer sessionSize = (Integer) session.getAttribute("fer_size");
        int s = (sessionSize != null) ? sessionSize : 10;
        if (s < 1)
            s = 10;
        if (s > 100)
            s = 100;

        String k = (String) session.getAttribute("fer_keyword");
        if (k == null)
            k = "";

        Page<Feriado> pageRes = feriadoService.listar(k, p, s);

        model.addAttribute("feriados", pageRes.getContent());
        model.addAttribute("pagina", pageRes);
        model.addAttribute("keyword", k);
        model.addAttribute("size", s);
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
