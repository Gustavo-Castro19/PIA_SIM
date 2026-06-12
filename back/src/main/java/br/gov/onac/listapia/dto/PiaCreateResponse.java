package br.gov.onac.listapia.dto;

import br.gov.onac.listapia.entity.Pia;
import br.gov.onac.listapia.entity.enums.GrauInteresse;
import br.gov.onac.listapia.entity.enums.Risco;
import br.gov.onac.listapia.entity.enums.StatusPia;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class PiaCreateResponse {

    private final Long id;
    private final GrauInteresse grauInteresse;
    private final StatusPia status;
    private final Risco iaRiscoAtual;
    private final LocalDateTime dataCriacao;

    public static PiaCreateResponse from(Pia pia) {
        return PiaCreateResponse.builder()
                .id(pia.getId())
                .grauInteresse(pia.getGrauInteresse())
                .status(pia.getStatus())
                .iaRiscoAtual(pia.getIaRiscoAtual())
                .dataCriacao(pia.getDataCriacao())
                .build();
    }
}
