package com.grupoperuana.sistema.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.grupoperuana.sistema.beans.Notificacion;

@Repository
public interface NotificacionRepository extends JpaRepository<Notificacion, Integer> {
    List<Notificacion> findByEmpleadoIdOrderByCreadoEnDesc(Integer empleadoId);
    List<Notificacion> findByEmpleadoIdAndLeidoFalse(Integer empleadoId);
}
