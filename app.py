"""Prototipo App de Taxi - Flask + MySQL.

Pantallas: pasajero, conductor y empresa.
Ejecutar:  python app.py   ->  http://127.0.0.1:5000
"""
import os

import mysql.connector
from flask import Flask, flash, redirect, render_template, request, url_for
from werkzeug.security import generate_password_hash

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "prototipo-taxi")

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", "123456"),
    "database": os.getenv("DB_NAME", "ruta_andina"),
}

TIPOS_SERVICIO = ["economico", "confort", "XL"]
TIPOS_DOCUMENTO = ["CC", "CE", "TI", "DNI", "Pasaporte"]
TIPOS_EMPRESA = ["operadora", "cliente_corporativo", "flota"]
BANCOS_DEFAULT = "Bancolombia"


def get_conn():
    return mysql.connector.connect(**DB_CONFIG)


def consultar(sql, params=(), uno=False):
    """SELECT -> lista de dicts (o un dict si uno=True)."""
    conn = get_conn()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params)
        filas = cur.fetchall()
        return (filas[0] if filas else None) if uno else filas
    finally:
        conn.close()


def ejecutar(sql, params=()):
    """INSERT/UPDATE de una sentencia -> id insertado."""
    conn = get_conn()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        conn.commit()
        return cur.lastrowid
    finally:
        conn.close()


def a_nulo(valor):
    valor = (valor or "").strip()
    return valor or None


def crear_usuario(cur, f):
    cur.execute(
        """INSERT INTO usuario (nombres, apellidos, tipo_documento, numero_documento,
                                telefono, correo, contrasena_hash, id_pais)
           VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
        (f["nombres"].strip(), f["apellidos"].strip(), f["tipo_documento"],
         f["numero_documento"].strip(), f["telefono"].strip(), f["correo"].strip(),
         generate_password_hash(f["contrasena"]), f["id_pais"]),
    )
    return cur.lastrowid


def con_transaccion(funcion, mensaje_ok):
    """Ejecuta funcion(cur) en una transacción y muestra el resultado."""
    conn = None
    try:
        conn = get_conn()
        cur = conn.cursor()
        funcion(cur)
        conn.commit()
        flash(mensaje_ok, "ok")
    except mysql.connector.Error as e:
        if conn:
            conn.rollback()
        if e.errno == 1062:
            flash("Ya existe un registro con ese documento, correo, placa o NIT.", "error")
        else:
            flash(f"No se pudo guardar: {e.msg}", "error")
    finally:
        if conn:
            conn.close()


def paises():
    return consultar("SELECT id_pais, nombre, moneda FROM pais ORDER BY nombre")


def empresas(tipo=None):
    if tipo:
        return consultar("SELECT id_empresa, razon_social FROM empresa WHERE tipo=%s AND activo=TRUE "
                         "ORDER BY razon_social", (tipo,))
    return consultar("SELECT id_empresa, razon_social FROM empresa WHERE activo=TRUE ORDER BY razon_social")


def registrar_estado(cur, id_viaje, anterior, nuevo, obs=None):
    cur.execute(
        "INSERT INTO historial_estado_viaje (id_viaje, estado_anterior, estado_nuevo, observacion) "
        "VALUES (%s,%s,%s,%s)", (id_viaje, anterior, nuevo, obs))


@app.errorhandler(mysql.connector.Error)
def error_bd(e):
    return render_template("error.html", detalle=str(e)), 500


@app.route("/")
def inicio():
    return render_template("index.html")


@app.route("/pasajero")
def pasajero():
    pasajeros = consultar(
        """SELECT p.id_pasajero, CONCAT(u.nombres,' ',u.apellidos) AS nombre
           FROM pasajero p JOIN usuario u ON u.id_usuario = p.id_usuario ORDER BY u.nombres""")
    id_sel = request.args.get("id", type=int)
    viajes = []
    if id_sel:
        viajes = consultar(
            """SELECT v.id_viaje, v.origen_direccion, v.destino_direccion, v.tipo_servicio,
                      v.estado, v.fecha_solicitud, v.tarifa, v.moneda,
                      CONCAT(uc.nombres,' ',uc.apellidos) AS conductor
               FROM viaje v
               LEFT JOIN conductor c ON c.id_conductor = v.id_conductor
               LEFT JOIN usuario uc ON uc.id_usuario = c.id_usuario
               WHERE v.id_pasajero=%s ORDER BY v.fecha_solicitud DESC""", (id_sel,))
    return render_template("pasajero.html", pasajeros=pasajeros, id_sel=id_sel, viajes=viajes,
                           paises=paises(), empresas=empresas("cliente_corporativo"),
                           tipos_doc=TIPOS_DOCUMENTO, servicios=TIPOS_SERVICIO)


@app.post("/pasajero/registrar")
def pasajero_registrar():
    f = request.form

    def op(cur):
        id_usuario = crear_usuario(cur, f)
        id_empresa = a_nulo(f.get("id_empresa"))
        cur.execute("INSERT INTO pasajero (id_usuario, id_empresa, perfil_corporativo) VALUES (%s,%s,%s)",
                    (id_usuario, id_empresa, bool(id_empresa)))
    con_transaccion(op, "Pasajero registrado.")
    return redirect(url_for("pasajero"))


@app.post("/pasajero/viaje")
def pasajero_viaje():
    f = request.form
    id_pasajero = int(f["id_pasajero"])
    datos = consultar(
        """SELECT pa.moneda, p.id_empresa FROM pasajero p
           JOIN usuario u ON u.id_usuario = p.id_usuario JOIN pais pa ON pa.id_pais = u.id_pais
           WHERE p.id_pasajero=%s""", (id_pasajero,), uno=True)

    def op(cur):
        id_empresa = datos["id_empresa"]
        cur.execute(
            """INSERT INTO viaje (id_pasajero, origen_direccion, destino_direccion, moneda,
                                  tipo_servicio, es_corporativo, id_empresa)
               VALUES (%s,%s,%s,%s,%s,%s,%s)""",
            (id_pasajero, f["origen"].strip(), f["destino"].strip(), datos["moneda"],
             f["tipo_servicio"], bool(id_empresa), id_empresa))
        registrar_estado(cur, cur.lastrowid, None, "solicitado", "Viaje solicitado")
    con_transaccion(op, "Viaje solicitado. Un conductor puede aceptarlo.")
    return redirect(url_for("pasajero", id=id_pasajero))


@app.route("/conductor")
def conductor():
    conductores = consultar(
        """SELECT c.id_conductor, CONCAT(u.nombres,' ',u.apellidos) AS nombre
           FROM conductor c JOIN usuario u ON u.id_usuario = c.id_usuario ORDER BY u.nombres""")
    id_sel = request.args.get("id", type=int)
    disponibles = consultar(
        """SELECT id_viaje, origen_direccion, destino_direccion, tipo_servicio, fecha_solicitud
           FROM viaje WHERE estado='solicitado' ORDER BY fecha_solicitud""")
    mis_viajes, vehiculos = [], []
    if id_sel:
        mis_viajes = consultar(
            """SELECT id_viaje, origen_direccion, destino_direccion, estado, tarifa, moneda
               FROM viaje WHERE id_conductor=%s ORDER BY fecha_solicitud DESC""", (id_sel,))
        vehiculos = consultar(
            """SELECT v.placa, v.marca, v.modelo, v.tipo_servicio, cv.es_activo
               FROM conductor_vehiculo cv JOIN vehiculo v ON v.id_vehiculo = cv.id_vehiculo
               WHERE cv.id_conductor=%s""", (id_sel,))
    return render_template("conductor.html", conductores=conductores, id_sel=id_sel,
                           disponibles=disponibles, mis_viajes=mis_viajes, vehiculos=vehiculos,
                           paises=paises(), empresas=empresas("flota"),
                           tipos_doc=TIPOS_DOCUMENTO, servicios=TIPOS_SERVICIO)


@app.post("/conductor/registrar")
def conductor_registrar():
    f = request.form

    def op(cur):
        id_usuario = crear_usuario(cur, f)
        cur.execute("INSERT INTO conductor (id_usuario, cuenta_banco, banco, id_empresa_flota) "
                    "VALUES (%s,%s,%s,%s)",
                    (id_usuario, f["cuenta_banco"].strip(), f["banco"].strip() or BANCOS_DEFAULT,
                     a_nulo(f.get("id_empresa_flota"))))
        cur.execute("INSERT INTO licencia (id_conductor, numero_licencia, categoria, "
                    "fecha_expedicion, fecha_vencimiento) VALUES (%s,%s,%s,%s,%s)",
                    (cur.lastrowid, f["numero_licencia"].strip(), f["categoria"].strip(),
                     f["fecha_expedicion"], f["fecha_vencimiento"]))
    con_transaccion(op, "Conductor registrado (queda en revisión).")
    return redirect(url_for("conductor"))


@app.post("/conductor/vehiculo")
def conductor_vehiculo():
    f = request.form
    id_conductor = int(f["id_conductor"])

    def op(cur):
        cur.execute(
            """INSERT INTO vehiculo (placa, marca, modelo, anio, color, tipo_servicio,
                                     numero_seguro, fecha_vencimiento_seguro)
               VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
            (f["placa"].strip().upper(), f["marca"].strip(), f["modelo"].strip(), int(f["anio"]),
             f["color"].strip(), f["tipo_servicio"], f["numero_seguro"].strip(),
             f["fecha_vencimiento_seguro"]))
        id_vehiculo = cur.lastrowid
        cur.execute("UPDATE conductor_vehiculo SET es_activo=FALSE WHERE id_conductor=%s", (id_conductor,))
        cur.execute("INSERT INTO conductor_vehiculo (id_conductor, id_vehiculo, fecha_asignacion, es_activo) "
                    "VALUES (%s,%s,CURDATE(),TRUE)", (id_conductor, id_vehiculo))
    con_transaccion(op, "Vehículo registrado y marcado como activo.")
    return redirect(url_for("conductor", id=id_conductor))


TRANSICIONES = {
    "aceptar": ("solicitado", "aceptado"),
    "iniciar": ("aceptado", "en_curso"),
    "finalizar": ("en_curso", "finalizado"),
    "cancelar": (None, "cancelado"),
}


@app.post("/conductor/viaje/<int:id_viaje>/<accion>")
def conductor_viaje(id_viaje, accion):
    id_conductor = request.form.get("id_conductor", type=int)
    if accion not in TRANSICIONES or not id_conductor:
        flash("Elige un conductor antes de usar los botones del viaje.", "error")
        return redirect(url_for("conductor"))
    requerido, nuevo = TRANSICIONES[accion]

    def op(cur):
        cur.execute("SELECT estado FROM viaje WHERE id_viaje=%s FOR UPDATE", (id_viaje,))
        fila = cur.fetchone()
        actual = fila[0] if fila else None
        if actual is None or (requerido and actual != requerido):
            raise ValueError(f"El viaje está '{actual}', no se puede {accion}.")
        if accion == "aceptar":
            cur.execute("SELECT id_vehiculo FROM conductor_vehiculo "
                        "WHERE id_conductor=%s AND es_activo=TRUE LIMIT 1", (id_conductor,))
            v = cur.fetchone()
            cur.execute("UPDATE viaje SET estado=%s, id_conductor=%s, id_vehiculo=%s WHERE id_viaje=%s",
                        (nuevo, id_conductor, v[0] if v else None, id_viaje))
        elif accion == "iniciar":
            cur.execute("UPDATE viaje SET estado=%s, fecha_inicio=NOW() WHERE id_viaje=%s", (nuevo, id_viaje))
        elif accion == "finalizar":
            cur.execute("UPDATE viaje SET estado=%s, fecha_fin=NOW(), distancia_km=%s, tarifa=%s "
                        "WHERE id_viaje=%s",
                        (nuevo, a_nulo(request.form.get("distancia_km")),
                         a_nulo(request.form.get("tarifa")), id_viaje))
        else:
            cur.execute("UPDATE viaje SET estado=%s WHERE id_viaje=%s", (nuevo, id_viaje))
        registrar_estado(cur, id_viaje, actual, nuevo)

    try:
        con_transaccion(op, f"Viaje {nuevo}.")
    except ValueError as e:  # pragma: no cover
        flash(str(e), "error")
    return redirect(url_for("conductor", id=id_conductor))

@app.route("/empresa")
def empresa():
    lista = consultar(
        """SELECT e.id_empresa, e.razon_social, e.ruc_nit, e.tipo, pa.nombre AS pais,
                  (SELECT COUNT(*) FROM pasajero p WHERE p.id_empresa = e.id_empresa) AS pasajeros,
                  (SELECT COUNT(*) FROM conductor c WHERE c.id_empresa_flota = e.id_empresa) AS conductores,
                  (SELECT COUNT(*) FROM viaje v WHERE v.id_empresa = e.id_empresa) AS viajes
           FROM empresa e JOIN pais pa ON pa.id_pais = e.id_pais ORDER BY e.razon_social""")
    return render_template("empresa.html", lista=lista, paises=paises(), tipos=TIPOS_EMPRESA)


@app.post("/empresa/registrar")
def empresa_registrar():
    f = request.form

    def op(cur):
        cur.execute(
            """INSERT INTO empresa (ruc_nit, razon_social, tipo, id_pais, direccion,
                                    telefono_contacto, correo_contacto)
               VALUES (%s,%s,%s,%s,%s,%s,%s)""",
            (f["ruc_nit"].strip(), f["razon_social"].strip(), f["tipo"], f["id_pais"],
             a_nulo(f.get("direccion")), f["telefono_contacto"].strip(), f["correo_contacto"].strip()))
    con_transaccion(op, "Empresa registrada.")
    return redirect(url_for("empresa"))


if __name__ == "__main__":
    app.run(debug=True)
