-- Reset manual: remove todas as tabelas do schema ONAC Lista PIA
-- Uso: psql -f database/reset/drop_all.sql
-- ATENÇÃO: operação destrutiva — preferir docker compose down -v para dev

DROP VIEW IF EXISTS v_relatorio_seguro CASCADE;
DROP VIEW IF EXISTS v_lista_pia CASCADE;

DROP TRIGGER IF EXISTS trg_sincronizar_pia_apos_ia ON incidente_analise;
DROP TRIGGER IF EXISTS trg_pia_auditoria ON pia;
DROP TRIGGER IF EXISTS trg_pia_atualizacao ON pia;
DROP TRIGGER IF EXISTS trg_incidente_analise_atualizacao ON incidente_analise;
DROP TRIGGER IF EXISTS trg_incidente_atualizacao ON incidente;
DROP TRIGGER IF EXISTS trg_usuario_atualizacao ON usuario;

DROP FUNCTION IF EXISTS fn_sincronizar_pia() CASCADE;
DROP FUNCTION IF EXISTS fn_auditar_pia() CASCADE;
DROP FUNCTION IF EXISTS fn_atualizar_timestamp() CASCADE;

DROP TABLE IF EXISTS pia_historico CASCADE;
DROP TABLE IF EXISTS incidente_analise CASCADE;
DROP TABLE IF EXISTS incidente CASCADE;
DROP TABLE IF EXISTS pia CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;
