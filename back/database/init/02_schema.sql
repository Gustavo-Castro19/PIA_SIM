-- =====================================================
-- Tabelas do sistema - Lista PIA
-- Identificador público: pia.id (BIGSERIAL)
-- =====================================================

-- -----------------------------------------------------
-- TABELA: usuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS usuario (
    id                      BIGSERIAL PRIMARY KEY,
    nome                    VARCHAR(150) NOT NULL,
    email                   VARCHAR(255) NOT NULL UNIQUE,
    senha_hash              VARCHAR(255) NOT NULL,
    perfil                  VARCHAR(30) NOT NULL DEFAULT 'ANALISTA'
                            CHECK (perfil IN ('ADMIN', 'GESTOR', 'ANALISTA')),
    ativo                   BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE usuario IS 'Usuários internos do sistema (analistas antifraude, gestores de dados, administradores)';
COMMENT ON COLUMN usuario.perfil IS 'ADMIN: acesso total | GESTOR: relatórios e filtros | ANALISTA: triagem e análise';

-- -----------------------------------------------------
-- TABELA: pia (Pessoas de Interesse Antifraude)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pia (
    id                      BIGSERIAL PRIMARY KEY,

    grau_interesse          VARCHAR(20) NOT NULL DEFAULT 'MEDIO'
                            CHECK (grau_interesse IN ('ALTO', 'MEDIO', 'BAIXO')),
    status                  VARCHAR(30) NOT NULL DEFAULT 'ATIVO'
                            CHECK (status IN ('ATIVO', 'SUSPEITO', 'CONFIRMADO', 'INOCENTE', 'ARQUIVADO')),

    total_incidentes        INTEGER NOT NULL DEFAULT 0,
    ultimo_incidente_id     BIGINT,
    data_ultimo_incidente   TIMESTAMP,

    ia_risco_atual          VARCHAR(10)
                            CHECK (ia_risco_atual IN ('ALTO', 'MEDIO', 'BAIXO')),
    ia_ultimo_resumo        VARCHAR(500),

    criado_por              BIGINT REFERENCES usuario(id),
    data_criacao            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE pia IS 'Lista PIA - Pessoas de Interesse Antifraude (dados anonimizados para operação)';
COMMENT ON COLUMN pia.grau_interesse IS 'Nível de atenção do analista baseado em padrões históricos';
COMMENT ON COLUMN pia.ia_risco_atual IS 'Risco mais recente sugerido pela IA (sincronizado com incidente_analise)';

-- -----------------------------------------------------
-- TABELA: incidente
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS incidente (
    id                      BIGSERIAL PRIMARY KEY,
    pia_id                  BIGINT REFERENCES pia(id),

    titulo                  VARCHAR(300) NOT NULL,
    descricao               TEXT NOT NULL,
    descricao_anonimizada   TEXT,

    tipo_fraude             VARCHAR(50) NOT NULL
                            CHECK (tipo_fraude IN (
                                'PHISHING', 'WHATSAPP_CLONADO', 'VAZAMENTO_DADOS_BANCARIOS',
                                'GOLPE_PIX', 'ROUBO_IDENTIDADE', 'ENGENHARIA_SOCIAL',
                                'MALWARE', 'RANSOMWARE', 'OUTRO'
                            )),

    status                  VARCHAR(30) NOT NULL DEFAULT 'PENDENTE'
                            CHECK (status IN ('PENDENTE', 'PENDENTE_ANALISE_MANUAL', 'EM_ANALISE', 'CONCLUIDO', 'ARQUIVADO')),

    canal_recebimento       VARCHAR(30) NOT NULL DEFAULT 'FORMULARIO_WEB'
                            CHECK (canal_recebimento IN ('FORMULARIO_WEB', 'TELEFONE', 'EMAIL', 'DENUNCIA_ANONIMA')),

    data_ocorrencia         DATE,
    data_criacao            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE incidente IS 'Registros de fraudes cibernéticas reportadas (vinculados a um registro PIA)';
COMMENT ON COLUMN incidente.pia_id IS 'Referência ao registro PIA associado ao incidente';
COMMENT ON COLUMN incidente.descricao_anonimizada IS 'Texto limpo sem CPF, nome ou dados pessoais (input para IA)';
COMMENT ON COLUMN incidente.status IS 'PENDENTE: novo | PENDENTE_ANALISE_MANUAL: IA indisponível | EM_ANALISE: em investigação | CONCLUIDO: finalizado | ARQUIVADO: sem procedimento';

ALTER TABLE pia
    DROP CONSTRAINT IF EXISTS fk_pia_ultimo_incidente;

ALTER TABLE pia
    ADD CONSTRAINT fk_pia_ultimo_incidente
    FOREIGN KEY (ultimo_incidente_id) REFERENCES incidente(id);

-- -----------------------------------------------------
-- TABELA: incidente_analise
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS incidente_analise (
    id                      BIGSERIAL PRIMARY KEY,
    incidente_id            BIGINT NOT NULL UNIQUE REFERENCES incidente(id) ON DELETE CASCADE,
    pia_id                  BIGINT REFERENCES pia(id),

    ia_risco_sugerido       VARCHAR(10)
                            CHECK (ia_risco_sugerido IN ('ALTO', 'MEDIO', 'BAIXO')),
    ia_resumo               VARCHAR(500),
    ia_confianca            DECIMAL(3,2),
    ia_data_processamento   TIMESTAMP,
    ia_status_processamento VARCHAR(30) DEFAULT 'NAO_INICIADO'
                            CHECK (ia_status_processamento IN ('NAO_INICIADO', 'PROCESSANDO', 'CONCLUIDO', 'FALHA', 'TIMEOUT')),

    risco_validado          VARCHAR(10)
                            CHECK (risco_validado IN ('ALTO', 'MEDIO', 'BAIXO')),
    analista_id             BIGINT REFERENCES usuario(id),
    data_validacao          TIMESTAMP,
    observacoes_analista    TEXT,

    palavras_chave_extraidas JSONB,

    data_criacao            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE incidente_analise IS 'Resultados da análise de IA e validação humana dos incidentes';
COMMENT ON COLUMN incidente_analise.pia_id IS 'Referência denormalizada ao registro PIA (via incidente.pia_id)';
COMMENT ON COLUMN incidente_analise.ia_risco_sugerido IS 'Classificação automática: ALTO (vazamento bancário), MEDIO (phishing), BAIXO (tentativa)';
COMMENT ON COLUMN incidente_analise.ia_resumo IS 'Resumo estritamente proibido de conter nomes ou CPFs';
COMMENT ON COLUMN incidente_analise.ia_confianca IS 'Nível de confiança da IA (0.00 a 1.00)';
COMMENT ON COLUMN incidente_analise.ia_status_processamento IS 'NAO_INICIADO: aguardando | PROCESSANDO: em andamento | CONCLUIDO: finalizado | FALHA: erro IA | TIMEOUT: demora excessiva';

-- -----------------------------------------------------
-- TABELA: pia_historico
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS pia_historico (
    id                      BIGSERIAL PRIMARY KEY,
    pia_id                  BIGINT NOT NULL REFERENCES pia(id) ON DELETE CASCADE,

    tipo_operacao           VARCHAR(20) NOT NULL
                            CHECK (tipo_operacao IN ('INCLUSAO', 'EDICAO', 'EXCLUSAO', 'ATUALIZACAO_RISCO', 'ATUALIZACAO_STATUS')),

    grau_interesse_anterior VARCHAR(20),
    grau_interesse_novo     VARCHAR(20),
    status_anterior         VARCHAR(30),
    status_novo             VARCHAR(30),

    motivo_alteracao        TEXT,
    usuario_id              BIGINT NOT NULL REFERENCES usuario(id),
    data_operacao           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE pia_historico IS 'Auditoria completa de todas as alterações na Lista PIA (LGPD compliance)';
COMMENT ON COLUMN pia_historico.tipo_operacao IS 'INCLUSAO: novo registro | EDICAO: alteração | EXCLUSAO: remoção | ATUALIZACAO_RISCO/STATUS: mudança automática';
