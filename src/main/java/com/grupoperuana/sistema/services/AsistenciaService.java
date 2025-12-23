package com.grupoperuana.sistema.services;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import jakarta.persistence.criteria.Predicate;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

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
import com.grupoperuana.sistema.beans.Justificacion;

@Service
public class AsistenciaService {

    private final AsistenciaRepository asistenciaRepository;
    private final EmpleadoRepository empleadoRepository;
    private final HorarioRepository horarioRepository;

    @org.springframework.beans.factory.annotation.Value("${app.asistencia.factor-descuento:1.0}")
    private double factorDescuento;

    @org.springframework.beans.factory.annotation.Value("${app.asistencia.factor-bonificacion:1.0}")
    private double factorBonificacion;

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

    public Page<Asistencia> listarAsistenciasPaginado(Pageable pageable, String keyword, Integer sucursalId,
            LocalDate fechaInicio, LocalDate fechaFin) {
        Specification<Asistencia> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (sucursalId != null) {
                predicates.add(cb.equal(root.get("empleado").get("sucursal").get("id"), sucursalId));
            }

            if (fechaInicio != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("fecha"), fechaInicio));
            }

            if (fechaFin != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("fecha"), fechaFin));
            }

            if (keyword != null && !keyword.isEmpty()) {
                String likePattern = "%" + keyword.toLowerCase() + "%";
                Predicate nombre = cb.like(cb.lower(root.get("empleado").get("nombres")), likePattern);
                Predicate apellido = cb.like(cb.lower(root.get("empleado").get("apellidos")), likePattern);
                Predicate dni = cb.like(root.get("empleado").get("dni"), likePattern);
                predicates.add(cb.or(nombre, apellido, dni));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
        return asistenciaRepository.findAll(spec, pageable);
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

            // --- CÁLCULO DE DESCUENTOS Y BONIFICACIONES ---
            // Recuperamos el Horario Objetivo asociado a la asistencia?
            // Necesitamos saber cual era el horario original para calcular tardanzas/extras
            List<Horario> posibles = horarioRepository.findByEmpleadoIdAndFecha(idEmpleado, a.getFecha());
            Horario horarioTurno = null;
            // Buscamos colisión
            for (Horario h : posibles) {
                if (a.getHoraEntrada().isBefore(h.getHoraFin()) &&
                        Duration.between(a.getHoraEntrada(), h.getHoraInicio()).abs().toHours() <= 4) {
                    horarioTurno = h;
                    break;
                }
            }

            if (horarioTurno != null) {
                long minutosTardanza = 0;
                long minutosExtras = 0;

                // 1. Tardanza: Si entró después de la hora inicio
                if (a.getHoraEntrada().isAfter(horarioTurno.getHoraInicio())) {
                    minutosTardanza = Duration.between(horarioTurno.getHoraInicio(), a.getHoraEntrada()).toMinutes();
                    // Tolerancia 5 min opcional? No especificado, calculamos directo
                    if (minutosTardanza < 0)
                        minutosTardanza = 0;
                }

                // 2. Extras: Si salió después de la hora fin
                if (ahora.isAfter(horarioTurno.getHoraFin())) {
                    minutosExtras = Duration.between(horarioTurno.getHoraFin(), ahora).toMinutes();
                    if (minutosExtras < 0)
                        minutosExtras = 0;
                }

                // --- LÓGICA POR TIPO DE MODALIDAD ---
                // LIBRE: No genera descuentos ni bonificaciones, solo registro de horas
                // OBLIGADO / FIJO: Aplica reglas estrictas de horario
                if (a.getEmpleado().getTipoModalidad() != null &&
                        "LIBRE".equalsIgnoreCase(a.getEmpleado().getTipoModalidad())) {
                    minutosTardanza = 0;
                    minutosExtras = 0;
                }

                a.setMinutosTardanza(minutosTardanza);
                a.setMinutosExtras(minutosExtras);

                // Calculo Monetario
                // CostoMinuto = Sueldo / 30 / 8 / 60 = Sueldo / 14400
                // Asumimos 30 días, 8 horas.
                Double sueldo = a.getEmpleado().getSueldoBase();
                if (sueldo == null)
                    sueldo = 1025.00; // Default sueldo minimo

                double costoMinuto = sueldo / 30.0 / 8.0 / 60.0;

                double descuento = minutosTardanza * costoMinuto * factorDescuento;
                double bonificacion = minutosExtras * costoMinuto * factorBonificacion;

                // Redondear a 2 decimales
                a.setDineroDescuento(Math.round(descuento * 100.0) / 100.0);
                a.setDineroBonificacion(Math.round(bonificacion * 100.0) / 100.0);
            }

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
            // Refactor: Usamos la lógica estricta del reporte para determinar qué turnos
            // están REALMENTE pendientes.
            List<TurnoDTO> reporte = obtenerReporteDiario(idEmpleado);
            Horario horarioObjetivo = null;

            // 2. Buscamos el horario "objetivo" más cercano que NO haya sido marcado aún
            // Refactor: Buscar el el PENDIENTE con inicio más cercano a 'ahora'.
            TurnoDTO candidato = null;
            long minDiff = Long.MAX_VALUE;

            for (TurnoDTO t : reporte) {
                if ("PENDIENTE".equals(t.getEstado())) {
                    long diff = Duration.between(ahora, t.getHorario().getHoraInicio()).abs().toMinutes();
                    if (diff < minDiff) {
                        minDiff = diff;
                        candidato = t;
                    }
                }
            }

            if (candidato != null) {
                horarioObjetivo = candidato.getHorario();
                System.out.println("DEBUG_ASISTENCIA: Horario encontrado (Más cercano): " + horarioObjetivo.getId()
                        + " Diff: " + minDiff + "min");
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

    private Horario obtenerproximoTurnoInmediato(int idEmpleado, LocalTime ahora) {
        // Busca si hay un horario que empiece pronto (ej. en menos de 1 hora)
        // Usamos obtenerReporteDiario para saber cuales siguen pendientes
        List<TurnoDTO> reporte = obtenerReporteDiario(idEmpleado);

        for (TurnoDTO t : reporte) {
            Horario h = t.getHorario();
            // Solo nos interesan los PENDIENTES
            if ("PENDIENTE".equals(t.getEstado())) {
                if (h.getHoraInicio().isAfter(ahora)) {
                    // Si empieza dentro de los proximos 60 min
                    long minutosParaInicio = Duration.between(ahora, h.getHoraInicio()).toMinutes();
                    if (minutosParaInicio < 60) {
                        return h;
                    }
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

        // --- ALGORITMO BEST-MATCH (MEJOR AJUSTE) ---
        // Asocia asistencias a horarios minimizando la diferencia de tiempo.
        // Esto evita que un horario agregado tardíamente "robe" una asistencia de otro
        // horario.

        class MatchCandidate {
            Horario h;
            Asistencia a;
            long diffAbs;

            MatchCandidate(Horario h, Asistencia a, long diff) {
                this.h = h;
                this.a = a;
                this.diffAbs = diff;
            }
        }

        List<MatchCandidate> candidates = new ArrayList<>();

        for (Horario h : horarios) {
            for (Asistencia a : asistencias) {
                // Calc distancia en minutos
                long diff = java.time.Duration.between(h.getHoraInicio(), a.getHoraEntrada()).toMinutes();
                long absDiff = Math.abs(diff);

                // Ventana amplia de coincidencia (4 horas)
                if (absDiff <= 240) {
                    candidates.add(new MatchCandidate(h, a, absDiff));
                }
            }
        }

        // Ordenar candidatos: El de menor diferencia de tiempo va primero
        candidates.sort(Comparator.comparingLong(c -> c.diffAbs));

        java.util.Map<Integer, Asistencia> assignments = new java.util.HashMap<>();
        java.util.Set<Integer> usedAsistencias = new java.util.HashSet<>();

        for (MatchCandidate c : candidates) {
            // Greedy assignment sobre lista ordenada óptima
            if (!assignments.containsKey(c.h.getId()) && !usedAsistencias.contains(c.a.getId())) {
                assignments.put(c.h.getId(), c.a);
                usedAsistencias.add(c.a.getId());
            }
        }

        for (Horario h : horarios) {
            Asistencia asistenciaEncontrada = assignments.get(h.getId());

            String estado = "PENDIENTE";
            String mensaje = "Pendiente";
            String css = "status-pending";

            if (asistenciaEncontrada != null) {
                long diffMinutos = Duration.between(h.getHoraInicio(), asistenciaEncontrada.getHoraEntrada())
                        .toMinutes();

                if ("JUSTIFICACION".equals(asistenciaEncontrada.getModo())) {
                    estado = "JUSTIFICADA";
                    mensaje = "Falta Justificada";
                    css = "status-ontime";
                } else if (diffMinutos < -2) {
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
        // 1. Si hay turno abierto (entrada sin salida), NO ha terminado jornada (debe
        // marcar salida).
        boolean turnoAbierto = asistenciaRepository.findTopByEmpleadoIdAndHoraSalidaIsNullOrderByFechaDesc(empleadoId)
                .isPresent();
        if (turnoAbierto)
            return false;

        // 2. Reutilizamos la lógica de "Reporte Diario" para ver el estado REAL de cada
        // horario
        // Esto evita el bug donde verificarFinJornada usaba un matching "laxo" y creía
        // que
        // un turno nuevo ya estaba cubierto por una asistencia antigua cercana.
        List<TurnoDTO> turnos = obtenerReporteDiario(empleadoId);

        for (TurnoDTO t : turnos) {
            // Si hay algun turno PENDIENTE, significa que aun se puede marcar entrada
            if ("PENDIENTE".equals(t.getEstado())) {
                return false;
            }
        }

        // Si no hay pendientes (solo ASISTIDO o FALTA), entonces sí terminó jornada
        return true;
    }

    // --- Manejo de Fotos ---
    public String guardarFoto(MultipartFile foto) {
        if (foto == null || foto.isEmpty())
            return null;
        try {
            String folder = "uploads/evidencias/";
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

    public void aplicarJustificacion(Justificacion j) {
        System.out.println("DEBUG_JUSTIFICACION: --- APLICANDO JUSTIFICACION ---");
        System.out.println("DEBUG_JUSTIFICACION: Justificacion ID: " + j);
        System.out.println("DEBUG_JUSTIFICACION: Empleado ID: " + j.getEmpleado().getId());
        System.out.println("DEBUG_JUSTIFICACION: Rango: " + j.getFechaInicio() + " - " + j.getFechaFin());

        LocalDate start = j.getFechaInicio();
        LocalDate end = j.getFechaFin();

        // Loop through dates
        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
            System.out.println("DEBUG_JUSTIFICACION: Procesando fecha: " + date);
            try {
                List<Horario> horarios = horarioRepository.findByEmpleadoIdAndFecha(j.getEmpleado().getId(), date);
                System.out.println("DEBUG_JUSTIFICACION: Horarios encontrados: " + horarios.size());

                List<Asistencia> asistenciasExistentes = asistenciaRepository
                        .findByEmpleadoIdAndFecha(j.getEmpleado().getId(), date);
                System.out.println("DEBUG_JUSTIFICACION: Asistencias existentes: " + asistenciasExistentes.size());

                // --- ALGORITMO MATCHING (SIMPLIFICADO) ---
                // Mapeamos Horario -> Asistencia para asegurar 1-a-1
                java.util.Map<Integer, Asistencia> mapaAsistencia = new java.util.HashMap<>();
                java.util.Set<Integer> asistenciasUsadas = new java.util.HashSet<>();

                // 1. Encontramos mejor candidato para cada asistencia
                // (Reusamos logica de reporte para consistencia)
                for (Horario h : horarios) {
                    Asistencia mejorCandidato = null;
                    long menorDiff = Long.MAX_VALUE;

                    for (Asistencia a : asistenciasExistentes) {
                        if (asistenciasUsadas.contains(a.getId()))
                            continue;

                        // Check null safety
                        if (h.getHoraInicio() == null || a.getHoraEntrada() == null)
                            continue;

                        long diff = Duration.between(h.getHoraInicio(), a.getHoraEntrada()).abs().toMinutes();
                        if (diff < 120 && diff < menorDiff) {
                            menorDiff = diff;
                            mejorCandidato = a;
                        }
                    }

                    if (mejorCandidato != null) {
                        System.out.println("DEBUG_JUSTIFICACION: Match Horario(" + h.getId() + ") -> Asistencia("
                                + mejorCandidato.getId() + ")");
                        mapaAsistencia.put(h.getId(), mejorCandidato);
                        asistenciasUsadas.add(mejorCandidato.getId());
                    }
                }

                for (Horario h : horarios) {
                    System.out.println("DEBUG_JUSTIFICACION: Aplicando a Horario ID: " + h.getId());
                    // RELAXED RULE: If there is a justification for the day, IT APPLIES TO ALL
                    // SHIFTS.
                    boolean match = true;

                    if (match) {
                        Asistencia target = mapaAsistencia.get(h.getId());

                        if (target == null) {
                            System.out
                                    .println("DEBUG_JUSTIFICACION: Creando NUEVA Asistencia para Horario " + h.getId());
                            target = new Asistencia();
                            target.setEmpleado(j.getEmpleado());
                            target.setFecha(date);
                            // Add to map to prevent re-creation or confusion in subsequent logic if we were
                            // to loop again
                            mapaAsistencia.put(h.getId(), target);
                        } else {
                            System.out.println("DEBUG_JUSTIFICACION: Actualizando Asistencia " + target.getId());
                        }

                        // Update fields
                        target.setModo("JUSTIFICACION");
                        target.setHoraEntrada(h.getHoraInicio());
                        target.setHoraSalida(h.getHoraFin()); // Set exit time too to close it
                        target.setObservacion("Falta Justificada: " + j.getMotivo());
                        target.setDineroDescuento(0.0);
                        target.setDineroBonificacion(0.0);
                        target.setMinutosTardanza(0L);
                        target.setMinutosExtras(0L);

                        asistenciaRepository.save(target);
                        System.out.println("DEBUG_JUSTIFICACION: Guardado Exitoso.");
                    }
                }
            } catch (Exception e) {
                System.err.println("ERROR_JUSTIFICACION: Error procesando fecha " + date);
                e.printStackTrace();
            }
        }
    }

}