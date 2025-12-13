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





