package br.gov.onac.listapia.controller;

import br.gov.onac.listapia.dto.PiaCreateRequest;
import br.gov.onac.listapia.dto.PiaCreateResponse;
import br.gov.onac.listapia.dto.PiaListResponse;
import br.gov.onac.listapia.dto.PiaUpdateRequest;
import br.gov.onac.listapia.dto.PiaUpdateResponse;
import br.gov.onac.listapia.service.PiaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/pia")
@RequiredArgsConstructor
@Tag(name = "PIA", description = "Operações da Lista PIA")
public class PiaController {

    private final PiaService piaService;

    @GetMapping
    @Operation(summary = "Listar registros PIA com filtros e paginação")
    public PiaListResponse listar(
            @RequestParam(required = false) String risco,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "1") int pagina,
            @RequestParam(defaultValue = "10") int por_pagina
    ) {
        return piaService.listar(risco, status, pagina, por_pagina);
    }

    @GetMapping("/export")
    @Operation(summary = "Exportar relatório seguro em CSV")
    public ResponseEntity<String> exportar() {
        String csv = piaService.exportarCsv();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"relatorio_pia.csv\"")
                .contentType(new MediaType("text", "csv"))
                .body(csv);
    }

    @PostMapping
    @Operation(summary = "Criar registro PIA com incidente e análise IA (stub)")
    public ResponseEntity<PiaCreateResponse> criar(@Valid @RequestBody PiaCreateRequest request) {
        PiaCreateResponse response = piaService.criar(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualizar grau de interesse e/ou status do PIA")
    public PiaUpdateResponse atualizar(
            @PathVariable Long id,
            @Valid @RequestBody PiaUpdateRequest request
    ) {
        return piaService.atualizar(id, request);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Excluir registro PIA")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        piaService.excluir(id);
        return ResponseEntity.noContent().build();
    }
}
