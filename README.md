# Prototipo App de Taxi (Flask + MySQL)

1. Corre `01_ddl.sql` y `02_dml.sql` en MySQL (debe haber al menos un país en la tabla pais).
2. `pip install -r requirements.txt`
3. Ajusta la conexión en `app.py` (`DB_CONFIG`; la base por defecto es `ruta_andina`) o usa variables de entorno: DB_HOST, DB_USER, DB_PASSWORD, DB_NAME.
4. `python app.py` y abre http://127.0.0.1:5000

Si un ENUM falla, revisa las listas al inicio de `app.py` (TIPOS_SERVICIO, etc.): deben escribirse igual que en tu 01_ddl.sql (sin tildes ni espacios, p. ej. 'economico', 'en_curso').

## Prueba rápida (registrar y consultar)
1. Empresa → registra una empresa (flota o cliente corporativo).
2. Pasajero → registra un pasajero → elígelo → pide un viaje.
3. Conductor → registra un conductor → elígelo → registra un vehículo → acepta el viaje → inicia → finaliza.
4. Vuelve a Pasajero: el viaje aparece con estado y conductor. Revisa en MySQL: usuario, viaje, historial_estado_viaje.
