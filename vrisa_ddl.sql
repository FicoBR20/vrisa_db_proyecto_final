--CREATE TYPE 


CREATE TABLE sistema(
    id_sistema  SERIAL PRIMARY KEY,
    nombre_sistema  VARCHAR(30)
);


CREATE TABLE listado_referencial_intituciones(
    id_listado_ref_institucion  SERIAL PRIMARY KEY,
    id_sistema                  INT NOT NULL,
    nombre_institucion   VARCHAR(100)NOT NULL,
    clave_institucion   VARCHAR(14)NOT NULL,--usada para registro
    CONSTRAINT fk_listado_intit_sistema
        FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)

);

CREATE TABLE listado_referencial_investigadores(
    id_listado_ref_investigador  SERIAL PRIMARY KEY,
    id_sistema                  INT NOT NULL,
    nombre_investigador VARCHAR(30)NOT NULL,
    apellido_invesigador VARCHAR(30)NOT NULL,
    licencia_investigador VARCHAR(50)NOT NULL  -- usada para registro
    CONSTRAINT fk_listado_invest_sistema
        FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)


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
    id_sistema  INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    tipo tipo_informe NOT NULL,-- type data
    consulta_sql TEXT NOT NULL,--Consulta view materializarla
    creado TIMESTAMP DEFAULT now()
    CONSTRAINT fk_dashboard_sistema
        FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)

);

CREATE TABLE estacion (
    id_estacion     SERIAL PRIMARY KEY,
    id_sistema      INT NOT NULL,
    nombre          VARCHAR(100),
    emision         BOOLEAN DEFAULT FALSE,
    geo_ubicacion   GEOMETRY(Point, 4326) NOT NULL,
    calle           VARCHAR(20),
    numero          VARCHAR(20),
    CONSTRAINT fk_estacion_sistema
        FOREIGN KEY (id_sistema)
        REFERENCES sistema(id_sistema)
);

CREATE TABLE sensor(
    id_sensor SERIAL PRIMARY KEY,
    id_estacion INT NOT NULL,
    nombre      VARCHAR(50) NOT NULL,
    descirpcion  TEXT,
    CONSTRAINT fk_sensor_estacion
        FOREIGN KEY (id_estacion)
        REFERENCES estacion(id_estacion)


);

CREATE TYPE accion_mto AS ENUM (
    'mantenimiento',
    'calibracion'
);



CREATE TABLE ajuste(
    id_ajuste SERIAL PRIMARY KEY,
    id_sensor INT NOT NULL,
    fecha     TIMESTAMP NOT NULL,
    accion_hecha    accion_mto
    FOREIGN KEY (id_sensor) REFERENCES sensor(id_sensor)
    

);

-- CREATE TABLE mantenimiento (
--     id_mantenimiento SERIAL PRIMARY KEY,
--     id_sensor        INT NOT NULL,
--     fecha            TIMESTAMP NOT NULL,
--     tipo             VARCHAR(20) NOT NULL CHECK (tipo IN ('preventivo', 'correctivo')),
--     FOREIGN KEY (id_sensor) REFERENCES sensor(id_sensor)
-- );

/*
Como ea la herencia en sql
Se crea una nueva tabla con el nombre de la hija
Se usa la misma id del padre en las tablas hijas, igual nombre y como PK en la tabla hija
FOREIGN KEY (id_padre) REFERENCES tabla_padre(id_padre)
ON DELETE CASCADE // u otra restriccion.

*/

CREATE DOMAIN tipo_mantenimiento AS VARCHAR(20)
    CHECK (VALUE IN ('preventivo', 'correctivo'));


CREATE TABLE mantenimiento (
    id_ajuste SERIAL PRIMARY KEY,
    repuesto    VARCHAR(20),
    tipo_mto    tipo_mantenimiento NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_ajuste)
        REFERENCES ajuste(id_ajuste)
        ON DELETE CASCADE
);


CREATE DOMAIN metodo_calibracion AS VARCHAR(20)
    CHECK (VALUE IN ('metodo manual', 'metodo automatido remoto", "metodo patron referencia","metodo gavimetria, "metodo dos puntos"" ));




CREATE TABLE calibracion (
    id_ajuste SERIAL PRIMARY KEY,
    metodologia    observaciones TEXT,
    FOREIGN KEY (id_ajuste)
        REFERENCES ajuste(id_ajuste)
        ON DELETE CASCADE
);









/*
CREATE TABLE factura (
    id_factura SERIAL PRIMARY KEY,
    id_cliente INT,
    CONSTRAINT fk_factura_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);



**/