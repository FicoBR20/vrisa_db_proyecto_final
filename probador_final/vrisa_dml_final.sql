INSERT INTO sistema (id_sistema, nombre_sistema)
VALUES (999, 'Sistema por defecto')
ON CONFLICT DO NOTHING;

--datos listado referencial instituciones

INSERT INTO listado_referencial_intituciones
(id_sistema, nombre_institucion, clave_institucion)
VALUES
(999, 'Universidad Nacional', 'UNI001'), -- válida
(999, 'Instituto Ambiental', 'AMB002'),  -- válida
(999, 'Fundación Verde', 'FUN003'),
(999, 'Centro Eco', 'ECO004'),
(999, 'Laboratorio Aire', 'LAB005'),
(999, 'Red Climática', 'CLI006'),
(999, 'Agencia Ambiental', 'AGE007'),
(999, 'Observatorio Urbano', 'OBS008'),
(999, 'ONG Atmosfera', 'ONG009'),
(999, 'Centro Meteorológico', 'MET010');

-- datos listado_investigadores


INSERT INTO listado_referencial_investigadores
(id_sistema, nombre_investigador, apellido_invesigador, licencia_investigador)
VALUES
(999, 'Carlos', 'Ramírez', 'LIC001'), -- válida
(999, 'Ana', 'Torres', 'LIC002'),     -- válida
(999, 'Luis', 'Pérez', 'LIC003'),
(999, 'María', 'Gómez', 'LIC004'),
(999, 'Jorge', 'Castro', 'LIC005'),
(999, 'Laura', 'Ríos', 'LIC006'),
(999, 'Diego', 'Martínez', 'LIC007'),
(999, 'Paola', 'Suárez', 'LIC008'),
(999, 'Andrés', 'Moreno', 'LIC009'),
(999, 'Natalia', 'Vargas', 'LIC010');


--