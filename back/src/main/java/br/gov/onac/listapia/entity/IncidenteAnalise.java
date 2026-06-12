package br.gov.onac.listapia.entity;

import br.gov.onac.listapia.entity.enums.IaStatusProcessamento;
import br.gov.onac.listapia.entity.enums.Risco;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "incidente_analise")
@Getter
@Setter
@NoArgsConstructor
public class IncidenteAnalise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "incidente_id", nullable = false, unique = true)
    private Incidente incidente;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pia_id")
    private Pia pia;

    @Enumerated(EnumType.STRING)
    @Column(name = "ia_risco_sugerido", length = 10)
    private Risco iaRiscoSugerido;

    @Column(name = "ia_resumo", length = 500)
    private String iaResumo;

    @Column(name = "ia_confianca", precision = 3, scale = 2)
    private BigDecimal iaConfianca;

    @Column(name = "ia_data_processamento")
    private LocalDateTime iaDataProcessamento;

    @Enumerated(EnumType.STRING)
    @Column(name = "ia_status_processamento", length = 30)
    private IaStatusProcessamento iaStatusProcessamento = IaStatusProcessamento.NAO_INICIADO;

    @Enumerated(EnumType.STRING)
    @Column(name = "risco_validado", length = 10)
    private Risco riscoValidado;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "analista_id")
    private Usuario analista;

    @Column(name = "data_validacao")
    private LocalDateTime dataValidacao;

    @Column(name = "observacoes_analista", columnDefinition = "TEXT")
    private String observacoesAnalista;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "palavras_chave_extraidas", columnDefinition = "jsonb")
    private Map<String, Object> palavrasChaveExtraidas;

    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    private LocalDateTime dataAtualizacao;
}
