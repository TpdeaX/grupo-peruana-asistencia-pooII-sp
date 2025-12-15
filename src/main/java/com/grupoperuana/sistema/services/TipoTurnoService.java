package com.grupoperuana.sistema.services;

import java.util.List;
import org.springframework.stereotype.Service;
import com.grupoperuana.sistema.beans.TipoTurno;
import com.grupoperuana.sistema.repositories.TipoTurnoRepository;

@Service
public class TipoTurnoService {

    private final TipoTurnoRepository tipoTurnoRepository;

    public TipoTurnoService(TipoTurnoRepository tipoTurnoRepository) {
        this.tipoTurnoRepository = tipoTurnoRepository;
    }

    public List<TipoTurno> listarTipos() {
        return tipoTurnoRepository.findAll();
    }

    public TipoTurno obtenerPorId(int id) {
        return tipoTurnoRepository.findById(id).orElse(null);
    }

    public void guardarTipo(TipoTurno tipo) {
        tipoTurnoRepository.save(tipo);
    }

    public void eliminarTipo(int id) {
        tipoTurnoRepository.deleteById(id);
    }
}
