# 📋 Módulo PIA - Pessoas de Interesse Antifraude

Sistema completo de gerenciamento de registros PIA (Pessoas de Interesse Antifraude) para o ONAC, desenvolvido com Angular seguindo rigorosamente o **Design System do Governo Federal Brasileiro (DSGOV)**.

## 🎯 Visão Geral

O módulo PIA fornece uma interface intuitiva e acessível para:
- ✅ Listar registros de pessoas de interesse
- ✅ Criar novos registros com validações
- ✅ Editar registros existentes
- ✅ Excluir registros com confirmação
- ✅ Visualizar detalhes completos
- ✅ Filtrar por múltiplos critérios
- ✅ Exportar relatórios em CSV
- ✅ Paginação automática

## 📁 Estrutura de Arquivos

```
src/app/pia/
├── pia.module.ts              # Declaração do módulo
├── pia-routing.module.ts      # Configuração de rotas
├── models/
│   └── pia.model.ts           # Interfaces e tipos
├── services/
│   └── pia.service.ts         # Lógica de negócio
├── pages/
│   ├── pia-list/
│   │   ├── pia-list.component.ts
│   │   ├── pia-list.component.html
│   │   └── pia-list.component.scss
│   └── pia-detail/
│       ├── pia-detail.component.ts
│       ├── pia-detail.component.html
│       └── pia-detail.component.scss
└── components/
    └── pia-modal-criar/
        ├── pia-modal-criar.component.ts
        ├── pia-modal-criar.component.html
        └── pia-modal-criar.component.scss
```

## 🚀 Instalação e Configuração

### 1. Dependências

Adicione as dependências do DSGOV ao `package.json`:

```json
{
  "dependencies": {
    "@govbr-ds/core": "^3.2.0",
    "@govbr-ds/web-components": "^3.2.0"
  }
}
```

Instale com:
```bash
npm install
```

### 2. Configuração no `angular.json`

Adicione o CSS e JS do DSGOV na seção `styles` e `scripts`:

```json
{
  "projects": {
    "lista-pia": {
      "architect": {
        "build": {
          "options": {
            "styles": [
              "src/styles.scss",
              "node_modules/@govbr-ds/core/dist/core.min.css"
            ],
            "scripts": [
              "node_modules/@govbr-ds/core/dist/core.min.js"
            ]
          }
        }
      }
    }
  }
}
```

### 3. Integração no Módulo Principal

Importe o módulo PIA no `AppModule`:

```typescript
import { PiaModule } from './pia/pia.module';

@NgModule({
  imports: [
    // ... outros imports
    PiaModule
  ]
})
export class AppModule { }
```

### 4. Configuração de Rotas

Adicione a rota no `app-routing.module.ts`:

```typescript
const routes: Routes = [
  {
    path: 'pia',
    loadChildren: () => import('./pia/pia.module').then(m => m.PiaModule)
  }
  // ... outras rotas
];
```

## 📊 Modelo de Dados

### Interface Pia

```typescript
export interface Pia {
  id: string;                           // ONAC-YYYY-NNNN
  nome: string;
  cpf: string;                          // XXX.XXX.XXX-XX
  taxaRisco: number;                    // 0-100
  nivelRisco: 'Alto' | 'Médio' | 'Baixo';
  dataUltimoRegistro: Date;
  statusAnalise: 'Pendente' | 'Em Análise' | 'Concluído' | 'Arquivado';
}
```

### Cálculo de Nível de Risco

- **Alto**: Taxa ≥ 70
- **Médio**: Taxa ≥ 40 e < 70
- **Baixo**: Taxa < 40

## 🔧 Serviço PIA

O `PiaService` gerencia toda a lógica de negócio usando `BehaviorSubject` para estado local:

### Métodos Principais

#### `getAll(filtros?: FiltrosPia): Observable<Pia[]>`
Retorna lista filtrada de registros com suporte a:
- Busca por ID, CPF ou Nome (case-insensitive)
- Filtro por data (hoje, 7, 30, 90 dias)
- Filtro por nível de risco
- Filtro por status

#### `create(data: Partial<Pia>): Observable<Pia>`
Cria novo registro com:
- ID gerado automaticamente (ONAC-YYYY-NNNN)
- Cálculo automático do nível de risco
- Data de registro definida como agora

#### `update(id: string, data: Partial<Pia>): Observable<Pia>`
Atualiza registro existente e recalcula nível de risco

#### `delete(id: string): Observable<void>`
Remove registro da lista

#### `getById(id: string): Observable<Pia | undefined>`
Retorna um registro específico

## 🎨 Design System DSGOV

### Componentes Utilizados

- **`br-button`**: Botões com variações (primary, secondary, danger)
- **`br-input`**: Campos de entrada com suporte a validação
- **`br-select`**: Seleções com estilo consistente
- **`br-table`**: Tabelas responsivas
- **`br-pagination`**: Paginação
- **`br-modal`**: Modais
- **`br-tag`**: Badges/etiquetas
- **`br-breadcrumb`**: Navegação por breadcrumb

### Cores Principais (Tokens DSGOV)

- **Primary**: `#0050b3`
- **Danger**: `#cc0000`
- **Warning**: `#f4a400`
- **Success**: `#07893b`
- **Info**: `#0066cc`
- **Secondary**: `#666666`

### Tipografia

- **Títulos (H1)**: 2rem, peso 700
- **Subtítulos (H2)**: 1.5rem, peso 700
- **Labels**: 0.875rem, peso 600
- **Corpo**: 1rem, peso 400

## 📄 Páginas Principais

### pia-list (Listagem Principal)

**Recursos:**
- ✅ Tabela com 10 itens por página
- ✅ Barra de busca com ícone
- ✅ Filtros por data, nível de risco e status
- ✅ Botões de ação: visualizar, editar, excluir
- ✅ Paginação completa
- ✅ Exportação em CSV
- ✅ Estado vazio com ícone

**Componentes:**
- Breadcrumb DSGOV
- Barra de busca com debounce
- Filtros avançados
- Tabela responsiva
- Modal de confirmação de exclusão
- Modal de criar/editar

### pia-detail (Detalhes)

**Recursos:**
- ✅ Visualização completa do registro
- ✅ Cards informativos com indicadores
- ✅ Seção expandida de detalhes
- ✅ Botões de ação (editar, excluir, voltar)
- ✅ Estado de carregamento
- ✅ Estado de erro

## 🔐 Validações

### Formulário de Criar/Editar

**Nome:**
- Obrigatório
- Mínimo 3 caracteres

**CPF:**
- Obrigatório
- Validação de dígito verificador
- Formatação automática XXX.XXX.XXX-XX

**Taxa de Risco:**
- Obrigatório
- Range: 0-100
- Indicador visual em tempo real

**Status:**
- Obrigatório
- Valores pré-definidos

## 🧪 Dados de Exemplo

O serviço inclui método `loadMockData()` que carrega 3 registros de exemplo:

```typescript
this.piaService.loadMockData();
```

Isso é útil para desenvolvimento e testes iniciais.

## 🎯 Funcionalidades Detalhadas

### Busca

- Busca parcial (case-insensitive)
- Busca em 3 campos: ID, CPF, Nome
- Atualização em tempo real

### Filtros

1. **Data do Relato**
   - Hoje
   - Últimos 7 dias
   - Últimos 30 dias
   - Últimos 90 dias

2. **Nível de Risco**
   - Alto (≥70)
   - Médio (40-69)
   - Baixo (<40)

3. **Status da Análise**
   - Pendente
   - Em Análise
   - Concluído
   - Arquivado

### Badges de Status

| Status | Cor | Classe |
|--------|-----|--------|
| Alto | Vermelho | `br-tag danger` |
| Médio | Amarelo | `br-tag warning` |
| Baixo | Verde | `br-tag success` |
| Pendente | Amarelo | `br-tag warning` |
| Em Análise | Azul | `br-tag info` |
| Concluído | Verde | `br-tag success` |
| Arquivado | Cinza | `br-tag` |

### Exportação CSV

Gera arquivo com nome: `relatorio-pia-YYYY-MM-DD.csv`

Colunas exportadas:
- ID ONAC
- Nome
- CPF (formatado)
- Taxa de Risco
- Nível de Risco
- Data do Último Registro (formatada)
- Status da Análise

## 🌐 Responsividade

Componentes totalmente responsivos para:
- Desktop (≥1200px)
- Tablet (768px - 1199px)
- Mobile (<768px)

Ajustes específicos:
- Grid adaptativa
- Fonte maior em inputs mobile (previne zoom automático)
- Modais ajustados para mobile
- Tabela scrollável em mobile

## 🔗 Integração com Backend

O serviço usa `BehaviorSubject` para estado local. Para integrar com API:

1. Substitua `BehaviorSubject` por chamadas HTTP
2. Implemente interceptadores de autenticação
3. Adicione tratamento de erros específicos
4. Configure base URL da API

Exemplo:

```typescript
getAll(filtros?: FiltrosPia): Observable<Pia[]> {
  return this.http.get<Pia[]>('/api/pia', {
    params: new HttpParams().set('filtros', JSON.stringify(filtros))
  });
}
```

## 📚 Componentes Customizados

### Validador de CPF

Implementado em `pia-modal-criar.component.ts`:
- Valida formato
- Valida dígito verificador
- Formata automaticamente

### Formatação de Data

Método `formatarData()` retorna formato brasileiro: `DD/MM/YYYY HH:MM`

## 🎓 Melhores Práticas Implementadas

✅ Componentes bem tipados com TypeScript
✅ Reatividade com RxJS observables
✅ Validação em tempo real
✅ Feedback visual clara
✅ Acessibilidade WCAG
✅ Responsividade mobile-first
✅ Componentes reutilizáveis
✅ Separação de responsabilidades
✅ Padrão de projeto Observable

## 📖 Documentação DSGOV

Referências:
- [Design System Governo Federal](https://www.gov.br/ds)
- [Componentes DSGOV](https://www.gov.br/ds/componentes)
- [Guia de Estilo](https://www.gov.br/ds/guia-de-estilo)

## 🤝 Suporte

Para dúvidas ou sugestões sobre o módulo PIA:
1. Consulte a documentação do DSGOV
2. Verifique os exemplos no código
3. Teste com os dados mock fornecidos

## 📝 Licença

Este módulo segue as mesmas restrições de uso do Design System do Governo Federal Brasileiro.

---

**Desenvolvido com ❤️ seguindo os padrões DSGOV**
