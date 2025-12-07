package com.grupoperuana.sistema.services;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.grupoperuana.sistema.beans.Asistencia;
import com.grupoperuana.sistema.beans.Empleado;
import com.grupoperuana.sistema.beans.Horario;
import com.grupoperuana.sistema.dto.TurnoDTO;
import com.grupoperuana.sistema.repositories.AsistenciaRepository;
import com.grupoperuana.sistema.repositories.EmpleadoRepository;
import com.grupoperuana.sistema.repositories.HorarioRepository;

@Service
public class AsistenciaService {

    private final AsistenciaRepository asistenciaRepository;
    private final EmpleadoRepository empleadoRepository;
    private final HorarioRepository horarioRepository;

    public AsistenciaService(AsistenciaRepository asistenciaRepository, EmpleadoRepository empleadoRepository,
            HorarioRepository horarioRepository) {
        this.asistenciaRepository = asistenciaRepository;
        this.empleadoRepository = empleadoRepository;
        this.horarioRepository = horarioRepository;
    }
    
    // --- MÉTODO NUEVO: PUENTE PARA EL CONTROLLER ---
    public boolean verificarSiMarcoHoy(int empleadoId) {
        return asistenciaRepository.existsByEmpleadoIdAndFecha(empleadoId, LocalDate.now());
    }

    public List<Asistencia> listarTodo() {
        return asistenciaRepository.findAllByOrderByFechaDescHoraEntradaDesc();
    }

    public List<Asistencia> listarPorEmpleado(int idEmpleado) {
        return asistenciaRepository.findByEmpleadoIdOrderByFechaDesc(idEmpleado);
    }

    public String marcarAsistencia(int idEmpleado, String modo, double lat, double lon, String observacion) {
        LocalDate hoy = LocalDate.now();
        Optional<Asistencia> abierta = asistenciaRepository.findByEmpleadoIdAndFechaAndHoraSalidaIsNull(idEmpleado, hoy);

        if (abierta.isPresent()) {
            Asistencia a = abierta.get();
            a.setHoraSalida(LocalTime.now());
            asistenciaRepository.save(a);
            return "SALIDA";
        } else {
          
            
            Asistencia a = new Asistencia();
            Empleado e = empleadoRepository.findById(idEmpleado).orElse(null);
            if (e == null) return "ERROR";

            a.setEmpleado(e);
            a.setFecha(hoy);
            a.setHoraEntrada(LocalTime.now());
            a.setModo(modo);
            a.setLatitud(lat);
            a.setLongitud(lon);
            a.setObservacion(observacion != null ? observacion : "");
            asistenciaRepository.save(a);
            return "ENTRADA";
        }
    }

    public Horario obtenerProximoTurno(int idEmpleado) {
        return horarioRepository.findFirstByEmpleadoIdAndFechaAndHoraFinAfterOrderByHoraInicioAsc(idEmpleado,
                LocalDate.now(), LocalTime.now());
    }

    public List<TurnoDTO> obtenerReporteDiario(int empleadoId) {
        LocalDate hoy = LocalDate.now();
        List<Horario> horarios = horarioRepository.findByEmpleadoIdAndFecha(empleadoId, hoy);
        List<Asistencia> asistencias = asistenciaRepository.findByEmpleadoIdAndFecha(empleadoId, hoy);
        List<TurnoDTO> reporte = new ArrayList<>();

        horarios.sort(Comparator.comparing(Horario::getHoraInicio));
        List<Integer> asistenciasAsignadas = new ArrayList<>();

        for (Horario h : horarios) {
            Asistencia asistenciaEncontrada = null;

            for (Asistencia a : asistencias) {
                if (asistenciasAsignadas.contains(a.getId())) continue;

                LocalTime ventanaFin = h.getHoraFin();
                if (a.getHoraEntrada().isBefore(ventanaFin)) {
                    long diffHoras = Duration.between(a.getHoraEntrada(), h.getHoraInicio()).toHours();
                    if (diffHoras <= 4) { 
                        asistenciaEncontrada = a;
                        asistenciasAsignadas.add(a.getId());
                        break;
                    }
                }
            }

            String estado = "PENDIENTE";
            String mensaje = "Pendiente";
            String css = "status-pending";

            if (asistenciaEncontrada != null) {
                long diffMinutos = Duration.between(h.getHoraInicio(), asistenciaEncontrada.getHoraEntrada()).toMinutes();

                if (diffMinutos < -2) {
                    estado = "ASISTIDO"; mensaje = "Ingreso Temprano"; css = "status-early";
                } else if (diffMinutos >= -2 && diffMinutos <= 2) {
                    estado = "ASISTIDO"; mensaje = "Puntual"; css = "status-ontime";
                } else {
                    estado = "ASISTIDO"; mensaje = "Tardanza"; css = "status-late";
                }
            } else {
                if (LocalTime.now().isAfter(h.getHoraInicio().plusMinutes(2))) {
                    if (LocalTime.now().isAfter(h.getHoraFin())) {
                        estado = "FALTA"; mensaje = "No Marcado"; css = "status-missed";
                    } else {
                        estado = "PENDIENTE"; mensaje = "Retrasado"; css = "status-warning";
                    }
                }
            }
            reporte.add(new TurnoDTO(h, asistenciaEncontrada, estado, mensaje, css));
        }
        return reporte;
    }

    public String procesarQrDinamico(int idEmpleado, String tokenQrRecibido) {
        
        String fechaHoy = LocalDate.now().toString();
        String tokenEsperado = "GRUPO_PERUANA_" + fechaHoy;
    
        if (!tokenEsperado.equals(tokenQrRecibido)) {
            return "ERROR: El código QR ha caducado o no es válido.";
        }
       
        if (asistenciaRepository.existsByEmpleadoIdAndFecha(idEmpleado, LocalDate.now())) {
             return "ERROR: Ya registraste tu asistencia el día de hoy.";
        }

        Empleado empleado = empleadoRepository.findById(idEmpleado).orElse(null);
        if (empleado == null) return "ERROR: Empleado no encontrado.";

        Asistencia asistencia = new Asistencia();
        asistencia.setEmpleado(empleado);
        asistencia.setFecha(LocalDate.now());
        asistencia.setHoraEntrada(LocalTime.now());
        asistencia.setModo("QR_DINAMICO"); 
        asistencia.setObservacion("Ingreso verificado por QR");
        
        asistenciaRepository.save(asistencia);

        return "EXITO"; 
    }
}