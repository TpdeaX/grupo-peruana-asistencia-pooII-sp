<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 
    theme-init.jsp - Inline script to prevent FOUC (Flash of Unstyled Content)
    Must be included in <head> BEFORE any stylesheets for best results.
    This script runs synchronously and applies the theme immediately.
--%>
<script>
// Apply theme immediately to prevent flash
(function() {
    try {
        var theme = localStorage.getItem('theme');
        if (theme === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
        }
    } catch (e) {
        // localStorage might not be available (private browsing, etc.)
    }
})();
</script>
