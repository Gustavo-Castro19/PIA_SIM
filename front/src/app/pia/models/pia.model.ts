/** Enums espelhando o backend (br.gov.onac.listapia.entity.enums). */

export type Risco = 'ALTO' | 'MEDIO' | 'BAIXO';

export type StatusPia = 'ATIVO' | 'SUSPEITO' | 'CONFIRMADO' | 'INOCENTE' | 'ARQUIVADO';

export type GrauInteresse = 'ALTO' | 'MEDIO' | 'BAIXO';

export type TipoFraude =
    | 'PHISHING'
    | 'WHATSAPP_CLONADO'
    | 'VAZAMENTO_DADOS_BANCARIOS'
    | 'GOLPE_PIX'
    | 'ROUBO_IDENTIDADE'
    | 'ENGENHARIA_SOCIAL'
    | 'MALWARE'
    | 'RANSOMWARE'
    | 'OUTRO';

/** Item retornado por GET /api/v1/pia e GET /api/v1/pia/{id}. */
export interface PiaListItem {
    id: number;
    risco: Risco;
    grauInteresse: GrauInteresse;
    status: StatusPia;
    totalIncidentes: number;
    dataUltimoIncidente: string;
    resumoIa: string;
    confiancaIa: number;
    dataAnaliseIa: string;
}

/** Resposta paginada de GET /api/v1/pia. */
export interface PiaListResponse {
    data: PiaListItem[];
    total: number;
    pagina: number;
    porPagina: number;
}

/** Payload de POST /api/v1/pia. */
export interface PiaCreateRequest {
    titulo: string;
    descricaoAnonimizada: string;
    tipoFraude: TipoFraude;
}

/** Resposta de POST /api/v1/pia. */
export interface PiaCreateResponse {
    id: number;
    grauInteresse: GrauInteresse;
    status: StatusPia;
    iaRiscoAtual: Risco;
    dataCriacao: string;
}

/** Payload de PUT /api/v1/pia/{id}. */
export interface PiaUpdateRequest {
    grauInteresse?: GrauInteresse;
    status?: StatusPia;
}

/** Resposta de PUT /api/v1/pia/{id}. */
export interface PiaUpdateResponse {
    id: number;
    grauInteresse: GrauInteresse;
    status: StatusPia;
    iaRiscoAtual: Risco;
    dataAtualizacao: string;
}

/** Corpo de erro padronizado do backend. */
export interface ErrorResponse {
    status: number;
    message: string;
    timestamp: string;
    details?: string[];
}

/** Filtros suportados pela listagem server-side. */
export interface FiltrosPia {
    risco?: Risco | '';
    status?: StatusPia | '';
}
