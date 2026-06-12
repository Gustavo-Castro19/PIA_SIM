-- Views para consultas seguras (sem dados pessoais)

CREATE OR REPLACE VIEW v_lista_pia AS
SELECT
    p.id,
    p.ia_risco_atual AS risco,
    p.grau_interesse,
    p.status,
    p.total_incidentes,
    p.data_ultimo_incidente,
    p.ia_ultimo_resumo AS resumo_ia,
    p.data_atualizacao,
    ia.ia_confianca AS confianca_ia,
    ia.ia_data_processamento AS data_analise_ia
FROM pia p
LEFT JOIN incidente_analise ia
    ON ia.incidente_id = p.ultimo_incidente_id
    AND ia.ia_status_processamento = 'CONCLUIDO'
ORDER BY
    CASE p.ia_risco_atual
        WHEN 'ALTO' THEN 1
        WHEN 'MEDIO' THEN 2
        WHEN 'BAIXO' THEN 3
        ELSE 4
    END,
    p.data_atualizacao DESC;

COMMENT ON VIEW v_lista_pia IS 'View segura para exibição no painel Angular. Identificador público: p.id numérico.';

CREATE OR REPLACE VIEW v_relatorio_seguro AS
SELECT
    p.id AS pia_id,
    p.ia_risco_atual,
    p.grau_interesse,
    p.status,
    p.total_incidentes,
    i.tipo_fraude,
    i.data_ocorrencia,
    i.data_criacao AS data_registro,
    ia.ia_resumo,
    ia.ia_confianca,
    ia.data_validacao,
    u.nome AS analista_validador
FROM pia p
LEFT JOIN incidente i ON p.ultimo_incidente_id = i.id
LEFT JOIN incidente_analise ia ON ia.incidente_id = p.ultimo_incidente_id
LEFT JOIN usuario u ON ia.analista_id = u.id;

COMMENT ON VIEW v_relatorio_seguro IS 'View para exportação de relatórios estatísticos sem violar LGPD';
