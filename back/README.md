# ONAC - Lista PIA (Backend)

API Spring Boot 3 para gerenciamento da Lista de Pessoas de Interesse Antifraude (PIA), com banco PostgreSQL provisionado via Docker.

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (ou Docker Engine + Compose)
- Java 17
- Maven 3.9+

## Estrutura do projeto

```
back/
├── database/
│   ├── init/           # Scripts executados na 1ª criação do volume Docker
│   ├── seeds/          # Seed de desenvolvimento (reaplicável)
│   └── reset/          # DROP CASCADE (reset manual)
├── scripts/            # Utilitários para subir/parar/resetar banco e seed
├── src/main/java/      # API Spring Boot
├── onac_lista_pia.sql  # Legado — use database/init/ como fonte da verdade
└── pom.xml
```

O `docker-compose.yml` fica na **raiz do repositório** (`PIA_SIM/`), não dentro de `back/`.

## Quick start

Na raiz do repositório:

```powershell
# 1. Variáveis de ambiente
cp .env.example .env

# 2. Subir PostgreSQL (scripts em back/database/init/ rodam na 1ª inicialização)
./back/scripts/db-up.ps1

# 3. Dados de demonstração (reaplicável sem destruir o volume)
./back/scripts/db-seed-dev.ps1

# 4. API Spring Boot
cd back
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

Em Linux/macOS, use `db-up.sh` no lugar de `db-up.ps1`.

## URLs

| Recurso | URL |
|---------|-----|
| API (listagem) | http://localhost:8080/api/v1/pia |
| Swagger UI | http://localhost:8080/swagger-ui.html |
| OpenAPI JSON | http://localhost:8080/api-docs |
| PostgreSQL | `localhost:5432` (credenciais no `.env`) |
| pgAdmin (opcional) | http://localhost:5050 |

Para habilitar o pgAdmin:

```powershell
docker compose --profile tools up -d
```

## Identificador da API

O identificador público de cada registro PIA é o **`id` numérico** (`BIGSERIAL`). Não há endpoint de detalhe individual (`GET /api/v1/pia/{id}` para leitura). O frontend Angular ainda usa mocks com ID no formato `ONAC-YYYY-NNNN` — a integração é fase futura.

## Endpoints

| Método | Path | Descrição |
|--------|------|-----------|
| `GET` | `/api/v1/pia` | Lista com filtros `risco`, `status` e paginação (`pagina`, `por_pagina`) |
| `POST` | `/api/v1/pia` | Cria PIA + incidente + análise IA (stub) |
| `PUT` | `/api/v1/pia/{id}` | Atualiza `grauInteresse` e/ou `status` |
| `DELETE` | `/api/v1/pia/{id}` | Remove registro (auditoria em `pia_historico`) |
| `GET` | `/api/v1/pia/export` | Exporta CSV a partir de `v_relatorio_seguro` |

### Exemplos

**Listar com filtro:**

```http
GET /api/v1/pia?risco=ALTO&pagina=1&por_pagina=10
```

**Criar registro:**

```json
POST /api/v1/pia
{
  "descricaoAnonimizada": "Relato de fraude sem dados pessoais...",
  "tipoFraude": "PHISHING",
  "titulo": "Tentativa de phishing via e-mail"
}
```

**Atualizar:**

```json
PUT /api/v1/pia/100
{
  "grauInteresse": "MEDIO",
  "status": "SUSPEITO"
}
```

## Scripts do banco

| Script | Função |
|--------|--------|
| `scripts/db-up.ps1` | `docker compose up -d` |
| `scripts/db-down.ps1` | Para containers |
| `scripts/db-reset.ps1` | `docker compose down -v` + `up -d` (recria volume e reexecuta init) |
| `scripts/db-seed-dev.ps1` | Reaplica `database/seeds/dev_seed.sql` sem destruir o volume |

> Os scripts assumem execução a partir da **raiz do repositório** (eles fazem `cd` automaticamente).

## Banco de dados

### Tabelas

- `usuario` — operadores do sistema
- `incidente` — relatos vinculados a um `pia_id`
- `incidente_analise` — resultado da análise IA por incidente
- `pia` — registro consolidado na lista
- `pia_historico` — auditoria de alterações

### Views

- `v_lista_pia` — listagem segura (usada pelo `GET /api/v1/pia`)
- `v_relatorio_seguro` — exportação CSV

### Recursos

- Índices para performance
- Triggers de auditoria e sincronização (`fn_sincronizar_pia`, `fn_auditar_pia`)
- Seed base em `database/init/07_seed_base.sql` (usuários de teste)
- Seed de demo em `database/seeds/dev_seed.sql` (~8 registros PIA)

### Reset completo

```powershell
./back/scripts/db-reset.ps1
./back/scripts/db-seed-dev.ps1
```

Os scripts em `database/init/` só rodam na **primeira criação** do volume `onac_pia_data`. Use `db-reset` para recriar o schema do zero.

## Tecnologias

- PostgreSQL 16 (Docker)
- Spring Boot 3.3 / Java 17
- Spring Data JPA (`ddl-auto: validate`)
- springdoc-openapi (Swagger)
- pgAdmin 4 (perfil `tools`, opcional)

## Checklist de validação

Fluxo validado localmente (Docker → seed → API):

- [x] `docker compose up` sobe Postgres saudável
- [x] Init scripts criam tabelas, triggers e views sem colunas SID
- [x] Seed dev popula `v_lista_pia` com registros visíveis (campo `id` numérico)
- [x] `GET /api/v1/pia?risco=ALTO` retorna JSON paginado com `id`
- [x] `POST /api/v1/pia` cria registro e sincroniza métricas via trigger
- [x] `PUT /api/v1/pia/{id}` e `DELETE /api/v1/pia/{id}` operam por ID numérico
- [x] `DELETE /api/v1/pia/{id}` gera linha em `pia_historico`
- [x] `GET /api/v1/pia/export` retorna CSV

Para repetir a validação dos endpoints:

```powershell
./back/scripts/validate-api.ps1
```

> Requer API em execução (`mvn spring-boot:run "-Dspring-boot.run.profiles=dev"` no diretório `back/`).

## Arquivo legado

O arquivo `onac_lista_pia.sql` na raiz de `back/` é o schema monolítico original. A fonte da verdade para o ambiente Docker é `database/init/`. O SQL legado pode conter referências desatualizadas (ex.: coluna SID removida).
