package com.grupoperuana.sistema.services;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.grupoperuana.sistema.beans.Configuracion;
import com.grupoperuana.sistema.repositories.ConfiguracionRepository;

import jakarta.annotation.PostConstruct;

@Service
public class ConfiguracionService {

    @Autowired
    private ConfiguracionRepository configuracionRepository;

    public List<Configuracion> findAll() {
        return configuracionRepository.findAll();
    }

    public Configuracion findByClave(String clave) {
        return configuracionRepository.findByClave(clave);
    }

    public String getValor(String clave) {
        Configuracion conf = configuracionRepository.findByClave(clave);
        return conf != null ? conf.getValor() : null;
    }

    public void guardar(Configuracion configuracion) {
        // Check if exists to update instead of insert (though save does this if ID is
        // present,
        // we might want to lookup by Key if ID is missing from form)
        Configuracion existing = configuracionRepository.findByClave(configuracion.getClave());
        if (existing != null) {
            existing.setValor(configuracion.getValor());
            // Update other fields if necessary
            configuracionRepository.save(existing);
        } else {
            configuracionRepository.save(configuracion);
        }
    }

    public void actualizarValor(String clave, String valor) {
        Configuracion conf = configuracionRepository.findByClave(clave);
        if (conf != null) {
            conf.setValor(valor);
            configuracionRepository.save(conf);
        }
    }

    public Map<String, String> getAllAsMap() {
        List<Configuracion> configs = configuracionRepository.findAll();
        Map<String, String> map = new HashMap<>();
        for (Configuracion c : configs) {
            map.put(c.getClave(), c.getValor());
        }
        return map;
    }

    @PostConstruct
    public void initDefaults() {
        createIfNotExists("descuento_falta_enabled", "true", "Habilitar descuento por faltas", "BOOLEAN");
        createIfNotExists("descuento_tardanza_enabled", "true", "Habilitar descuento por tardanzas", "BOOLEAN");
        createIfNotExists("ui_blur_modal", "true", "Activar efecto blur en fondo de modales", "BOOLEAN");
        // Removed ui_dark_sidebar

        // Company Data defaults removed

        // Attendance Config
        createIfNotExists("asistencia_hora_entrada", "08:00", "Hora de entrada por defecto", "TIME");
        createIfNotExists("asistencia_tolerancia", "15", "Minutos de tolerancia para tardanza", "NUMBER");
        createIfNotExists("asistencia_permitir_extras", "false", "Permitir horas extras", "BOOLEAN");

        // System Config
        // createIfNotExists("sistema_moneda", "S/.", "Símbolo de moneda", "STRING");
    }

    private void createIfNotExists(String clave, String valor, String descripcion, String tipo) {
        if (configuracionRepository.findByClave(clave) == null) {
            configuracionRepository.save(new Configuracion(clave, valor, descripcion, tipo));
        }
    }
}
