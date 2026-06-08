import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { Pia } from '../../models/pia.model';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
    selector: 'app-pia-modal-criar',
    templateUrl: './pia-modal-criar.component.html',
    styleUrls: ['./pia-modal-criar.component.scss']
})
export class PiaModalCriarComponent implements OnInit {
    @Input() piaEmEdicao: Partial<Pia> | null = null;
    @Output() fechar = new EventEmitter<void>();
    @Output() salvar = new EventEmitter<Partial<Pia>>();

    formulario: FormGroup;
    modo: 'criar' | 'editar' = 'criar';

    opcoesStatus = [
        { value: 'Pendente', label: 'Pendente' },
        { value: 'Em Análise', label: 'Em Análise' },
        { value: 'Concluído', label: 'Concluído' },
        { value: 'Arquivado', label: 'Arquivado' }
    ];

    constructor(private fb: FormBuilder) {
        this.formulario = this.criarFormulario();
    }

    ngOnInit(): void {
        if (this.piaEmEdicao) {
            this.modo = 'editar';
            this.preencherFormulario(this.piaEmEdicao);
        } else {
            this.modo = 'criar';
        }
    }

    criarFormulario(): FormGroup {
        return this.fb.group({
            nome: ['', [Validators.required, Validators.minLength(3)]],
            cpf: ['', [Validators.required, this.validarCPF.bind(this)]],
            taxaRisco: ['', [Validators.required, Validators.min(0), Validators.max(100)]],
            statusAnalise: ['Pendente', Validators.required]
        });
    }

    preencherFormulario(pia: Partial<Pia>): void {
        this.formulario.patchValue({
            nome: pia.nome || '',
            cpf: pia.cpf || '',
            taxaRisco: pia.taxaRisco || 0,
            statusAnalise: pia.statusAnalise || 'Pendente'
        });
    }

    validarCPF(control: any): { [key: string]: any } | null {
        const cpf = control.value;
        if (!cpf) return null;

        // Remove formatação
        const cpfLimpo = cpf.replace(/\D/g, '');

        // Valida comprimento
        if (cpfLimpo.length !== 11) {
            return { 'cpfInvalido': true };
        }

        // Valida se todos os dígitos são iguais
        if (/^(\d)\1{10}$/.test(cpfLimpo)) {
            return { 'cpfInvalido': true };
        }

        // Calcula primeiro dígito verificador
        let soma = 0;
        for (let i = 0; i < 9; i++) {
            soma += parseInt(cpfLimpo[i]) * (10 - i);
        }
        let digito1 = 11 - (soma % 11);
        digito1 = digito1 >= 10 ? 0 : digito1;

        // Calcula segundo dígito verificador
        soma = 0;
        for (let i = 0; i < 10; i++) {
            soma += parseInt(cpfLimpo[i]) * (11 - i);
        }
        let digito2 = 11 - (soma % 11);
        digito2 = digito2 >= 10 ? 0 : digito2;

        // Valida dígitos verificadores
        if (digito1 !== parseInt(cpfLimpo[9]) || digito2 !== parseInt(cpfLimpo[10])) {
            return { 'cpfInvalido': true };
        }

        return null;
    }

    obterTextoTaxaRisco(): string {
        const taxa = this.formulario.get('taxaRisco')?.value || 0;
        if (taxa >= 70) return 'Alto';
        if (taxa >= 40) return 'Médio';
        return 'Baixo';
    }

    obterClasseRisco(): string {
        const taxa = this.formulario.get('taxaRisco')?.value || 0;
        if (taxa >= 70) return 'danger';
        if (taxa >= 40) return 'warning';
        return 'success';
    }

    formatarCPFInput(event: any): void {
        let cpf = event.target.value.replace(/\D/g, '');
        if (cpf.length > 11) {
            cpf = cpf.substring(0, 11);
        }
        cpf = cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
        this.formulario.get('cpf')?.setValue(cpf, { emitEvent: false });
    }

    obterErrosNome(): string[] {
        const control = this.formulario.get('nome');
        const erros: string[] = [];

        if (control?.hasError('required')) {
            erros.push('Nome é obrigatório');
        }
        if (control?.hasError('minlength')) {
            erros.push('Nome deve ter no mínimo 3 caracteres');
        }

        return erros;
    }

    obterErrosCPF(): string[] {
        const control = this.formulario.get('cpf');
        const erros: string[] = [];

        if (control?.hasError('required')) {
            erros.push('CPF é obrigatório');
        }
        if (control?.hasError('cpfInvalido')) {
            erros.push('CPF inválido');
        }

        return erros;
    }

    obterErrosTaxa(): string[] {
        const control = this.formulario.get('taxaRisco');
        const erros: string[] = [];

        if (control?.hasError('required')) {
            erros.push('Taxa de Risco é obrigatória');
        }
        if (control?.hasError('min')) {
            erros.push('Taxa de Risco deve ser no mínimo 0');
        }
        if (control?.hasError('max')) {
            erros.push('Taxa de Risco deve ser no máximo 100');
        }

        return erros;
    }

    fecharModal(): void {
        this.formulario.reset();
        this.fechar.emit();
    }

    enviarFormulario(): void {
        if (this.formulario.invalid) {
            // Marca todos os campos como tocados para exibir erros
            Object.keys(this.formulario.controls).forEach(key => {
                this.formulario.get(key)?.markAsTouched();
            });
            return;
        }

        const dados: Partial<Pia> = {
            ...this.formulario.value
        };

        // Se estiver editando, preserve o ID
        if (this.piaEmEdicao && this.piaEmEdicao.id) {
            dados.id = this.piaEmEdicao.id;
            dados.dataUltimoRegistro = this.piaEmEdicao.dataUltimoRegistro;
        }

        this.salvar.emit(dados);
        this.formulario.reset();
    }

    get tituloModal(): string {
        return this.modo === 'criar' ? 'Novo Registro PIA' : 'Editar Registro PIA';
    }

    get textoBotaoPrincipal(): string {
        return this.modo === 'criar' ? 'Criar' : 'Atualizar';
    }
}
