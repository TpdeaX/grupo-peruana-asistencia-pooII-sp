package com.grupoperuana.sistema.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.grupoperuana.sistema.beans.Permiso;
import java.util.Optional;
import java.util.List;

public interface PermisoRepository extends JpaRepository<Permiso, Integer> {

    Optional<Permiso> findByNombre(String nombre);

    List<Permiso> findByNombreIn(List<String> nombres);
}