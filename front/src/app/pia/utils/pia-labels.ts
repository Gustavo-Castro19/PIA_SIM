import {
    GrauInteresse,
    Risco,
    StatusPia,
    TipoFraude
} from '../models/pia.model';

export interface SelectOption<T extends string = string> {
    value: T | '';
    label: string;
}

export const RISCOS: Risco[] = ['ALTO', 'MEDIO', 'BAIXO'];

export const STATUS_PIA: StatusPia[] = [
    'ATIVO',
    'SUSPEITO',
    'CONFIRMADO',
    'INOCENTE',
    'ARQUIVADO'
];

export const GRAUS_INTERESSE: GrauInteresse[] = ['ALTO', 'MEDIO', 'BAIXO'];

export const TIPOS_FRAUDE: TipoFraude[] = [
    'PHISHING',
    'WHATSAPP_CLONADO',
    'VAZAMENTO_DADOS_BANCARIOS',
    'GOLPE_PIX',
    'ROUBO_IDENTIDADE',
    'ENGENHARIA_SOCIAL',
    'MALWARE',
    'RANSOMWARE',
    'OUTRO'
];

export const RISCO_LABELS: Record<Risco, string> = {
    ALTO: 'Alto',
    MEDIO: 'Médio',
    BAIXO: 'Baixo'
};

export const STATUS_PIA_LABELS: Record<StatusPia, string> = {
    ATIVO: 'Ativo',
    SUSPEITO: 'Suspeito',
    CONFIRMADO: 'Confirmado',
    INOCENTE: 'Inocente',
    ARQUIVADO: 'Arquivado'
};

export const GRAU_INTERESSE_LABELS: Record<GrauInteresse, string> = {
    ALTO: 'Alto',
    MEDIO: 'Médio',
    BAIXO: 'Baixo'
};

export const TIPO_FRAUDE_LABELS: Record<TipoFraude, string> = {
    PHISHING: 'Phishing',
    WHATSAPP_CLONADO: 'WhatsApp clonado',
    VAZAMENTO_DADOS_BANCARIOS: 'Vazamento de dados bancários',
    GOLPE_PIX: 'Golpe PIX',
    ROUBO_IDENTIDADE: 'Roubo de identidade',
    ENGENHARIA_SOCIAL: 'Engenharia social',
    MALWARE: 'Malware',
    RANSOMWARE: 'Ransomware',
    OUTRO: 'Outro'
};

export function labelRisco(risco: Risco): string {
    return RISCO_LABELS[risco];
}

export function labelStatusPia(status: StatusPia): string {
    return STATUS_PIA_LABELS[status];
}

export function labelGrauInteresse(grau: GrauInteresse): string {
    return GRAU_INTERESSE_LABELS[grau];
}

export function labelTipoFraude(tipo: TipoFraude): string {
    return TIPO_FRAUDE_LABELS[tipo];
}

function opcoesComPlaceholder<T extends string>(
    valores: readonly T[],
    labels: Record<T, string>,
    placeholder: string
): SelectOption<T>[] {
    return [
        { value: '', label: placeholder },
        ...valores.map((valor) => ({ value: valor, label: labels[valor] }))
    ];
}

export function opcoesRisco(placeholder = 'Risco IA'): SelectOption<Risco>[] {
    return opcoesComPlaceholder(RISCOS, RISCO_LABELS, placeholder);
}

export function opcoesStatusPia(placeholder = 'Status'): SelectOption<StatusPia>[] {
    return opcoesComPlaceholder(STATUS_PIA, STATUS_PIA_LABELS, placeholder);
}

export function opcoesGrauInteresse(placeholder = 'Grau de interesse'): SelectOption<GrauInteresse>[] {
    return opcoesComPlaceholder(GRAUS_INTERESSE, GRAU_INTERESSE_LABELS, placeholder);
}

export function opcoesTipoFraude(placeholder = 'Tipo de fraude'): SelectOption<TipoFraude>[] {
    return opcoesComPlaceholder(TIPOS_FRAUDE, TIPO_FRAUDE_LABELS, placeholder);
}
