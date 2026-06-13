import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import {
    FiltrosPia,
    GrauInteresse,
    PiaCreateRequest,
    PiaListItem,
    PiaUpdateRequest,
    Risco,
    StatusPia
} from '../../models/pia.model';
import { PiaService } from '../../services/pia.service';
import {
    labelGrauInteresse,
    labelRisco,
    labelStatusPia,
    opcoesRisco,
    opcoesStatusPia,
    SelectOption
} from '../../utils/pia-labels';

@Component({
    selector: 'app-pia-list',
    templateUrl: './pia-list.component.html',
    styleUrls: ['./pia-list.component.scss']
})
export class PiaListComponent implements OnInit {
    registros: PiaListItem[] = [];
    totalRegistros = 0;
    carregando = false;
    erro: string | null = null;

    paginaAtual = 1;
    itensPorPagina = 10;
    totalPaginas = 0;

    filtros: FiltrosPia = {
        risco: '',
        status: ''
    };

    opcoesRisco: SelectOption<Risco>[] = opcoesRisco();
    opcoesStatus: SelectOption<StatusPia>[] = opcoesStatusPia();

    mostrarModalCriar = false;
    mostrarModalEdicao = false;
    mostrarModalConfirmacao = false;
    piaEmEdicao: PiaListItem | null = null;
    piaParaExcluir: number | null = null;

    labelRisco = labelRisco;
    labelStatusPia = labelStatusPia;
    labelGrauInteresse = labelGrauInteresse;

    constructor(
        private piaService: PiaService,
        private router: Router
    ) { }

    ngOnInit(): void {
        this.carregarRegistros();
    }

    carregarRegistros(): void {
        this.carregando = true;
        this.erro = null;

        this.piaService.listar(this.filtros, this.paginaAtual, this.itensPorPagina).subscribe({
            next: (resposta) => {
                this.registros = resposta.data;
                this.totalRegistros = resposta.total;
                this.paginaAtual = resposta.pagina;
                this.itensPorPagina = resposta.porPagina;
                this.totalPaginas = Math.ceil(this.totalRegistros / this.itensPorPagina) || 0;
                this.carregando = false;
            },
            error: (erro: Error) => {
                this.erro = erro.message;
                this.registros = [];
                this.totalRegistros = 0;
                this.totalPaginas = 0;
                this.carregando = false;
            }
        });
    }

    aplicarFiltros(): void {
        this.paginaAtual = 1;
        this.carregarRegistros();
    }

    limparFiltros(): void {
        this.filtros = {
            risco: '',
            status: ''
        };
        this.paginaAtual = 1;
        this.carregarRegistros();
    }

    exportarRelatorio(): void {
        this.piaService.baixarCsv();
    }

    abrirModalCriar(): void {
        this.mostrarModalCriar = true;
        this.piaEmEdicao = null;
    }

    fecharModalCriar(): void {
        this.mostrarModalCriar = false;
    }

    salvarNovaPia(dados: PiaCreateRequest): void {
        this.piaService.criar(dados).subscribe({
            next: () => {
                this.fecharModalCriar();
                this.carregarRegistros();
            },
            error: (erro: Error) => {
                console.error('Erro ao criar PIA:', erro.message);
            }
        });
    }

    abrirModalEdicao(pia: PiaListItem): void {
        this.piaEmEdicao = { ...pia };
        this.mostrarModalEdicao = true;
    }

    fecharModalEdicao(): void {
        this.mostrarModalEdicao = false;
        this.piaEmEdicao = null;
    }

    salvarPiaEditada(dados: PiaUpdateRequest): void {
        if (!this.piaEmEdicao) {
            return;
        }

        this.piaService.atualizar(this.piaEmEdicao.id, dados).subscribe({
            next: () => {
                this.fecharModalEdicao();
                this.carregarRegistros();
            },
            error: (erro: Error) => {
                console.error('Erro ao atualizar PIA:', erro.message);
            }
        });
    }

    abrirModalConfirmacao(id: number): void {
        this.piaParaExcluir = id;
        this.mostrarModalConfirmacao = true;
    }

    fecharModalConfirmacao(): void {
        this.mostrarModalConfirmacao = false;
        this.piaParaExcluir = null;
    }

    confirmarExclusao(): void {
        if (this.piaParaExcluir === null) {
            return;
        }

        this.piaService.excluir(this.piaParaExcluir).subscribe({
            next: () => {
                this.fecharModalConfirmacao();
                this.carregarRegistros();
            },
            error: (erro: Error) => {
                console.error('Erro ao excluir PIA:', erro.message);
            }
        });
    }

    verDetalhes(id: number): void {
        this.router.navigate(['/pia', id]);
    }

    irParaPagina(pagina: number): void {
        if (pagina >= 1 && pagina <= this.totalPaginas && pagina !== this.paginaAtual) {
            this.paginaAtual = pagina;
            this.carregarRegistros();
        }
    }

    proximaPagina(): void {
        this.irParaPagina(this.paginaAtual + 1);
    }

    paginaAnterior(): void {
        this.irParaPagina(this.paginaAtual - 1);
    }

    obterNumerosPaginas(): number[] {
        const numeros: number[] = [];
        const maximo = Math.min(this.totalPaginas, 5);
        const inicio = Math.max(1, this.paginaAtual - Math.floor(maximo / 2));
        const fim = Math.min(this.totalPaginas, inicio + maximo - 1);

        for (let i = inicio; i <= fim; i++) {
            numeros.push(i);
        }
        return numeros;
    }

    obterClasseBadgeRisco(risco: Risco): string {
        switch (risco) {
            case 'ALTO':
                return 'br-tag danger';
            case 'MEDIO':
                return 'br-tag warning';
            case 'BAIXO':
                return 'br-tag success';
            default:
                return 'br-tag';
        }
    }

    obterClasseBadgeGrau(grau: GrauInteresse): string {
        return this.obterClasseBadgeRisco(grau);
    }

    obterClasseBadgeStatus(status: StatusPia): string {
        switch (status) {
            case 'ATIVO':
                return 'br-tag info';
            case 'SUSPEITO':
                return 'br-tag warning';
            case 'CONFIRMADO':
                return 'br-tag danger';
            case 'INOCENTE':
                return 'br-tag success';
            case 'ARQUIVADO':
                return 'br-tag';
            default:
                return 'br-tag';
        }
    }

    formatarData(data: string): string {
        if (!data) {
            return '—';
        }
        return new Date(data).toLocaleDateString('pt-BR');
    }

    formatarConfianca(valor: number): string {
        return `${Math.round(valor * 100)}%`;
    }
}
