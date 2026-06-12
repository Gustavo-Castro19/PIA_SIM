-- Índices para performance

CREATE INDEX IF NOT EXISTS idx_incidente_pia_id ON incidente(pia_id);
CREATE INDEX IF NOT EXISTS idx_incidente_status ON incidente(status);
CREATE INDEX IF NOT EXISTS idx_incidente_tipo ON incidente(tipo_fraude);
CREATE INDEX IF NOT EXISTS idx_incidente_data ON incidente(data_criacao);
CREATE INDEX IF NOT EXISTS idx_incidente_status_data ON incidente(status, data_criacao);

CREATE INDEX IF NOT EXISTS idx_analise_pia_id ON incidente_analise(pia_id);
CREATE INDEX IF NOT EXISTS idx_analise_risco ON incidente_analise(ia_risco_sugerido);
CREATE INDEX IF NOT EXISTS idx_analise_status ON incidente_analise(ia_status_processamento);
CREATE INDEX IF NOT EXISTS idx_analise_data ON incidente_analise(data_criacao);

CREATE INDEX IF NOT EXISTS idx_pia_risco ON pia(ia_risco_atual);
CREATE INDEX IF NOT EXISTS idx_pia_status ON pia(status);
CREATE INDEX IF NOT EXISTS idx_pia_grau ON pia(grau_interesse);
CREATE INDEX IF NOT EXISTS idx_pia_data ON pia(data_atualizacao);
CREATE INDEX IF NOT EXISTS idx_pia_composto ON pia(ia_risco_atual, status, data_atualizacao);

CREATE INDEX IF NOT EXISTS idx_historico_pia ON pia_historico(pia_id);
CREATE INDEX IF NOT EXISTS idx_historico_data ON pia_historico(data_operacao);
CREATE INDEX IF NOT EXISTS idx_historico_usuario ON pia_historico(usuario_id);
