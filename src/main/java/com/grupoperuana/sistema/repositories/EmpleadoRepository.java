package com.grupoperuana.sistema.repositories;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.grupoperuana.sistema.beans.Empleado;

@Repository
public interface EmpleadoRepository extends JpaRepository<Empleado, Integer> {

    Empleado findByDniAndPasswordAndEstado(String dni, String password, int estado);

    List<Empleado> findByEstadoOrderByApellidosAsc(int estado);

    Empleado findByDni(String dni);
}
