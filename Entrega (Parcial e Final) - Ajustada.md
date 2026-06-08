# **Residência Tecnológica (Entrega Parcial e Final) 1 - Definição do Problema e Personas "IA-Augmented"**

* Descrição do Problema, Solução e Oportunidade de IA:

  * Problema (250 caracteres)

    A Serpro está desenvolvendo o "Lista PIA", um sistema que registra fraudes associadas a um CPF, para tal eles estão em um ambiente extremamente restritivo, é difícil testar, e mudanças têm de ser graduais, portanto testar a API é um processo complexo e oneroso.

  * Solução (250 caracteres)

    Faremos um sistema espelho, um simulador que se conecta ao back-end com as mesmas rotas do Lista PIA permitindo testar o fluxo de trabalho, gerar registros rápidos para teste e viabilizar ideias de interface ou lógica de negócios.

  * Identificar explicitamente onde a IA gera valor (automação, predição ou geração de conteúdo).

    A I.A pode ser usada livremente num ambiente seguro para gerar códigos, testes e componentes sem afetar o sistema que necessita de certo grau de segurança. Por conseguinte, a geração de código e testes de orquestração de I.A são um valor a ser extraído do sistema.

2. # **\- Backlog e Engenharia de Requisitos "AI-First"**

   * Backlog Priorizado e Categorizado:

     * Descrição dos Requisitos Funcionais e Não Funcionais

Requisitos funcionais

- Formulário com CPF, nome, risco estimado, status de análise(inicialmente, "em análise"), e ações é mandado pelo usuário na interface para o back-end, resultado esperado: registro novo no banco de dados e uma mensagem de OK na interface
- botão de registros rápidos gera 20 registros conforme a estrutura de uma entidade no banco de dados resultado esperado: 20 novos registros aparecem na tela
- buscar registro por CPF, o consultante digita o cpf em um campo o sistema consulta no back se a pessoa está na lista resultado esperado: formulário da pessoa aparece na tela restrição: sem o campo de CPF

Requisitos não funcionais

- tratamento de dados: verificar CPF válido e esconder CPF na resposta de uma consulta do usuário
- estrutura do back-end e banco de dados baseada no projeto lista PIA

   * Descrição dos padrões de uso de ferramentas de IA no projeto.

     **Ferramentas de IA Utilizadas:**

     - **OpenCode (CLI)**: Agente de IA via terminal para edição de código, refatoração e completude de documentação técnica
     - **Claude Code (CLI)**: Agente de IA para exploração de código, análise de arquitetura e sugestões de implementação
     - **Cursor (IDE com agente)**: IDE com agente de IA embutido para desenvolvimento de componentes Angular
     - **ChatGPT/Gemini (web gratuita)**: LLMs para consultas pontuais, geração de exemplos e validação de lógica de negócios

     **Padrões de Uso:**

     - Geração de código boilerplate (componentes, serviços, módulos)
     - Criação de testes unitários e dados mock
     - Refatoração assistida de código existente
     - Documentação técnica e READMEs
     - Validação de lógica de validação (ex: dígitos verificadores do CPF)
     - Geração de scripts SQL e triggers

     **Cuidados Adotados:**

     - Todo código gerado por IA é revisado manualmente antes de commit
     - Dados sensíveis (CPF, senhas) nunca são expostos em prompts
     - Preferência por ferramentas gratuitas ou open-source

3. # **\- Banco de dados e API**

   * Representação da estrutura do banco de dados contendo:

     * Entidades, Atributos, Relacionamentos, Chaves primárias e estrangeiras.

     **Diagrama Entidade-Relacionamento:**

     ```
     ┌─────────────┐       ┌──────────────────┐       ┌──────────────────┐
     │   usuario   │       │   incidente      │       │ incidente_analise│
     ├─────────────┤       ├──────────────────┤       ├──────────────────┤
     │ id (PK)     │       │ id (PK)          │       │ id (PK)          │
     │ nome        │◄───── │ sid              │───────│ incidente_id (FK)│
     │ email       │       │ titulo           │       │ sid              │
     │ senha_hash  │       │ descricao        │       │ ia_risco_sugerido│
     │ perfil      │       │ tipo_fraude      │       │ ia_resumo        │
     │ ativo       │       │ status           │       │ ia_confiança     │
     └─────────────┘       │ canal_recebimento│       │ risco_validado   │
                           │ data_ocorrencia  │       │ analista_id (FK) │
                           └────────┬─────────┘       │ palavras_chave   │
                                    │                  └──────────────────┘
                                    │
                           ┌────────▼─────────┐       ┌──────────────────┐
                           │      pia         │       │  pia_historico   │
                           ├──────────────────┤       ├──────────────────┤
                           │ id (PK)          │       │ id (PK)          │
                           │ sid (UNIQUE)     │───────│ pia_id (FK)      │
                           │ grau_interesse   │       │ sid              │
                           │ status           │       │ tipo_operacao    │
                           │ total_incidentes │       │ grau_interesse_* │
                           │ ia_risco_atual   │       │ status_*         │
                           │ criado_por (FK)  │       │ usuario_id (FK)  │
                           └──────────────────┘       └──────────────────┘
     ```

     **Entidades:**

     | Entidade | Descrição | Chave Primária | Chaves Estrangeiras |
     |----------|-----------|----------------|---------------------|
     | `usuario` | Usuários internos (analistas, gestores, admins) | `id` (BIGSERIAL) | - |
     | `incidente` | Ocorrências de fraude reportadas (anonimizadas) | `id` (BIGSERIAL) | - |
     | `incidente_analise` | Resultados da IA e validação humana | `id` (BIGSERIAL) | `incidente_id` → incidente(`id`), `analista_id` → usuario(`id`) |
     | `pia` | Lista centralizada de Pessoas de Interesse Antifraude | `id` (BIGSERIAL) | `ultimo_incidente_id` → incidente(`id`), `criado_por` → usuario(`id`) |
     | `pia_historico` | Auditoria de alterações na Lista PIA (LGPD) | `id` (BIGSERIAL) | `pia_id` → pia(`id`), `usuario_id` → usuario(`id`) |

     * Identificar no modelo de dados quais entidades ou estruturas estão relacionadas ao uso de IA no sistema (caso faça sentido).

       A entidade `incidente_analise` é o núcleo do uso de IA no sistema:
       - `ia_risco_sugerido`: Classificação automática de risco (ALTO/MEDIO/BAIXO) gerada por LLM
       - `ia_resumo`: Resumo do incidente gerado por IA (até 500 caracteres)
       - `ia_confiança`: Nível de confiança da IA na análise (0.00 a 1.00)
       - `ia_status_processamento`: Status do pipeline de IA (NAO_INICIADO, PROCESSANDO, CONCLUIDO, FALHA, TIMEOUT)
       - `palavras_chave_extraidas`: Dados estruturados (JSONB) extraídos pela IA

       A entidade `pia` também possui campos relacionados à IA:
       - `ia_risco_atual`: Risco mais recente sincronizado automaticamente via trigger
       - `ia_ultimo_resumo`: Último resumo gerado pela IA

   * Design da API e principais endpoints com métodos HTTP.

     | Método | Endpoint | Descrição |
     |--------|----------|-----------|
     | `GET` | `/api/v1/pia` | Lista todos os registros (usa view `v_lista_pia`) |
     | `GET` | `/api/v1/pia?risco=ALTO` | Filtro por nível de risco |
     | `GET` | `/api/v1/pia?status=ATIVO` | Filtro por status |
     | `GET` | `/api/v1/pia/{sid}` | Detalhes de um registro por SID |
     | `POST` | `/api/v1/pia` | Cria novo registro (recebe SID do Sujeito ONAC) |
     | `PUT` | `/api/v1/pia/{sid}` | Atualiza status/grau de interesse |
     | `DELETE` | `/api/v1/pia/{sid}` | Remove registro (com auditoria) |
     | `GET` | `/api/v1/pia/export` | Exporta relatório CSV (usa view `v_relatorio_seguro`) |

     * Estrutura de requisições e respostas.

     **POST /api/v1/pia - Criação:**
     ```json
     // Request
     {
       "sid": "SID-123456789",
       "descricao_anonimizada": "Relato de fraude sem dados pessoais..."
     }

     // Response (201 Created)
     {
       "id": 1,
       "sid": "SID-123456789",
       "grau_interesse": "MEDIO",
       "status": "ATIVO",
       "total_incidentes": 1,
       "ia_risco_atual": "MEDIO",
       "data_criacao": "2026-06-08T10:00:00Z"
     }
     ```

     **GET /api/v1/pia - Listagem:**
     ```json
     // Response (200 OK)
     {
       "data": [
         {
           "id": 1,
           "sid": "SID-123456789",
           "risco": "ALTO",
           "grau_interesse": "ALTO",
           "status": "CONFIRMADO",
           "total_incidentes": 3,
           "data_ultimo_incidente": "2026-06-05T14:30:00Z",
           "resumo_ia": "Indivíduo vinculado a múltiplos relatos de phishing...",
           "confianca_ia": 0.92,
           "data_analise_ia": "2026-06-05T14:35:00Z"
         }
       ],
       "total": 1,
       "pagina": 1,
       "por_pagina": 10
     }
     ```

   * Fluxo de dados e lógica do sistema, incluindo:

     * Entrada de dados, processamento clássico, integração com serviços de IA, estratégias de indexação e recuperação de dados para IA, persistência, retorno para o Frontend.

     **Fluxo Completo:**

     ```
     1. Sujeito ONAC (anonimizador)
        ↓ Envia SID + relato anonimizado via API
     2. Spring Boot (Lista PIA)
        ↓ Persiste em incidente (descricao_anonimizada)
        ↓ Envia descricao_anonimizada para serviço de IA
     3. Serviço de IA (LLM)
        ↓ Retorna: risco_sugerido, resumo, confiança, palavras_chave
     4. Spring Boot
        ↓ Persiste em incidente_analise
        ↓ Trigger fn_sincronizar_pia() atualiza tabela pia automaticamente
     5. Frontend Angular
        ↓ Consulta view v_lista_pia via GET /api/v1/pia
        ↓ Exibe dados anonimizados (apenas SID, risco, resumo)
     ```

     **Índices para Performance:**
     - `idx_incidente_sid`, `idx_incidente_status`, `idx_incidente_tipo`, `idx_incidente_data`
     - `idx_analise_risco`, `idx_analise_status`, `idx_analise_data`
     - `idx_pia_risco`, `idx_pia_status`, `idx_pia_grau`, `idx_pia_data`, `idx_pia_composto`
     - `idx_historico_pia`, `idx_historico_data`, `idx_historico_usuario`

     * Exemplos de fluxo completo da requisição.

     **Exemplo: Analista consulta lista de PIA com risco ALTO**

     ```
     Angular (frontend)
       → GET /api/v1/pia?risco=ALTO
       → Spring Boot consulta v_lista_pia WHERE risco = 'ALTO'
       → PostgreSQL retorna registros com SIDs anonimizados
       → Spring Boot retorna JSON
       → Angular exibe tabela com badges de risco, breadcrumb e paginação
     ```

4. # **\- Arquitetura de Software e Stack de Desenvolvimento**

   * Escolha da Stack de Desenvolvimento e IA:

     * Detalhamento de stack, detalhando as ferramentas de IA utilizadas (pagas vs gratuitas)

     **Stack de Desenvolvimento:**

     | Camada | Tecnologia | Versão | Finalidade |
     |--------|-----------|--------|------------|
     | Frontend | Angular | 17 | Framework web TypeScript |
     | Estilização | Tailwind + DSGOV | - | Design System do Governo Federal |
     | UI Components | PrimeNG + DSGOV | - | Componentes acessíveis |
     | Backend | Spring Boot | 3 | API REST em Java |
     | Banco de Dados | PostgreSQL | - | SGBD relacional |
     | Infraestrutura | Docker | - | Containerização |
     | Versionamento | Git + GitHub | - | Controle de código fonte |

     **Ferramentas de IA:**

     | Ferramenta | Tipo | Custo | Uso |
     |------------|------|-------|-----|
     | OpenCode (CLI) | Agente de terminal | Gratuito (open-source) | Edição, refatoração, documentação |
     | Claude Code | Agente de terminal | Gratuito (uso limitado) | Exploração de código, análise |
     | Cursor | IDE com agente IA | Gratuito (plano free) | Desenvolvimento de componentes |
     | ChatGPT | LLM web | Gratuito | Consultas, exemplos, validação |
     | Gemini | LLM web | Gratuito | Geração de código alternativa |

   * Desenho de Arquitetura e Tratamento de Erros:

     * Relatório da estrutura de pastas e arquitetura, destacando:

     ```
     PIA_SIM/
     ├── Entrega (Parcial e Final) - Ajustada.md   ← Este documento
     │
     ├── listaPIA/                                   ← Frontend Angular
     │   ├── src/
     │   │   ├── index.html
     │   │   ├── main.ts                             ← Bootstrap do Angular
     │   │   ├── styles.scss                         ← Estilos globais + tokens DSGOV
     │   │   └── app/
     │   │       ├── app.module.ts                   ← Módulo raiz
     │   │       ├── app-routing.module.ts            ← Rotas raiz (/pia)
     │   │       ├── app.component.ts                 ← Componente raiz
     │   │       └── pia/
     │   │           ├── pia.module.ts                ← Módulo PIA
     │   │           ├── pia-routing.module.ts         ← Rotas filhas
     │   │           ├── models/
     │   │           │   └── pia.model.ts             ← Interfaces Pia e FiltrosPia
     │   │           ├── services/
     │   │           │   └── pia.service.ts           ← Lógica de negócio + estado
     │   │           ├── pages/
     │   │           │   ├── pia-list/                ← Página de listagem
     │   │           │   └── pia-detail/              ← Página de detalhes
     │   │           └── components/
     │   │               └── pia-modal-criar/         ← Modal criar/editar
     │   ├── package.json
     │   ├── angular.json
     │   └── tsconfig.json
     │
     └── ONAC-Lista-PIA/                              ← Banco de Dados PostgreSQL
         ├── README.md
         ├── database/
         │   └── README.md
         └── onac_lista_pia.sql                       ← Schema completo (496 linhas)
             ├── 5 tabelas (usuario, incidente, incidente_analise, pia, pia_historico)
             ├── Índices de performance
             ├── Triggers de auditoria e sincronização
             ├── Views de consulta segura
             └── Dados iniciais (seed)
     ```

     * Como tratar problemas com latência, erros, timeout e indisponibilidade.

     **Estratégias de Tratamento de Erros:**

     | Problema | Estratégia | Implementação |
     |----------|-----------|---------------|
     | **Latência de IA** | Processamento assíncrono | `ia_status_processamento` com estados: NAO_INICIADO → PROCESSANDO → CONCLUIDO |
     | **Timeout de IA** | Modo degradado | Status `TIMEOUT` em `incidente_analise.ia_status_processamento`; incidente vai para `PENDENTE_ANALISE_MANUAL` |
     | **IA indisponível** | Fallback manual | Incidente marcado como `PENDENTE_ANALISE_MANUAL`; analista avalia manualmente |
     | **Erro de validação (frontend)** | Feedback visual imediato | Validação reativa com ReactiveForms; mensagens de erro por campo |
     | **Erro de requisição HTTP** | Tratamento no Observable | Callbacks de erro nos subscriptions do serviço PiaService |
     | **Alucinação de IA** | Validação Spring Boot | Resumo da IA validado antes de persistir; proibido conter dados pessoais |
     | **Exclusão acidental** | Auditoria completa | Trigger `fn_auditar_pia()` registra tudo em `pia_historico` |
     | **SID duplicado** | UNIQUE constraint | Garantido pelo banco (`pia.sid UNIQUE`) |
     | **Estado vazio** | UX com ícone | Componente de estado vazio na listagem |

5. # **\- Link dos Arquivos do MVP "AI-Powered"**

   * Código-Fonte e Integrações de IA: Link para o repositório contendo o código da solução

     **Repositório GitHub:** [https://github.com/SEU-ORG/PIA_SIM](https://github.com/SEU-ORG/PIA_SIM)

     **Estrutura do Repositório:**
     ```
     PIA_SIM/
     ├── listaPIA/               → Frontend Angular (código-fonte completo)
     │   ├── src/app/pia/        → Módulo PIA com componentes, serviços, modelos
     │   └── ...
     ├── ONAC-Lista-PIA/         → Banco de Dados PostgreSQL (schema SQL)
     │   ├── onac_lista_pia.sql  → Schema completo com índices, triggers, views, seed
     │   └── database/README.md
     └── Entrega (Parcial e Final) - Ajustada.md → Este documento
     ```

   * Documentação de Integrações de IA e Engenharia de Prompt: Documentação referente às APIs de IA utilizadas (ex.: OpenAI, Anthropic, LangChain ou modelos locais), contexto de uso das IAs, incluindo prompts que sustentam o core da aplicação (ex.: prompts de sistema, templates de geração ou agentes de validação).

     **APIs de IA Utilizadas:**
     - Nenhuma API de IA paga foi integrada diretamente no backend
     - O uso de IA foi exclusivamente no processo de **desenvolvimento assistido**:
       - OpenCode (CLI): Agente local que opera sobre o filesystem, sem chamadas de API externa
       - Claude Code: Agente via terminal para análise de código
       - ChatGPT/Gemini: LLMs gratuitas via navegador para consultas pontuais
     - A arquitetura do banco (`incidente_analise`) está preparada para integrar uma API de IA (ex: OpenAI, Anthropic) via Spring Boot, mas a implementação da integração não foi realizada por restrições de escopo do MVP

     **Prompts Exemplos Utilizados no Desenvolvimento:**
     ```
     Prompt: "Crie um componente Angular para modal de criação de PIA com validação de CPF e cálculo de nível de risco"
     Contexto: Geração de código boilerplate para pia-modal-criar.component.ts

     Prompt: "Gere um schema PostgreSQL para um sistema de lista PIA com tabelas de incidentes, análise de IA e auditoria"
     Contexto: Criação do onac_lista_pia.sql

     Prompt: "Implemente validação de dígitos verificadores do CPF em TypeScript"
     Contexto: Método validarCPF() no pia-modal-criar.component.ts
     ```

   * Documentação e Guia de Implantação (Readme.md): Instruções para recriar o ambiente, incluindo a configuração de chaves de API e variáveis de ambiente necessárias para os serviços de inteligência artificial.

     **Pré-requisitos:**
     - Node.js 18+
     - Angular CLI 17 (`npm install -g @angular/cli`)
     - Docker (para PostgreSQL)
     - Java 17+ (para Spring Boot, futuro)

     **Passos para Execução do Frontend:**

     ```bash
     # 1. Clone o repositório
     git clone https://github.com/SEU-ORG/PIA_SIM.git
     cd PIA_SIM/listaPIA

     # 2. Instale as dependências
     npm install

     # 3. Execute em modo desenvolvimento
     npm start
     # Acesse: http://localhost:4200/pia
     ```

     **Passos para Configuração do Banco de Dados:**

     ```bash
     # 1. Inicie o PostgreSQL (via Docker)
     docker run --name onac-pia-db -e POSTGRES_DB=onac_lista_pia \
       -e POSTGRES_USER=onac -e POSTGRES_PASSWORD=onac123 \
       -p 5432:5432 -d postgres:16

     # 2. Execute o script SQL
     docker exec -i onac-pia-db psql -U onac -d onac_lista_pia \
       < ONAC-Lista-PIA/onac_lista_pia.sql
     ```

     **Configuração de Variáveis de Ambiente (para backend Spring Boot futuro):**
     ```env
     DATABASE_URL=jdbc:postgresql://localhost:5432/onac_lista_pia
     DATABASE_USERNAME=onac
     DATABASE_PASSWORD=onac123
     AI_API_KEY=          # Opcional: chave da API de IA (ex: OpenAI)
     AI_API_URL=          # Opcional: URL do serviço de IA
     ```

     **Nota:** O frontend atualmente opera com dados mock (`loadMockData()`) via `BehaviorSubject`, sem necessidade de backend ou chaves de API para funcionar.

   * Versão final do repositório de prompts com rastreabilidade de alterações (ex.: Drive, Github): O repositório deve ser atualizado de forma que seja possível verificar as modificações feitas durante o projeto.

     O repositório GitHub mantém o histórico completo de alterações via Git. Para rastrear as modificações:

     ```bash
     # Ver histórico de commits
     git log --oneline --graph --all

     # Ver alterações de um arquivo específico
     git log --follow -- src/app/pia/services/pia.service.ts

     # Ver diff entre versões
     git diff <commit1> <commit2> -- listaPIA/src/
     ```

     **Registro de Prompts Utilizados:** Mantido em documentação interna da equipe (Drive do Squad 02 - UCB). Os prompts mais relevantes estão documentados na seção anterior.

6. # **\- Apresentação e Pitch Final**

Apresentação estruturada em 10 minutos, destacando a inovação trazida pela IA. Esta é a camada de reflexão crítica e defesa de decisões, onde os squads demonstram que entendem o que construíram.

* # **Problemática, Solução Proposta e Demonstração**

  * A problemática e a oportunidade de IA: resumo do problema e valor gerado com uso de ferramentas de IA;

    **Problemática:** A Serpro está desenvolvendo o sistema "Lista PIA" para registrar fraudes associadas a CPFs em um ambiente altamente restritivo. Testar a API real é complexo, oneroso e arriscado devido às restrições de segurança.

    **Oportunidade de IA:** A IA permitiu acelerar o desenvolvimento do simulador em um ambiente seguro, gerando código, testes e documentação sem comprometer o sistema real. O valor gerado está na **automação da geração de código e componentes**, permitindo iterações rápidas e seguras.

    * Ferramentas utilizadas;

      | Ferramenta | Função no Projeto |
      |------------|-------------------|
      | Angular 17 | Framework frontend |
      | DSGOV (GovBr) | Design System do Governo Federal |
      | PostgreSQL | Banco de dados relacional |
      | Spring Boot 3 | Backend API REST (planejado) |
      | Docker | Containerização do ambiente |
      | **OpenCode (CLI)** | Agente IA para edição e refatoração |
      | **Claude Code** | Agente IA para exploração e análise |
      | **Cursor** | IDE com IA embutida |
      | **ChatGPT/Gemini** | LLMs para consultas |

    * Serviços de IA utilizados e impactos na utilização no desenvolvimento do projeto;

      **Serviços:** Todos gratuitos (OpenCode, Claude Code, Cursor free, ChatGPT web, Gemini web).

      **Impactos:**
      - Redução do tempo de criação de componentes Angular (estimativa: 40% mais rápido)
      - Geração automatizada de schema SQL complexo com triggers, views e índices
      - Documentação técnica gerada e mantida com auxílio de IA
      - Validação de lógica de negócios (CPF, cálculos de risco) assistida por IA
      - Código mais consistente seguindo padrões DSGOV

    * Diferenciais da solução;

      - **Simulador espelho**: mesma estrutura de rotas do sistema real, permitindo testes sem impactar produção
      - **Design System GovBr**: interface acessível e padronizada conforme padrões do governo federal
      - **Arquitetura preparada para IA**: banco de dados com pipeline completo de análise de IA (incidente → análise → sincronização → PIA)
      - **LGPD compliance**: auditoria completa via triggers, sem armazenamento de dados pessoais
      - **Zero dependência de APIs pagas**: MVP funcional apenas com ferramentas gratuitas

    * Demonstração da Solução.

      **Fluxo de Demonstração:**
      1. Usuário acessa `http://localhost:4200/pia`
      2. Visualiza listagem com 3 registros mock (João Silva, Maria Oliveira, Pedro Ferreira)
      3. Filtra por nível de risco "Alto" → exibe apenas João Silva (taxa 85)
      4. Clica em "Novo Registro PIA" → preenche formulário com validação de CPF
      5. Cria registro → novo item aparece na listagem
      6. Clica em detalhes → visualiza informações completas do registro
      7. Exporta relatório CSV → download do arquivo `relatorio-pia-YYYY-MM-DD.csv`
      8. Exclui registro com confirmação → registro removido

  * # **Análise de Custo e Viabilidade Econômica**

    * Estimativas de custo do uso de IA (ex.: custo por chamada / token / usuário);

      **Custos do Desenvolvimento (MVP):**

      | Recurso | Custo |
      |---------|-------|
      | OpenCode (CLI) | Gratuito (open-source) |
      | Claude Code | Gratuito (plano free) |
      | Cursor (IDE) | Gratuito (plano free) |
      | ChatGPT (web) | Gratuito |
      | Gemini (web) | Gratuito |
      | **Custo total de IA no MVP** | **R$ 0,00** |

    * Trade-offs de custo x qualidade do sistema;

      **Prós do modelo gratuito:**
      - Sem custos recorrentes para o projeto
      - Liberdade para experimentação sem restrições financeiras
      - Ferramentas open-source com comunidade ativa

      **Contras do modelo gratuito:**
      - Limitação de requisições em alguns serviços
      - Sem garantia de SLA ou suporte
      - Modelos gratuitos podem ser menos precisos que versões pagas

      **Cenário de Produção (estimativa com APIs pagas):**
      - Se integrado com OpenAI GPT-4 para análise de incidentes:
        - ~1000 tokens por análise = ~$0.03/incidente
        - 1000 incidentes/mês = ~$30/mês
      - Se integrado com Anthropic Claude:
        - ~$0.015/incidente (modelo mais econômico)
        - 1000 incidentes/mês = ~$15/mês
      - **Custo adicional de infraestrutura**: Docker + servidor cloud = ~$50-100/mês

    * Reflexão sobre viabilidade econômica em escala de produção.

      O modelo de desenvolvimento assistido por IA gratuita é **altamente viável** para MVP e prototipação. Para produção, a integração de APIs de IA pagas no backend (para análise automática de incidentes) seria necessária, mas o custo por incidente é baixo (centavos de dólar). Considerando o ambiente da Serpro, onde a segurança é prioridade, a abordagem de agentes locais (OpenCode, Claude Code) é preferível por não expor dados a servidores externos.

  * # **Limites, Qualidade e Aprendizados**

    * E se a IA falhasse?

      **Cenários de falha e mitigação:**

      | Falha | Impacto | Mitigação |
      |-------|---------|-----------|
      | IA gera código incorreto | Bug no sistema | Revisão manual obrigatória |
      | IA sugere lógica insegura | Vulnerabilidade | Code review + testes |
      | IA alucina documentação | Docs incorretas | Verificação pela equipe |
      | IA offline/indisponível | Bloqueio de desenvolvimento | Ferramentas alternativas (trocar de LLM) |
      | IA gera código inconsistente | Conflitos no projeto | Uso de TypeScript strict + linter |

      **Conclusão:** O projeto não possui dependência crítica de IA. Todas as ferramentas de IA foram usadas como **aceleradores**, não como componentes essenciais. Se a IA falhasse, o desenvolvimento seria mais lento, mas não inviabilizado.

    * Processo de garantia de qualidade dos outputs de IA (ex.: homologação de outputs, detecção de alucinação, testes manuais/automatizados, etc.);

      1. **Code Review obrigatório**: todo código gerado por IA é revisado por um membro da equipe
      2. **TypeScript strict mode**: o compilador detecta erros de tipo automaticamente
      3. **Angular strict templates**: validação de templates em tempo de compilação
      4. **Testes manuais**: fluxo completo testado manualmente antes de considerar pronto
      5. **Validação de CPF**: implementação revisada contra casos de borda (dígitos iguais, tamanho incorreto)
      6. **Schema SQL**: triggers testados quanto a loops infinitos e consistência de dados
      7. **Revisão de prompts**: prompts são ajustados iterativamente com base nos outputs

    * O que a equipe deixou de fazer porque a IA não era confiável o suficiente?

      - **Integração direta de API de IA no backend**: não implementada porque os modelos gratuitos não garantem consistência. Seria necessário usar APIs pagas com validação rigorosa.
      - **Geração automática de testes E2E**: a IA gerava testes muito genéricos que não refletiam a complexidade real do sistema Angular com DSGOV.
      - **Criptografia e segurança sensível**: a IA não foi usada para implementar autenticação/autorização por riscos de segurança.
      - **Deploy automatizado**: scripts gerados pela IA não foram confiáveis para ambientes reais restritivos.

    * Superações e aprendizados da equipe durante o processo.

      - **Aprendizado 1**: IAs de terminal (OpenCode, Claude Code) são mais eficazes para refatoração e exploração de código do que para geração de componentes visuais complexos.
      - **Aprendizado 2**: O DSGOV requer conhecimento específico; a IA ajuda com boilerplate mas o ajuste fino dos componentes exige intervenção manual.
      - **Aprendizado 3**: Para validações complexas (CPF), a IA gera implementação inicial, mas a revisão de casos de borda é essencial.
      - **Aprendizado 4**: A documentação técnica é onde a IA mais brilha - estrutura consistente, formatação correta e cobertura completa.
      - **Aprendizado 5**: Trabalhar com agentes CLI (OpenCode, Claude Code) é mais produtivo que copiar/colar código de chatbots web, pois os agentes entendem o contexto do projeto.

  * # **Evoluções Futuras e Equipe**

    * Evoluções futuras pensadas pela equipe que não foram implementadas;

      1. **Backend Spring Boot**: implementar a API REST real em Spring Boot 3 conectada ao PostgreSQL
      2. **Integração com LLM paga**: conectar a OpenAI/Anthropic para análise automática de incidentes
      3. **Autenticação e RBAC**: implementar login com perfis (ADMIN, GESTOR, ANALISTA) conforme tabela `usuario`
      4. **Geração de registros rápidos**: botão na interface que gera 20 registros simulados de uma vez
      5. **Dashboard com gráficos**: painel estatístico com contagem por risco, status e tipo de fraude
      6. **Notificações em tempo real**: WebSocket para alertar analistas sobre novos incidentes de alto risco
      7. **Dark mode**: tema escuro seguindo DSGOV
      8. **Testes unitários**: implementar testes com Jasmine/Karma para todos os componentes
      9. **CI/CD pipeline**: GitHub Actions para build, lint e deploy automáticos
      10. **Ocultação de CPF**: esconder CPF nas respostas de consulta (conforme requisito não funcional)

    * Apresentação de membros da equipe e responsabilidades de cada membro.

      | Membro | Papel | Responsabilidades |
      |--------|-------|-------------------|
      | [Nome Membro 1] | Desenvolvedor Frontend | Componentes Angular, estilização DSGOV, validações |
      | [Nome Membro 2] | Desenvolvedor Backend/DBA | Schema PostgreSQL, triggers, views, API design |
      | [Nome Membro 3] | Arquiteto de Solução | Arquitetura geral, documentação, integração IA |
      | [Nome Membro 4] | QA / Testes | Validação de funcionalidades, testes manuais |

      **Squad 02 - Universidade Católica de Brasília (UCB)**
