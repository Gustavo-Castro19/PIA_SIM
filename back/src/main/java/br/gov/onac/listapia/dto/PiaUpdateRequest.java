package br.gov.onac.listapia.dto;

import br.gov.onac.listapia.entity.enums.GrauInteresse;
import br.gov.onac.listapia.entity.enums.StatusPia;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PiaUpdateRequest {

    private GrauInteresse grauInteresse;
    private StatusPia status;
}
