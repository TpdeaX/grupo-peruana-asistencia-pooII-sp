package com.grupoperuana.sistema.controllers;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.beans.Notificacion;
import com.grupoperuana.sistema.services.NotificacionService;

@RestController
@RequestMapping("/api/notificaciones")
public class NotificacionController {

    @Autowired
    private NotificacionService service;

    @GetMapping("/{empleadoId}")
    public List<Notificacion> getNotificaciones(@PathVariable Integer empleadoId) {
        return service.obtenerNotificacionesEmpleado(empleadoId);
    }

    @GetMapping("/no-leidas/{empleadoId}")
    public List<Notificacion> getNoLeidas(@PathVariable Integer empleadoId) {
        return service.obtenerNoLeidas(empleadoId);
    }

    @PostMapping("/crear")
    public Notificacion crear(@RequestBody Map<String, String> body) {
  
        Empleado emp = new Empleado();
        emp.setId(Integer.parseInt(body.get("empleadoId")));
        return service.crearNotificacion(emp, body.get("tipo"), body.get("mensaje"));
    }

    @PutMapping("/marcar-leida/{id}")
    public void marcarComoLeida(@PathVariable Integer id) {
        service.marcarComoLeida(id);
    }
}
