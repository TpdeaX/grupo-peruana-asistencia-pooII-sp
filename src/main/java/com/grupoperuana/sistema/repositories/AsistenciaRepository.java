package com.grupoperuana.sistema.repositories;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.grupoperuana.sistema.beans.Asistencia;

@Repository
public interface AsistenciaRepository extends JpaRepository<Asistencia, Integer>,
        org.springframework.data.jpa.repository.JpaSpecificationExecutor<Asistencia> {

    List<Asistencia> findByEmpleadoIdOrderByFechaDesc(int empleadoId);

    List<Asistencia> findAllByOrderByFechaDescHoraEntradaDesc();

    Optional<Asistencia> findByEmpleadoIdAndFechaAndHoraSalidaIsNull(int empleadoId, LocalDate fecha);

    // Encuentra el ultimo turno abierto (sin salida) sin importar la fecha (para
    // cerrar turnos de dias previos)
    Optional<Asistencia> findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(int empleadoId);

    List<Asistencia> findByEmpleadoIdAndFecha(int empleadoId, LocalDate fecha);

    boolean existsByEmpleadoIdAndFecha(int empleadoId, LocalDate fecha);

    List<Asistencia> findByFechaBetweenOrderByFechaAsc(LocalDate start, LocalDate end);

    List<Asistencia> findByEmpleadoIdAndFechaBetweenOrderByFechaAsc(int empleadoId, LocalDate start, LocalDate end);
}