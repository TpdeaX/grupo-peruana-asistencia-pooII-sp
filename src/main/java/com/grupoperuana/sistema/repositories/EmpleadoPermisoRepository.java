package com.grupoperuana.sistema.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.grupoperuana.sistema.beans.EmpleadoPermiso;

import jakarta.transaction.Transactional;

import java.util.List;

public interface EmpleadoPermisoRepository extends JpaRepository<EmpleadoPermiso, Integer> {


    List<EmpleadoPermiso> findByEmpleadoId(Integer empleadoId);
    
    @Transactional 
    void deleteByEmpleadoId(Integer empleadoId);
}
