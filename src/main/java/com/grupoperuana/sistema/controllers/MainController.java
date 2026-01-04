package com.grupoperuana.sistema.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import jakarta.servlet.http.HttpSession;

@Controller
public class MainController {

    @GetMapping("/login")
    public String loginPage(HttpSession session) {
        if (session.getAttribute("usuario") != null) {
            // Already logged in
            return "redirect:/dashboard";
        }
        return "index"; // Maps to /index.jsp
    }

    @GetMapping("/")
    public String root() {
        return "redirect:/login";
    }
}
