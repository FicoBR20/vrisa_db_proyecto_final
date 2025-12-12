-- crea usuario institucional e investigador verificado

CREATE OR REPLACE FUNCTION fn_verificar_ingreso()
RETURNS TRIGGER AS $$
DECLARE
    v_inst_id INT := NULL;
    v_inv_id  INT := NULL;
BEGIN
    -- Verificación institución
    IF TG_TABLE_NAME = 'institucion' THEN
        SELECT id_listado_ref_institucion
        INTO v_inst_id
        FROM listado_referencial_intituciones
        WHERE clave_institucion = NEW.secret_key;

        IF v_inst_id IS NULL THEN
            RAISE EXCEPTION
            'Institución no autorizada para registro';
        END IF;
    END IF;

    -- Verificación investigador
    IF TG_TABLE_NAME = 'investigador' THEN
        SELECT id_listado_ref_investigador
        INTO v_inv_id
        FROM listado_referencial_investigadores
        WHERE licencia_investigador = NEW.licencia_profesinal;

        IF v_inv_id IS NULL THEN
            RAISE EXCEPTION
            'Investigador no autorizado para registro';
        END IF;
    END IF;

    -- Activar usuario
    UPDATE usuario
    SET activo = TRUE,
        roll = 'privado'
    WHERE id_usuario = NEW.id_usuario;

    -- Registrar verificación
    INSERT INTO verifica_ingreso_usuario (
        id_listado_ref_institucion,
        id_listado_ref_investigador,
        id_usuario,
        habilitado,
        fecha
    )
    VALUES (
        v_inst_id,
        v_inv_id,
        NEW.id_usuario,
        TRUE,
        now()
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger asociado a funcion
CREATE TRIGGER trg_verificar_institucion
BEFORE INSERT ON institucion
FOR EACH ROW
EXECUTE FUNCTION fn_verificar_ingreso();

CREATE TRIGGER trg_verificar_investigador
BEFORE INSERT ON investigador
FOR EACH ROW
EXECUTE FUNCTION fn_verificar_ingreso();

