package com.grupoperuana.sistema.repositories;

import com.grupoperuana.sistema.beans.Feriado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Repository
public interface FeriadoRepository extends JpaRepository<Feriado, Integer> {
    Optional<Feriado> findByFecha(LocalDate fecha);

    Page<Feriado> findByDescripcionContaining(String descripcion, Pageable pageable);
}
