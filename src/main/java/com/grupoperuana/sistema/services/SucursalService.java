package com.grupoperuana.sistema.services;

import com.grupoperuana.sistema.beans.Sucursal;
import com.grupoperuana.sistema.repositories.SucursalRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SucursalService {

    @Autowired
    private SucursalRepository sucursalRepository;

    public List<Sucursal> listarTodas() {
        return sucursalRepository.findAll();
    }

    public Page<Sucursal> listarPagina(String keyword, Pageable pageable) {
        if (keyword != null && !keyword.isEmpty()) {
            return sucursalRepository.findByNombreContainingOrDireccionContainingOrTelefonoContaining(keyword, keyword,
                    keyword, pageable);
        }
        return sucursalRepository.findAll(pageable);
    }

    public Optional<Sucursal> obtenerPorId(int id) {
        return sucursalRepository.findById(id);
    }

    public Sucursal guardar(Sucursal sucursal) {
        return sucursalRepository.save(sucursal);
    }

    public void eliminar(int id) {
        sucursalRepository.deleteById(id);
    }
}
