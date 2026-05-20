
# Comparativo de Estratégias Frontend no Backstage — V2

## Objetivo

Este documento compara diferentes estratégias arquiteturais para construção de experiências frontend relacionadas ao ecossistema do Backstage, considerando:

- Experiência do usuário
- Autonomia dos times
- Governança
- Escalabilidade organizacional
- Evolução tecnológica
- Complexidade operacional
- Sustentabilidade no longo prazo

---

# As 3 Visões

| Critério | Frontend Totalmente Integrado | Frontend via App no Backstage | Frontend Desacoplado |
|---|---|---|---|
| Modelo | Plugin nativo dentro do Backstage | Microfrontend embarcado via iframe/proxy/federation | Aplicação independente |
| Propriedade do código | Time do Backstage | Time do produto | Time do produto |
| Acoplamento | Alto | Médio | Baixo |
| Autonomia tecnológica | Baixa | Média | Alta |
| Experiência unificada | Alta | Média | Baixa |
| Evolução independente | Baixa | Média | Alta |

---

# 1. Frontend Totalmente Integrado

O frontend vive dentro do Backstage como um plugin React, utilizando os componentes e abstrações da própria plataforma.

## Pontos Positivos

- Experiência visual unificada
- Navegação integrada
- Autenticação herdada automaticamente
- Integração nativa com catálogo, TechDocs e RBAC
- Menor necessidade de infraestrutura adicional
- Descoberta natural via portal

## Pontos Negativos

- Forte acoplamento ao ciclo de releases do Backstage
- Dependência das tecnologias da plataforma
- Build monolítico e aumento do tempo de CI/CD
- Desenvolvimento local mais pesado
- Governança centralizada
- Maior risco de regressões em upgrades

## Riscos de Evolução

- Transformar o Backstage em um monolito frontend corporativo
- Dificuldade crescente de upgrades
- Dependência excessiva do time de plataforma
- Acoplamento organizacional entre equipes

---

# 2. Frontend via App no Backstage

A aplicação é desenvolvida separadamente, mas aparece dentro do Backstage via iframe, proxy reverso ou Module Federation.

## Pontos Positivos

- Deploy independente
- Maior autonomia tecnológica
- Presença centralizada no portal
- Isolamento parcial de falhas
- Menor impacto no restante do Backstage

## Pontos Negativos

- Experiência parcialmente fragmentada
- Complexidade de autenticação
- Necessidade de comunicação entre aplicações
- Overhead operacional adicional
- Problemas de UX em iframes
- Complexidade de CSP e CORS

## Observação Arquitetural

Existem diferenças relevantes entre:
- iframe: maior isolamento, porém pior integração
- Module Federation: melhor experiência integrada, porém maior acoplamento de runtime

## Riscos de Evolução

- Complexidade crescente de comunicação entre apps
- Inconsistências visuais
- Dependência de mecanismos de integração
- Acoplamento indireto via APIs compartilhadas

---

# 3. Frontend Desacoplado

O frontend é uma aplicação completamente independente. O Backstage atua apenas como camada de descoberta, catálogo e integração organizacional.

## Pontos Positivos

- Máxima autonomia dos times
- Independência tecnológica
- Deploy independente
- Melhor experiência de desenvolvimento
- Escalabilidade isolada
- Evolução desacoplada da plataforma
- Liberdade para UX altamente customizadas
- Possibilidade de adoção de arquiteturas modernas sem restrições do Backstage

## Pontos Negativos

- Experiência menos unificada
- Necessidade de SSO independente
- Maior responsabilidade operacional
- Ausência de integrações nativas
- Risco de divergência entre padrões de UX

## Riscos de Evolução

- Fragmentação da experiência entre produtos
- Necessidade de padronização organizacional
- Divergência entre times
- Maior responsabilidade de observabilidade e segurança por aplicação

---

# Modelo Operacional

Independentemente da abordagem escolhida, alguns pontos precisam ser claramente definidos:

- Ownership da aplicação
- Processo de publicação
- Estratégia de autenticação
- Padrões de UX
- Observabilidade
- Responsabilidade por infraestrutura
- Estratégia de versionamento
- Governança de segurança

Grande parte dos problemas organizacionais relacionados ao Backstage normalmente surgem mais de ambiguidades operacionais do que de limitações técnicas.

---

# Maturidade Organizacional

| Maturidade do Time | Abordagem Mais Natural |
|---|---|
| Times pequenos ou centralizados | Integrado |
| Times intermediários | App embarcado |
| Times maduros e independentes | Desacoplado |

Autonomia normalmente aumenta junto com:
- maturidade técnica
- ownership
- capacidade operacional
- cultura de plataforma

---

# Matriz de Impacto

| Dimensão | Integrado | App no Backstage | Desacoplado |
|---|:---:|:---:|:---:|
| Experiência do usuário | ★★★ | ★★☆ | ★☆☆ |
| Autonomia do time | ★☆☆ | ★★☆ | ★★★ |
| Velocidade de evolução | ★☆☆ | ★★☆ | ★★★ |
| Facilidade de integração | ★★★ | ★★☆ | ★☆☆ |
| Complexidade distribuída | ★☆☆ | ★★☆ | ★★★ |
| Sustentabilidade de longo prazo | ★☆☆ | ★★☆ | ★★★ |

---

# Conclusão Arquitetural

A escolha da abordagem depende menos da tecnologia e mais do equilíbrio desejado entre:

- autonomia dos times
- governança central
- experiência unificada
- velocidade de evolução
- independência tecnológica

Para produtos com necessidade elevada de customização, evolução rápida de UX e independência de plataforma, o modelo desacoplado tende a oferecer maior sustentabilidade no longo prazo.

Já funcionalidades diretamente relacionadas à experiência central da plataforma podem continuar integradas ao Backstage, aproveitando o ecossistema nativo da ferramenta.

---

# Visão Recomendada

## Backstage como:

- catálogo
- camada de descoberta
- portal de entrada
- identidade e autenticação
- governança
- scaffolding
- documentação

## Aplicações desacopladas como:

- experiências ricas de produto
- workflows avançados
- interfaces altamente customizadas
- aplicações com autonomia completa de evolução
