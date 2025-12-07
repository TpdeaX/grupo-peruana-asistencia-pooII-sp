package com.grupoperuana.sistema.services;

import java.util.List;
import org.springframework.stereotype.Service;
import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.repositories.EmpleadoRepository;

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
}