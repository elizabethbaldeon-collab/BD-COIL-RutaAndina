DROP DATABASE IF EXISTS ruta_andina;
CREATE DATABASE ruta_andina CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ruta_andina;

-- 1. PAIS
CREATE TABLE pais (
    id_pais INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    codigo_iso CHAR(3) NOT NULL UNIQUE,
    moneda CHAR(3) NOT NULL,
    prefijo_tel VARCHAR(5) NOT NULL,
    CONSTRAINT chk_pais_moneda CHECK (moneda IN ('PEN', 'COP'))
);

-- 2. EMPRESA
CREATE TABLE empresa (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    ruc_nit VARCHAR(20) NOT NULL UNIQUE,
    razon_social VARCHAR(150) NOT NULL,
    tipo ENUM('operadora', 'cliente_corporativo', 'flota') NOT NULL,
    id_pais INT NOT NULL,
    direccion VARCHAR(200) NULL,
    telefono_contacto VARCHAR(20) NOT NULL,
    correo_contacto VARCHAR(150) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_empresa_pais FOREIGN KEY (id_pais) REFERENCES pais(id_pais)
);

-- 3. USUARIO (Superentidad)
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    numero_documento VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    id_pais INT NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_usuario_pais FOREIGN KEY (id_pais) REFERENCES pais(id_pais),
    CONSTRAINT chk_tipo_doc CHECK (tipo_documento IN ('DNI', 'CE', 'CC', 'TI', 'Pasaporte'))
);

-- 4. PASAJERO
CREATE TABLE pasajero (
    id_pasajero INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    id_empresa INT NULL,
    perfil_corporativo BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_pasajero_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_pasajero_empresa FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa)
);

-- 5. CONDUCTORTables
CREATE TABLE conductor (
    id_conductor INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    estado ENUM('activo', 'suspendido', 'en_revision') NOT NULL DEFAULT 'en_revision',
    cuenta_banco VARCHAR(30) NOT NULL,
    banco VARCHAR(50) NOT NULL,
    id_empresa_flota INT NULL,
    CONSTRAINT fk_conductor_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_conductor_empresa FOREIGN KEY (id_empresa_flota) REFERENCES empresa(id_empresa)
);

-- 6. LICENCIA
CREATE TABLE licencia (
    id_licencia INT AUTO_INCREMENT PRIMARY KEY,
    id_conductor INT NOT NULL UNIQUE,
    numero_licencia VARCHAR(30) NOT NULL UNIQUE,
    categoria VARCHAR(10) NOT NULL,
    fecha_expedicion DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    CONSTRAINT fk_licencia_conductor FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor) ON DELETE CASCADE
);

-- 7. VEHICULO
CREATE TABLE vehiculo (
    id_vehiculo INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INT NOT NULL,
    color VARCHAR(30) NOT NULL,
    tipo_servicio ENUM('economico', 'confort', 'XL') NOT NULL,
    id_empresa_flota INT NULL,
    numero_seguro VARCHAR(30) NOT NULL UNIQUE,
    fecha_vencimiento_seguro DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_vehiculo_empresa FOREIGN KEY (id_empresa_flota) REFERENCES empresa(id_empresa),
    CONSTRAINT chk_vehiculo_anio CHECK (anio >= 2000)
);

-- 8. CONDUCTOR_VEHICULO (Solo 1 vehículo activo a la vez por conductor)
CREATE TABLE conductor_vehiculo (
    id_conductor_vehiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_conductor INT NOT NULL,
    id_vehiculo INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    es_activo BOOLEAN NOT NULL DEFAULT FALSE,
    conductor_activo_unico INT AS (IF(es_activo = TRUE, id_conductor, NULL)) STORED UNIQUE,
    CONSTRAINT fk_cv_conductor FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor),
    CONSTRAINT fk_cv_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo)
);

-- 9. METODO_PAGO
CREATE TABLE metodo_pago (
    id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_pasajero INT NOT NULL,
    tipo ENUM('tarjeta_credito', 'tarjeta_debito', 'efectivo', 'billetera_digital') NOT NULL,
    detalle VARCHAR(100) NULL,
    es_predeterminado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_registro DATE NOT NULL,
    CONSTRAINT fk_mp_pasajero FOREIGN KEY (id_pasajero) REFERENCES pasajero(id_pasajero) ON DELETE CASCADE
);

-- 10. DIRECCION_FAVORITA
CREATE TABLE direccion_favorita (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    id_pasajero INT NOT NULL,
    etiqueta VARCHAR(50) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    latitud DECIMAL(10,7) NULL,
    longitud DECIMAL(10,7) NULL,
    CONSTRAINT fk_dir_pasajero FOREIGN KEY (id_pasajero) REFERENCES pasajero(id_pasajero) ON DELETE CASCADE
);

-- 11. VIAJE
CREATE TABLE viaje (
    id_viaje INT AUTO_INCREMENT PRIMARY KEY,
    id_pasajero INT NOT NULL,
    id_conductor INT NULL,
    id_vehiculo INT NULL,
    origen_direccion VARCHAR(200) NOT NULL,
    origen_latitud DECIMAL(10,7) NULL,
    origen_longitud DECIMAL(10,7) NULL,
    destino_direccion VARCHAR(200) NOT NULL,
    destino_latitud DECIMAL(10,7) NULL,
    destino_longitud DECIMAL(10,7) NULL,
    fecha_solicitud DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_inicio DATETIME NULL,
    fecha_fin DATETIME NULL,
    distancia_km DECIMAL(8,2) NULL,
    tarifa DECIMAL(12,2) NULL,
    moneda CHAR(3) NOT NULL,
    tipo_servicio ENUM('economico', 'confort', 'XL') NOT NULL,
    estado ENUM('solicitado', 'aceptado', 'en_curso', 'finalizado', 'cancelado') NOT NULL DEFAULT 'solicitado',
    es_corporativo BOOLEAN NOT NULL DEFAULT FALSE,
    id_empresa INT NULL,
    CONSTRAINT fk_viaje_pasajero FOREIGN KEY (id_pasajero) REFERENCES pasajero(id_pasajero),
    CONSTRAINT fk_viaje_conductor FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor),
    CONSTRAINT fk_viaje_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo),
    CONSTRAINT fk_viaje_empresa FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa),
    CONSTRAINT chk_viaje_moneda CHECK (moneda IN ('PEN', 'COP'))
);

-- 12. HISTORIAL_ESTADO_VIAJE
CREATE TABLE historial_estado_viaje (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_viaje INT NOT NULL,
    estado_anterior ENUM('solicitado', 'aceptado', 'en_curso', 'finalizado', 'cancelado') NULL,
    estado_nuevo ENUM('solicitado', 'aceptado', 'en_curso', 'finalizado', 'cancelado') NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacion VARCHAR(255) NULL,
    CONSTRAINT fk_hist_viaje FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje) ON DELETE CASCADE
);

-- 13. PAGO
CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_viaje INT NOT NULL UNIQUE,
    monto_total DECIMAL(12,2) NOT NULL,
    moneda CHAR(3) NOT NULL,
    id_metodo_pago INT NOT NULL,
    fecha_pago DATETIME NOT NULL,
    estado ENUM('pendiente', 'procesado', 'reembolsado', 'fallido') NOT NULL DEFAULT 'pendiente',
    comision_porcentaje DECIMAL(5,2) NOT NULL,
    comision_monto DECIMAL(12,2) NOT NULL,
    monto_conductor DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_pago_viaje FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje),
    CONSTRAINT fk_pago_metodo FOREIGN KEY (id_metodo_pago) REFERENCES metodo_pago(id_metodo_pago),
    CONSTRAINT chk_pago_moneda CHECK (moneda IN ('PEN', 'COP'))
);

-- 14. CALIFICACION
CREATE TABLE calificacion (
    id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_viaje INT NOT NULL,
    tipo ENUM('pasajero_a_conductor', 'conductor_a_pasajero') NOT NULL,
    puntaje TINYINT NOT NULL,
    comentario VARCHAR(500) NULL,
    fecha_calificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (id_viaje, tipo),
    CONSTRAINT fk_calif_viaje FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje),
    CONSTRAINT chk_calif_puntaje CHECK (puntaje BETWEEN 1 AND 5)
);