package br.gov.onac.listapia.entity;

import br.gov.onac.listapia.entity.enums.GrauInteresse;
import br.gov.onac.listapia.entity.enums.Risco;
import br.gov.onac.listapia.entity.enums.StatusPia;
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
import java.time.LocalDateTime;

@Entity
@Immutable
@Table(name = "v_lista_pia")
@Getter
@NoArgsConstructor
public class VListaPia {

    @Id
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private Risco risco;

    @Enumerated(EnumType.STRING)
    @Column(name = "grau_interesse", length = 20)
    private GrauInteresse grauInteresse;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    private StatusPia status;

    @Column(name = "total_incidentes")
    private Integer totalIncidentes;

    @Column(name = "data_ultimo_incidente")
    private LocalDateTime dataUltimoIncidente;

    @Column(name = "resumo_ia", length = 500)
    private String resumoIa;

    @Column(name = "data_atualizacao")
    private LocalDateTime dataAtualizacao;

    @Column(name = "confianca_ia", precision = 3, scale = 2)
    private BigDecimal confiancaIa;

    @Column(name = "data_analise_ia")
    private LocalDateTime dataAnaliseIa;
}
