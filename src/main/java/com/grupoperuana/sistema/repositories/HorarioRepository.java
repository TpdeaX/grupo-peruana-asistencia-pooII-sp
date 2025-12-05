package com.grupoperuana.sistema.repositories;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.grupoperuana.sistema.beans.Horario;

@Repository
public interface HorarioRepository extends JpaRepository<Horario, Integer> {

    Horario findFirstByEmpleadoIdAndFechaAndHoraFinAfterOrderByHoraInicioAsc(int empleadoId, LocalDate fecha,
            LocalTime hora);

    List<Horario> findByFechaOrderByHoraInicioAsc(LocalDate fecha);

    List<Horario> findByEmpleadoIdAndFecha(int empleadoId, LocalDate fecha);
}
