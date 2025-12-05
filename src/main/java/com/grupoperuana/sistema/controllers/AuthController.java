package com.grupoperuana.sistema.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.services.EmpleadoService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/auth")
public class AuthController {

    private final EmpleadoService empleadoService;

    public AuthController(EmpleadoService empleadoService) {
        this.empleadoService = empleadoService;
    }

    @GetMapping
    public String auth(HttpSession session) {
        // If logout action is passed via query param, handled here or separate method
        // For simplicity, redirect to index
        return "redirect:/index.jsp";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/index.jsp";
    }

    @PostMapping("/login")
    public String login(@RequestParam("dni") String dni,
            @RequestParam("password") String password,
            @RequestParam(value = "g-recaptcha-response", required = false) String recaptchaResponse,
            HttpSession session) {

        // Captcha validation logic can be added here if needed

        Empleado emp = empleadoService.validarLogin(dni, password);

        if (emp != null) {
            session.setAttribute("usuario", emp);
            if ("ADMIN".equals(emp.getRol())) {
                return "redirect:/admin"; // Assuming admin is mapped
            } else {
                return "redirect:/empleado"; // Assuming empleado is mapped
            }
        } else {
            session.setAttribute("error", "Credenciales incorrectas");
            return "redirect:/index.jsp";
        }
    }
}
