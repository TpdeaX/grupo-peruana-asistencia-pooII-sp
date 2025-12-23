package com.grupoperuana.sistema.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.grupoperuana.sistema.beans.TipoTurno;

@Repository
public interface TipoTurnoRepository extends JpaRepository<TipoTurno, Integer> {
    TipoTurno findByNombre(String nombre);

    Page<TipoTurno> findByNombreContainingIgnoreCase(String nombre, Pageable pageable);
}
