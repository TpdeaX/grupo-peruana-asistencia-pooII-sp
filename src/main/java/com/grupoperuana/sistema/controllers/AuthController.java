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
            @RequestParam(value = "rememberMe", required = false) boolean rememberMe,
            HttpSession session,
            jakarta.servlet.http.HttpServletResponse response) {

        Empleado emp = empleadoService.validarLogin(dni, password);

        if (emp != null) {
            session.setAttribute("usuario", emp);

            if (rememberMe) {
                // 30 dias en segundos
                int timeout = 30 * 24 * 60 * 60;
                session.setMaxInactiveInterval(timeout);

                // Persistir cookie SESSION (Spring Session) o JSESSIONID
                String encodedSessionId = java.util.Base64.getEncoder().encodeToString(session.getId().getBytes());

                jakarta.servlet.http.Cookie cookie = new jakarta.servlet.http.Cookie("JSESSIONID", session.getId());
                cookie.setPath("/");
                cookie.setMaxAge(timeout);
                cookie.setHttpOnly(true);
                response.addCookie(cookie);

                // Por si acaso usan Spring Session con nombre SESSION
                jakarta.servlet.http.Cookie springCookie = new jakarta.servlet.http.Cookie("SESSION", encodedSessionId);
                springCookie.setPath("/");
                springCookie.setMaxAge(timeout);
                springCookie.setHttpOnly(true);
                response.addCookie(springCookie);
            }

            if ("ADMIN".equals(emp.getRol())) {
            	return "redirect:/empleados?accion=dashboard";

            } else {
                return "redirect:/empleado";
            }
        } else {
            session.setAttribute("error", "Credenciales incorrectas");
            return "redirect:/index.jsp";
        }
    }
}
