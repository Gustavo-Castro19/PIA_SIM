export interface Pia {
    id: string;           // ID ONAC gerado automaticamente (ex: ONAC-2024-0001)
    nome: string;
    cpf: string;
    taxaRisco: number;    // número de 0 a 100
    nivelRisco: 'Alto' | 'Médio' | 'Baixo';  // calculado a partir de taxaRisco
    dataUltimoRegistro: Date;
    statusAnalise: 'Pendente' | 'Em Análise' | 'Concluído' | 'Arquivado';
}

export interface FiltrosPia {
    busca: string;
    dataRelato: '' | 'hoje' | '7dias' | '30dias' | '90dias';
    nivelRisco: '' | 'Alto' | 'Médio' | 'Baixo';
    status: '' | 'Pendente' | 'Em Análise' | 'Concluído' | 'Arquivado';
}
