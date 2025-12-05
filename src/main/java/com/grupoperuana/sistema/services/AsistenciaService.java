package com.grupoperuana.sistema.services;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.ArrayList;
import java.time.Duration;
import java.util.Collections;
import java.util.Comparator;

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

    public List<Asistencia> listarTodo() {
        return asistenciaRepository.findAllByOrderByFechaDescHoraEntradaDesc();
    }

    public List<Asistencia> listarPorEmpleado(int idEmpleado) {
        return asistenciaRepository.findByEmpleadoIdOrderByFechaDesc(idEmpleado);
    }

    public String marcarAsistencia(int idEmpleado, String modo, double lat, double lon, String observacion) {
        LocalDate hoy = LocalDate.now();
        Optional<Asistencia> abierta = asistenciaRepository.findByEmpleadoIdAndFechaAndHoraSalidaIsNull(idEmpleado,
                hoy);

        if (abierta.isPresent()) {
            Asistencia a = abierta.get();
            a.setHoraSalida(LocalTime.now());
            asistenciaRepository.save(a);
            return "SALIDA";
        } else {
            Asistencia a = new Asistencia();
            Empleado e = empleadoRepository.findById(idEmpleado).orElse(null);
            if (e == null)
                return "ERROR";

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

        // Ordenar horarios por hora de inicio
        // Ordenar horarios por hora de inicio
        horarios.sort(Comparator.comparing(Horario::getHoraInicio));

        // Mantener registro de asistencias ya asignadas para no repetirlas
        List<Integer> asistenciasAsignadas = new ArrayList<>();

        for (Horario h : horarios) {
            Asistencia asistenciaEncontrada = null;

            // Buscar la mejor coincidencia de asistencia para este turno
            for (Asistencia a : asistencias) {
                if (asistenciasAsignadas.contains(a.getId())) {
                    continue;
                }

                // Lógica mejorada:
                // 1. La asistencia debe ser ANTES del fin del turno (obvio)
                // 2. La asistencia debe ser DESPUÉS de un tiempo razonable antes del inicio
                // (ej. 4 horas)
                // o simplemente buscamos la primera disponible que tenga sentido cronológico.
                // Al estar ordenados los turnos, si asignamos una asistencia al primer turno,
                // el segundo turno buscará en las restantes.

                // Ventana de búsqueda: Desde 4 horas antes del inicio hasta el fin del turno.
                LocalTime ventanaInicio = h.getHoraInicio().minusHours(4);
                LocalTime ventanaFin = h.getHoraFin();

                // Manejo de cruce de medianoche (si fuera necesario, pero por ahora simple)
                // Asumimos turnos en el mismo día por la lógica de 'hoy'.

                boolean dentroDeRango = false;
                if (ventanaInicio.isAfter(ventanaFin)) {
                    // Caso raro donde ventana inicio cruza medianoche hacia atrás en el mismo día?
                    // No, LocalTime.minusHours ajusta. Pero si es 08:00 - 4h = 04:00.
                    // Si turno es 01:00 - 4h = 21:00 (del día anterior).
                    // Pero estamos filtrando asistencias por FECHA 'hoy'.
                    // Así que solo nos importa desde 00:00.
                    // Si ventanaInicio > horaInicio (por wrap around), lo tratamos como 00:00.
                }

                // Simplificación: Si la asistencia es del mismo día, verificamos hora.
                // Si hora entrada está entre ventanaInicio y ventanaFin.
                // Ojo: Si ventanaInicio es "ayer" (ej 23:00), y asistencia es hoy 07:00,
                // LocalTime 23:00 > 07:00.

                // Para simplificar y dado que filtramos por FECHA = HOY:
                // Solo miramos si es antes del fin del turno.
                // Y para evitar tomar asistencias de turnos MUY anteriores que se olvidaron
                // marcar salida,
                // ponemos un límite razonable, pero la clave es el orden y no repetir.

                if (a.getHoraEntrada().isBefore(ventanaFin)) {
                    // Si es la primera que encontramos no asignada y es anterior al fin del turno,
                    // es candidata. Pero verifiquemos que no sea "demasiado" temprano si hay otro
                    // turno antes.
                    // Pero como ya procesamos los turnos anteriores y asignamos sus asistencias,
                    // esta debería ser la correcta para ESTE turno.

                    // Un check extra: que no sea más de 4 horas antes del inicio,
                    // para no agarrar una asistencia de la mañana para el turno de la noche si el
                    // de la mañana faltó.
                    long diffHoras = Duration.between(a.getHoraEntrada(), h.getHoraInicio()).toHours();
                    if (diffHoras <= 4) { // Si entró hasta 4 horas antes (o después)
                        asistenciaEncontrada = a;
                        asistenciasAsignadas.add(a.getId());
                        break;
                    }
                }
            }

            String estado = "PENDIENTE";
            String mensaje = "Pendiente";
            String css = "status-pending"; // gris o amarillo claro

            if (asistenciaEncontrada != null) {
                // Calcular puntualidad
                long diffMinutos = Duration.between(h.getHoraInicio(), asistenciaEncontrada.getHoraEntrada())
                        .toMinutes();

                if (diffMinutos < -2) {
                    estado = "ASISTIDO";
                    mensaje = "Ingreso Temprano";
                    css = "status-early"; // azul o verde
                } else if (diffMinutos >= -2 && diffMinutos <= 2) {
                    estado = "ASISTIDO";
                    mensaje = "Puntual";
                    css = "status-ontime"; // verde
                } else {
                    estado = "ASISTIDO";
                    mensaje = "Tardanza";
                    css = "status-late"; // naranja/rojo
                }
            } else {
                // No hay asistencia. Verificar si ya pasó el turno.
                if (LocalTime.now().isAfter(h.getHoraInicio().plusMinutes(2))) {
                    // Si ya pasaron 2 minutos del inicio y no marcó, ya es "Tarde" o "Falta" si
                    // acabó el turno
                    if (LocalTime.now().isAfter(h.getHoraFin())) {
                        estado = "FALTA";
                        mensaje = "No Marcado";
                        css = "status-missed"; // rojo
                    } else {
                        estado = "PENDIENTE"; // Aún puede marcar pero será tarde
                        mensaje = "Retrasado";
                        css = "status-warning"; // naranja
                    }
                }
            }

            reporte.add(new TurnoDTO(h, asistenciaEncontrada, estado, mensaje, css));
        }

        return reporte;
    }
}
