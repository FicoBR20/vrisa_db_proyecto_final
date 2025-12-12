INSERT INTO sistema (
    id_sistema, nombre_sistema)
    VALUES ('Vrisa'
);

INSERT INTO sistema (
    id_sistema, nombre_sistema)
    VALUES (999,'copia de seguridad'
);





INSERT INTO estacion (
    id_sistema, nombre, emision, geo_ubicacion, calle, numero
) VALUES (
    1,
    'Estación Cali Centro',
    FALSE,
    ST_SetSRID(ST_MakePoint(-76.514339, 3.437101), 4326),
    'Calle 5',
    '123'
);
INSERT INTO estacion (
    id_sistema, nombre, emision, geo_ubicacion, calle, numero
) VALUES (
    1,
    'Estación Cali Sur',
    FALSE,
    ST_SetSRID(ST_MakePoint(-76.534533, 3.375205), 4326),
    'Avenida Pasoancho',
    '100-123'
);

INSERT INTO estacion (
    id_sistema, nombre, emision, geo_ubicacion, calle, numero
) VALUES (
    1,
    'Estación Cali Oriente',
    FALSE,
    ST_SetSRID(ST_MakePoint(-76.470586, 3.431586), 4326),
    'Cra 25 A',
    '89-16'
);
INSERT INTO estacion (
    id_sistema, nombre, emision, geo_ubicacion, calle, numero
) VALUES (
    1,
    'Estación Cali Oeste',
    FALSE,
    ST_SetSRID(ST_MakePoint(-76.5417705, 3.447553), 4326),
    'Carrera 1 oeste',
    '12-112'
);
INSERT INTO estacion (
    id_sistema, nombre, emision, geo_ubicacion, calle, numero
) VALUES (
    99,
    'Estacion por defecto Pascual Guerrero',
    FALSE,
    ST_SetSRID(ST_MakePoint(-76.54105, 3.429960), 4326),
    'Calle 5',
    '34-152'
);