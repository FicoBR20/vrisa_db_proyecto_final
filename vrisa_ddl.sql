--CREATE TYPE 


CREATE TABLE sistema(
    id_sistema  SERIAL PRIMARY KEY,
    nombre_sistema  VARCHAR(30)
);


CREATE TABLE listado_referencial_intituciones(
    id_listado_ref_institucion  SERIAL PRIMARY KEY,
    id_sistema                  INT NOT NULL DEFAULT 999, -- 999 sistama default
    nombre_institucion   VARCHAR(100)NOT NULL,
    clave_institucion   VARCHAR(6)NOT NULL,--usada para validar registro inicial
    CONSTRAINT fk_listado_instit_sistema
        FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)
        ON DELETE RESTRICT


);

CREATE TABLE listado_referencial_investigadores(
    id_listado_ref_investigador  SERIAL PRIMARY KEY,
    id_sistema                  INT NOT NULL DEFAULT 999,
    nombre_investigador VARCHAR(30)NOT NULL,
    apellido_invesigador VARCHAR(30)NOT NULL,
    licencia_investigador VARCHAR(6)NOT NULL  -- usada para validar registro inicial
    CONSTRAINT fk_listado_invest_sistema
        FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)
        ON DELETE RESTRICT


);

CREATE TYPE tipo_informe AS ENUM (
    'tabla',
    'grafica',
    'kpi',
    'mapa'
);

--ALTER TYPE tipo_informe ADD VALUE 'nuevo_tipo';


CREATE TABLE dashboard (
    id_dashboard SERIAL PRIMARY KEY,
    id_sistema  INT NOT NULL DEFAULT 999,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    tipo tipo_informe NOT NULL,-- type data
    consulta_sql TEXT NOT NULL,--Consulta view materializarla
    creado TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_dashboard_sistema
        FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)
        ON DELETE SET DEFAULT
        ON UPDATE SET DEFAULT

);

CREATE TABLE estacion (
    id_estacion     SERIAL PRIMARY KEY,
    id_sistema      INT NOT NULL DEFAULT 999,
    nombre          VARCHAR(100),
    emision         BOOLEAN DEFAULT FALSE,
    geo_ubicacion   GEOMETRY(Point, 4326) NOT NULL,
    calle           VARCHAR(20),
    numero          VARCHAR(20),
    CONSTRAINT fk_estacion_sistema
        FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)
        ON UPDATE SET DEFAULT
        ON DELETE SET DEFAULT
);

-- crear funcion aleatoria para que al crear un sensor
-- genere un serial de [10] campos

CREATE TABLE sensor(
    id_sensor SERIAL PRIMARY KEY,
    serial_sensor   VARCHAR(10) UNIQUE, -- funcion aleatoria
    id_estacion INT NOT NULL DEFAULT 99, -- 99 estacion default
    nombre      VARCHAR(50) NOT NULL,
    descirpcion  TEXT,
    CONSTRAINT fk_sensor_estacion
        FOREIGN KEY (id_estacion)
        REFERENCES estacion(id_estacion)
        ON DELETE SET DEFAULT
        ON UPDATE SET DEFAULT


);

CREATE TYPE accion_mto AS ENUM (
    'mantenimiento',
    'calibracion'
);

------------=======================================FUNCION PARA GUARDAR LOS AJUSTES EN UNA NUEVA TABLA AL BORRAR UN SENSOR

CREATE TABLE ajuste( -- TABLA PADRE
    id_ajuste SERIAL PRIMARY KEY,
    id_sensor INT NOT NULL,
    fecha     TIMESTAMP NOT NULL,
    accion_hecha    accion_mto, -- type definido
    FOREIGN KEY (id_sensor) REFERENCES sensor(id_sensor)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    

);



CREATE DOMAIN tipo_mantenimiento AS VARCHAR(20)
    CHECK (VALUE IN ('preventivo', 'correctivo'));


CREATE TABLE mantenimiento (--ok TABLA HIJA DE AJUSTE
    id_ajuste SERIAL PRIMARY KEY,
    repuesto    VARCHAR(20),
    tipo_mto    tipo_mantenimiento NOT NULL,--domain definido
    descripcion TEXT,
    FOREIGN KEY (id_ajuste)
        REFERENCES ajuste(id_ajuste)
        ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE DOMAIN metodo_calibracion AS VARCHAR(20)
    CHECK (VALUE IN ('metodo manual', 'metodo automatico remoto', 'metodo patron referencia','metodo gavimetria', 'metodo dos puntos'));




CREATE TABLE calibracion (--OK TABLA HIJA DE AJUSTE
    id_ajuste SERIAL PRIMARY KEY,
    metodo_usado metodo_calibracion,
    observaciones TEXT,
    FOREIGN KEY (id_ajuste)
        REFERENCES ajuste(id_ajuste)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);


CREATE DOMAIN tipo_usuario AS VARCHAR(20)
    CHECK (VALUE IN ('publico', 'privado', 'rechazado'));



CREATE TABLE usuario( -- padre1
    id_usuario SERIAL PRIMARY KEY,
    activo      BOOLEAN DEFAULT FALSE,
    roll        tipo_usuario DEFAULT 'rechazado'

);


CREATE TABLE persona(--padre2
    id_persona SERIAL PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL,
    apellido    VARCHAR(50) NOT NULL,
    correo      VARCHAR(100) NOT NULL,
    celular     VARCHAR(30) NOT NULL,

);


CREATE TABLE color_inst ( -- se generaran 10 colores basicos a usar por las instituciones
    id_color SERIAL PRIMARY KEY,
    nombre VARCHAR(20) UNIQUE NOT NULL,
    hex VARCHAR(7) NOT NULL,
    rgb VARCHAR(11) NOT NULL
);



CREATE TYPE tipo_institucion AS ENUM (
    'privada',
    'publica', 'ong'
);




CREATE TABLE institucion(
    id_institucion SERIAL PRIMARY KEY,
    id_usuario      INT NOT NULL,
    nombre          VARCHAR(30) NOT NULL,
    calle           VARCHAR(30) NOT NULL,
    numero          VARCHAR(30) NOT NULL,
    correo_gte      VARCHAR(40) NOT NULL,
    tipo_inst       tipo_institucion NOT NULL,
    color_1         VARCHAR(20) NOT NULL,
    color_2         VARCHAR(20) NOT NULL,
    logo_image_path TEXT NOT NULL, -- path de la imagen png
    secret_key      VARCHAR(6), -- checkea durante el registro 
    FOREIGN KEY (color_1, color_2)REFERENCES color_inst(id_color)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
    ON DELETE RESTRICT ON UPDATE CASCADE

);

CREATE TABLE investigador(
    id_investigador      SERIAL PRIMARY KEY,
    id_usuario          INT NOT NULL,
    id_persona          INT NOT NULL,
    especialidad        VARCHAR(50),
    licencia_profesinal     VARCHAR(6),
    FOREIGN KEY (id_usuario, id_persona) 
    REFERENCES usuario(id_usuario), persona(id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE

);

CREATE TABLE ciudadano(
    id_ciudadano  SERIAL PRIMARY KEY,
    id_usuario   INT NOT NULL,
    id_persona   INT NOT NULL,
    profesion  VARCHAR(50) DEFAULT 'veedor',
    FOREIGN KEY (id_usuario, id_persona) 
    REFERENCES usuario(id_usuario), persona(id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE

);

CREATE TABLE empleado(
    id_empleado  SERIAL PRIMARY KEY,
    id_usuario   INT NOT NULL,
    id_persona   INT NOT NULL,
    id_estacion  INT NOT NULL,
    cargo       VARCHAR(30) NOT NULL,
    salario     INT NOT NULL,
    fecha_ingreso   TIMESTAMP,
    FOREIGN KEY (id_usuario, id_persona) 
    REFERENCES usuario(id_usuario), persona(id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_estacion) REFERENCES estacion(id_estacion)
    ON DELETE RESTRICT ON UPDATE CASCADE


);

/*
Check inicial al registrarse en el sistema
usuario.institucion.secret_key (vs)listado
usuario.persona.investigador.licencia_profesional (vs) listado
*/

CREATE TABLE verifica_ingreso_usuario(
    id_verifica SERIAL PRIMARY KEY,
    id_listado_ref_institucion INT NOT NULL,
    id_usuario INT NOT NULL,
    habilitada_inst BOOLEAN DEFAULT FALSE,
    fecha           TIMESTAMP
    
);

