# Estratégia Frontend GustaLab Store — V3 (Decisão Arquitetural)

> Este documento registra a decisão arquitetural final para o frontend do GustaLab Store,  
> consolidando a análise das versões V1 e V2 deste comparativo.

---

## Decisão

**O GustaLab Store adota o modelo Frontend Desacoplado.**

O Backstage atua como plataforma de backend — responsável por autenticação, catálogo, scaffolding e governança.  
O frontend Next.js é uma aplicação independente, responsável exclusivamente pela experiência do usuário, consumindo as APIs do Backstage via BFF layer (Next.js Route Handlers).

---

## Contexto

O GustaLab Store é um developer portal no modelo de loja de infraestrutura: engenheiros provisionam recursos cloud (EKS, RDS, VPCs, etc.) com a experiência de comprar produtos numa loja online.

A experiência do usuário é o diferencial central do produto. A liberdade de UX, a cadência de evolução do frontend e a separação de responsabilidades entre times foram os fatores determinantes da decisão.

---

## Justificativa

### Ciclos de vida independentes

O Backstage possui cadência de releases própria, com atualizações frequentes e breaking changes. O frontend de produto tem seu próprio ritmo de evolução — novas funcionalidades, melhorias de UX, experimentos de interface. Acoplar os dois ciclos criaria dependência desnecessária e risco mútuo.

### Separação de responsabilidades entre times

A longo prazo, times diferentes irão operar cada lado:

| Time | Responsabilidade |
|---|---|
| Time de Plataforma | Backstage: catálogo, templates, RBAC, upgrades |
| Time de Produto | GustaLab Store: UX, frontend, experiência do usuário |

Cada time evolui no seu ritmo. A coordenação acontece apenas quando o contrato de API precisa ser alterado — não em cada deploy.

### Liberdade tecnológica e de UX

A proposta de valor do GustaLab Store depende de uma interface que cause impacto — a sensação de estar numa loja premium, não num painel técnico genérico. Isso não é possível dentro das restrições do plugin nativo do Backstage (Material UI, convenções da plataforma). O modelo desacoplado remove essas restrições completamente.

### Sustentabilidade de longo prazo

Conforme o projeto cresce, o desacoplamento evita que o Backstage se torne um monolito frontend corporativo. Cada parte do sistema pode ser substituída, migrada ou escalada de forma independente.

---

## Arquitetura Resultante

```
┌─────────────────────────────────┐
│        GustaLab Store           │
│    (Next.js — porta 3000)       │
│                                 │
│  UI  →  Route Handlers (BFF)    │
└──────────────┬──────────────────┘
               │ HTTP (interno)
               │ Contrato de API documentado
               ▼
┌─────────────────────────────────┐
│           Backstage             │
│    (Backend — porta 7007)       │
│                                 │
│  Catalog API   Scaffolder API   │
│  Auth API      Permissions API  │
└─────────────────────────────────┘
```

### Responsabilidades por camada

| Camada | Tecnologia | Responsabilidade |
|---|---|---|
| Frontend | Next.js 14 + Tailwind | Experiência do usuário, navegação, estado |
| BFF Layer | Next.js Route Handlers | Proxy seguro para o Backstage, evita CORS |
| Backend | Backstage (porta 7007) | Catálogo, scaffolding, auth, RBAC |

---

## Contrato de API

O contrato entre frontend e Backstage é o ponto de coordenação entre os times.  
Qualquer alteração que afete ambos os lados deve ser discutida e documentada antes da implementação.

### Endpoints consumidos pelo frontend

| Funcionalidade | Método | Endpoint |
|---|---|---|
| Listar produtos (templates) | GET | `/api/catalog/entities?filter=kind=Template` |
| Detalhe de produto | GET | `/api/catalog/entities/by-name/template/default/{name}` |
| Criar instalação (task) | POST | `/api/scaffolder/v2/tasks` |
| Status de instalação | GET | `/api/scaffolder/v2/tasks/{id}` |
| Histórico do usuário | GET | `/api/catalog/entities?filter=kind=Component,spec.owner={user}` |
| Sessão do usuário | GET | `/api/auth/v1/session` |

> **Regra:** o frontend nunca chama o Backstage diretamente pelo browser.  
> Toda comunicação passa pelos Route Handlers do Next.js.

---

## Trade-offs Aceitos

| Trade-off | Mitigação |
|---|---|
| Autenticação não herdada automaticamente | Implementada via BFF: token do Backstage repassado nos Route Handlers |
| Sem RBAC nativo do Backstage no frontend | Permissões consultadas via API e aplicadas no frontend |
| Dois deploys para gerenciar | Pipelines independentes — cada um com seu próprio ciclo |
| Risco de divergência entre times | Contrato de API documentado e versionado neste repositório |

---

## O que esta decisão não cobre

- A estratégia de autenticação em produção (Guest Auth vs SSO) será definida em documento separado.
- A estratégia de deploy e hospedagem do frontend será definida quando o projeto sair do ambiente local.
- Plugins internos do Backstage (se necessários) continuam sendo desenvolvidos no modelo integrado nativo — esta decisão se aplica exclusivamente ao GustaLab Store.

---

## Referências

- `estrategias-backstage-v1.md` — Análise inicial dos três modelos
- `estrategias-backstage-v2.md` — Análise aprofundada com riscos de evolução e modelo operacional
- Protótipo de referência visual: `gustalabstore.jsx`
- Prompt de implementação: `PROMPT_CLAUDE_CODE.md`

---

*Decisão registrada em maio de 2025.*  
*Autor: Gustavo — GustaLab*
