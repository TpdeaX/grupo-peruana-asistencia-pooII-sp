package com.grupoperuana.sistema.services;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.beans.Permiso;
import com.grupoperuana.sistema.repositories.EmpleadoRepository;
import com.grupoperuana.sistema.repositories.PermisoRepository;

@Service
public class EmpleadoService {

    private final EmpleadoRepository empleadoRepository;
    private final PermisoRepository permisoRepository;

    public EmpleadoService(EmpleadoRepository empleadoRepository, PermisoRepository permisoRepository) {
        this.empleadoRepository = empleadoRepository;
        this.permisoRepository = permisoRepository;
    }

    public Empleado validarLogin(String dni, String password) {
        return empleadoRepository.findByDniAndPasswordAndEstado(dni, password, 1);
    }

    public List<Empleado> listarEmpleados() {
        return empleadoRepository.findByEstadoOrderByApellidosAsc(1);
    }

    // Método para la paginación en la vista web
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

    // --- ESTE ES EL MÉTODO QUE FALTABA (Para Excel y PDF) ---
    public List<Empleado> listarAvanzadoSinPaginacion(String keyword, String rol, String modalidad,
            Integer sucursalId) {
        // Pedimos "página 0" con tamaño 10000 para traer casi todo de golpe
        Pageable pageable = PageRequest.of(0, 10000, Sort.by("apellidos").ascending());

        if (keyword != null && keyword.trim().isEmpty())
            keyword = null;
        if (rol != null && rol.trim().isEmpty())
            rol = null;
        if (modalidad != null && modalidad.trim().isEmpty())
            modalidad = null;

        // .getContent() extrae la lista de la página
        return empleadoRepository.buscarAvanzado(keyword, rol, modalidad, sucursalId, pageable).getContent();
    }

    // --- LÓGICA DE GUARDADO ---
    public int registrarEmpleado(Empleado e, List<String> permisosSeleccionados) {
        try {
            e.setEstado(1);
            if (e.getPassword() == null || e.getPassword().trim().isEmpty()) {
                e.setPassword(e.getDni());
            }
            asignarPermisosLogica(e, permisosSeleccionados);
            empleadoRepository.save(e);
            return 1;
        } catch (Exception ex) {
            ex.printStackTrace();
            return 0;
        }
    }

    // --- LÓGICA DE ACTUALIZACIÓN ---
    @Transactional
    public int actualizarEmpleado(Empleado e, List<String> permisosSeleccionados) {
        return empleadoRepository.findById(e.getId()).map(existing -> {
            existing.setNombres(e.getNombres());
            existing.setApellidos(e.getApellidos());
            existing.setDni(e.getDni());
            existing.setSueldoBase(e.getSueldoBase());
            existing.setRol(e.getRol());
            existing.setTipoModalidad(e.getTipoModalidad());
            existing.setSucursal(e.getSucursal());

            asignarPermisosLogica(existing, permisosSeleccionados);

            empleadoRepository.save(existing);
            return 1;
        }).orElse(0);
    }

    // --- MÉTODO AUXILIAR ---
    private void asignarPermisosLogica(Empleado e, List<String> permisosSeleccionados) {
        if (e.getPermisos() == null) {
            e.setPermisos(new HashSet<>());
        } else {
            e.getPermisos().clear();
        }

        if ("ADMIN".equals(e.getRol())) {
            List<Permiso> todos = permisoRepository.findAll();
            e.getPermisos().addAll(todos);
        } else if ("PERSONALIZADO".equals(e.getRol())) {
            if (permisosSeleccionados != null && !permisosSeleccionados.isEmpty()) {
                List<String> permisosLimpios = new ArrayList<>();
                for (String p : permisosSeleccionados) {
                    if (p != null)
                        permisosLimpios.add(p.trim());
                }
                List<Permiso> permisosEncontrados = permisoRepository.findByNombreIn(permisosLimpios);
                e.getPermisos().addAll(permisosEncontrados);
            }
        }
    }

    public Empleado obtenerPorId(int id) {
        return empleadoRepository.findById(id).orElse(null);
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