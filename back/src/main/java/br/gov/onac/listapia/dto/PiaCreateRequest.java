package br.gov.onac.listapia.dto;

import br.gov.onac.listapia.entity.enums.TipoFraude;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PiaCreateRequest {

    @NotBlank
    @Size(max = 5000)
    private String descricaoAnonimizada;

    @NotNull
    private TipoFraude tipoFraude;

    @NotBlank
    @Size(max = 300)
    private String titulo;
}
