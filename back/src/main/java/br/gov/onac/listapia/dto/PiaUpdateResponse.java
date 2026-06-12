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
public class PiaUpdateResponse {

    private final Long id;
    private final GrauInteresse grauInteresse;
    private final StatusPia status;
    private final Risco iaRiscoAtual;
    private final LocalDateTime dataAtualizacao;

    public static PiaUpdateResponse from(Pia pia) {
        return PiaUpdateResponse.builder()
                .id(pia.getId())
                .grauInteresse(pia.getGrauInteresse())
                .status(pia.getStatus())
                .iaRiscoAtual(pia.getIaRiscoAtual())
                .dataAtualizacao(pia.getDataAtualizacao())
                .build();
    }
}
