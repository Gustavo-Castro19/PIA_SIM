package br.gov.onac.listapia.entity;

import br.gov.onac.listapia.entity.enums.GrauInteresse;
import br.gov.onac.listapia.entity.enums.StatusPia;
import br.gov.onac.listapia.entity.enums.TipoOperacaoHistorico;
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
@Table(name = "pia_historico")
@Getter
@Setter
@NoArgsConstructor
public class PiaHistorico {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "pia_id", nullable = false)
    private Pia pia;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_operacao", nullable = false, length = 20)
    private TipoOperacaoHistorico tipoOperacao;

    @Enumerated(EnumType.STRING)
    @Column(name = "grau_interesse_anterior", length = 20)
    private GrauInteresse grauInteresseAnterior;

    @Enumerated(EnumType.STRING)
    @Column(name = "grau_interesse_novo", length = 20)
    private GrauInteresse grauInteresseNovo;

    @Enumerated(EnumType.STRING)
    @Column(name = "status_anterior", length = 30)
    private StatusPia statusAnterior;

    @Enumerated(EnumType.STRING)
    @Column(name = "status_novo", length = 30)
    private StatusPia statusNovo;

    @Column(name = "motivo_alteracao", columnDefinition = "TEXT")
    private String motivoAlteracao;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Column(name = "data_operacao", nullable = false)
    private LocalDateTime dataOperacao;
}
