import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Pia } from '../../models/pia.model';
import { PiaService } from '../../services/pia.service';

@Component({
    selector: 'app-pia-detail',
    templateUrl: './pia-detail.component.html',
    styleUrls: ['./pia-detail.component.scss']
})
export class PiaDetailComponent implements OnInit {
    pia: Pia | undefined;
    carregando = true;
    erroCarregamento = false;
    mostrarModalConfirmacao = false;

    constructor(
        private route: ActivatedRoute,
        private router: Router,
        private piaService: PiaService
    ) { }

    ngOnInit(): void {
        this.carregarDetalhes();
    }

    carregarDetalhes(): void {
        const id = this.route.snapshot.paramMap.get('id');
        if (id) {
            this.piaService.getById(id).subscribe(
                (pia: Pia | undefined) => {
                    if (pia) {
                        this.pia = pia;
                        this.carregando = false;
                    } else {
                        this.erroCarregamento = true;
                        this.carregando = false;
                    }
                },
                (erro) => {
                    console.error('Erro ao carregar PIA:', erro);
                    this.erroCarregamento = true;
                    this.carregando = false;
                }
            );
        }
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
        return d.toLocaleDateString('pt-BR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    editarRegistro(): void {
        if (this.pia) {
            // Aqui você pode implementar a navegação para uma tela de edição
            // ou abrir um modal de edição
            console.log('Editar:', this.pia);
        }
    }

    abrirModalConfirmacao(): void {
        this.mostrarModalConfirmacao = true;
    }

    fecharModalConfirmacao(): void {
        this.mostrarModalConfirmacao = false;
    }

    confirmarExclusao(): void {
        if (this.pia) {
            this.piaService.delete(this.pia.id).subscribe(
                () => {
                    console.log('PIA excluída');
                    this.router.navigate(['/pia']);
                },
                (erro) => {
                    console.error('Erro ao excluir PIA:', erro);
                }
            );
        }
    }

    voltar(): void {
        this.router.navigate(['/pia']);
    }
}
