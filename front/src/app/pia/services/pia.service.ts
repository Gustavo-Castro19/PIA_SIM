import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { Pia, FiltrosPia } from '../models/pia.model';

@Injectable({
    providedIn: 'root'
})
export class PiaService {
    private piasSubject = new BehaviorSubject<Pia[]>([]);
    private sequencialAtual = 0;

    constructor() { }

    /**
     * Retorna lista de PIAs com filtros aplicados
     */
    getAll(filtros?: FiltrosPia): Observable<Pia[]> {
        return this.piasSubject.asObservable().pipe(
            map(pias => {
                if (!filtros) {
                    return pias;
                }

                return pias.filter(pia => {
                    // Filtro de busca (ID, CPF ou Nome)
                    if (filtros.busca && filtros.busca.trim()) {
                        const termo = filtros.busca.toLowerCase();
                        const match =
                            pia.id.toLowerCase().includes(termo) ||
                            pia.cpf.toLowerCase().includes(termo) ||
                            pia.nome.toLowerCase().includes(termo);
                        if (!match) return false;
                    }

                    // Filtro de data
                    if (filtros.dataRelato) {
                        const agora = new Date();
                        const dataRegistro = new Date(pia.dataUltimoRegistro);
                        const dias = Math.floor((agora.getTime() - dataRegistro.getTime()) / (1000 * 60 * 60 * 24));

                        switch (filtros.dataRelato) {
                            case 'hoje':
                                if (dias > 0) return false;
                                break;
                            case '7dias':
                                if (dias > 7) return false;
                                break;
                            case '30dias':
                                if (dias > 30) return false;
                                break;
                            case '90dias':
                                if (dias > 90) return false;
                                break;
                        }
                    }

                    // Filtro de nível de risco
                    if (filtros.nivelRisco && pia.nivelRisco !== filtros.nivelRisco) {
                        return false;
                    }

                    // Filtro de status
                    if (filtros.status && pia.statusAnalise !== filtros.status) {
                        return false;
                    }

                    return true;
                });
            })
        );
    }

    /**
     * Cria novo registro de PIA
     */
    create(data: Partial<Pia>): Observable<Pia> {
        // Gera ID automático no formato ONAC-ANO-SEQUENCIAL
        const ano = new Date().getFullYear();
        this.sequencialAtual++;
        const sequencial = String(this.sequencialAtual).padStart(4, '0');
        const id = `ONAC-${ano}-${sequencial}`;

        // Calcula nível de risco a partir da taxa
        let nivelRisco: 'Alto' | 'Médio' | 'Baixo' = 'Baixo';
        if (data.taxaRisco !== undefined) {
            if (data.taxaRisco >= 70) {
                nivelRisco = 'Alto';
            } else if (data.taxaRisco >= 40) {
                nivelRisco = 'Médio';
            }
        }

        const novoPia: Pia = {
            id,
            nome: data.nome || '',
            cpf: data.cpf || '',
            taxaRisco: data.taxaRisco || 0,
            nivelRisco,
            dataUltimoRegistro: new Date(),
            statusAnalise: data.statusAnalise || 'Pendente'
        };

        // Adiciona ao BehaviorSubject
        const piasAtuais = this.piasSubject.getValue();
        this.piasSubject.next([...piasAtuais, novoPia]);

        return new Observable(observer => {
            observer.next(novoPia);
            observer.complete();
        });
    }

    /**
     * Deleta um registro de PIA
     */
    delete(id: string): Observable<void> {
        const piasAtuais = this.piasSubject.getValue();
        const piasFiltradas = piasAtuais.filter(pia => pia.id !== id);
        this.piasSubject.next(piasFiltradas);

        return new Observable(observer => {
            observer.next();
            observer.complete();
        });
    }

    /**
     * Atualiza um registro de PIA
     */
    update(id: string, data: Partial<Pia>): Observable<Pia> {
        const piasAtuais = this.piasSubject.getValue();
        const index = piasAtuais.findIndex(pia => pia.id === id);

        if (index === -1) {
            return new Observable(observer => {
                observer.error('PIA não encontrada');
            });
        }

        const piaAtualizada = { ...piasAtuais[index], ...data };

        // Recalcula nível de risco se taxaRisco foi alterada
        if (data.taxaRisco !== undefined) {
            if (data.taxaRisco >= 70) {
                piaAtualizada.nivelRisco = 'Alto';
            } else if (data.taxaRisco >= 40) {
                piaAtualizada.nivelRisco = 'Médio';
            } else {
                piaAtualizada.nivelRisco = 'Baixo';
            }
        }

        const novasPias = [...piasAtuais];
        novasPias[index] = piaAtualizada;
        this.piasSubject.next(novasPias);

        return new Observable(observer => {
            observer.next(piaAtualizada);
            observer.complete();
        });
    }

    /**
     * Retorna um registro específico por ID
     */
    getById(id: string): Observable<Pia | undefined> {
        return this.piasSubject.asObservable().pipe(
            map(pias => pias.find(pia => pia.id === id))
        );
    }

    /**
     * Gera 20 registros rápidos para teste
     */
    gerarRegistrosRapidos(): Observable<Pia[]> {
        const nomes = [
            'Ana Beatriz Lima', 'Carlos Eduardo Souza', 'Diana Ferreira Martins', 'Eduardo Almeida Neto',
            'Fernanda Oliveira Rocha', 'Gabriel Santos Pereira', 'Helena Costa Barbosa', 'Igor Nascimento Dias',
            'Julia Carvalho Teixeira', 'Lucas Mendes Araujo', 'Marina Ribeiro Campos', 'Nicolas Barbosa Faria',
            'Patricia Silva Gomes', 'Rafael Oliveira Cruz', 'Sandra Vieira Moreira', 'Thiago Monteiro Lopes',
            'Valentina Rocha Duarte', 'William Correia Novaes', 'Yara Campos Peixoto', 'Zeca Martins Toledo'
        ];
        const statusList: Array<'Pendente' | 'Em Análise' | 'Concluído' | 'Arquivado'> = [
            'Pendente', 'Em Análise', 'Concluído', 'Arquivado'
        ];

        const novosRegistros: Pia[] = nomes.map((nome, index) => {
            const taxaRisco = Math.floor(Math.random() * 101);
            let nivelRisco: 'Alto' | 'Médio' | 'Baixo' = 'Baixo';
            if (taxaRisco >= 70) nivelRisco = 'Alto';
            else if (taxaRisco >= 40) nivelRisco = 'Médio';

            const ano = new Date().getFullYear();
            this.sequencialAtual++;
            const sequencial = String(this.sequencialAtual).padStart(4, '0');
            const id = `ONAC-${ano}-${sequencial}`;

            const cpf = `${String(Math.floor(100 + Math.random() * 899))}.${String(Math.floor(100 + Math.random() * 899))}.${String(Math.floor(100 + Math.random() * 899))}-${String(Math.floor(10 + Math.random() * 89))}`;

            return {
                id,
                nome,
                cpf,
                taxaRisco,
                nivelRisco,
                dataUltimoRegistro: new Date(Date.now() - Math.floor(Math.random() * 90 * 24 * 60 * 60 * 1000)),
                statusAnalise: statusList[Math.floor(Math.random() * statusList.length)]
            };
        });

        const piasAtuais = this.piasSubject.getValue();
        this.piasSubject.next([...piasAtuais, ...novosRegistros]);

        return new Observable(observer => {
            observer.next(novosRegistros);
            observer.complete();
        });
    }

    /**
     * Busca registro por CPF
     */
    buscarPorCPF(cpf: string): Observable<Pia | null> {
        const cpfLimpo = cpf.replace(/\D/g, '');
        return this.piasSubject.asObservable().pipe(
            map(pias => {
                const encontrado = pias.find(pia => pia.cpf.replace(/\D/g, '') === cpfLimpo);
                return encontrado || null;
            })
        );
    }

    /**
     * Carrega dados de exemplo (para desenvolvimento)
     */
    loadMockData(): void {
        const mockData: Pia[] = [
            {
                id: 'ONAC-2026-0001',
                nome: 'João Silva Santos',
                cpf: '123.456.789-00',
                taxaRisco: 85,
                nivelRisco: 'Alto',
                dataUltimoRegistro: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 dias atrás
                statusAnalise: 'Em Análise'
            },
            {
                id: 'ONAC-2026-0002',
                nome: 'Maria Oliveira Costa',
                cpf: '987.654.321-00',
                taxaRisco: 55,
                nivelRisco: 'Médio',
                dataUltimoRegistro: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000), // 10 dias atrás
                statusAnalise: 'Pendente'
            },
            {
                id: 'ONAC-2026-0003',
                nome: 'Pedro Ferreira Gomes',
                cpf: '456.789.123-00',
                taxaRisco: 30,
                nivelRisco: 'Baixo',
                dataUltimoRegistro: new Date(),
                statusAnalise: 'Concluído'
            }
        ];
        this.sequencialAtual = 3;
        this.piasSubject.next(mockData);
    }
}
