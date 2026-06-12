-- Triggers de timestamp, auditoria e sincronização PIA

DROP TRIGGER IF EXISTS trg_incidente_atualizacao ON incidente;
CREATE TRIGGER trg_incidente_atualizacao
    BEFORE UPDATE ON incidente
    FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp();

DROP TRIGGER IF EXISTS trg_incidente_analise_atualizacao ON incidente_analise;
CREATE TRIGGER trg_incidente_analise_atualizacao
    BEFORE UPDATE ON incidente_analise
    FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp();

DROP TRIGGER IF EXISTS trg_pia_atualizacao ON pia;
CREATE TRIGGER trg_pia_atualizacao
    BEFORE UPDATE ON pia
    FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp();

DROP TRIGGER IF EXISTS trg_usuario_atualizacao ON usuario;
CREATE TRIGGER trg_usuario_atualizacao
    BEFORE UPDATE ON usuario
    FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp();

DROP TRIGGER IF EXISTS trg_pia_auditoria ON pia;
CREATE TRIGGER trg_pia_auditoria
    AFTER INSERT OR UPDATE OR DELETE ON pia
    FOR EACH ROW EXECUTE FUNCTION fn_auditar_pia();

DROP TRIGGER IF EXISTS trg_sincronizar_pia_apos_ia ON incidente_analise;
CREATE TRIGGER trg_sincronizar_pia_apos_ia
    AFTER UPDATE OF ia_status_processamento ON incidente_analise
    FOR EACH ROW
    WHEN (NEW.ia_status_processamento = 'CONCLUIDO')
    EXECUTE FUNCTION fn_sincronizar_pia();
