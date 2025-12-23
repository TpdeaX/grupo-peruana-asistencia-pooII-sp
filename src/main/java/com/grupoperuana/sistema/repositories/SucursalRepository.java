package com.grupoperuana.sistema.repositories;

import com.grupoperuana.sistema.beans.Sucursal;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SucursalRepository extends JpaRepository<Sucursal, Integer> {
    Page<Sucursal> findByNombreContainingOrDireccionContainingOrTelefonoContaining(String nombre, String direccion,
            String telefono, Pageable pageable);
}
