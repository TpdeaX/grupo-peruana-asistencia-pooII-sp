package com.grupoperuana.sistema.services;

import com.grupoperuana.sistema.beans.Feriado;
import com.grupoperuana.sistema.repositories.FeriadoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

@Service
public class FeriadoService {

    @Autowired
    private FeriadoRepository feriadoRepository;

    public List<Feriado> listarTodos() {
        return feriadoRepository.findAll();
    }

    public Page<Feriado> listar(String keyword, int page, int size) {
        return feriadoRepository.findByDescripcionContaining(keyword,
                PageRequest.of(page, size, Sort.by("fecha").descending()));
    }

    public Optional<Feriado> obtenerPorId(int id) {
        return feriadoRepository.findById(id);
    }

    public Feriado guardar(Feriado feriado) {
        return feriadoRepository.save(feriado);
    }

    public void eliminar(int id) {
        feriadoRepository.deleteById(id);
    }

    public boolean esFeriado(LocalDate fecha) {
        return feriadoRepository.findByFecha(fecha).isPresent();
    }
}
