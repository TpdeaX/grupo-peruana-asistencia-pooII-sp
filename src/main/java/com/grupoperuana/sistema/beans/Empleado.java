package com.grupoperuana.sistema.beans;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "empleados")
public class Empleado {
    // private static final long serialVersionUID = 1L; // Not strictly needed for
    // JPA unless Serializable

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false, length = 100)
    private String nombres;

    @Column(nullable = false, length = 100)
    private String apellidos;

    @Column(nullable = false, length = 15, unique = true)
    private String dni;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, length = 20)
    private String rol;

    @Column(columnDefinition = "tinyint(1) default 1")
    private int estado;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Timestamp createdAt;

    public Empleado() {
    }

    public Empleado(int id, String nombres, String apellidos, String dni, String rol) {
        this.id = id;
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.dni = dni;
        this.rol = rol;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public int getEstado() {
        return estado;
    }

    public void setEstado(int estado) {
        this.estado = estado;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getNombreCompleto() {
        return nombres + " " + apellidos;
    }
}
