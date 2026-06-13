import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import {
    PiaCreateRequest,
    PiaListItem,
    PiaUpdateRequest,
    TipoFraude
} from '../../models/pia.model';
import {
    opcoesGrauInteresse,
    opcoesStatusPia,
    opcoesTipoFraude,
    SelectOption
} from '../../utils/pia-labels';

@Component({
    selector: 'app-pia-modal-criar',
    templateUrl: './pia-modal-criar.component.html',
    styleUrls: ['./pia-modal-criar.component.scss']
})
export class PiaModalCriarComponent implements OnInit {
    @Input() piaEmEdicao: PiaListItem | null = null;
    @Output() fechar = new EventEmitter<void>();
    @Output() salvarCriar = new EventEmitter<PiaCreateRequest>();
    @Output() salvarEditar = new EventEmitter<PiaUpdateRequest>();

    formulario: FormGroup;
    modo: 'criar' | 'editar' = 'criar';

    opcoesStatus = opcoesStatusPia('Selecione o status').filter((o) => o.value !== '');
    opcoesGrauInteresse = opcoesGrauInteresse('Selecione o grau').filter((o) => o.value !== '');
    opcoesTipoFraude: SelectOption<TipoFraude>[] = opcoesTipoFraude('Selecione o tipo').filter((o) => o.value !== '');

    constructor(private fb: FormBuilder) {
        this.formulario = this.criarFormulario();
    }

    ngOnInit(): void {
        if (this.piaEmEdicao) {
            this.modo = 'editar';
            this.formulario = this.criarFormularioEdicao();
            this.preencherFormularioEdicao(this.piaEmEdicao);
        } else {
            this.modo = 'criar';
            this.formulario = this.criarFormulario();
        }
    }

    criarFormulario(): FormGroup {
        return this.fb.group({
            titulo: ['', [Validators.required, Validators.maxLength(300)]],
            descricaoAnonimizada: ['', [Validators.required, Validators.maxLength(5000)]],
            tipoFraude: ['', Validators.required]
        });
    }

    criarFormularioEdicao(): FormGroup {
        return this.fb.group({
            grauInteresse: ['', Validators.required],
            status: ['', Validators.required]
        });
    }

    preencherFormularioEdicao(pia: PiaListItem): void {
        this.formulario.patchValue({
            grauInteresse: pia.grauInteresse,
            status: pia.status
        });
    }

    obterErrosTitulo(): string[] {
        const control = this.formulario.get('titulo');
        const erros: string[] = [];

        if (control?.hasError('required')) {
            erros.push('Título é obrigatório');
        }
        if (control?.hasError('maxlength')) {
            erros.push('Título deve ter no máximo 300 caracteres');
        }

        return erros;
    }

    obterErrosDescricao(): string[] {
        const control = this.formulario.get('descricaoAnonimizada');
        const erros: string[] = [];

        if (control?.hasError('required')) {
            erros.push('Descrição é obrigatória');
        }
        if (control?.hasError('maxlength')) {
            erros.push('Descrição deve ter no máximo 5000 caracteres');
        }

        return erros;
    }

    fecharModal(): void {
        this.formulario.reset();
        this.fechar.emit();
    }

    enviarFormulario(): void {
        if (this.formulario.invalid) {
            Object.keys(this.formulario.controls).forEach(key => {
                this.formulario.get(key)?.markAsTouched();
            });
            return;
        }

        if (this.modo === 'criar') {
            this.salvarCriar.emit(this.formulario.value as PiaCreateRequest);
        } else {
            this.salvarEditar.emit(this.formulario.value as PiaUpdateRequest);
        }

        this.formulario.reset();
    }

    get tituloModal(): string {
        return this.modo === 'criar' ? 'Novo Registro PIA' : 'Editar Registro PIA';
    }

    get textoBotaoPrincipal(): string {
        return this.modo === 'criar' ? 'Criar' : 'Atualizar';
    }
}
