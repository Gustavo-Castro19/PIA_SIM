package br.gov.onac.listapia.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class PiaListResponse {

    private final List<PiaListItemResponse> data;
    private final long total;
    private final int pagina;
    private final int porPagina;
}
