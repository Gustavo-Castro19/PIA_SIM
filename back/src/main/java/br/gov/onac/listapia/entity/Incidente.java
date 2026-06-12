package br.gov.onac.listapia.entity;

import br.gov.onac.listapia.entity.enums.CanalRecebimento;
import br.gov.onac.listapia.entity.enums.StatusIncidente;
import br.gov.onac.listapia.entity.enums.TipoFraude;
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

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "incidente")
@Getter
@Setter
@NoArgsConstructor
public class Incidente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pia_id")
    private Pia pia;

    @Column(nullable = false, length = 300)
    private String titulo;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "descricao_anonimizada", columnDefinition = "TEXT")
    private String descricaoAnonimizada;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_fraude", nullable = false, length = 50)
    private TipoFraude tipoFraude;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private StatusIncidente status = StatusIncidente.PENDENTE;

    @Enumerated(EnumType.STRING)
    @Column(name = "canal_recebimento", nullable = false, length = 30)
    private CanalRecebimento canalRecebimento = CanalRecebimento.FORMULARIO_WEB;

    @Column(name = "data_ocorrencia")
    private LocalDate dataOcorrencia;

    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao", nullable = false)
    private LocalDateTime dataAtualizacao;
}
