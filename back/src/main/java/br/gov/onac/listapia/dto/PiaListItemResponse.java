package br.gov.onac.listapia.dto;

import br.gov.onac.listapia.entity.VListaPia;
import br.gov.onac.listapia.entity.enums.GrauInteresse;
import br.gov.onac.listapia.entity.enums.Risco;
import br.gov.onac.listapia.entity.enums.StatusPia;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Builder
public class PiaListItemResponse {

    private final Long id;
    private final Risco risco;
    private final GrauInteresse grauInteresse;
    private final StatusPia status;
    private final Integer totalIncidentes;
    private final LocalDateTime dataUltimoIncidente;
    private final String resumoIa;
    private final BigDecimal confiancaIa;
    private final LocalDateTime dataAnaliseIa;

    public static PiaListItemResponse from(VListaPia view) {
        return PiaListItemResponse.builder()
                .id(view.getId())
                .risco(view.getRisco())
                .grauInteresse(view.getGrauInteresse())
                .status(view.getStatus())
                .totalIncidentes(view.getTotalIncidentes())
                .dataUltimoIncidente(view.getDataUltimoIncidente())
                .resumoIa(view.getResumoIa())
                .confiancaIa(view.getConfiancaIa())
                .dataAnaliseIa(view.getDataAnaliseIa())
                .build();
    }
}
