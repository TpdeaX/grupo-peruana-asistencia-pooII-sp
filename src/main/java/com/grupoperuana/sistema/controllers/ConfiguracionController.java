package com.grupoperuana.sistema.controllers;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.grupoperuana.sistema.services.ConfiguracionService;

@Controller
@RequestMapping("/parametros")
public class ConfiguracionController {

    @Autowired
    private ConfiguracionService configuracionService;

    @GetMapping("/generales")
    public String verParametros(Model model) {
        Map<String, String> configs = configuracionService.getAllAsMap();
        model.addAttribute("configs", configs);
        return "views/admin/parametros_generales";
    }

    @PostMapping("/generales/guardar")
    public String guardarParametros(@RequestParam Map<String, String> allParams,
            RedirectAttributes redirectAttributes) {
        // Handle boolean checkboxes: if unchecked, they are not sent in POST.
        // We need to know which keys act as booleans to set them to false if missing.
        // For simplicity, we can just iterate known boolean keys or handle them
        // explicitly.

        // Explicitly handle known booleans
        String[] booleanKeys = {
                "descuento_falta_enabled",
                "descuento_tardanza_enabled",
                "ui_blur_modal",
                "asistencia_permitir_extras"
        };

        for (String key : booleanKeys) {
            String value = allParams.containsKey(key) ? "true" : "false";
            configuracionService.actualizarValor(key, value);
        }

        // Handle text/number parameters
        String[] textKeys = {
                "asistencia_hora_entrada",
                "asistencia_tolerancia"
        };

        for (String key : textKeys) {
            if (allParams.containsKey(key)) {
                configuracionService.actualizarValor(key, allParams.get(key));
            }
        }

        // Handle other unknown params if we had dynamic ones?
        // For now, let's just stick to the explicit ones or iterate defaults.

        redirectAttributes.addFlashAttribute("mensaje", "Configuración guardada correctamente");
        redirectAttributes.addFlashAttribute("tipoMensaje", "success");

        return "redirect:/parametros/generales";
    }
}
