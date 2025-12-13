--dominios

CREATE TYPE tipo_informe AS ENUM ('tabla','grafica','kpi','mapa');
CREATE TYPE accion_mto AS ENUM ('mantenimiento','calibracion');
CREATE TYPE tipo_institucion AS ENUM ('privada','publica','ong');
CREATE TYPE tipo_size AS ENUM ('PM₂.₅','PM₁₀');

CREATE DOMAIN tipo_mantenimiento VARCHAR(20)
CHECK (VALUE IN ('preventivo','correctivo'));

CREATE DOMAIN metodo_calibracion VARCHAR(50)
CHECK (VALUE IN (
 'metodo manual',
 'metodo automatico remoto',
 'metodo patron referencia',
 'metodo gavimetria',
 'metodo dos puntos'
));

CREATE DOMAIN tipo_usuario VARCHAR(20)
CHECK (VALUE IN ('publico','privado','rechazado'));

CREATE DOMAIN limite_und_tiempo VARCHAR(20)
CHECK (VALUE IN ('24 horas','1 hora','8 horas'));

CREATE DOMAIN temp_climatica VARCHAR(20)
CHECK (VALUE IN ('seca','lluviosa','ventisca','atipica'));

CREATE DOMAIN direccion_viento NUMERIC(5,2)
CHECK (VALUE >= 0 AND VALUE < 360);

CREATE DOMAIN temperatura NUMERIC(5,2)
CHECK (VALUE >= -100 AND VALUE <= 100);

CREATE DOMAIN humedad_relativa NUMERIC(5,2)
CHECK (VALUE >= 0 AND VALUE <= 100);

CREATE DOMAIN sitio_de_toma VARCHAR(30)
CHECK (VALUE IN ('interno ->sensor','externo ->estacion'));


--tablas base

CREATE TABLE sistema(
    id_sistema SERIAL PRIMARY KEY,
    nombre_sistema VARCHAR(30)
);

INSERT INTO sistema(id_sistema,nombre_sistema)
VALUES (999,'Sistema por defecto');


--listados referenciales

CREATE TABLE listado_referencial_intituciones(
    id_listado_ref_institucion SERIAL PRIMARY KEY,
    id_sistema INT NOT NULL DEFAULT 999,
    nombre_institucion VARCHAR(100) NOT NULL,
    clave_institucion VARCHAR(6) NOT NULL,
    FOREIGN KEY (id_sistema) REFERENCES sistema(id_sistema)
);

CREATE TABLE listado_referencial_investigadores(
    id_listado_ref_investigador SERIAL PRIMARY KEY,
    id_sistema INT NOT NULL DEFAULT 999,
    nombre_investigador VARCHAR(30) NOT NULL,
    apellido_invesigador VARCHAR(30) NOT NULL,
    licencia_investigador VARCHAR(6) NOT NULL,
    FOREIGN KEY (id_sistema) REFERENCES sistema(id_sistema)
);
-- dashboard

CREATE TABLE dashboard(
    id_dashboard SERIAL PRIMARY KEY,
    id_sistema INT NOT NULL DEFAULT 999,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    tipo tipo_informe NOT NULL,
    consulta_sql TEXT NOT NULL,
    creado TIMESTAMP DEFAULT now(),
    FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)
        ON DELETE SET DEFAULT
        ON UPDATE SET DEFAULT
);

-- estacion y sensor

CREATE TABLE estacion(
    id_estacion SERIAL PRIMARY KEY,
    id_sistema INT NOT NULL DEFAULT 999,
    nombre VARCHAR(100),
    emision BOOLEAN DEFAULT FALSE,
    geo_ubicacion GEOMETRY(Point,4326) NOT NULL,
    calle VARCHAR(20),
    numero VARCHAR(20),
    FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)
        ON DELETE SET DEFAULT
        ON UPDATE SET DEFAULT
);

INSERT INTO estacion(id_estacion,id_sistema,geo_ubicacion)
VALUES (99,999,ST_Point(0,0));

CREATE TABLE sensor(
    id_sensor SERIAL PRIMARY KEY,
    serial_sensor VARCHAR(10) UNIQUE,
    id_estacion INT NOT NULL DEFAULT 99,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_estacion)
        REFERENCES estacion(id_estacion)
        ON DELETE SET DEFAULT
        ON UPDATE SET DEFAULT
);

INSERT INTO sensor(id_sensor,id_estacion,nombre)
VALUES (9999,99,'Sensor por defecto');


-- ajuste mantenimiento y calibracion

CREATE TABLE ajuste(
    id_ajuste SERIAL PRIMARY KEY,
    id_sensor INT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    accion_hecha accion_mto,
    FOREIGN KEY (id_sensor)
        REFERENCES sensor(id_sensor)
        ON DELETE CASCADE
);

CREATE TABLE mantenimiento(
    id_ajuste INT PRIMARY KEY,
    repuesto VARCHAR(20),
    tipo_mto tipo_mantenimiento NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_ajuste)
        REFERENCES ajuste(id_ajuste)
        ON DELETE RESTRICT
);

CREATE TABLE calibracion(
    id_ajuste INT PRIMARY KEY,
    metodo_usado metodo_calibracion,
    observaciones TEXT,
    FOREIGN KEY (id_ajuste)
        REFERENCES ajuste(id_ajuste)
        ON DELETE RESTRICT
);


--usuario y personas

CREATE TABLE usuario(
    id_usuario SERIAL PRIMARY KEY,
    activo BOOLEAN DEFAULT FALSE,
    roll tipo_usuario DEFAULT 'rechazado'
);

CREATE TABLE persona(
    id_persona SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    celular VARCHAR(30) NOT NULL
);

-- colores e institucion

CREATE TABLE color_inst(
    id_color SERIAL PRIMARY KEY,
    nombre VARCHAR(20) UNIQUE NOT NULL,
    hex VARCHAR(7) NOT NULL,
    rgb VARCHAR(11) NOT NULL
);

CREATE TABLE institucion(
    id_institucion SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    calle VARCHAR(30) NOT NULL,
    numero VARCHAR(30) NOT NULL,
    correo_gte VARCHAR(40) NOT NULL,
    tipo_inst tipo_institucion NOT NULL,
    color_1 INT NOT NULL,
    color_2 INT NOT NULL,
    logo_image_path TEXT NOT NULL
    CHECK (length(logo_image_path) > 5)
    CHECK (logo_image_path ~* '\.(png|jpg|jpeg)$')
    secret_key VARCHAR(6),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (color_1) REFERENCES color_inst(id_color),
    FOREIGN KEY (color_2) REFERENCES color_inst(id_color)
);


--roles derivados

CREATE TABLE investigador(
    id_investigador SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_persona INT NOT NULL,
    especialidad VARCHAR(50),
    licencia_profesinal VARCHAR(6),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona)
);

CREATE TABLE ciudadano(
    id_ciudadano SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_persona INT NOT NULL,
    profesion VARCHAR(50) DEFAULT 'veedor',
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona)
);

CREATE TABLE empleado(
    id_empleado SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_persona INT NOT NULL,
    id_estacion INT NOT NULL,
    cargo VARCHAR(30) NOT NULL,
    salario INT NOT NULL,
    fecha_ingreso TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona),
    FOREIGN KEY (id_estacion) REFERENCES estacion(id_estacion)
);


-- verifica ingreso usuario

CREATE TABLE verifica_ingreso_usuario(
    id_verifica SERIAL PRIMARY KEY,
    id_listado_ref_institucion INT,
    id_listado_ref_investigador INT,
    id_usuario INT NOT NULL,
    habilitado BOOLEAN DEFAULT FALSE,
    fecha           TIMESTAMP
    
);



-- muestra y variables ambientales

CREATE TABLE muestra(
    id_muestra SERIAL PRIMARY KEY,
    id_sensor INT NOT NULL DEFAULT 9999,
    fecha_inicial TIMESTAMP NOT NULL,
    fecha_final TIMESTAMP NOT NULL,
    FOREIGN KEY (id_sensor)
        REFERENCES sensor(id_sensor)
        ON DELETE SET DEFAULT
);

CREATE TABLE contaminante(
    id_contaminante SERIAL PRIMARY KEY,
    cantidad_recolectada DECIMAL(10,2),
    unidad VARCHAR(15) DEFAULT 'µg/m³',
    limite_max_permitido DECIMAL(10,2) NOT NULL,
    limite_unidad_tiempo limite_und_tiempo NOT NULL
);

CREATE TABLE tipo_atmosferico(
    id_tipo_atmosferico SERIAL PRIMARY KEY,
    estacion_climatica temp_climatica NOT NULL
);

CREATE TABLE viento(
    id_viento SERIAL PRIMARY KEY,
    id_muestra INT NOT NULL,
    id_tipo_atmosferico INT NOT NULL,
    velocidad_kxh INT NOT NULL,
    direccion_grados direccion_viento NOT NULL,
    FOREIGN KEY (id_muestra) REFERENCES muestra(id_muestra),
    FOREIGN KEY (id_tipo_atmosferico) REFERENCES tipo_atmosferico(id_tipo_atmosferico)
);

CREATE TABLE temperatura(
    id_temperatura SERIAL PRIMARY KEY,
    id_muestra INT NOT NULL,
    id_tipo_atmosferico INT NOT NULL,
    valor_temp temperatura NOT NULL,
    unidad_grados VARCHAR(10) DEFAULT '°C',
    sitio_muestra sitio_de_toma NOT NULL,
    FOREIGN KEY (id_muestra) REFERENCES muestra(id_muestra),
    FOREIGN KEY (id_tipo_atmosferico) REFERENCES tipo_atmosferico(id_tipo_atmosferico)
);

CREATE TABLE humedad(
    id_humedad SERIAL PRIMARY KEY,
    id_muestra INT NOT NULL,
    id_tipo_atmosferico INT NOT NULL,
    valor_humedad humedad_relativa NOT NULL,
    FOREIGN KEY (id_muestra) REFERENCES muestra(id_muestra),
    FOREIGN KEY (id_tipo_atmosferico) REFERENCES tipo_atmosferico(id_tipo_atmosferico)
);

CREATE TABLE particula(
    id_particula SERIAL PRIMARY KEY,
    id_muestra INT NOT NULL,
    id_contaminante INT NOT NULL,
    descripcion_size tipo_size,
    FOREIGN KEY (id_muestra) REFERENCES muestra(id_muestra),
    FOREIGN KEY (id_contaminante) REFERENCES contaminante(id_contaminante)
);

CREATE TABLE compuesto(
    id_compuesto SERIAL PRIMARY KEY,
    id_muestra INT NOT NULL,
    id_contaminante INT NOT NULL,
    molecula VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_muestra) REFERENCES muestra(id_muestra),
    FOREIGN KEY (id_contaminante) REFERENCES contaminante(id_contaminante)
);

--======================= FUNCIONES INICIALES DE CONFIGURACION =================================

-- funcion que verifica institucion y investigador para registrarlos y activarles roll y estado de usuario.

CREATE OR REPLACE FUNCTION fn_verificar_ingreso_usuario(
    p_id_usuario INT,
    p_secret_key VARCHAR DEFAULT NULL,
    p_licencia VARCHAR DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_listado_inst INT;
    v_id_listado_inv INT;
BEGIN
    -- Verificar institución
    IF p_secret_key IS NOT NULL THEN
        SELECT id_listado_ref_institucion
        INTO v_id_listado_inst
        FROM listado_referencial_intituciones
        WHERE clave_institucion = p_secret_key
        LIMIT 1;
    END IF;

    -- Verificar investigador
    IF p_licencia IS NOT NULL THEN
        SELECT id_listado_ref_investigador
        INTO v_id_listado_inv
        FROM listado_referencial_investigadores
        WHERE licencia_investigador = p_licencia
        LIMIT 1;
    END IF;

    -- Si alguna verificación fue exitosa
    IF v_id_listado_inst IS NOT NULL OR v_id_listado_inv IS NOT NULL THEN

        -- Activar usuario
        UPDATE usuario
        SET activo = TRUE,
            roll = 'privado'
        WHERE id_usuario = p_id_usuario;

        -- Registrar verificación
        INSERT INTO verifica_ingreso_usuario(
            id_listado_ref_institucion,
            id_listado_ref_investigador,
            id_usuario,
            habilitado,
            fecha
        )
        VALUES (
            v_id_listado_inst,
            v_id_listado_inv,
            p_id_usuario,
            TRUE,
            now()
        );

    END IF;
END;
$$;


-- trigger after insert institucin

CREATE OR REPLACE FUNCTION trg_verifica_institucion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM fn_verificar_ingreso_usuario(
        NEW.id_usuario,
        NEW.secret_key,
        NULL
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER after_insert_institucion
AFTER INSERT ON institucion
FOR EACH ROW
EXECUTE FUNCTION trg_verifica_institucion();


-- trigger after insert investigador 

CREATE OR REPLACE FUNCTION trg_verifica_investigador()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM fn_verificar_ingreso_usuario(
        NEW.id_usuario,
        NULL,
        NEW.licencia_profesinal
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER after_insert_investigador
AFTER INSERT ON investigador
FOR EACH ROW
EXECUTE FUNCTION trg_verifica_investigador();





