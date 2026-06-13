import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import {
    GrauInteresse,
    PiaListItem,
    PiaUpdateRequest,
    Risco,
    StatusPia
} from '../../models/pia.model';
import { PiaService } from '../../services/pia.service';
import {
    labelGrauInteresse,
    labelRisco,
    labelStatusPia
} from '../../utils/pia-labels';

@Component({
    selector: 'app-pia-detail',
    templateUrl: './pia-detail.component.html',
    styleUrls: ['./pia-detail.component.scss']
})
export class PiaDetailComponent implements OnInit {
    pia: PiaListItem | undefined;
    carregando = true;
    erroCarregamento = false;
    mostrarModalConfirmacao = false;
    mostrarModalEdicao = false;

    labelRisco = labelRisco;
    labelGrauInteresse = labelGrauInteresse;
    labelStatusPia = labelStatusPia;

    constructor(
        private route: ActivatedRoute,
        private router: Router,
        private piaService: PiaService
    ) { }

    ngOnInit(): void {
        this.carregarDetalhes();
    }

    carregarDetalhes(): void {
        const idParam = this.route.snapshot.paramMap.get('id');
        const id = idParam ? Number(idParam) : NaN;

        if (!idParam || Number.isNaN(id)) {
            this.erroCarregamento = true;
            this.carregando = false;
            return;
        }

        this.piaService.buscarPorId(id).subscribe({
            next: (pia) => {
                this.pia = pia;
                this.carregando = false;
            },
            error: () => {
                this.erroCarregamento = true;
                this.carregando = false;
            }
        });
    }

    obterClasseBadgeRisco(risco: Risco | GrauInteresse): string {
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
        return new Date(data).toLocaleDateString('pt-BR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    formatarConfianca(valor: number): string {
        return `${Math.round(valor * 100)}%`;
    }

    editarRegistro(): void {
        if (this.pia) {
            this.mostrarModalEdicao = true;
        }
    }

    fecharModalEdicao(): void {
        this.mostrarModalEdicao = false;
    }

    salvarPiaEditada(dados: PiaUpdateRequest): void {
        if (!this.pia) {
            return;
        }

        this.piaService.atualizar(this.pia.id, dados).subscribe({
            next: () => {
                this.fecharModalEdicao();
                this.carregarDetalhes();
            },
            error: (erro: Error) => {
                console.error('Erro ao atualizar PIA:', erro.message);
            }
        });
    }

    abrirModalConfirmacao(): void {
        this.mostrarModalConfirmacao = true;
    }

    fecharModalConfirmacao(): void {
        this.mostrarModalConfirmacao = false;
    }

    confirmarExclusao(): void {
        if (!this.pia) {
            return;
        }

        this.piaService.excluir(this.pia.id).subscribe({
            next: () => {
                this.router.navigate(['/pia']);
            },
            error: (erro: Error) => {
                console.error('Erro ao excluir PIA:', erro.message);
            }
        });
    }

    voltar(): void {
        this.router.navigate(['/pia']);
    }
}
