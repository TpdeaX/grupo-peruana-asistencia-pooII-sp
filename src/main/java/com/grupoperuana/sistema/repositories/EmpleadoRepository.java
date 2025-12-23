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

    boolean existsByDni(String dni);

    @org.springframework.data.jpa.repository.Query("SELECT e FROM Empleado e WHERE " +
            "( e.estado = 1 ) AND " +
            "( COALESCE(:keyword, '') = '' OR LOWER(e.nombres) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(e.apellidos) LIKE LOWER(CONCAT('%', :keyword, '%')) OR e.dni LIKE %:keyword% ) AND "
            +
            "( COALESCE(:rol, '') = '' OR e.rol = :rol ) AND " +
            "( COALESCE(:modalidad, '') = '' OR e.tipoModalidad = :modalidad ) AND " +
            "( :sucursalId IS NULL OR e.sucursal.id = :sucursalId )")
    org.springframework.data.domain.Page<Empleado> buscarAvanzado(
            @org.springframework.data.repository.query.Param("keyword") String keyword,
            @org.springframework.data.repository.query.Param("rol") String rol,
            @org.springframework.data.repository.query.Param("modalidad") String modalidad,
            @org.springframework.data.repository.query.Param("sucursalId") Integer sucursalId,
            org.springframework.data.domain.Pageable pageable);
}
