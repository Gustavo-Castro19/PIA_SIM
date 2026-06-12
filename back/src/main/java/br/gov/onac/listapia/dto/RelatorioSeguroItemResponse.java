package br.gov.onac.listapia.dto;

import br.gov.onac.listapia.entity.VRelatorioSeguro;
import br.gov.onac.listapia.entity.enums.GrauInteresse;
import br.gov.onac.listapia.entity.enums.Risco;
import br.gov.onac.listapia.entity.enums.StatusPia;
import br.gov.onac.listapia.entity.enums.TipoFraude;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
public class RelatorioSeguroItemResponse {

    private final Long piaId;
    private final Risco iaRiscoAtual;
    private final GrauInteresse grauInteresse;
    private final StatusPia status;
    private final Integer totalIncidentes;
    private final TipoFraude tipoFraude;
    private final LocalDate dataOcorrencia;
    private final LocalDateTime dataRegistro;
    private final String iaResumo;
    private final BigDecimal iaConfianca;
    private final LocalDateTime dataValidacao;
    private final String analistaValidador;

    public static RelatorioSeguroItemResponse from(VRelatorioSeguro view) {
        return RelatorioSeguroItemResponse.builder()
                .piaId(view.getPiaId())
                .iaRiscoAtual(view.getIaRiscoAtual())
                .grauInteresse(view.getGrauInteresse())
                .status(view.getStatus())
                .totalIncidentes(view.getTotalIncidentes())
                .tipoFraude(view.getTipoFraude())
                .dataOcorrencia(view.getDataOcorrencia())
                .dataRegistro(view.getDataRegistro())
                .iaResumo(view.getIaResumo())
                .iaConfianca(view.getIaConfianca())
                .dataValidacao(view.getDataValidacao())
                .analistaValidador(view.getAnalistaValidador())
                .build();
    }
}
