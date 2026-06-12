-- Seed de desenvolvimento: incidentes, análises e registros PIA para demo
-- Reaplicável via scripts/db-seed-dev.ps1 (não destrói o volume Docker)
-- Pré-requisito: 07_seed_base.sql já executado (usuários existentes)

BEGIN;

-- Limpa dados de demo anteriores (preserva usuários)
DELETE FROM incidente_analise WHERE incidente_id IN (
    SELECT id FROM incidente WHERE titulo LIKE '[DEV]%'
);
DELETE FROM incidente WHERE titulo LIKE '[DEV]%';
DELETE FROM pia WHERE id >= 100;

-- Ajusta sequência de PIA para IDs previsíveis em demo
SELECT setval(
    'pia_id_seq',
    GREATEST(COALESCE((SELECT MAX(id) FROM pia), 0), 99)
);

-- -----------------------------------------------------
-- PIA 1: risco ALTO, status CONFIRMADO, múltiplos incidentes
-- -----------------------------------------------------
INSERT INTO pia (id, grau_interesse, status, criado_por)
VALUES (100, 'ALTO', 'CONFIRMADO', (SELECT id FROM usuario WHERE email = 'carlos.oliveira@onac.serpro.gov.br'));

INSERT INTO incidente (pia_id, titulo, descricao, descricao_anonimizada, tipo_fraude, status, data_ocorrencia)
VALUES
    (100, '[DEV] Phishing bancário recorrente', 'Relato completo anonimizado #1', 'Vítima recebeu e-mails falsos solicitando dados bancários em três ocasiões distintas.', 'PHISHING', 'CONCLUIDO', '2026-05-10'),
    (100, '[DEV] Golpe PIX vinculado', 'Relato completo anonimizado #2', 'Transferência indevida via PIX após engenharia social por WhatsApp clonado.', 'GOLPE_PIX', 'CONCLUIDO', '2026-05-28'),
    (100, '[DEV] Vazamento de credenciais', 'Relato completo anonimizado #3', 'Credenciais expostas em site falso de instituição financeira.', 'VAZAMENTO_DADOS_BANCARIOS', 'CONCLUIDO', '2026-06-02');

INSERT INTO incidente_analise (incidente_id, pia_id, ia_risco_sugerido, ia_resumo, ia_confianca, ia_data_processamento, ia_status_processamento)
SELECT i.id, 100, 'ALTO',
    'Indivíduo vinculado a múltiplos relatos de phishing e golpe PIX com padrão recorrente.',
    0.92, CURRENT_TIMESTAMP - INTERVAL '2 days', 'CONCLUIDO'
FROM incidente i
WHERE i.pia_id = 100
ORDER BY i.id DESC
LIMIT 1;

UPDATE pia SET
    total_incidentes = 3,
    ultimo_incidente_id = (SELECT id FROM incidente WHERE pia_id = 100 ORDER BY id DESC LIMIT 1),
    data_ultimo_incidente = CURRENT_TIMESTAMP - INTERVAL '2 days',
    ia_risco_atual = 'ALTO',
    ia_ultimo_resumo = 'Indivíduo vinculado a múltiplos relatos de phishing e golpe PIX com padrão recorrente.'
WHERE id = 100;

-- -----------------------------------------------------
-- PIA 2: risco ALTO, status SUSPEITO
-- -----------------------------------------------------
INSERT INTO pia (id, grau_interesse, status, criado_por)
VALUES (101, 'ALTO', 'SUSPEITO', (SELECT id FROM usuario WHERE email = 'carlos.oliveira@onac.serpro.gov.br'));

INSERT INTO incidente (pia_id, titulo, descricao, descricao_anonimizada, tipo_fraude, status, data_ocorrencia)
VALUES (101, '[DEV] Ransomware em conta corporativa', 'Relato ransomware', 'Arquivos criptografados após abertura de anexo malicioso em e-mail corporativo.', 'RANSOMWARE', 'CONCLUIDO', '2026-06-01');

INSERT INTO incidente_analise (incidente_id, pia_id, ia_risco_sugerido, ia_resumo, ia_confianca, ia_data_processamento, ia_status_processamento)
VALUES (
    (SELECT id FROM incidente WHERE pia_id = 101 LIMIT 1), 101, 'ALTO',
    'Ataque de ransomware com impacto operacional significativo; requer monitoramento contínuo.',
    0.88, CURRENT_TIMESTAMP - INTERVAL '1 day', 'CONCLUIDO'
);

UPDATE pia SET
    total_incidentes = 1,
    ultimo_incidente_id = (SELECT id FROM incidente WHERE pia_id = 101 LIMIT 1),
    data_ultimo_incidente = CURRENT_TIMESTAMP - INTERVAL '1 day',
    ia_risco_atual = 'ALTO',
    ia_ultimo_resumo = 'Ataque de ransomware com impacto operacional significativo; requer monitoramento contínuo.'
WHERE id = 101;

-- -----------------------------------------------------
-- PIA 3: risco MEDIO, status ATIVO
-- -----------------------------------------------------
INSERT INTO pia (id, grau_interesse, status, criado_por)
VALUES (102, 'MEDIO', 'ATIVO', (SELECT id FROM usuario WHERE email = 'julia.mendes@onac.serpro.gov.br'));

INSERT INTO incidente (pia_id, titulo, descricao, descricao_anonimizada, tipo_fraude, status, data_ocorrencia)
VALUES (102, '[DEV] WhatsApp clonado', 'Relato WhatsApp', 'Conta de mensagens clonada para solicitar transferências a contatos.', 'WHATSAPP_CLONADO', 'CONCLUIDO', '2026-05-20');

INSERT INTO incidente_analise (incidente_id, pia_id, ia_risco_sugerido, ia_resumo, ia_confianca, ia_data_processamento, ia_status_processamento)
VALUES (
    (SELECT id FROM incidente WHERE pia_id = 102 LIMIT 1), 102, 'MEDIO',
    'Clonagem de WhatsApp com tentativa de golpe financeiro contra terceiros.',
    0.75, CURRENT_TIMESTAMP - INTERVAL '5 days', 'CONCLUIDO'
);

UPDATE pia SET
    total_incidentes = 1,
    ultimo_incidente_id = (SELECT id FROM incidente WHERE pia_id = 102 LIMIT 1),
    data_ultimo_incidente = CURRENT_TIMESTAMP - INTERVAL '5 days',
    ia_risco_atual = 'MEDIO',
    ia_ultimo_resumo = 'Clonagem de WhatsApp com tentativa de golpe financeiro contra terceiros.'
WHERE id = 102;

-- -----------------------------------------------------
-- PIA 4: risco MEDIO, status ATIVO — fluxo via trigger (INSERT + UPDATE)
-- -----------------------------------------------------
INSERT INTO pia (id, grau_interesse, status, criado_por)
VALUES (103, 'MEDIO', 'ATIVO', (SELECT id FROM usuario WHERE email = 'carlos.oliveira@onac.serpro.gov.br'));

INSERT INTO incidente (pia_id, titulo, descricao, descricao_anonimizada, tipo_fraude, status, data_ocorrencia)
VALUES (103, '[DEV] Engenharia social telefônica', 'Relato telefone', 'Ligação fraudulenta se passando por suporte técnico solicitando acesso remoto.', 'ENGENHARIA_SOCIAL', 'CONCLUIDO', '2026-06-04');

INSERT INTO incidente_analise (incidente_id, ia_risco_sugerido, ia_resumo, ia_confianca, ia_status_processamento)
VALUES (
    (SELECT id FROM incidente WHERE pia_id = 103 LIMIT 1),
    'MEDIO',
    'Tentativa de engenharia social por telefone com solicitação de acesso remoto.',
    0.71,
    'NAO_INICIADO'
);

UPDATE incidente_analise SET
    ia_status_processamento = 'CONCLUIDO',
    ia_data_processamento = CURRENT_TIMESTAMP - INTERVAL '3 hours'
WHERE incidente_id = (SELECT id FROM incidente WHERE pia_id = 103 LIMIT 1);

-- -----------------------------------------------------
-- PIA 5: risco BAIXO, status INOCENTE
-- -----------------------------------------------------
INSERT INTO pia (id, grau_interesse, status, criado_por)
VALUES (104, 'BAIXO', 'INOCENTE', (SELECT id FROM usuario WHERE email = 'julia.mendes@onac.serpro.gov.br'));

INSERT INTO incidente (pia_id, titulo, descricao, descricao_anonimizada, tipo_fraude, status, data_ocorrencia)
VALUES (104, '[DEV] Tentativa de phishing isolada', 'Relato phishing', 'E-mail suspeito identificado e reportado antes de qualquer prejuízo.', 'PHISHING', 'ARQUIVADO', '2026-04-15');

INSERT INTO incidente_analise (incidente_id, pia_id, ia_risco_sugerido, ia_resumo, ia_confianca, ia_data_processamento, ia_status_processamento)
VALUES (
    (SELECT id FROM incidente WHERE pia_id = 104 LIMIT 1), 104, 'BAIXO',
    'Incidente isolado sem confirmação de prejuízo; classificado como baixo risco.',
    0.55, CURRENT_TIMESTAMP - INTERVAL '30 days', 'CONCLUIDO'
);

UPDATE pia SET
    total_incidentes = 1,
    ultimo_incidente_id = (SELECT id FROM incidente WHERE pia_id = 104 LIMIT 1),
    data_ultimo_incidente = CURRENT_TIMESTAMP - INTERVAL '30 days',
    ia_risco_atual = 'BAIXO',
    ia_ultimo_resumo = 'Incidente isolado sem confirmação de prejuízo; classificado como baixo risco.'
WHERE id = 104;

-- -----------------------------------------------------
-- PIA 6: risco BAIXO, status ARQUIVADO
-- -----------------------------------------------------
INSERT INTO pia (id, grau_interesse, status, criado_por)
VALUES (105, 'BAIXO', 'ARQUIVADO', (SELECT id FROM usuario WHERE email = 'admin@onac.serpro.gov.br'));

INSERT INTO incidente (pia_id, titulo, descricao, descricao_anonimizada, tipo_fraude, status, data_ocorrencia)
VALUES (105, '[DEV] Malware em download', 'Relato malware', 'Antivírus bloqueou download suspeito; nenhum dano confirmado.', 'MALWARE', 'ARQUIVADO', '2026-03-10');

INSERT INTO incidente_analise (incidente_id, pia_id, ia_risco_sugerido, ia_resumo, ia_confianca, ia_data_processamento, ia_status_processamento)
VALUES (
    (SELECT id FROM incidente WHERE pia_id = 105 LIMIT 1), 105, 'BAIXO',
    'Tentativa de malware bloqueada preventivamente; registro arquivado.',
    0.48, CURRENT_TIMESTAMP - INTERVAL '60 days', 'CONCLUIDO'
);

UPDATE pia SET
    total_incidentes = 1,
    ultimo_incidente_id = (SELECT id FROM incidente WHERE pia_id = 105 LIMIT 1),
    data_ultimo_incidente = CURRENT_TIMESTAMP - INTERVAL '60 days',
    ia_risco_atual = 'BAIXO',
    ia_ultimo_resumo = 'Tentativa de malware bloqueada preventivamente; registro arquivado.'
WHERE id = 105;

-- -----------------------------------------------------
-- PIA 7: risco ALTO, status ATIVO — dois incidentes
-- -----------------------------------------------------
INSERT INTO pia (id, grau_interesse, status, criado_por)
VALUES (106, 'ALTO', 'ATIVO', (SELECT id FROM usuario WHERE email = 'carlos.oliveira@onac.serpro.gov.br'));

INSERT INTO incidente (pia_id, titulo, descricao, descricao_anonimizada, tipo_fraude, status, data_ocorrencia)
VALUES
    (106, '[DEV] Roubo de identidade digital', 'Relato identidade #1', 'Contas online acessadas com credenciais comprometidas.', 'ROUBO_IDENTIDADE', 'CONCLUIDO', '2026-05-05'),
    (106, '[DEV] Fraude em marketplace', 'Relato identidade #2', 'Anúncio falso em marketplace usando identidade digital roubada.', 'OUTRO', 'EM_ANALISE', '2026-06-03');

INSERT INTO incidente_analise (incidente_id, pia_id, ia_risco_sugerido, ia_resumo, ia_confianca, ia_data_processamento, ia_status_processamento)
VALUES (
    (SELECT id FROM incidente WHERE pia_id = 106 ORDER BY id DESC LIMIT 1), 106, 'ALTO',
    'Padrão de roubo de identidade com reutilização em plataformas de e-commerce.',
    0.85, CURRENT_TIMESTAMP - INTERVAL '12 hours', 'CONCLUIDO'
);

UPDATE pia SET
    total_incidentes = 2,
    ultimo_incidente_id = (SELECT id FROM incidente WHERE pia_id = 106 ORDER BY id DESC LIMIT 1),
    data_ultimo_incidente = CURRENT_TIMESTAMP - INTERVAL '12 hours',
    ia_risco_atual = 'ALTO',
    ia_ultimo_resumo = 'Padrão de roubo de identidade com reutilização em plataformas de e-commerce.'
WHERE id = 106;

-- -----------------------------------------------------
-- PIA 8: registro mínimo (sem análise IA concluída)
-- -----------------------------------------------------
INSERT INTO pia (id, grau_interesse, status, criado_por)
VALUES (107, 'MEDIO', 'ATIVO', (SELECT id FROM usuario WHERE email = 'carlos.oliveira@onac.serpro.gov.br'));

INSERT INTO incidente (pia_id, titulo, descricao, descricao_anonimizada, tipo_fraude, status)
VALUES (107, '[DEV] Denúncia anônima pendente', 'Relato pendente', 'Denúncia recebida aguardando processamento pela IA.', 'OUTRO', 'PENDENTE');

INSERT INTO incidente_analise (incidente_id, pia_id, ia_status_processamento)
VALUES (
    (SELECT id FROM incidente WHERE pia_id = 107 LIMIT 1), 107, 'NAO_INICIADO'
);

COMMIT;
