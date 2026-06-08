import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { Pia, FiltrosPia } from '../../models/pia.model';
import { PiaService } from '../../services/pia.service';

@Component({
    selector: 'app-pia-list',
    templateUrl: './pia-list.component.html',
    styleUrls: ['./pia-list.component.scss']
})
export class PiaListComponent implements OnInit {
    registros: Pia[] = [];
    registrosFiltrados: Pia[] = [];

    // Paginação
    paginaAtual = 1;
    itensPorPagina = 10;
    totalPaginas = 0;
    registrosPaginados: Pia[] = [];

    filtros: FiltrosPia = {
        busca: '',
        dataRelato: '',
        nivelRisco: '',
        status: ''
    };

    // Opções de selects
    opcoesDataRelato = [
        { value: '', label: 'Data do Relato' },
        { value: 'hoje', label: 'Hoje' },
        { value: '7dias', label: 'Últimos 7 dias' },
        { value: '30dias', label: 'Últimos 30 dias' },
        { value: '90dias', label: 'Últimos 90 dias' }
    ];

    opcoesNivelRisco = [
        { value: '', label: 'Nível de Risco' },
        { value: 'Alto', label: 'Alto' },
        { value: 'Médio', label: 'Médio' },
        { value: 'Baixo', label: 'Baixo' }
    ];

    opcoesStatus = [
        { value: '', label: 'Status' },
        { value: 'Pendente', label: 'Pendente' },
        { value: 'Em Análise', label: 'Em Análise' },
        { value: 'Concluído', label: 'Concluído' },
        { value: 'Arquivado', label: 'Arquivado' }
    ];

    // Modais
    mostrarModalCriar = false;
    mostrarModalEdicao = false;
    mostrarModalConfirmacao = false;
    piaEmEdicao: Partial<Pia> | null = null;
    piaParaExcluir: string | null = null;

    constructor(
        private piaService: PiaService,
        private router: Router
    ) { }

    ngOnInit(): void {
        // Carrega dados de exemplo
        this.piaService.loadMockData();
        this.carregarRegistros();
    }

    carregarRegistros(): void {
        this.piaService.getAll(this.filtros).subscribe(
            (pias: Pia[]) => {
                this.registrosFiltrados = pias;
                this.atualizarPaginacao();
            }
        );
    }

    atualizarPaginacao(): void {
        this.totalPaginas = Math.ceil(this.registrosFiltrados.length / this.itensPorPagina);
        if (this.paginaAtual > this.totalPaginas) {
            this.paginaAtual = this.totalPaginas || 1;
        }

        const inicio = (this.paginaAtual - 1) * this.itensPorPagina;
        const fim = inicio + this.itensPorPagina;
        this.registrosPaginados = this.registrosFiltrados.slice(inicio, fim);
    }

    aplicarFiltros(): void {
        this.paginaAtual = 1;
        this.carregarRegistros();
    }

    limparFiltros(): void {
        this.filtros = {
            busca: '',
            dataRelato: '',
            nivelRisco: '',
            status: ''
        };
        this.paginaAtual = 1;
        this.carregarRegistros();
    }

    exportarRelatorio(): void {
        if (this.registrosFiltrados.length === 0) {
            alert('Nenhum registro para exportar.');
            return;
        }

        // Prepara cabeçalhos
        const cabecalhos = ['ID ONAC', 'Nome', 'CPF', 'Taxa de Risco', 'Nível de Risco', 'Data do Último Registro', 'Status da Análise'];

        // Prepara linhas de dados
        const linhas = this.registrosFiltrados.map(pia => [
            pia.id,
            pia.nome,
            pia.cpf,
            pia.taxaRisco,
            pia.nivelRisco,
            new Date(pia.dataUltimoRegistro).toLocaleDateString('pt-BR'),
            pia.statusAnalise
        ]);

        // Cria conteúdo CSV
        const conteudoCSV = [
            cabecalhos.join(','),
            ...linhas.map(linha =>
                linha.map(celula =>
                    typeof celula === 'string' && celula.includes(',')
                        ? `"${celula}"`
                        : celula
                ).join(',')
            )
        ].join('\n');

        // Download do arquivo
        const blob = new Blob([conteudoCSV], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);
        link.setAttribute('href', url);
        link.setAttribute('download', `relatorio-pia-${new Date().toISOString().split('T')[0]}.csv`);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    // Modal Criar
    abrirModalCriar(): void {
        this.mostrarModalCriar = true;
        this.piaEmEdicao = null;
    }

    fecharModalCriar(): void {
        this.mostrarModalCriar = false;
    }

    salvarNovaPia(novaPia: Partial<Pia>): void {
        this.piaService.create(novaPia).subscribe(
            (pia: Pia) => {
                console.log('PIA criada:', pia);
                this.fecharModalCriar();
                this.carregarRegistros();
            },
            (erro) => {
                console.error('Erro ao criar PIA:', erro);
            }
        );
    }

    // Modal Edição
    abrirModalEdicao(pia: Pia): void {
        this.piaEmEdicao = { ...pia };
        this.mostrarModalEdicao = true;
    }

    fecharModalEdicao(): void {
        this.mostrarModalEdicao = false;
        this.piaEmEdicao = null;
    }

    salvarPiaEditada(piaEditada: Partial<Pia>): void {
        if (this.piaEmEdicao && this.piaEmEdicao.id) {
            this.piaService.update(this.piaEmEdicao.id, piaEditada).subscribe(
                (pia: Pia) => {
                    console.log('PIA atualizada:', pia);
                    this.fecharModalEdicao();
                    this.carregarRegistros();
                },
                (erro) => {
                    console.error('Erro ao atualizar PIA:', erro);
                }
            );
        }
    }

    // Modal Confirmação Exclusão
    abrirModalConfirmacao(id: string): void {
        this.piaParaExcluir = id;
        this.mostrarModalConfirmacao = true;
    }

    fecharModalConfirmacao(): void {
        this.mostrarModalConfirmacao = false;
        this.piaParaExcluir = null;
    }

    confirmarExclusao(): void {
        if (this.piaParaExcluir) {
            this.piaService.delete(this.piaParaExcluir).subscribe(
                () => {
                    console.log('PIA excluída');
                    this.fecharModalConfirmacao();
                    this.carregarRegistros();
                },
                (erro) => {
                    console.error('Erro ao excluir PIA:', erro);
                }
            );
        }
    }

    // Navegação
    verDetalhes(id: string): void {
        this.router.navigate(['/pia', id]);
    }

    // Busca por CPF
    cpfBusca = '';
    resultadoBusca: Pia | null = null;
    mostrandoResultadoBusca = false;

    buscarCPF(): void {
        const cpfLimpo = this.cpfBusca.replace(/\D/g, '');
        if (cpfLimpo.length !== 11) {
            alert('Digite um CPF válido (11 dígitos)');
            return;
        }

        this.piaService.buscarPorCPF(this.cpfBusca).subscribe(pia => {
            this.resultadoBusca = pia;
            this.mostrandoResultadoBusca = true;
        });
    }

    fecharResultadoBusca(): void {
        this.mostrandoResultadoBusca = false;
        this.resultadoBusca = null;
        this.cpfBusca = '';
    }

    formatarCPFInput(event: any): void {
        let cpf = event.target.value.replace(/\D/g, '');
        if (cpf.length > 11) cpf = cpf.substring(0, 11);
        cpf = cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
        this.cpfBusca = cpf;
    }

    // Gerar Registros Rápidos
    gerandoRegistros = false;

    gerarRegistrosRapidos(): void {
        this.gerandoRegistros = true;
        this.piaService.gerarRegistrosRapidos().subscribe(registros => {
            this.carregarRegistros();
            this.gerandoRegistros = false;
        });
    }

    // Paginação
    irParaPagina(pagina: number): void {
        if (pagina >= 1 && pagina <= this.totalPaginas) {
            this.paginaAtual = pagina;
            this.atualizarPaginacao();
        }
    }

    proximaPagina(): void {
        this.irParaPagina(this.paginaAtual + 1);
    }

    paginaAnterior(): void {
        this.irParaPagina(this.paginaAtual - 1);
    }

    obterNumerosPaginas(): number[] {
        const numeros = [];
        const maximo = Math.min(this.totalPaginas, 5);
        const inicio = Math.max(1, this.paginaAtual - Math.floor(maximo / 2));
        const fim = Math.min(this.totalPaginas, inicio + maximo - 1);

        for (let i = inicio; i <= fim; i++) {
            numeros.push(i);
        }
        return numeros;
    }

    obterClasseBadgeRisco(nivelRisco: string): string {
        switch (nivelRisco) {
            case 'Alto':
                return 'br-tag danger';
            case 'Médio':
                return 'br-tag warning';
            case 'Baixo':
                return 'br-tag success';
            default:
                return 'br-tag';
        }
    }

    obterClasseBadgeStatus(status: string): string {
        switch (status) {
            case 'Pendente':
                return 'br-tag warning';
            case 'Em Análise':
                return 'br-tag info';
            case 'Concluído':
                return 'br-tag success';
            case 'Arquivado':
                return 'br-tag';
            default:
                return 'br-tag';
        }
    }

    formatarCPF(cpf: string): string {
        return cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    }

    formatarData(data: Date | string): string {
        const d = typeof data === 'string' ? new Date(data) : data;
        return d.toLocaleDateString('pt-BR');
    }
}
