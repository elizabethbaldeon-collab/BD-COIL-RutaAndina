USE ruta_andina;

-- 1. Viajes finalizados por conductor en el último mes
SELECT 
    c.id_conductor,
    CONCAT(u.nombres, ' ', u.apellidos) AS conductor,
    p.nombre AS pais,
    COUNT(v.id_viaje) AS viajes_finalizados_ultimo_mes
FROM conductor c
JOIN usuario u ON c.id_usuario = u.id_usuario
JOIN pais p ON u.id_pais = p.id_pais
LEFT JOIN viaje v ON c.id_conductor = v.id_conductor 
    AND v.estado = 'finalizado' 
    AND v.fecha_fin >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY c.id_conductor, conductor, p.nombre
ORDER BY viajes_finalizados_ultimo_mes DESC;

-- 2. Ingresos de la plataforma por país y moneda
SELECT 
    p.nombre AS pais,
    pg.moneda,
    COUNT(pg.id_pago) AS total_viajes_pagados,
    SUM(pg.monto_total) AS facturacion_bruta,
    SUM(pg.comision_monto) AS ingreso_neto_plataforma
FROM pago pg
JOIN viaje v ON pg.id_viaje = v.id_viaje
JOIN pasajero pas ON v.id_pasajero = pas.id_pasajero
JOIN usuario u ON pas.id_usuario = u.id_usuario
JOIN pais p ON u.id_pais = p.id_pais
WHERE pg.estado = 'procesado'
GROUP BY p.nombre, pg.moneda;

-- 3. Top 5 conductores por calificación promedio (mínimo 5 viajes finalizados)
SELECT 
    c.id_conductor,
    CONCAT(u.nombres, ' ', u.apellidos) AS conductor,
    COUNT(DISTINCT v.id_viaje) AS total_viajes,
    ROUND(AVG(cal.puntaje), 2) AS calificacion_promedio
FROM conductor c
JOIN usuario u ON c.id_usuario = u.id_usuario
JOIN viaje v ON c.id_conductor = v.id_conductor AND v.estado = 'finalizado'
JOIN calificacion cal ON v.id_viaje = cal.id_viaje AND cal.tipo = 'pasajero_a_conductor'
GROUP BY c.id_conductor, conductor
HAVING COUNT(DISTINCT v.id_viaje) >= 5
ORDER BY calificacion_promedio DESC
LIMIT 5;

-- 4. Consumo mensual de cada empresa cliente
SELECT 
    e.razon_social AS empresa_cliente,
    v.moneda,
    YEAR(v.fecha_fin) AS anio,
    MONTH(v.fecha_fin) AS mes,
    COUNT(v.id_viaje) AS viajes_corporativos,
    SUM(pg.monto_total) AS consumo_total
FROM empresa e
JOIN viaje v ON e.id_empresa = v.id_empresa AND v.es_corporativo = TRUE AND v.estado = 'finalizado'
JOIN pago pg ON v.id_viaje = pg.id_viaje
WHERE e.tipo = 'cliente_corporativo'
GROUP BY e.razon_social, v.moneda, anio, mes
ORDER BY anio DESC, mes DESC, consumo_total DESC;

-- 5. Conductores con licencia o seguro que vence en los próximos 30 días
SELECT 
    c.id_conductor,
    CONCAT(u.nombres, ' ', u.apellidos) AS conductor,
    u.telefono,
    l.numero_licencia,
    l.fecha_vencimiento AS vence_licencia,
    veh.placa,
    veh.fecha_vencimiento_seguro AS vence_seguro
FROM conductor c
JOIN usuario u ON c.id_usuario = u.id_usuario
JOIN licencia l ON c.id_conductor = l.id_conductor
JOIN conductor_vehiculo cv ON c.id_conductor = cv.id_conductor AND cv.es_activo = TRUE
JOIN vehiculo veh ON cv.id_vehiculo = veh.id_vehiculo
WHERE l.fecha_vencimiento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
   OR veh.fecha_vencimiento_seguro BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- 6. Tasa de cancelación por tipo de servicio
SELECT 
    tipo_servicio,
    COUNT(id_viaje) AS total_viajes,
    SUM(CASE WHEN estado = 'cancelado' THEN 1 ELSE 0 END) AS viajes_cancelados,
    ROUND((SUM(CASE WHEN estado = 'cancelado' THEN 1 ELSE 0 END) / COUNT(id_viaje)) * 100, 2) AS tasa_cancelacion_pct
FROM viaje
GROUP BY tipo_servicio;

-- 7. Pasajeros que nunca calificaron un viaje
SELECT 
    pas.id_pasajero,
    CONCAT(u.nombres, ' ', u.apellidos) AS pasajero,
    u.correo,
    COUNT(v.id_viaje) AS viajes_realizados
FROM pasajero pas
JOIN usuario u ON pas.id_usuario = u.id_usuario
LEFT JOIN viaje v ON pas.id_pasajero = v.id_pasajero AND v.estado = 'finalizado'
LEFT JOIN calificacion cal ON v.id_viaje = cal.id_viaje AND cal.tipo = 'pasajero_a_conductor'
WHERE cal.id_calificacion IS NULL
GROUP BY pas.id_pasajero, pasajero, u.correo;

-- 8. Vista (VIEW) con el resumen del viaje para el pasajero
CREATE OR REPLACE VIEW vw_resumen_viaje_pasajero AS
SELECT 
    v.id_viaje,
    CONCAT(up.nombres, ' ', up.apellidos) AS pasajero,
    CONCAT(uc.nombres, ' ', uc.apellidos) AS conductor,
    veh.placa AS placa_vehiculo,
    CONCAT(veh.marca, ' ', veh.modelo, ' (', veh.color, ')') AS detalle_vehiculo,
    v.tipo_servicio,
    v.origen_direccion,
    v.destino_direccion,
    v.fecha_solicitud,
    v.fecha_fin,
    v.distancia_km,
    v.tarifa,
    v.moneda,
    v.estado AS estado_viaje,
    IF(v.es_corporativo, 'Corporativo', 'Personal') AS modalidad
FROM viaje v
JOIN pasajero pas ON v.id_pasajero = pas.id_pasajero
JOIN usuario up ON pas.id_usuario = up.id_usuario
LEFT JOIN conductor c ON v.id_conductor = c.id_conductor
LEFT JOIN usuario uc ON c.id_usuario = uc.id_usuario
LEFT JOIN vehiculo veh ON v.id_vehiculo = veh.id_vehiculo;

-- Prueba de la vista:
SELECT * FROM vw_resumen_viaje_pasajero LIMIT 10;