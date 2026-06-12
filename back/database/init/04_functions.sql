-- Funções de negócio e utilitárias

CREATE OR REPLACE FUNCTION fn_atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_auditar_pia()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_id BIGINT;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        v_usuario_id := COALESCE(NEW.criado_por, (SELECT id FROM usuario WHERE email = 'sistema@onac.serpro.gov.br' LIMIT 1));

        INSERT INTO pia_historico (
            pia_id, tipo_operacao,
            grau_interesse_anterior, grau_interesse_novo,
            status_anterior, status_novo,
            motivo_alteracao, usuario_id
        ) VALUES (
            NEW.id, 'INCLUSAO',
            NULL, NEW.grau_interesse,
            NULL, NEW.status,
            'Cadastro inicial na Lista PIA', v_usuario_id
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        v_usuario_id := COALESCE(
            NEW.criado_por,
            (SELECT id FROM usuario WHERE email = 'sistema@onac.serpro.gov.br' LIMIT 1)
        );

        INSERT INTO pia_historico (
            pia_id, tipo_operacao,
            grau_interesse_anterior, grau_interesse_novo,
            status_anterior, status_novo,
            motivo_alteracao, usuario_id
        ) VALUES (
            NEW.id, 'EDICAO',
            OLD.grau_interesse, NEW.grau_interesse,
            OLD.status, NEW.status,
            COALESCE(NEW.ia_ultimo_resumo, 'Atualização de dados'),
            v_usuario_id
        );
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        v_usuario_id := COALESCE(
            OLD.criado_por,
            (SELECT id FROM usuario WHERE email = 'sistema@onac.serpro.gov.br' LIMIT 1)
        );

        INSERT INTO pia_historico (
            pia_id, tipo_operacao,
            grau_interesse_anterior, grau_interesse_novo,
            status_anterior, status_novo,
            motivo_alteracao, usuario_id
        ) VALUES (
            OLD.id, 'EXCLUSAO',
            OLD.grau_interesse, NULL,
            OLD.status, NULL,
            'Remoção da Lista PIA',
            v_usuario_id
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_sincronizar_pia()
RETURNS TRIGGER AS $$
DECLARE
    v_pia_id BIGINT;
BEGIN
    IF NEW.ia_status_processamento = 'CONCLUIDO' AND NEW.ia_risco_sugerido IS NOT NULL THEN
        SELECT COALESCE(NEW.pia_id, i.pia_id)
        INTO v_pia_id
        FROM incidente i
        WHERE i.id = NEW.incidente_id;

        IF v_pia_id IS NULL THEN
            RETURN NEW;
        END IF;

        UPDATE incidente_analise SET
            pia_id = v_pia_id
        WHERE id = NEW.id AND pia_id IS NULL;

        UPDATE pia SET
            ia_risco_atual = NEW.ia_risco_sugerido,
            ia_ultimo_resumo = NEW.ia_resumo,
            total_incidentes = (
                SELECT COUNT(*) FROM incidente i WHERE i.pia_id = v_pia_id
            ),
            ultimo_incidente_id = NEW.incidente_id,
            data_ultimo_incidente = CURRENT_TIMESTAMP,
            grau_interesse = CASE
                WHEN NEW.ia_risco_sugerido = 'ALTO' THEN 'ALTO'
                WHEN NEW.ia_risco_sugerido = 'MEDIO' THEN 'MEDIO'
                ELSE 'BAIXO'
            END,
            data_atualizacao = CURRENT_TIMESTAMP
        WHERE id = v_pia_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
