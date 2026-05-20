# Comparativo de Estratégias Frontend no Backstage

## As 3 Visões

| Critério | Frontend Totalmente Integrado | Frontend via App no Backstage | Frontend Desacoplado |
|---|---|---|---|
| **Modelo** | Plugin nativo dentro do Backstage | Micro-frontend embarcado via iframe/proxy | Aplicação independente, Backstage como catálogo |
| **Propriedade do código** | Time do Backstage | Time do produto, hospedado no Backstage | Time do produto, fora do Backstage |
| **Acoplamento** | Alto | Médio | Baixo |
| **Experiência do usuário** | Unificada | Parcialmente unificada | Fragmentada |
| **Autonomia do time** | Baixa | Média | Alta |

---

## 1. Frontend Totalmente Integrado

O frontend vive dentro do Backstage como um plugin React, usando os componentes e o design system do próprio Backstage (Material UI, `@backstage/core-components`).

### Pontos Positivos

- **Experiência consistente**: navegação, temas, autenticação e permissões unificados com o resto do portal.
- **Menor overhead de infraestrutura**: não há necessidade de hospedar uma aplicação separada.
- **Integração nativa com APIs do Backstage**: acesso direto ao catálogo, TechDocs, scaffolding, permissões via RBAC nativo.
- **SSO transparente**: o contexto de autenticação do Backstage é herdado automaticamente.
- **Fácil de descobrir**: o frontend aparece naturalmente no menu de navegação do portal.

### Pontos Negativos

- **Acoplamento forte ao ciclo de release do Backstage**: atualizações de versão do Backstage podem quebrar o plugin.
- **Stack engessada**: o time é forçado a usar React e as abstrações do Backstage, sem liberdade de escolha tecnológica.
- **Curva de aprendizado**: a API de plugins do Backstage tem suas próprias convenções (`createPlugin`, `createRouteRef`, etc.).
- **Build monolítico**: o frontend faz parte do build do Backstage, aumentando o tempo de CI/CD e o risco de deploys.
- **Dificuldade de trabalho local**: desenvolver exige subir o Backstage localmente, que é pesado.
- **Governança centralizada**: times dependem da equipe que opera o Backstage para publicar ou modificar plugins.

---

## 2. Frontend via App no Backstage (Micro-frontend embarcado)

O frontend é uma aplicação independente (React, Vue, Angular, etc.) hospedada separadamente, mas exposta dentro do Backstage por meio de um plugin wrapper — geralmente via `iframe`, proxy reverso ou Module Federation.

### Pontos Positivos

- **Autonomia de tecnologia**: o time do produto escolhe sua stack sem restrições do Backstage.
- **Deploy independente**: a aplicação tem seu próprio pipeline de CI/CD, sem depender do ciclo do Backstage.
- **Visibilidade no portal**: o usuário ainda acessa tudo a partir do Backstage, mantendo a centralização da experiência.
- **Menor risco de regressão no Backstage**: mudanças no app não afetam o restante do portal.
- **Isolamento de falhas**: se o app travar, o Backstage continua funcionando.

### Pontos Negativos

- **Experiência fragmentada**: temas, tipografia, componentes e navegação do app dificilmente batem 100% com o Backstage.
- **Autenticação duplicada**: é necessário resolver como passar o token do Backstage para o app interno (cookies, postMessage, headers).
- **iframes trazem limitações**: problemas de responsividade, deep-linking, acessibilidade e SEO.
- **Overhead de manutenção**: há dois deploys para gerenciar: o do Backstage e o do app.
- **Complexidade de comunicação**: integrar dados do catálogo do Backstage (ex: entidades, metadados) dentro do app exige chamadas à API do Backstage, adicionando latência e coupling indireto.
- **Segurança**: políticas de CSP e CORS precisam ser gerenciadas com cuidado ao embedar apps externos.

---

## 3. Frontend Desacoplado

O frontend é uma aplicação completamente independente, acessível pela sua própria URL. O Backstage serve apenas como catálogo/portal de descoberta — um link no catálogo aponta para a aplicação externa.

### Pontos Positivos

- **Máxima autonomia do time**: tecnologia, arquitetura, cadência de deploy e infraestrutura são 100% controlados pelo time do produto.
- **Sem acoplamento ao Backstage**: o time não precisa conhecer nem se preocupar com a plataforma do portal.
- **Experiência de desenvolvimento limpa**: ambiente local simples, sem dependência de nenhuma plataforma de portal.
- **Escalabilidade independente**: infra, CDN e otimizações são feitas exclusivamente para aquela aplicação.
- **Menor risco transversal**: um problema no Backstage não afeta o produto e vice-versa.

### Pontos Negativos

- **Fragmentação da experiência**: o usuário navega para fora do portal, perdendo a sensação de produto unificado.
- **Autenticação isolada**: SSO precisa ser implementado e mantido pelo time do produto (ex: integração com o IdP diretamente).
- **Sem acesso nativo ao ecossistema Backstage**: RBAC, catálogo, TechDocs e scaffolding não estão disponíveis out-of-the-box.
- **Descoberta depende de curadoria manual**: se alguém não registrar o link no catálogo, o frontend simplesmente não é encontrado via Backstage.
- **Silos de produto**: times tendem a divergir em padrões de UX, autenticação e infra quando não há plataforma compartilhada.
- **Overhead de infraestrutura por time**: cada time precisa operar sua própria hospedagem, CDN, certificados, etc.

---

## Resumo de Decisão

```
Precisa de experiência unificada e governança centralizada?
→ Frontend Totalmente Integrado

Precisa de autonomia de tecnologia mas quer presença no portal?
→ Frontend via App no Backstage

Time maduro, produto complexo, baixa necessidade de integração com o portal?
→ Frontend Desacoplado
```

---

## Matriz de Impacto

| Dimensão | Integrado | App no Backstage | Desacoplado |
|---|:---:|:---:|:---:|
| Experiência do usuário | ★★★ | ★★☆ | ★☆☆ |
| Autonomia do time | ★☆☆ | ★★☆ | ★★★ |
| Velocidade de entrega | ★☆☆ | ★★☆ | ★★★ |
| Facilidade de integração | ★★★ | ★★☆ | ★☆☆ |
| Complexidade operacional | ★☆☆ | ★★☆ | ★★★ |
| Consistência de segurança | ★★★ | ★★☆ | ★☆☆ |
