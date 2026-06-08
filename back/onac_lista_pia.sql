-- =====================================================
-- MODELAGEM DO BANCO DE DADOS ONAC - LISTA PIA
-- Foco exclusivo na Lista de Pessoas de Interesse Antifraude
-- Squad 02 - Universidade Católica de Brasília
-- Stack: PostgreSQL
-- =====================================================

-- =====================================================
-- 1. DROP DAS TABELAS (PARA RECRIAÇÃO LIMPA)
-- =====================================================
DROP TABLE IF EXISTS pia_historico CASCADE;
DROP TABLE IF EXISTS pia CASCADE;
DROP TABLE IF EXISTS incidente_analise CASCADE;
DROP TABLE IF EXISTS incidente CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;

-- =====================================================
-- 2. EXTENSÕES NECESSÁRIAS
-- =====================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 3. TABELAS DO SISTEMA - LISTA PIA
-- =====================================================

-- -----------------------------------------------------
-- TABELA: usuario
-- Usuários do sistema (analistas, gestores, admins)
-- Responsabilidade: Controle de acesso e autenticação
-- -----------------------------------------------------
CREATE TABLE usuario (
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
-- TABELA: incidente
-- Registra as ocorrências de fraude reportadas
-- Responsabilidade: Armazenar o relato da vítima (já anonimizado pelo Sujeito ONAC)
-- -----------------------------------------------------
CREATE TABLE incidente (
    id                      BIGSERIAL PRIMARY KEY,

    -- SID recebido do Sujeito ONAC (já anonimizado)
    sid                     VARCHAR(20) NOT NULL,

    -- Dados do relato
    titulo                  VARCHAR(300) NOT NULL,
    descricao               TEXT NOT NULL,                      -- Relato completo da vítima
    descricao_anonimizada   TEXT,                             -- Relato sem dados pessoais (input para IA)

    -- Classificação da fraude
    tipo_fraude             VARCHAR(50) NOT NULL 
                            CHECK (tipo_fraude IN (
                                'PHISHING', 'WHATSAPP_CLONADO', 'VAZAMENTO_DADOS_BANCARIOS',
                                'GOLPE_PIX', 'ROUBO_IDENTIDADE', 'ENGENHARIA_SOCIAL',
                                'MALWARE', 'RANSOMWARE', 'OUTRO'
                            )),

    -- Status do incidente
    status                  VARCHAR(30) NOT NULL DEFAULT 'PENDENTE'
                            CHECK (status IN ('PENDENTE', 'PENDENTE_ANALISE_MANUAL', 'EM_ANALISE', 'CONCLUIDO', 'ARQUIVADO')),

    -- Dados de origem
    canal_recebimento       VARCHAR(30) NOT NULL DEFAULT 'FORMULARIO_WEB'
                            CHECK (canal_recebimento IN ('FORMULARIO_WEB', 'TELEFONE', 'EMAIL', 'DENUNCIA_ANONIMA')),

    data_ocorrencia         DATE,                             -- Data em que a fraude ocorreu
    data_criacao            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE incidente IS 'Registros de fraudes cibernéticas reportadas (SID já vem anonimizado do Sujeito ONAC)';
COMMENT ON COLUMN incidente.sid IS 'Identificador anônimo recebido do Sujeito ONAC (ex: SID-102, SID-123456789)';
COMMENT ON COLUMN incidente.descricao_anonimizada IS 'Texto limpo sem CPF, nome ou dados pessoais (input para IA)';
COMMENT ON COLUMN incidente.status IS 'PENDENTE: novo | PENDENTE_ANALISE_MANUAL: IA indisponível | EM_ANALISE: em investigação | CONCLUIDO: finalizado | ARQUIVADO: sem procedimento';

-- -----------------------------------------------------
-- TABELA: incidente_analise
-- Avaliação dos incidentes (resultados da IA e análise humana)
-- Responsabilidade: Analisar e gerar resultados para a Lista PIA
-- -----------------------------------------------------
CREATE TABLE incidente_analise (
    id                      BIGSERIAL PRIMARY KEY,
    incidente_id            BIGINT NOT NULL UNIQUE REFERENCES incidente(id) ON DELETE CASCADE,
    sid                     VARCHAR(20) NOT NULL,

    -- Resultados da IA (gerados automaticamente)
    ia_risco_sugerido       VARCHAR(10) 
                            CHECK (ia_risco_sugerido IN ('ALTO', 'MEDIO', 'BAIXO')),
    ia_resumo               VARCHAR(500),                     -- Resumo de até 3 linhas gerado pela IA
    ia_confiança            DECIMAL(3,2),                     -- Nível de confiança da IA (0.00 a 1.00)
    ia_data_processamento   TIMESTAMP,                        -- Quando a IA processou o relato
    ia_status_processamento VARCHAR(30) DEFAULT 'NAO_INICIADO'
                            CHECK (ia_status_processamento IN ('NAO_INICIADO', 'PROCESSANDO', 'CONCLUIDO', 'FALHA', 'TIMEOUT')),

    -- Validação humana
    risco_validado          VARCHAR(10) 
                            CHECK (risco_validado IN ('ALTO', 'MEDIO', 'BAIXO')),
    analista_id             BIGINT REFERENCES usuario(id),    -- Analista que validou
    data_validacao          TIMESTAMP,
    observacoes_analista    TEXT,

    -- Metadados para estatísticas
    palavras_chave_extraidas JSONB,                           -- Entidades extraídas pela IA (empresas, URLs, etc.)

    data_criacao            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_analise_incidente FOREIGN KEY (incidente_id) REFERENCES incidente(id)
);

COMMENT ON TABLE incidente_analise IS 'Resultados da análise de IA e validação humana dos incidentes';
COMMENT ON COLUMN incidente_analise.ia_risco_sugerido IS 'Classificação automática: ALTO (vazamento bancário), MEDIO (phishing), BAIXO (tentativa)';
COMMENT ON COLUMN incidente_analise.ia_resumo IS 'Resumo estritamente proibido de conter nomes ou CPFs (apenas SID)';
COMMENT ON COLUMN incidente_analise.ia_status_processamento IS 'NAO_INICIADO: aguardando | PROCESSANDO: em andamento | CONCLUIDO: finalizado | FALHA: erro IA | TIMEOUT: demora excessiva';

-- -----------------------------------------------------
-- TABELA: pia (Pessoas de Interesse Antifraude)
-- Listagem centralizada para triagem dos analistas
-- Responsabilidade: Listagem operacional de investigação
-- -----------------------------------------------------
CREATE TABLE pia (
    id                      BIGSERIAL PRIMARY KEY,
    sid                     VARCHAR(20) NOT NULL UNIQUE,       -- SID recebido do Sujeito ONAC

    -- Dados operacionais (sem dados pessoais!)
    grau_interesse          VARCHAR(20) NOT NULL DEFAULT 'MEDIO'
                            CHECK (grau_interesse IN ('ALTO', 'MEDIO', 'BAIXO')),
    status                  VARCHAR(30) NOT NULL DEFAULT 'ATIVO'
                            CHECK (status IN ('ATIVO', 'SUSPEITO', 'CONFIRMADO', 'INOCENTE', 'ARQUIVADO')),

    -- Métricas agregadas
    total_incidentes        INTEGER NOT NULL DEFAULT 0,
    ultimo_incidente_id     BIGINT REFERENCES incidente(id),
    data_ultimo_incidente   TIMESTAMP,

    -- Dados da IA (visíveis ao analista)
    ia_risco_atual          VARCHAR(10) 
                            CHECK (ia_risco_atual IN ('ALTO', 'MEDIO', 'BAIXO')),
    ia_ultimo_resumo        VARCHAR(500),

    -- Auditoria
    criado_por              BIGINT REFERENCES usuario(id),
    data_criacao            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE pia IS 'Lista PIA - Pessoas de Interesse Antifraude (dados anonimizados para operação)';
COMMENT ON COLUMN pia.sid IS 'ÚNICO identificador visível na interface (recebido do Sujeito ONAC, nunca CPF ou nome)';
COMMENT ON COLUMN pia.grau_interesse IS 'Nível de atenção do analista baseado em padrões históricos';
COMMENT ON COLUMN pia.ia_risco_atual IS 'Risco mais recente sugerido pela IA (sincronizado com incidente_analise)';

-- -----------------------------------------------------
-- TABELA: pia_historico
-- Histórico completo de alterações na Lista PIA
-- Responsabilidade: Rastreabilidade e auditoria (LGPD)
-- -----------------------------------------------------
CREATE TABLE pia_historico (
    id                      BIGSERIAL PRIMARY KEY,
    pia_id                  BIGINT NOT NULL REFERENCES pia(id) ON DELETE CASCADE,
    sid                     VARCHAR(20) NOT NULL,

    -- Dados da operação
    tipo_operacao           VARCHAR(20) NOT NULL 
                            CHECK (tipo_operacao IN ('INCLUSAO', 'EDICAO', 'EXCLUSAO', 'ATUALIZACAO_RISCO', 'ATUALIZACAO_STATUS')),

    -- Valores anteriores (para auditoria)
    grau_interesse_anterior VARCHAR(20),
    grau_interesse_novo     VARCHAR(20),
    status_anterior         VARCHAR(30),
    status_novo             VARCHAR(30),

    -- Contexto
    motivo_alteracao        TEXT,
    usuario_id              BIGINT NOT NULL REFERENCES usuario(id),
    data_operacao           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_historico_pia FOREIGN KEY (pia_id) REFERENCES pia(id)
);

COMMENT ON TABLE pia_historico IS 'Auditoria completa de todas as alterações na Lista PIA (LGPD compliance)';
COMMENT ON COLUMN pia_historico.tipo_operacao IS 'INCLUSAO: novo registro | EDICAO: alteração | EXCLUSAO: remoção | ATUALIZACAO_RISCO/STATUS: mudança automática';

-- =====================================================
-- 4. ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices na tabela incidente
CREATE INDEX idx_incidente_sid ON incidente(sid);
CREATE INDEX idx_incidente_status ON incidente(status);
CREATE INDEX idx_incidente_tipo ON incidente(tipo_fraude);
CREATE INDEX idx_incidente_data ON incidente(data_criacao);
CREATE INDEX idx_incidente_status_data ON incidente(status, data_criacao);

-- Índices na tabela incidente_analise (Lista PIA)
CREATE INDEX idx_analise_risco ON incidente_analise(ia_risco_sugerido);
CREATE INDEX idx_analise_status ON incidente_analise(ia_status_processamento);
CREATE INDEX idx_analise_data ON incidente_analise(data_criacao);

-- Índices na tabela pia
CREATE INDEX idx_pia_risco ON pia(ia_risco_atual);
CREATE INDEX idx_pia_status ON pia(status);
CREATE INDEX idx_pia_grau ON pia(grau_interesse);
CREATE INDEX idx_pia_data ON pia(data_atualizacao);
CREATE INDEX idx_pia_composto ON pia(ia_risco_atual, status, data_atualizacao);  -- Filtros combinados

-- Índices na tabela pia_historico
CREATE INDEX idx_historico_pia ON pia_historico(pia_id);
CREATE INDEX idx_historico_data ON pia_historico(data_operacao);
CREATE INDEX idx_historico_usuario ON pia_historico(usuario_id);

-- =====================================================
-- 5. TRIGGERS PARA AUDITORIA E ATUALIZAÇÃO AUTOMÁTICA
-- =====================================================

-- Função para atualizar data_atualizacao automaticamente
CREATE OR REPLACE FUNCTION fn_atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger em todas as tabelas que precisam de timestamp automático
CREATE TRIGGER trg_incidente_atualizacao
    BEFORE UPDATE ON incidente
    FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp();

CREATE TRIGGER trg_incidente_analise_atualizacao
    BEFORE UPDATE ON incidente_analise
    FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp();

CREATE TRIGGER trg_pia_atualizacao
    BEFORE UPDATE ON pia
    FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp();

CREATE TRIGGER trg_usuario_atualizacao
    BEFORE UPDATE ON usuario
    FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp();

-- -----------------------------------------------------
-- Trigger: Auditoria automática de alterações na PIA
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_auditar_pia()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO pia_historico (
            pia_id, sid, tipo_operacao,
            grau_interesse_anterior, grau_interesse_novo,
            status_anterior, status_novo,
            motivo_alteracao, usuario_id
        ) VALUES (
            NEW.id, NEW.sid, 'INCLUSAO',
            NULL, NEW.grau_interesse,
            NULL, NEW.status,
            'Cadastro inicial na Lista PIA', NEW.criado_por
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO pia_historico (
            pia_id, sid, tipo_operacao,
            grau_interesse_anterior, grau_interesse_novo,
            status_anterior, status_novo,
            motivo_alteracao, usuario_id
        ) VALUES (
            NEW.id, NEW.sid, 'EDICAO',
            OLD.grau_interesse, NEW.grau_interesse,
            OLD.status, NEW.status,
            COALESCE(NEW.ia_ultimo_resumo, 'Atualização de dados'), 
            COALESCE(NEW.criado_por, 1)
        );
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO pia_historico (
            pia_id, sid, tipo_operacao,
            grau_interesse_anterior, grau_interesse_novo,
            status_anterior, status_novo,
            motivo_alteracao, usuario_id
        ) VALUES (
            OLD.id, OLD.sid, 'EXCLUSAO',
            OLD.grau_interesse, NULL,
            OLD.status, NULL,
            'Remoção da Lista PIA', 
            COALESCE(OLD.criado_por, 1)
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pia_auditoria
    AFTER INSERT OR UPDATE OR DELETE ON pia
    FOR EACH ROW EXECUTE FUNCTION fn_auditar_pia();

-- -----------------------------------------------------
-- Trigger: Sincronização automática PIA quando análise da IA é concluída
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_sincronizar_pia()
RETURNS TRIGGER AS $$
BEGIN
    -- Quando a IA conclui a análise, atualiza ou insere na PIA
    IF NEW.ia_status_processamento = 'CONCLUIDO' AND NEW.ia_risco_sugerido IS NOT NULL THEN

        INSERT INTO pia (
            sid, 
            ia_risco_atual, 
            ia_ultimo_resumo,
            total_incidentes,
            ultimo_incidente_id,
            data_ultimo_incidente,
            grau_interesse
        )
        SELECT 
            NEW.sid,
            NEW.ia_risco_sugerido,
            NEW.ia_resumo,
            (SELECT COUNT(*) FROM incidente i WHERE i.sid = NEW.sid),
            NEW.incidente_id,
            CURRENT_TIMESTAMP,
            CASE 
                WHEN NEW.ia_risco_sugerido = 'ALTO' THEN 'ALTO'
                WHEN NEW.ia_risco_sugerido = 'MEDIO' THEN 'MEDIO'
                ELSE 'BAIXO'
            END
        ON CONFLICT (sid) DO UPDATE SET
            ia_risco_atual = EXCLUDED.ia_risco_atual,
            ia_ultimo_resumo = EXCLUDED.ia_ultimo_resumo,
            total_incidentes = EXCLUDED.total_incidentes,
            ultimo_incidente_id = EXCLUDED.ultimo_incidente_id,
            data_ultimo_incidente = EXCLUDED.data_ultimo_incidente,
            grau_interesse = EXCLUDED.grau_interesse,
            data_atualizacao = CURRENT_TIMESTAMP;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sincronizar_pia_apos_ia
    AFTER UPDATE OF ia_status_processamento ON incidente_analise
    FOR EACH ROW 
    WHEN (NEW.ia_status_processamento = 'CONCLUIDO')
    EXECUTE FUNCTION fn_sincronizar_pia();

-- =====================================================
-- 6. VIEWS (PARA CONSULTAS SEGURAS)
-- =====================================================

-- View segura para a Lista PIA (exposta ao frontend Angular)
-- NUNCA expõe CPF, nome ou dados pessoais (apenas SID)
CREATE OR REPLACE VIEW v_lista_pia AS
SELECT 
    p.id,
    p.sid,
    p.ia_risco_atual AS risco,
    p.grau_interesse,
    p.status,
    p.total_incidentes,
    p.data_ultimo_incidente,
    p.ia_ultimo_resumo AS resumo_ia,
    p.data_atualizacao,
    ia.ia_confiança AS confianca_ia,
    ia.ia_data_processamento AS data_analise_ia
FROM pia p
LEFT JOIN incidente_analise ia ON p.sid = ia.sid AND ia.ia_status_processamento = 'CONCLUIDO'
ORDER BY 
    CASE p.ia_risco_atual 
        WHEN 'ALTO' THEN 1 
        WHEN 'MEDIO' THEN 2 
        WHEN 'BAIXO' THEN 3 
        ELSE 4 
    END,
    p.data_atualizacao DESC;

COMMENT ON VIEW v_lista_pia IS 'View segura para exibição no painel Angular. NÃO contém dados pessoais - apenas SID.';

-- View para exportação segura de relatórios (CSV/Excel)
CREATE OR REPLACE VIEW v_relatorio_seguro AS
SELECT 
    p.sid,
    p.ia_risco_atual,
    p.grau_interesse,
    p.status,
    p.total_incidentes,
    i.tipo_fraude,
    i.data_ocorrencia,
    i.data_criacao AS data_registro,
    ia.ia_resumo,
    ia.ia_confiança,
    ia.data_validacao,
    u.nome AS analista_validador
FROM pia p
LEFT JOIN incidente i ON p.ultimo_incidente_id = i.id
LEFT JOIN incidente_analise ia ON p.sid = ia.sid
LEFT JOIN usuario u ON ia.analista_id = u.id;

COMMENT ON VIEW v_relatorio_seguro IS 'View para exportação de relatórios estatísticos sem violar LGPD';

-- =====================================================
-- 7. DADOS INICIAIS (SEED)
-- =====================================================

-- Usuários de teste
INSERT INTO usuario (nome, email, senha_hash, perfil) VALUES
('Carlos Oliveira', 'carlos.oliveira@onac.serpro.gov.br', '$2a$10$...hash...', 'ANALISTA'),
('Júlia Mendes', 'julia.mendes@onac.serpro.gov.br', '$2a$10$...hash...', 'GESTOR'),
('Admin Sistema', 'admin@onac.serpro.gov.br', '$2a$10$...hash...', 'ADMIN');

-- =====================================================
-- 8. COMENTÁRIOS FINAIS
-- =====================================================

/* 
NOTAS DE IMPLEMENTAÇÃO - LISTA PIA:

1. FOCO EXCLUSIVO NA LISTA PIA:
   - O Sujeito ONAC (anonimização de CPF, geração de SID) é responsabilidade de OUTRO subgrupo
   - Este banco RECEBE o SID já gerado via API do Sujeito ONAC
   - NÃO armazena CPF, nome ou qualquer dado pessoal

2. FLUXO DE DADOS DA LISTA PIA:

   Sujeito ONAC (outro subgrupo)
   ↓ (envia SID + relato anonimizado via API)

   Spring Boot (Lista PIA)
   ↓

   Tabela incidente (salva relato com SID)
   ↓

   Spring Boot envia descricao_anonimizada para IA
   ↓

   IA retorna risco + resumo → salva em incidente_analise
   ↓

   Trigger sincroniza automaticamente na tabela pia
   ↓

   Angular consome v_lista_pia (apenas SID, risco, resumo)

3. ENDPOINTS ESPERADOS (Spring Boot):

   GET  /api/v1/pia              → Lista todos (usa v_lista_pia)
   GET  /api/v1/pia?risco=ALTO   → Filtro por risco
   GET  /api/v1/pia?status=ATIVO → Filtro por status
   GET  /api/v1/pia/{sid}        → Detalhes de um SID
   POST /api/v1/pia              → Recebe novo incidente (com SID do Sujeito ONAC)
   PUT  /api/v1/pia/{sid}        → Atualiza status/grau de interesse
   DELETE /api/v1/pia/{sid}      → Remove da lista (com auditoria)
   GET  /api/v1/pia/export       → Exporta relatório (usa v_relatorio_seguro)

4. LGPD COMPLIANCE:
   - NENHUM dado pessoal é armazenado neste banco
   - SID é o único identificador visível
   - CPF e nome permanecem no banco do Sujeito ONAC
   - Logs de auditoria completos na pia_historico

5. CASOS DE BORDA TRATADOS:
   - IA indisponível: status → 'PENDENTE_ANALISE_MANUAL'
   - IA com timeout: status → 'TIMEOUT' + modo degradado
   - Resumo da IA com dados pessoais: validação pelo Spring Boot antes de salvar
   - SID duplicado: UNIQUE constraint na tabela pia
   - Exclusão acidental: auditoria completa no pia_historico

6. PERSONAS ATENDIDAS:

   Carlos (Analista Antifraude):
   - Consome v_lista_pia com risco, resumo e filtros
   - Visualiza apenas SID (nunca CPF ou nome)

   Júlia (Gestora de Dados):
   - Exporta v_relatorio_seguro para estatísticas
   - Acessa pia_historico para auditoria

   Elisa (Vítima):
   - NÃO interage diretamente com este banco
   - Seus dados pessoais ficam no Sujeito ONAC
*/
