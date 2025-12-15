package com.grupoperuana.sistema.services;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

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

    public String marcarAsistencia(int idEmpleado, String modo, double lat, double lon, String observacion,
            MultipartFile foto) {
        System.out.println("DEBUG_ASISTENCIA: --- INICIO MARCA ---");
        System.out.println("DEBUG_ASISTENCIA: Empleado ID: " + idEmpleado);
        System.out.println("DEBUG_ASISTENCIA: Hora Servidor: " + java.time.LocalDateTime.now());

        LocalDate hoy = LocalDate.now();
        LocalTime ahora = LocalTime.now();

        // 1. Buscamos el ULTIMO turno ABIERTO (sin hora de salida), sin importar la
        // fecha
        Optional<Asistencia> abierta = asistenciaRepository
                .findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(idEmpleado);

        if (abierta.isPresent()) {
            System.out.println("DEBUG_ASISTENCIA: Encontrado turno ABIERTO (ID: " + abierta.get().getId() + ", Fecha: "
                    + abierta.get().getFecha() + ")");
            // --- CERRAR TURNO ACTUAL (SALIDA) ---
            Asistencia a = abierta.get();
            a.setHoraSalida(ahora);

            // Si cerramos turno, es SALIDA -> Guardar en fotoUrlSalida
            if (foto != null)
                a.setFotoUrlSalida(guardarFoto(foto));

            asistenciaRepository.save(a);
            System.out.println("DEBUG_ASISTENCIA: Turno CERRADO exitosamente.");

            // Verificamos si hay otro turno próximo inmediatamente para sugerir marcar
            Horario proximo = obtenerproximoTurnoInmediato(idEmpleado, ahora);
            if (proximo != null) {
                System.out
                        .println("DEBUG_ASISTENCIA: Se detecto proximo turno inmediato (ID: " + proximo.getId() + ")");
                return "SALIDA_CON_PROXIMO"; // Indicar al controller que pregunte
            }
            return "SALIDA";
        } else {
            System.out.println("DEBUG_ASISTENCIA: No hay turno abierto. Intentando crear ENTRADA.");
            // --- ABRIR NUEVO TURNO (ENTRADA) ---

            // 2. Buscamos el horario "objetivo" más cercano que NO haya sido marcado aún
            List<Horario> horariosHoy = horarioRepository.findByEmpleadoIdAndFecha(idEmpleado, hoy);
            horariosHoy.sort(Comparator.comparing(Horario::getHoraInicio)); // Ordenar por hora

            System.out.println("DEBUG_ASISTENCIA: Total horarios hoy: " + horariosHoy.size());

            Horario horarioObjetivo = null;

            for (Horario h : horariosHoy) {
                // Verificar si ya existe asistencia para este horario (aproximación por hora)
                if (yaMarcoParaHorario(idEmpleado, hoy, h)) {
                    System.out.println("DEBUG_ASISTENCIA: Horario ID " + h.getId() + " ya tiene marca.");
                    continue; // Ya marcado, siguiente
                }

                // Regla: ¿Ya es demasiado tarde? (Ej: Ya pasó la hora fin)
                // Se pondrá como actividad perdida y no asistida
                if (ahora.isAfter(h.getHoraFin())) {
                    System.out.println("DEBUG_ASISTENCIA: Horario ID " + h.getId() + " ya paso (HoraFin: "
                            + h.getHoraFin() + ").");
                    continue; // Considerado PERDIDO, pasar al siguiente
                }

                // Si llegamos aquí, es un horario disponible (futuro o en curso)
                horarioObjetivo = h;
                System.out.println("DEBUG_ASISTENCIA: Horario Objetivo encontrado: " + h.getId());
                break; // Encontramos el primero disponible
            }

            if (horarioObjetivo == null) {
                System.out.println("DEBUG_ASISTENCIA: SIN_TURNO (No se enconto horario valido para marcar).");
                return "SIN_TURNO"; // No hay mas turnos disponibles o válidos
            }

            // Crear la asistencia
            Asistencia a = new Asistencia();
            Empleado e = empleadoRepository.findById(idEmpleado).orElse(null);
            if (e == null)
                return "ERROR";

            a.setEmpleado(e);
            a.setFecha(hoy);
            a.setHoraEntrada(ahora);
            a.setModo(modo);
            a.setLatitud(lat);
            a.setLongitud(lon);
            a.setObservacion(observacion != null ? observacion : "Entrada Regular");
            if (foto != null)
                a.setFotoUrl(guardarFoto(foto));
            asistenciaRepository.save(a);
            System.out.println("DEBUG_ASISTENCIA: Nueva asistencia (ENTRADA) guardada.");
            return "ENTRADA";
        }
    }

    private boolean yaMarcoParaHorario(int idEmpleado, LocalDate fecha, Horario h) {
        // Lógica heurística: Si existe una asistencia cuya entrada esté cerca del
        // inicio del horario
        // O simplemente, si existe alguna asistencia "asignable" a este horario.
        List<Asistencia> asistencias = asistenciaRepository.findByEmpleadoIdAndFecha(idEmpleado, fecha);

        for (Asistencia a : asistencias) {
            // Si la asistencia entra ANTES de que termine el turno...
            if (a.getHoraEntrada().isBefore(h.getHoraFin())) {
                // Y la diferencia no es masiva (ej. es el turno de la tarde vs mañana)
                // Usamos la misma lógica del reporte: match por proximidad
                long diffHoras = Duration.between(a.getHoraEntrada(), h.getHoraInicio()).abs().toHours();
                if (diffHoras <= 4) {
                    return true;
                }
            }
        }
        return false;
    }

    private Horario obtenerproximoTurnoInmediato(int idEmpleado, LocalTime ahora) {
        // Busca si hay un horario que empiece pronto (ej. en menos de 1 hora)
        List<Horario> horarios = horarioRepository.findByEmpleadoIdAndFecha(idEmpleado, LocalDate.now());
        horarios.sort(Comparator.comparing(Horario::getHoraInicio));

        for (Horario h : horarios) {
            if (h.getHoraInicio().isAfter(ahora)) {
                // Si empieza dentro de los proximos 60 min, sugerimos marcar
                long minutosParaInicio = Duration.between(ahora, h.getHoraInicio()).toMinutes();
                if (minutosParaInicio < 60 && !yaMarcoParaHorario(idEmpleado, LocalDate.now(), h)) {
                    return h;
                }
            }
        }
        return null;
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
                if (asistenciasAsignadas.contains(a.getId()))
                    continue;

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
                long diffMinutos = Duration.between(h.getHoraInicio(), asistenciaEncontrada.getHoraEntrada())
                        .toMinutes();

                if (diffMinutos < -2) {
                    estado = "ASISTIDO";
                    mensaje = "Ingreso Temprano";
                    css = "status-early";
                } else if (diffMinutos >= -2 && diffMinutos <= 2) {
                    estado = "ASISTIDO";
                    mensaje = "Puntual";
                    css = "status-ontime";
                } else {
                    estado = "ASISTIDO";
                    mensaje = "Tardanza";
                    css = "status-late";
                }
            } else {
                if (LocalTime.now().isAfter(h.getHoraInicio().plusMinutes(2))) {
                    if (LocalTime.now().isAfter(h.getHoraFin())) {
                        estado = "FALTA";
                        mensaje = "No Marcado";
                        css = "status-missed";
                    } else {
                        estado = "PENDIENTE";
                        mensaje = "Retrasado";
                        css = "status-warning";
                    }
                }
            }
            reporte.add(new TurnoDTO(h, asistenciaEncontrada, estado, mensaje, css));
        }
        return reporte;
    }

    // --- Lógica de Fin de Jornada ---
    public boolean verificarFinJornada(int empleadoId) {
        // Verificar si quedan turnos PENDIENTES o RETRASADOS para hoy que aun se puedan
        // marcar (no completados y no pasados totalmente)
        // Simplificación: Si todos los horarios de hoy tienen una asistencia asignada O
        // ya pasaron su hora fin
        LocalDate hoy = LocalDate.now();
        List<Horario> horarios = horarioRepository.findByEmpleadoIdAndFecha(empleadoId, hoy);

        boolean quedaAlgo = false;
        LocalTime ahora = LocalTime.now();

        for (Horario h : horarios) {
            // Si ya pasó la hora fin, no cuenta como disponible
            if (ahora.isAfter(h.getHoraFin()))
                continue;

            // Si ya tiene marca (entrada), no cuenta como disponible (para entrada)
            if (yaMarcoParaHorario(empleadoId, hoy, h))
                continue;

            // Si llegamos aqui, es un horario activo o futuro sin marcar
            quedaAlgo = true;
            break;
        }

        // Pero espera! Si tienes CUALQUIER turno ABIERTO (sin salida), NO es fin de
        // jornada,
        // debes marcar salida (incluso si es de ayer).
        boolean turnoAbierto = asistenciaRepository.findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(empleadoId)
                .isPresent();
        if (turnoAbierto)
            return false; // Aun debes marcar salida

        return !quedaAlgo;
    }

    // --- Manejo de Fotos ---
    public String guardarFoto(MultipartFile foto) {
        if (foto == null || foto.isEmpty())
            return null;
        try {
            String folder = "src/main/resources/static/uploads/evidencias/";
            java.io.File directory = new java.io.File(folder);
            if (!directory.exists())
                directory.mkdirs();

            String filename = System.currentTimeMillis() + "_" + foto.getOriginalFilename();
            Path path = Paths.get(folder + filename);
            Files.write(path, foto.getBytes());

            return "uploads/evidencias/" + filename;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public String procesarQrDinamico(int idEmpleado, String tokenQrRecibido, MultipartFile foto) {

        String fechaHoy = LocalDate.now().toString();
        String tokenEsperado = "GRUPO_PERUANA_" + fechaHoy;

        if (!tokenEsperado.equals(tokenQrRecibido)) {
            return "ERROR: El código QR ha caducado o no es válido.";
        }

        // QR ahora permite multiples marcas, igual que GPS
        // Reusamos lógica similar pero simplificada para QR

        // 1. Check abierto GLOBAL
        Optional<Asistencia> abierta = asistenciaRepository
                .findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(idEmpleado);

        if (abierta.isPresent()) {
            Asistencia a = abierta.get();
            a.setHoraSalida(LocalTime.now());
            if (foto != null)
                a.setFotoUrlSalida(guardarFoto(foto));
            asistenciaRepository.save(a);

            // Check proximo (copia logica GPS)
            if (obtenerproximoTurnoInmediato(idEmpleado, LocalTime.now()) != null)
                return "EXITO_CON_PROXIMO";

            return "EXITO_SALIDA";
        }

        // 2. Check entrada (busca turno)
        // ... (Simplificación: QR asume entrada regular si no hay abierto)
        // Deberíamos validar si hay turno disponible igual que en GPS

        if (verificarFinJornada(idEmpleado))
            return "ERROR: Jornada finalizada o sin turnos.";

        Asistencia asistencia = new Asistencia();
        Empleado empleado = empleadoRepository.findById(idEmpleado).orElse(null);
        if (empleado == null)
            return "ERROR: Empleado no encontrado.";

        asistencia.setEmpleado(empleado);
        asistencia.setFecha(LocalDate.now());
        asistencia.setHoraEntrada(LocalTime.now());
        asistencia.setModo("QR_DINAMICO");
        asistencia.setObservacion("Ingreso QR");
        if (foto != null)
            asistencia.setFotoUrl(guardarFoto(foto));

        asistenciaRepository.save(asistencia);

        return "EXITO";
    }
}