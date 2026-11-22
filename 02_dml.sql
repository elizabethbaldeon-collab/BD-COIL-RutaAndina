USE ruta_andina;

-- 1. PAISES
INSERT INTO pais (nombre, codigo_iso, moneda, prefijo_tel) VALUES
('Perú', 'PER', 'PEN', '+51'),
('Colombia', 'COL', 'COP', '+57');

-- 2. EMPRESAS (4 empresas: operadora, 2 clientes corporativos, 1 flota)
INSERT INTO empresa (ruc_nit, razon_social, tipo, id_pais, direccion, telefono_contacto, correo_contacto) VALUES
('20601234561', 'RutaAndina Operaciones SAC', 'operadora', 1, 'Av. Javier Prado 1200, Lima', '999000111', 'admin@rutaandina.com'),
('20509876543', 'Minera Sur Perú S.A.', 'cliente_corporativo', 1, 'Av. El Derby 250, Surco, Lima', '014445566', 'facturacion@minerasur.pe'),
('900123456-7', 'TechBogotá Consultores SAS', 'cliente_corporativo', 2, 'Cra 7 #71-21, Bogotá', '6013334455', 'cuentas@techbogota.co'),
('900987654-1', 'Flota Express Bogotá SAS', 'flota', 2, 'Calle 80 #45-10, Bogotá', '6017778899', 'flota@expressbogota.co');

-- 3. USUARIOS (30 usuarios: 1..20 serán pasajeros, 21..30 serán conductores)
INSERT INTO usuario (nombres, apellidos, tipo_documento, numero_documento, telefono, correo, contrasena_hash, id_pais) VALUES
-- Pasajeros Perú (1..10)
('Carlos', 'Mendoza', 'DNI', '45123401', '987654301', 'carlos.mendoza@mail.pe', 'hash_pw_01', 1),
('Lucía', 'Quispe', 'DNI', '45123402', '987654302', 'lucia.quispe@mail.pe', 'hash_pw_02', 1),
('Jorge', 'Salazar', 'DNI', '45123403', '987654303', 'jorge.salazar@mail.pe', 'hash_pw_03', 1),
('María', 'Torres', 'DNI', '45123404', '987654304', 'maria.torres@mail.pe', 'hash_pw_04', 1),
('Diego', 'Vargas', 'DNI', '45123405', '987654305', 'diego.vargas@mail.pe', 'hash_pw_05', 1),
('Ana', 'Rojas', 'DNI', '45123406', '987654306', 'ana.rojas@mail.pe', 'hash_pw_06', 1),
('Luis', 'Paredes', 'DNI', '45123407', '987654307', 'luis.paredes@mail.pe', 'hash_pw_07', 1),
('Sofía', 'Castro', 'DNI', '45123408', '987654308', 'sofia.castro@mail.pe', 'hash_pw_08', 1),
('Pedro', 'Huamán', 'DNI', '45123409', '987654309', 'pedro.huaman@mail.pe', 'hash_pw_09', 1),
('Elena', 'Flores', 'DNI', '45123410', '987654310', 'elena.flores@mail.pe', 'hash_pw_10', 1),
-- Pasajeros Colombia (11..20)
('Andrés', 'Gómez', 'CC', '1010203001', '3102003001', 'andres.gomez@mail.co', 'hash_pw_11', 2),
('Camila', 'Rodríguez', 'CC', '1010203002', '3102003002', 'camila.rod@mail.co', 'hash_pw_12', 2),
('Sebastián', 'López', 'CC', '1010203003', '3102003003', 'sebastian.lopez@mail.co', 'hash_pw_13', 2),
('Valentina', 'Martínez', 'CC', '1010203004', '3102003004', 'valentina.m@mail.co', 'hash_pw_14', 2),
('Mateo', 'Hernández', 'CC', '1010203005', '3102003005', 'mateo.h@mail.co', 'hash_pw_15', 2),
('Isabella', 'García', 'CC', '1010203006', '3102003006', 'isabella.g@mail.co', 'hash_pw_16', 2),
('Santiago', 'Díaz', 'CC', '1010203007', '3102003007', 'santiago.diaz@mail.co', 'hash_pw_17', 2),
('Daniela', 'Moreno', 'CC', '1010203008', '3102003008', 'daniela.moreno@mail.co', 'hash_pw_18', 2),
('Nicolás', 'Álvarez', 'CC', '1010203009', '3102003009', 'nicolas.a@mail.co', 'hash_pw_19', 2),
('Paula', 'Jiménez', 'CC', '1010203010', '3102003010', 'paula.jimenez@mail.co', 'hash_pw_20', 2),
-- Conductores Perú (21..25)
('Marco', 'Chávez', 'DNI', '70112201', '991122001', 'marco.cond@mail.pe', 'hash_pw_21', 1),
('Raúl', 'Espinoza', 'DNI', '70112202', '991122002', 'raul.cond@mail.pe', 'hash_pw_22', 1),
('Javier', 'Ramos', 'DNI', '70112203', '991122003', 'javier.cond@mail.pe', 'hash_pw_23', 1),
('Héctor', 'Silva', 'DNI', '70112204', '991122004', 'hector.cond@mail.pe', 'hash_pw_24', 1),
('Óscar', 'Núñez', 'DNI', '70112205', '991122005', 'oscar.cond@mail.pe', 'hash_pw_25', 1),
-- Conductores Colombia (26..30)
('Camilo', 'Restrepo', 'CC', '80112206', '3201122006', 'camilo.cond@mail.co', 'hash_pw_26', 2),
('Felipe', 'Ospina', 'CC', '80112207', '3201122007', 'felipe.cond@mail.co', 'hash_pw_27', 2),
('Jhon', 'Cardona', 'CC', '80112208', '3201122008', 'jhon.cond@mail.co', 'hash_pw_28', 2),
('Mauricio', 'Mejía', 'CC', '80112209', '3201122009', 'mauricio.cond@mail.co', 'hash_pw_29', 2),
('Julián', 'Ríos', 'CC', '80112210', '3201122010', 'julian.cond@mail.co', 'hash_pw_30', 2);

-- 4. PASAJEROS (20 registros)
INSERT INTO pasajero (id_usuario, id_empresa, perfil_corporativo) VALUES
(1, 2, TRUE), (2, 2, TRUE), (3, NULL, FALSE), (4, NULL, FALSE), (5, 2, TRUE),
(6, NULL, FALSE), (7, NULL, FALSE), (8, NULL, FALSE), (9, 2, TRUE), (10, NULL, FALSE),
(11, 3, TRUE), (12, 3, TRUE), (13, NULL, FALSE), (14, NULL, FALSE), (15, 3, TRUE),
(16, NULL, FALSE), (17, NULL, FALSE), (18, NULL, FALSE), (19, 3, TRUE), (20, NULL, FALSE);

-- Métodos de pago y direcciones favoritas para los 20 pasajeros
INSERT INTO metodo_pago (id_pasajero, tipo, detalle, es_predeterminado, fecha_registro)
SELECT id_pasajero, 'tarjeta_credito', CONCAT('VISA **** ', 1000 + id_pasajero), TRUE, CURDATE() FROM pasajero;

INSERT INTO direccion_favorita (id_pasajero, etiqueta, direccion, latitud, longitud)
SELECT id_pasajero, 'Casa', CONCAT('Calle Los Olivos ', id_pasajero * 15), -12.0850000, -77.0350000 FROM pasajero;

-- 5. CONDUCTORES Y LICENCIAS (10 registros)
INSERT INTO conductor (id_usuario, estado, cuenta_banco, banco, id_empresa_flota) VALUES
(21, 'activo', '191-0001001', 'BCP', NULL),
(22, 'activo', '0011-002002', 'BBVA Perú', NULL),
(23, 'activo', '200-3003003', 'Interbank', NULL),
(24, 'activo', '191-0004004', 'BCP', NULL),
(25, 'activo', '0011-005005', 'BBVA Perú', NULL),
(26, 'activo', '5001-998801', 'Bancolombia', 4),
(27, 'activo', '6002-998802', 'Davivienda', 4),
(28, 'activo', '5003-998803', 'Bancolombia', 4),
(29, 'activo', '7004-998804', 'BBVA Colombia', NULL),
(30, 'activo', '5005-998805', 'Bancolombia', NULL);

-- Licencias (Conductores 2 y 7 vencen en menos de 30 días para probar alerta)
INSERT INTO licencia (id_conductor, numero_licencia, categoria, fecha_expedicion, fecha_vencimiento) VALUES
(1, 'Q70112201', 'A-IIb', '2023-05-10', '2028-05-10'),
(2, 'Q70112202', 'A-IIa', '2021-12-05', DATE_ADD(CURDATE(), INTERVAL 15 DAY)),
(3, 'Q70112203', 'A-IIb', '2022-11-20', '2027-11-20'),
(4, 'Q70112204', 'A-IIIa', '2023-01-15', '2028-01-15'),
(5, 'Q70112205', 'A-IIa', '2022-08-30', '2027-08-30'),
(6, 'C80112206', 'C1', '2023-03-12', '2028-03-12'),
(7, 'C80112207', 'C1', '2021-12-12', DATE_ADD(CURDATE(), INTERVAL 22 DAY)),
(8, 'C80112208', 'C2', '2022-12-01', '2027-12-01'),
(9, 'C80112209', 'C1', '2023-07-19', '2028-07-19'),
(10, 'C80112210', 'C1', '2022-09-25', '2027-09-25');

-- 6. VEHICULOS Y ASIGNACIONES (10 vehículos; vehículo 4 vence seguro en 10 días)
INSERT INTO vehiculo (placa, marca, modelo, anio, color, tipo_servicio, id_empresa_flota, numero_seguro, fecha_vencimiento_seguro) VALUES
('ABC-101', 'Toyota', 'Yaris', 2022, 'Gris', 'economico', NULL, 'SOAT-PE-001', '2027-06-15'),
('ABC-102', 'Hyundai', 'Elantra', 2023, 'Negro', 'confort', NULL, 'SOAT-PE-002', '2027-09-10'),
('ABC-103', 'Kia', 'Sportage', 2022, 'Blanco', 'XL', NULL, 'SOAT-PE-003', '2027-04-20'),
('ABC-104', 'Nissan', 'Versa', 2021, 'Plata', 'economico', NULL, 'SOAT-PE-004', DATE_ADD(CURDATE(), INTERVAL 10 DAY)),
('ABC-105', 'Toyota', 'Corolla', 2023, 'Azul', 'confort', NULL, 'SOAT-PE-005', '2027-10-05'),
('BOG-201', 'Chevrolet', 'Onix', 2022, 'Blanco', 'economico', 4, 'SOAT-CO-006', '2027-07-12'),
('BOG-202', 'Mazda', '3', 2023, 'Rojo', 'confort', 4, 'SOAT-CO-007', '2027-11-30'),
('BOG-203', 'Renault', 'Duster', 2022, 'Gris', 'XL', 4, 'SOAT-CO-008', '2027-05-18'),
('BOG-204', 'Kia', 'Picanto', 2021, 'Amarillo', 'economico', NULL, 'SOAT-CO-009', '2027-08-22'),
('BOG-205', 'Volkswagen', 'Jetta', 2023, 'Negro', 'confort', NULL, 'SOAT-CO-010', '2027-12-14');

INSERT INTO conductor_vehiculo (id_conductor, id_vehiculo, fecha_asignacion, es_activo) VALUES
(1,1,'2025-01-10',TRUE),(2,2,'2025-01-12',TRUE),(3,3,'2025-02-01',TRUE),(4,4,'2025-02-15',TRUE),(5,5,'2025-03-01',TRUE),
(6,6,'2025-01-20',TRUE),(7,7,'2025-02-10',TRUE),(8,8,'2025-02-18',TRUE),(9,9,'2025-03-05',TRUE),(10,10,'2025-03-10',TRUE);

-- 7. PROCEDIMIENTO PARA GENERAR 50 VIAJES, HISTORIAL, PAGOS Y CALIFICACIONES
DELIMITER //
CREATE PROCEDURE poblar_viajes_prueba()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_pasajero INT;
    DECLARE v_conductor INT;
    DECLARE v_servicio VARCHAR(20);
    DECLARE v_es_corp BOOLEAN;
    DECLARE v_empresa INT;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_dist DECIMAL(8,2);
    DECLARE v_tarifa DECIMAL(12,2);
    DECLARE v_comision DECIMAL(12,2);
    DECLARE v_moneda CHAR(3);
    DECLARE v_fecha DATETIME;
    
    WHILE i <= 50 DO
        IF i <= 25 THEN
            SET v_pasajero = ((i - 1) MOD 10) + 1;
            SET v_conductor = ((i - 1) MOD 5) + 1;
            SET v_moneda = 'PEN';
            SET v_dist = 4.5 + (i MOD 12);
            SET v_tarifa = ROUND(6.00 + (v_dist * 2.00), 2);
            SET v_empresa = IF(v_pasajero IN (1, 2, 5, 9) AND (i MOD 2 = 0), 2, NULL);
        ELSE
            SET v_pasajero = ((i - 1) MOD 10) + 11;
            SET v_conductor = ((i - 1) MOD 5) + 6;
            SET v_moneda = 'COP';
            SET v_dist = 5.0 + (i MOD 15);
            SET v_tarifa = ROUND(6500 + (v_dist * 2100), 2);
            SET v_empresa = IF(v_pasajero IN (11, 12, 15, 19) AND (i MOD 2 = 0), 3, NULL);
        END IF;

        SET v_es_corp = IF(v_empresa IS NOT NULL, TRUE, FALSE);
        SET v_servicio = ELT(((i - 1) MOD 3) + 1, 'economico', 'confort', 'XL');
        SET v_estado = IF(i MOD 6 = 0, 'cancelado', 'finalizado');
        SET v_fecha = DATE_SUB(NOW(), INTERVAL (50 - i) DAY);

        INSERT INTO viaje (id_pasajero, id_conductor, id_vehiculo, origen_direccion, destino_direccion, fecha_solicitud, fecha_inicio, fecha_fin, distancia_km, tarifa, moneda, tipo_servicio, estado, es_corporativo, id_empresa)
        VALUES (
            v_pasajero, v_conductor, v_conductor,
            CONCAT('Av. Principal #', i * 10), CONCAT('Centro Empresarial Torre ', i),
            v_fecha,
            IF(v_estado = 'finalizado', DATE_ADD(v_fecha, INTERVAL 5 MINUTE), NULL),
            IF(v_estado = 'finalizado', DATE_ADD(v_fecha, INTERVAL 25 MINUTE), NULL),
            v_dist, v_tarifa, v_moneda, v_servicio, v_estado, v_es_corp, v_empresa
        );

        INSERT INTO historial_estado_viaje (id_viaje, estado_anterior, estado_nuevo, fecha_cambio, observacion)
        VALUES (i, 'solicitado', v_estado, v_fecha, 'Registro automático de prueba');

        IF v_estado = 'finalizado' THEN
            SET v_comision = ROUND(v_tarifa * 0.15, 2);
            INSERT INTO pago (id_viaje, monto_total, moneda, id_metodo_pago, fecha_pago, estado, comision_porcentaje, comision_monto, monto_conductor)
            VALUES (i, v_tarifa, v_moneda, v_pasajero, DATE_ADD(v_fecha, INTERVAL 26 MINUTE), 'procesado', 15.00, v_comision, v_tarifa - v_comision);

            -- Pasajeros 3 y 13 nunca califican (para probar consulta #7)
            IF v_pasajero NOT IN (3, 13) THEN
                INSERT INTO calificacion (id_viaje, tipo, puntaje, comentario)
                VALUES (i, 'pasajero_a_conductor', IF(v_conductor IN (1, 6, 8), 5, 4), 'Buen servicio');
            END IF;

            INSERT INTO calificacion (id_viaje, tipo, puntaje, comentario)
            VALUES (i, 'conductor_a_pasajero', 5, 'Pasajero puntual');
        END IF;

        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL poblar_viajes_prueba();
DROP PROCEDURE poblar_viajes_prueba;