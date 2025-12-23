package com.grupoperuana.sistema.services;

import java.util.List;
import org.springframework.stereotype.Service;
import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.repositories.EmpleadoRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

@Service
public class EmpleadoService {

    private final EmpleadoRepository empleadoRepository;

    public EmpleadoService(EmpleadoRepository empleadoRepository) {
        this.empleadoRepository = empleadoRepository;
    }

    public Empleado validarLogin(String dni, String password) {
        return empleadoRepository.findByDniAndPasswordAndEstado(dni, password, 1);
    }

    public List<Empleado> listarEmpleados() {
        return empleadoRepository.findByEstadoOrderByApellidosAsc(1);
    }

    public Page<Empleado> listarAvanzado(String keyword, String rol, String modalidad, Integer sucursalId, int page,
            int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("apellidos").ascending());

        if (keyword != null && keyword.trim().isEmpty())
            keyword = null;
        if (rol != null && rol.trim().isEmpty())
            rol = null;
        if (modalidad != null && modalidad.trim().isEmpty())
            modalidad = null;

        return empleadoRepository.buscarAvanzado(keyword, rol, modalidad, sucursalId, pageable);
    }

    public List<Empleado> listarAvanzadoSinPaginacion(String keyword, String rol, String modalidad,
            Integer sucursalId) {
        Pageable pageable = PageRequest.of(0, 10000, Sort.by("apellidos").ascending());

        if (keyword != null && keyword.trim().isEmpty())
            keyword = null;
        if (rol != null && rol.trim().isEmpty())
            rol = null;
        if (modalidad != null && modalidad.trim().isEmpty())
            modalidad = null;

        return empleadoRepository.buscarAvanzado(keyword, rol, modalidad, sucursalId, pageable).getContent();
    }

    public int registrarEmpleado(Empleado e) {
        try {

            e.setEstado(1);

            if (e.getPassword() == null || e.getPassword().trim().isEmpty()) {
                e.setPassword(e.getDni());
            }

            System.out.println("Guardando empleado: " + e.getNombres() + " con pass: " + e.getPassword());

            empleadoRepository.save(e);
            return 1;

        } catch (Exception ex) {
            ex.printStackTrace();
            return 0;
        }
    }

    public Empleado obtenerPorId(int id) {
        return empleadoRepository.findById(id).orElse(null);
    }

    public int actualizarEmpleado(Empleado e) {
        return empleadoRepository.findById(e.getId()).map(existing -> {
            existing.setNombres(e.getNombres());
            existing.setApellidos(e.getApellidos());
            existing.setDni(e.getDni());
            existing.setRol(e.getRol());
            existing.setSucursal(e.getSucursal());

            empleadoRepository.save(existing);
            return 1;
        }).orElse(0);
    }

    public int eliminarEmpleado(int id) {
        return empleadoRepository.findById(id).map(existing -> {
            existing.setEstado(0);
            empleadoRepository.save(existing);
            return 1;
        }).orElse(0);
    }

    public int actualizarPassword(int id, String newPassword) {
        return empleadoRepository.findById(id).map(existing -> {
            existing.setPassword(newPassword);
            empleadoRepository.save(existing);
            return 1;
        }).orElse(0);
    }
}