package com.grupoperuana.sistema.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.beans.Notificacion;
import com.grupoperuana.sistema.repositories.NotificacionRepository;

@Service
public class NotificacionService {

    @Autowired
    private NotificacionRepository repo;

    public Notificacion crearNotificacion(Empleado empleado, String tipo, String mensaje) {
        Notificacion n = new Notificacion();
        n.setEmpleado(empleado);
        n.setTipo(tipo);
        n.setMensaje(mensaje);
        return repo.save(n);
    }

    public List<Notificacion> obtenerNotificacionesEmpleado(Integer empleadoId) {
        return repo.findByEmpleadoIdOrderByCreadoEnDesc(empleadoId);
    }

    public List<Notificacion> obtenerNoLeidas(Integer empleadoId) {
        return repo.findByEmpleadoIdAndLeidoFalse(empleadoId);
    }

    public void marcarComoLeida(Integer id) {
        Notificacion n = repo.findById(id).orElseThrow();
        n.setLeido(true);
        repo.save(n);
    }
}
