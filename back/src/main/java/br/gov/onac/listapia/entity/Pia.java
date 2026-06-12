package br.gov.onac.listapia.entity;

import br.gov.onac.listapia.entity.enums.GrauInteresse;
import br.gov.onac.listapia.entity.enums.Risco;
import br.gov.onac.listapia.entity.enums.StatusPia;
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
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "pia")
@Getter
@Setter
@NoArgsConstructor
public class Pia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "grau_interesse", nullable = false, length = 20)
    private GrauInteresse grauInteresse = GrauInteresse.MEDIO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private StatusPia status = StatusPia.ATIVO;

    @Column(name = "total_incidentes", nullable = false)
    private Integer totalIncidentes = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ultimo_incidente_id")
    private Incidente ultimoIncidente;

    @Column(name = "data_ultimo_incidente")
    private LocalDateTime dataUltimoIncidente;

    @Enumerated(EnumType.STRING)
    @Column(name = "ia_risco_atual", length = 10)
    private Risco iaRiscoAtual;

    @Column(name = "ia_ultimo_resumo", length = 500)
    private String iaUltimoResumo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "criado_por")
    private Usuario criadoPor;

    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    private LocalDateTime dataAtualizacao;
}
