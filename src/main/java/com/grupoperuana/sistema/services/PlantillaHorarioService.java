package com.grupoperuana.sistema.services;

import java.util.List;
import org.springframework.stereotype.Service;
import com.grupoperuana.sistema.beans.PlantillaHorario;
import com.grupoperuana.sistema.repositories.PlantillaHorarioRepository;

@Service
public class PlantillaHorarioService {

    private final PlantillaHorarioRepository repository;

    public PlantillaHorarioService(PlantillaHorarioRepository repository) {
        this.repository = repository;
    }

    public List<PlantillaHorario> listarTodos() {
        return repository.findAll();
    }

    public PlantillaHorario obtenerPorId(int id) {
        return repository.findById(id).orElse(null);
    }

    public PlantillaHorario guardar(PlantillaHorario plantilla) {
        return repository.save(plantilla);
    }

    public void eliminar(int id) {
        repository.deleteById(id);
    }
}
