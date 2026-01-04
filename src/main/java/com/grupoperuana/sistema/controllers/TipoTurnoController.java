package com.grupoperuana.sistema.controllers;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpSession;
import com.grupoperuana.sistema.beans.TipoTurno;
import com.grupoperuana.sistema.services.TipoTurnoService;

@Controller
@RequestMapping("/tipoturno")
public class TipoTurnoController {

    private final TipoTurnoService tipoTurnoService;

    public TipoTurnoController(TipoTurnoService tipoTurnoService) {
        this.tipoTurnoService = tipoTurnoService;
    }

    private boolean checkSession(HttpSession session) {
        return session.getAttribute("usuario") != null;
    }

    @PostMapping("/filter")
    public String filtrar(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(defaultValue = "") String keyword,
            HttpSession session) {

        session.setAttribute("turno_page", page);
        session.setAttribute("turno_size", size);
        session.setAttribute("turno_keyword", keyword);
        return "redirect:/tipoturno";
    }

    @GetMapping
    public String listar(Model model,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String keywordParam,
            HttpSession session) {

        if (!checkSession(session))
            return "redirect:/index.jsp";

        Integer sessionPage = (Integer) session.getAttribute("turno_page");
        int p = (sessionPage != null) ? sessionPage : 0;

        Integer sessionSize = (Integer) session.getAttribute("turno_size");
        int s = (sessionSize != null) ? sessionSize : 5;
        if (s < 1)
            s = 5;
        if (s > 100)
            s = 100;

        String k = (String) session.getAttribute("turno_keyword");
        if (k == null)
            k = "";

        Pageable pageable = PageRequest.of(p, s);
        Page<TipoTurno> pagina = tipoTurnoService.listarTipos(pageable, k);

        model.addAttribute("lista", pagina.getContent());
        model.addAttribute("pagina", pagina);
        model.addAttribute("keyword", k);
        model.addAttribute("size", s);
        model.addAttribute("tipos", pagina.getContent());
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
