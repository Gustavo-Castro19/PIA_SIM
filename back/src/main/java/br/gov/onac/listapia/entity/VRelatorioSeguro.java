package br.gov.onac.listapia.entity;

import br.gov.onac.listapia.entity.enums.GrauInteresse;
import br.gov.onac.listapia.entity.enums.Risco;
import br.gov.onac.listapia.entity.enums.StatusPia;
import br.gov.onac.listapia.entity.enums.TipoFraude;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Immutable
@Table(name = "v_relatorio_seguro")
@Getter
@NoArgsConstructor
public class VRelatorioSeguro {

    @Id
    @Column(name = "pia_id")
    private Long piaId;

    @Enumerated(EnumType.STRING)
    @Column(name = "ia_risco_atual", length = 10)
    private Risco iaRiscoAtual;

    @Enumerated(EnumType.STRING)
    @Column(name = "grau_interesse", length = 20)
    private GrauInteresse grauInteresse;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    private StatusPia status;

    @Column(name = "total_incidentes")
    private Integer totalIncidentes;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_fraude", length = 50)
    private TipoFraude tipoFraude;

    @Column(name = "data_ocorrencia")
    private LocalDate dataOcorrencia;

    @Column(name = "data_registro")
    private LocalDateTime dataRegistro;

    @Column(name = "ia_resumo", length = 500)
    private String iaResumo;

    @Column(name = "ia_confianca", precision = 3, scale = 2)
    private BigDecimal iaConfianca;

    @Column(name = "data_validacao")
    private LocalDateTime dataValidacao;

    @Column(name = "analista_validador", length = 150)
    private String analistaValidador;
}
