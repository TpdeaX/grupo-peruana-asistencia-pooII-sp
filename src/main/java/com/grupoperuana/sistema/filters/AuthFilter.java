package com.grupoperuana.sistema.filters;

import java.io.IOException;

import org.springframework.stereotype.Component;
import org.springframework.core.annotation.Order;

import com.grupoperuana.sistema.beans.Empleado;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
@Order(1) // Execute early in the chain
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // 1. HEADER IMPROVEMENTS FOR CACHE CONTROL (Fix "Back to Login" issue)
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
        res.setHeader("Pragma", "no-cache"); // HTTP 1.0.
        res.setHeader("Expires", "0"); // Proxies.

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // 0. CANONICAL URL ENFORCEMENT (User request: /index.jsp -> /login)
        if ("/index.jsp".equals(path) || "/".equals(path)) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Allowed public resources
        boolean isStaticResource = path.startsWith("/assets/") ||
                path.startsWith("/css/") ||
                path.startsWith("/js/") ||
                path.endsWith(".css") ||
                path.endsWith(".js") ||
                path.endsWith(".png") ||
                path.endsWith(".ico");

        boolean isPublicPage = path.equals("/login") ||
                path.equals("/auth/login") ||
                path.equals("/auth/logout") ||
                path.startsWith("/views/components/") ||
                path.startsWith("/views/shared/"); // Components used by public pages

        if (isStaticResource) {
            chain.doFilter(request, response);
            return;
        }

        Empleado usuario = (session != null) ? (Empleado) session.getAttribute("usuario") : null;
        boolean isLoggedIn = (usuario != null);

        // 2. AUTHENTICATION (Fix "Infinite Loading" when session expired but page
        // thinks otherwise)
        if (!isLoggedIn && !isPublicPage) {
            // Trying to access protected resource without session
            if (path.startsWith("/api/")) {
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            } else {
                res.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        // 3. PAGE ACCESS CONTROL (Fix "Logged in users seeing login page")
        if (isLoggedIn && (path.equals("/login") || path.equals("/auth/login"))) {
            // Already logged in, redirect to dashboard
            if ("ADMIN".equals(usuario.getRol())) {
                res.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                res.sendRedirect(req.getContextPath() + "/empleado");
            }
            return;
        }

        // 4. AUTHORIZATION (Fix "Access without admin")
        // Define admin-only routes
        boolean isAdminRoute = path.startsWith("/views/admin/") ||
                path.equals("/dashboard") ||
                path.startsWith("/dashboard/") ||
                path.startsWith("/empleados") ||
                path.startsWith("/sucursales") ||
                path.startsWith("/reportes") ||
                path.startsWith("/plantillas") ||
                path.startsWith("/horarios") ||
                path.startsWith("/feriados") ||
                path.startsWith("/tipoturno") ||
                path.startsWith("/parametros");

        if (isLoggedIn && isAdminRoute) {
            if (!"ADMIN".equals(usuario.getRol())) {
                res.sendRedirect(req.getContextPath() + "/empleado");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
