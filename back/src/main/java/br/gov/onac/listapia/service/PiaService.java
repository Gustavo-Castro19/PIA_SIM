package br.gov.onac.listapia.service;

import br.gov.onac.listapia.dto.PiaCreateRequest;
import br.gov.onac.listapia.dto.PiaCreateResponse;
import br.gov.onac.listapia.dto.PiaListItemResponse;
import br.gov.onac.listapia.dto.PiaListResponse;
import br.gov.onac.listapia.dto.PiaUpdateRequest;
import br.gov.onac.listapia.dto.PiaUpdateResponse;
import br.gov.onac.listapia.entity.Incidente;
import br.gov.onac.listapia.entity.IncidenteAnalise;
import br.gov.onac.listapia.entity.Pia;
import br.gov.onac.listapia.entity.Usuario;
import br.gov.onac.listapia.entity.VRelatorioSeguro;
import br.gov.onac.listapia.entity.enums.IaStatusProcessamento;
import br.gov.onac.listapia.entity.enums.Risco;
import br.gov.onac.listapia.entity.enums.TipoFraude;
import br.gov.onac.listapia.exception.ResourceNotFoundException;
import br.gov.onac.listapia.repository.IncidenteAnaliseRepository;
import br.gov.onac.listapia.repository.IncidenteRepository;
import br.gov.onac.listapia.repository.PiaRepository;
import br.gov.onac.listapia.repository.UsuarioRepository;
import br.gov.onac.listapia.repository.VListaPiaRepository;
import br.gov.onac.listapia.repository.VRelatorioSeguroRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PiaService {

    private static final String SISTEMA_EMAIL = "sistema@onac.serpro.gov.br";
    private static final BigDecimal STUB_CONFIANCA = new BigDecimal("0.75");
    private static final DateTimeFormatter CSV_DATE = DateTimeFormatter.ISO_LOCAL_DATE;
    private static final DateTimeFormatter CSV_DATETIME = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final VListaPiaRepository vListaPiaRepository;
    private final VRelatorioSeguroRepository vRelatorioSeguroRepository;
    private final PiaRepository piaRepository;
    private final IncidenteRepository incidenteRepository;
    private final IncidenteAnaliseRepository incidenteAnaliseRepository;
    private final UsuarioRepository usuarioRepository;

    @PersistenceContext
    private EntityManager entityManager;

    @Transactional(readOnly = true)
    public PiaListResponse listar(String risco, String status, int pagina, int porPagina) {
        Risco filtroRisco = parseEnum(risco, Risco.class, "risco");
        var filtroStatus = parseEnum(status, br.gov.onac.listapia.entity.enums.StatusPia.class, "status");

        int paginaNormalizada = Math.max(pagina, 1);
        int porPaginaNormalizada = Math.min(Math.max(porPagina, 1), 100);
        Pageable pageable = PageRequest.of(paginaNormalizada - 1, porPaginaNormalizada);

        Page<PiaListItemResponse> page = vListaPiaRepository
                .findByFiltros(filtroRisco, filtroStatus, pageable)
                .map(PiaListItemResponse::from);

        return PiaListResponse.builder()
                .data(page.getContent())
                .total(page.getTotalElements())
                .pagina(paginaNormalizada)
                .porPagina(porPaginaNormalizada)
                .build();
    }

    @Transactional(readOnly = true)
    public PiaListItemResponse buscarPorId(Long id) {
        return vListaPiaRepository.findById(id)
                .map(PiaListItemResponse::from)
                .orElseThrow(() -> new ResourceNotFoundException("PIA não encontrado: " + id));
    }

    @Transactional
    public PiaCreateResponse criar(PiaCreateRequest request) {
        Usuario sistema = usuarioRepository.findByEmail(SISTEMA_EMAIL)
                .orElseThrow(() -> new IllegalStateException("Usuário sistema não encontrado no banco"));

        LocalDateTime agora = LocalDateTime.now();

        Pia pia = new Pia();
        pia.setCriadoPor(sistema);
        pia.setDataCriacao(agora);
        pia.setDataAtualizacao(agora);
        pia = piaRepository.save(pia);

        Incidente incidente = new Incidente();
        incidente.setPia(pia);
        incidente.setTitulo(request.getTitulo());
        incidente.setDescricao(request.getDescricaoAnonimizada());
        incidente.setDescricaoAnonimizada(request.getDescricaoAnonimizada());
        incidente.setTipoFraude(request.getTipoFraude());
        incidente.setDataOcorrencia(LocalDate.now());
        incidente.setDataCriacao(agora);
        incidente.setDataAtualizacao(agora);
        incidente = incidenteRepository.save(incidente);

        Risco riscoStub = riscoStubPara(request.getTipoFraude());
        String resumoStub = resumoStubPara(request.getTipoFraude());

        IncidenteAnalise analise = new IncidenteAnalise();
        analise.setIncidente(incidente);
        analise.setPia(pia);
        analise.setIaRiscoSugerido(riscoStub);
        analise.setIaResumo(resumoStub);
        analise.setIaConfianca(STUB_CONFIANCA);
        analise.setIaDataProcessamento(agora);
        analise.setIaStatusProcessamento(IaStatusProcessamento.NAO_INICIADO);
        analise.setDataCriacao(agora);
        analise.setDataAtualizacao(agora);
        analise = incidenteAnaliseRepository.save(analise);

        // O trigger fn_sincronizar_pia dispara apenas em UPDATE de ia_status_processamento
        analise.setIaStatusProcessamento(IaStatusProcessamento.CONCLUIDO);
        incidenteAnaliseRepository.save(analise);

        entityManager.flush();
        entityManager.clear();

        Pia piaAtualizado = piaRepository.findById(pia.getId())
                .orElseThrow(() -> new ResourceNotFoundException("PIA não encontrado após criação"));

        return PiaCreateResponse.from(piaAtualizado);
    }

    @Transactional
    public PiaUpdateResponse atualizar(Long id, PiaUpdateRequest request) {
        if (request.getGrauInteresse() == null && request.getStatus() == null) {
            throw new IllegalArgumentException("Informe ao menos grauInteresse ou status para atualização");
        }

        Pia pia = piaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("PIA não encontrado: " + id));

        if (request.getGrauInteresse() != null) {
            pia.setGrauInteresse(request.getGrauInteresse());
        }
        if (request.getStatus() != null) {
            pia.setStatus(request.getStatus());
        }
        pia.setDataAtualizacao(LocalDateTime.now());

        return PiaUpdateResponse.from(piaRepository.save(pia));
    }

    @Transactional
    public void excluir(Long id) {
        Pia pia = piaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("PIA não encontrado: " + id));

        List<Incidente> incidentes = incidenteRepository.findByPia_Id(id);
        for (Incidente incidente : incidentes) {
            incidenteAnaliseRepository.findByIncidente_Id(incidente.getId())
                    .ifPresent(incidenteAnaliseRepository::delete);
        }

        pia.setUltimoIncidente(null);
        piaRepository.save(pia);
        incidenteRepository.deleteAll(incidentes);
        piaRepository.delete(pia);
    }

    @Transactional(readOnly = true)
    public String exportarCsv() {
        List<VRelatorioSeguro> itens = vRelatorioSeguroRepository.findAllByOrderByPiaIdAsc();

        StringBuilder csv = new StringBuilder();
        csv.append("pia_id,ia_risco_atual,grau_interesse,status,total_incidentes,tipo_fraude,");
        csv.append("data_ocorrencia,data_registro,ia_resumo,ia_confianca,data_validacao,analista_validador\n");

        for (VRelatorioSeguro item : itens) {
            csv.append(item.getPiaId()).append(',');
            csv.append(csvValue(item.getIaRiscoAtual())).append(',');
            csv.append(csvValue(item.getGrauInteresse())).append(',');
            csv.append(csvValue(item.getStatus())).append(',');
            csv.append(item.getTotalIncidentes() != null ? item.getTotalIncidentes() : 0).append(',');
            csv.append(csvValue(item.getTipoFraude())).append(',');
            csv.append(csvValue(item.getDataOcorrencia())).append(',');
            csv.append(csvValue(item.getDataRegistro())).append(',');
            csv.append(csvValue(item.getIaResumo())).append(',');
            csv.append(item.getIaConfianca() != null ? item.getIaConfianca() : "").append(',');
            csv.append(csvValue(item.getDataValidacao())).append(',');
            csv.append(csvValue(item.getAnalistaValidador())).append('\n');
        }

        return csv.toString();
    }

    private Risco riscoStubPara(TipoFraude tipoFraude) {
        return switch (tipoFraude) {
            case VAZAMENTO_DADOS_BANCARIOS, RANSOMWARE, GOLPE_PIX -> Risco.ALTO;
            case PHISHING, WHATSAPP_CLONADO, ENGENHARIA_SOCIAL, ROUBO_IDENTIDADE -> Risco.MEDIO;
            case MALWARE, OUTRO -> Risco.BAIXO;
        };
    }

    private String resumoStubPara(TipoFraude tipoFraude) {
        return switch (tipoFraude) {
            case PHISHING -> "Análise automática: padrão de phishing identificado em relato anonimizado.";
            case WHATSAPP_CLONADO -> "Análise automática: indícios de clonagem de conta de mensagens.";
            case VAZAMENTO_DADOS_BANCARIOS -> "Análise automática: possível vazamento de credenciais bancárias.";
            case GOLPE_PIX -> "Análise automática: relato compatível com golpe via PIX.";
            case RANSOMWARE -> "Análise automática: indícios de ataque por ransomware.";
            case ROUBO_IDENTIDADE -> "Análise automática: padrão sugestivo de roubo de identidade.";
            case ENGENHARIA_SOCIAL -> "Análise automática: técnicas de engenharia social detectadas.";
            case MALWARE -> "Análise automática: relato compatível com infecção por malware.";
            case OUTRO -> "Análise automática preliminar: fraude cibernética identificada pelo sistema.";
        };
    }

    private <E extends Enum<E>> E parseEnum(String value, Class<E> enumClass, String campo) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Enum.valueOf(enumClass, value.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException("Valor inválido para " + campo + ": " + value);
        }
    }

    private String csvValue(Object value) {
        if (value == null) {
            return "";
        }
        String text;
        if (value instanceof LocalDate date) {
            text = date.format(CSV_DATE);
        } else if (value instanceof LocalDateTime dateTime) {
            text = dateTime.format(CSV_DATETIME);
        } else if (value instanceof Enum<?> enumValue) {
            text = enumValue.name();
        } else {
            text = value.toString();
        }
        if (text.contains(",") || text.contains("\"") || text.contains("\n")) {
            return "\"" + text.replace("\"", "\"\"") + "\"";
        }
        return text;
    }
}
