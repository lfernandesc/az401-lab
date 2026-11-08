# Laboratório guiado AZ-401 — Orders API

Português com termos técnicos em English. Questionário e respostas em English.
Preparado em 8 de novembro de 2026. Material original de estudo; as perguntas não são questões reais nem previsões garantidas do exame.

## Como usar

Este guia amplia o [README inicial](../README.md). Trabalha no repository `lfernandesc/az401-lab` e no project `https://dev.azure.com/lucasfernandesc/az401-lab`. Não recries estes ambientes. A Orders API existente tem `/health`, `/orders` e a configuração `SIMULATE_FAILURE`.

Reserva aproximadamente 35–50 horas, conforme a experiência e as licenças disponíveis. Executa o percurso inicial do README e depois os aprofundamentos abaixo, sem saltar as validações. Os exemplos de terminal usam **Bash**, em WSL, Linux ou Azure Cloud Shell; não os copies diretamente para PowerShell. Python local deve ser 3.12, conforme o starter. Precisas de Git, Azure CLI, GitHub CLI, VS Code, Node.js compatível com o MCP e GitHub Copilot autorizado.

Cria uma feature branch para cada exercício e um ficheiro `evidence/Lxx.md`: objetivo, alterações, links de runs, resultado esperado/obtido e dúvidas. Estados permitidos: **executado**, **simulado**, **pendente**. A existência deste guia não significa que os recursos Azure ou as integrações já foram configurados. Não há evidência de execução remota desta versão do curso.

Não há garantia de free tier para todos os exercícios. Configura Cost Management budget e alert antes de criar recursos; alerts não bloqueiam despesas. Deployment slots requerem um App Service tier adequado, como Standard; o B1 do starter não os suporta. Scanning privado, approvals, agents e AI podem depender de plano, policy, região e permissões. Quando não disponíveis, faz o desenho e marca **simulado**, mantendo o hands-on pendente. Nunca uses produção como alvo de fault injection.

### Mapa de cobertura

Os percentuais oficiais são: processos 15–20%, source control 10–15%, pipelines 35–40%, security 15–20% e instrumentation 15–20%. O mapa seguinte é uma organização didática própria. Confere sempre a versão vigente do [study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-401); o âmbito da prova pode mudar.

| Área | Competências a praticar | Laboratórios |
|---|---|---|
| Processos | Work flow, feedback, Boards, traceability, métricas e queries | L01–L02 |
| Colaboração | Wiki, README, changelog, releases, license, CODEOWNERS, diagramas; agents, skills, loops, webhooks e MCP; Boards/GitHub | L01–L03 |
| Source control | Trunk, feature/release branches, Git flow/GitHub flow, worktrees, PRs, restrições para Copilot, permissions, tags, hooks, migration, recovery | L04–L05 |
| Packages | Artifacts/Packages, feeds, views, upstreams, SemVer, CalVer, artifact versions | L06 |
| Testing | Local/unit/integration/load, coverage, test agents/results, quality/release gates com Copilot/MCP | L07 |
| Pipelines | Actions/Pipelines, runner/agent design e implementação, GitHub integration, YAML, triggers, parallelism/stages, templates/task groups/variables, approvals, Agentic Workflows | L08–L10 |
| Deployment | Blue-green/canary/rings/progressive exposure/flags/A-B, dependências, slots/swap/rolling, hotfix, resilience, containers/binaries/scripts/database | L11–L12 |
| IaC e manutenção | IaC/configuration management, pipeline health, custo/tempo/reliability, retention | L13–L14 |
| Security | Entra identities, GitHub App/token/PAT, federation, service connections, permissions/access levels/teams | L15 |
| Secrets e compliance | Key Vault, secrets/keys/certificates, secure files, leak prevention, scanning, Defender integrations | L16–L17 |
| Instrumentation | Dashboards, platform monitoring, Monitor/Log Analytics, GitHub insights/charts e alerts | L02, L14, L18 |
| AI operations | Observability Agent, SRE Agent, incident resolution, performance, distributed traces, Copilot logs, natural language e KQL | L19–L20 |

## L01 — Plan → build → deploy → operate

**Conceitos:** Work item expressa intenção; commit identifica alteração; PR permite review; build produz artifact; deployment associa artifact a environment. Traceability liga estes objetos. Feedback só fecha o ciclo quando regressa ao backlog.

1. No project existente, verifica o process. Em Agile usa User Story; em Scrum usa Product Backlog Item. Cria o item `Orders API: entrega e recuperação rastreáveis`, com critérios: HTTP 200, coverage ≥90%, PR protegido, artifact por SHA, secretless deployment, alerta e recuperação demonstrados.
2. Cria Tasks para testes, pipeline, IaC, security e observability. Define owner, iteration, Area Path e Definition of Done. Em Boards configura colunas com limites de Work in Progress e uma política explícita para itens bloqueados.
3. Em Project Settings → GitHub connections, conecta apenas o repository do lab, autorizando a Azure Boards GitHub App. Verifica as permissões pedidas e se tens autoridade em ambos os serviços.
4. Num PR inclui `AB#<ID>` e confirma o link na secção Development do work item. Faz um segundo link via MCP no L03; não assumes que mencionar um ID configura a integração.
5. Em Project Settings → Notifications cria uma subscription para build failure destinada a ti; no GitHub escolhe Watch → Custom para os eventos relevantes. Não envies notificações para terceiros neste lab.
6. Documenta `README`, `CHANGELOG.md`, `docs/runbook.md`, uma release e uma wiki page com o fluxo. Acrescenta uma license apenas depois de escolheres os direitos de utilização. Pede ao Copilot um rascunho e verifica os factos.
7. Em `.github/CODEOWNERS`, usa `/infra/ @lfernandesc` como exemplo e exige Code Owner review quando o plano permitir. Um ficheiro CODEOWNERS isolado não obriga review.

**Checkpoint:** navega de work item a commit, PR, run, artifact e environment. Abre um Bug a partir de um incidente fictício, liga-o à story e acrescenta uma ação preventiva. Guarda os URLs.

## L02 — Métricas que respondem a objetivos

**Conceitos:** Lead time depende dos pontos inicial/final escolhidos; cycle time mede a parte ativa do fluxo. Deployment frequency mede entregas; change failure rate mede deployments com falha; time to recovery mede recuperação. Não confundas velocidade com qualidade.

1. Define um KPI fictício: reduzir interrupções de checkout. Deriva padrões: availability SLO 99,9% por mês; p95 <500 ms em carga acordada; recovery <15 min; nenhuma critical vulnerability sem tratamento antes de release. São metas didáticas, não defaults do produto.
2. Cria uma Boards query com Work Item Type Bug, State diferente de Closed e tag `production`. Adiciona um Query Tile e um Cycle Time widget ao dashboard; mantém o significado dos estados consistente.
3. Para treino reproduzível, cria `evidence/deployments.csv` com 10 deployments, UTC start/recovery e indicador failed. Calcula frequency por dia, failed/total e média de recovery apenas nos incidentes. Explica a amostra e os deployments sem falha.
4. Pede ao Copilot uma WIQL query para bugs ativos no project. Inspeciona project scope, nomes de campos e estado; executa-a por MCP e compara os IDs com a query do Boards. Não forneças passwords ao chat.
5. No GitHub abre Insights → Pulse e Actions; num Project cria campos status e priority, adiciona items e cria um chart em Insights, se disponível. Documenta o que cada gráfico mede e o que não consegue inferir.

**Checkpoint:** entrega um dashboard e uma tabela KPI → métrica → fonte → query → threshold → ação. Demonstra por que 100 commits por dia não prova valor entregue.

## L03 — Copilot, MCP, skills e autonomia

**Conceitos:** Prompt define o pedido; instructions impõem contexto duradouro; skill reúne conhecimento/procedimento reutilizável; agent usa tools e decide próximos passos; MCP padroniza acesso a ferramentas. Um webhook entrega um evento; não tem o mesmo papel de MCP. Um loop sem limite pode repetir alterações e custos.

Usa o [learning path](https://learn.microsoft.com/en-us/training/paths/optimize-devops-ai-agents-azure/) para estudar modos de autonomia. Em Plan mode pede um plano para acrescentar paginação a `/orders`, com critérios, riscos, testes e rollback. Revê o plano antes de mudar para implementação.

1. Revê `.github/copilot-instructions.md`: só o lab como scope; sem secrets; não fazer merge; alterações por PR; no máximo três tentativas de correção antes de parar e reportar. Instructions são orientação; aplica os controlos reais por permissions, checks e branch rules.
2. Configura `.vscode/mcp.json`, usando os [passos oficiais de Azure DevOps MCP](https://learn.microsoft.com/en-us/training/modules/manage-ado-mcp-server/3-install-configure-azure-devops-mcp-vs-code) e a configuração de GitHub MCP autorizada pela organization. Não guardes tokens no JSON.

```json
{
  "servers": {
    "ado": {"type":"stdio", "command":"npx", "args":["-y","@azure-devops/mcp","lucasfernandesc"]},
    "github": {"type":"http", "url":"https://api.githubcopilot.com/mcp/"}
  }
}
```

3. Autentica, descobre as tools e começa com `Lista os projects da organization e os PRs abertos de lfernandesc/az401-lab. Não alteres dados.` Confirma tool call, argumentos e resultado real.
4. Pede a criação de uma Task ligada à story de L01 e um comentário contendo o URL do PR. Revê ID, relação e texto antes de autorizar. Confirma ambos os lados no browser.
5. Em Project Settings → Service hooks cria uma subscription de build completed para um endpoint de teste sob teu controlo. Usa apenas dados fictícios, valida o evento e elimina a subscription. Não uses um coletor público para dados privados. Se não tiveres endpoint, desenha o payload e marca simulado.
6. Escreve uma skill de review de Bicep com critérios TLS, identity, scope e naming. Aplica-a a `infra/main.bicep`; guarda findings verificados e false positives.
7. Desenha um conductor com três papéis: planner produz `plan.md`; implementer produz diff e testes; reviewer produz `review.md`. Define tools por papel, schema dos artifacts, limite de retries e condição de paragem. Executa os papéis sequencialmente no Copilot, mantendo os artifacts como handoff, caso multi-agent execution não esteja disponível.

**Checkpoint:** leitura em ambos os MCP servers, escrita rastreável no Boards, uma revisão humana e uma falha de autorização diagnosticada sem aumentar privilégios indiscriminadamente.

## L04 — Branching, policies e Git recovery

**Conceitos:** Trunk-based usa branches curtas e integração frequente; GitHub flow usa branch/PR/main deployable; release branch estabiliza uma versão; Git flow acrescenta develop/release/hotfix com maior complexidade. Worktree oferece outro working directory sobre o mesmo repository, não outra remote copy.

1. Em GitHub Settings → Rules configura `main`: PR obrigatório, check de CI obrigatório, reviews, invalidar approvals após novos commits, bloquear force push/deletion e restringir bypass. Inclui Copilot e identidades de automação no modelo: não lhes dês exceção geral.
2. Num Azure Repos de treino, abre Repos → Branches → Branch policies e configura minimum reviewers, linked work items e build validation. Nas permissions separa Contribute de bypass policies; faz um PR com um teste vermelho e confirma bloqueio.
3. No GitHub repete o PR vermelho/verde descrito no README. Uma falha local de hook não substitui o check no server.

```bash
git switch main
git switch -c feature/pagination
git worktree add ../az401-hotfix -b hotfix/orders main
git worktree list
```

4. No worktree cria um hotfix e PR. Depois de integrado, propaga-o para qualquer release branch ainda suportada, resolvendo conflitos e repetindo testes. Remove o worktree só depois de guardar/commitar o trabalho.
5. Cria um repository local descartável para recovery: faz três commits fictícios, usa `git log --oneline`, reverte o segundo com `git revert <SHA>` e observa o novo commit. Experimenta `git restore --source=<SHA> -- ficheiro.txt` para restaurar um ficheiro. Usa `git reflog` para encontrar um commit perdido e `git branch rescue <SHA>` para o preservar.
6. Compara `revert` com `reset`: revert preserva a história partilhada; reset move o branch pointer e pode descartar trabalho. Reescrita para remover um secret exige coordenação, limpeza de refs/caches e revogação imediata; apagar o ficheiro no último commit não resolve a exposição histórica.

**Checkpoint:** explica qual estratégia escolherias para releases semanais versus várias entregas diárias; demonstra merge bloqueado para pessoa e automação.

## L05 — Repositories, tags, hooks e migration

1. Define uma matriz de acesso: readers, contributors, maintainers e automation. Valida com uma identidade de teste de menor acesso; nunca assumas que access level e permission são equivalentes.
2. Cria uma annotated tag numa versão testada: `git tag -a v1.1.0 -m 'Orders API release'`; publica-a por `git push origin v1.1.0` depois da review. Configura tag rules para proteger releases.
3. Cria `.githooks/pre-commit` com shebang Bash e `python -m pytest -q`, torna-o executável (`chmod +x .githooks/pre-commit`) e ativa `git config core.hooksPath .githooks`. Quebra um teste e comprova o bloqueio. O utilizador pode contornar o hook; CI mantém a autoridade.
4. Para migration usa **um Azure Repos de treino e um GitHub destination vazio separado**, sem substituir este repository. Congela writes no source e faz inventário de branches, tags, LFS e permissions.

```bash
git clone --mirror '<AZURE_REPOS_TRAINING_URL>' migration.git
cd migration.git
git show-ref > ../source-refs.txt
git remote add destination '<EMPTY_GITHUB_TRAINING_URL>'
git push --mirror destination
git ls-remote destination > ../destination-refs.txt
```

5. Compara SHAs de heads e tags, faz clone limpo e testes. `--mirror` pode apagar refs no destino: usa-o apenas no destino vazio deste exercício. Git LFS exige transferência adicional. Work items, policies, PR discussions, pipelines, secrets e permissions não migram com Git; recria-os e verifica os deep links.
6. Define cutover, rollback de acesso e atualização de remotes. Usa links explícitos para work item, coverage e code quality no PR e na release.

**Checkpoint:** tabela do que migrou e do que exigiu reconstrução; branches/tags verificadas; build a partir do clone GitHub.

## L06 — Package management e versões

**Conceitos:** Feed distribui packages; upstream agrega fontes; view expõe versões aprovadas. SemVer `MAJOR.MINOR.PATCH` comunica compatibilidade; CalVer comunica calendário, como `2026.11.1`. Pipeline artifact transporta output de um run e não substitui package registry.

1. Em Azure DevOps → Artifacts cria um feed privado `az401-training`; adiciona PyPI como upstream e usa Connect to feed → pip para configurar um virtual environment exclusivo. Não commites credenciais geradas.
2. Instala uma dependency pelo feed e confirma que a versão foi guardada a partir do upstream. Dá Reader ao consumer e o role necessário para guardar upstream packages apenas à identidade autorizada.
3. Cria um package Python fictício `az401-order-rules`, versão `0.1.0`, com `pyproject.toml`, módulo e teste. Usa `python -m build`; em Connect to feed → twine segue o comando gerado para publicar com credencial temporária. Nunca publiques o mesmo version number com conteúdo diferente.
4. Promove a versão para `@Prerelease` e, após os testes, `@Release` pela interface Artifacts. Configura um consumer para a view aprovada e confirma que uma versão não promovida não aparece ali. Publica no feed base; views servem seleção de versões. Veja [feed views](https://learn.microsoft.com/en-us/azure/devops/artifacts/concepts/views).
5. Para GitHub Packages escolhe um formato suportado, por exemplo uma imagem no GHCR; PyPI não é um registry de GitHub Packages. Em CI publica `ghcr.io/lfernandesc/az401-lab:<SHA>` com `packages: write`, associando o package ao repository. Testa pull com um consumer autorizado.
6. Escreve três decisões: breaking API → major; feature compatível → minor; fix compatível → patch. Compara uma política CalVer para snapshots operacionais. Identifica artifact com run ID + commit SHA; usa digest para containers e guarda checksums no release manifest.

**Checkpoint:** instalação via upstream, package publicado/promovido e uma tabela de escolha Azure Artifacts versus GitHub Packages. Dependências lockadas devem ser revalidadas e atualizadas, não congeladas indefinidamente.

## L07 — Testing e gates assistidos por AI

**Conceitos:** Unit isola comportamento; integration valida fronteiras; smoke verifica o mínimo após deployment; load testa sob carga; coverage mede execução, não correção. Quality gate decide se o output pode avançar; release gate considera também prontidão do environment.

1. Executa os testes locais do README. Pede ao Copilot testes para `SIMULATE_FAILURE=true/false`, e verifica que a environment variable é restaurada entre testes. Exige ≥90% de coverage e publica JUnit/Cobertura no CI existente.
2. Acrescenta integration test que inicia o servidor num processo e chama `/orders` por HTTP, verifica JSON e termina o processo em cleanup. Não o confundas com Flask test client em memória.
3. Num environment de lab, cria um script k6 ou Azure Load Testing para `/orders`: baseline, ramp-up, 5 minutos de carga e threshold p95/erro explícito. Começa com pouca carga; regista concurrency, região e dataset. Um teste local não demonstra capacidade de produção.
4. Define gates: unit+integration verdes, coverage mínimo, scan sem finding bloqueante, load threshold satisfeito, aprovação para promoção. Em falha, não publiques nova release; preserva reports mesmo com testes vermelhos.
5. Via MCP pede ao Copilot que encontre o run com falha e resuma o test report. Revê uma proposta de alteração do YAML e abre PR. Faz uma falha deliberada para demonstrar que o gate efetivamente impede avanço.
6. Compara test agents: hosted é efémero e simples; self-hosted tem controlo de rede e ferramentas, mas exige patching e isolamento. Para endpoints privados usa connectivity privada e identidade limitada.

**Checkpoint:** reports de unit/integration/load, coverage e run bloqueado. Não aumentes coverage removendo testes úteis nem eliminando o threshold.

## L08 — YAML, triggers e reutilização

1. Inspeciona o `azure-pipelines.yml` existente: hoje é CI, não CD. Conecta-o a GitHub em Pipelines → New pipeline e limita a autorização do repository.
2. Cria stages Build → Test → DeployLab; use `dependsOn` para ordem. Coloca unit e lint em jobs paralelos, depois faz Deploy depender de ambos. Mede a diferença de duração; parallel jobs têm limite de quota/custo.
3. Em GitHub Actions implementa o equivalente com `needs`, `on: pull_request`, `push` em main e `workflow_dispatch`. Num Azure Repos, PR validation é configurada por branch policy; não assumes que `pr:` YAML funciona da mesma forma que GitHub.
4. Configura path filters para docs e código, mas verifica se required status checks continuam a receber resultado. Um workflow inteiro ignorado pode deixar um check pendente.
5. Extrai os steps Python para `templates/python-tests.yml` e usa parâmetros tipados. No GitHub cria um reusable workflow com `workflow_call`, inputs explícitos e permissions mínimas. Não passes todos os secrets automaticamente.
6. Usa variables não sensíveis para região/nome e variable group para configuração partilhada. Um task group reutiliza tasks em classic pipelines; YAML templates são o mecanismo apropriado no percurso YAML. Documenta a escolha e experimenta um task group num pipeline classic de treino se essa opção estiver autorizada.
7. Cria um Environment ADO `lab-ado` e um deployment job que o referencia. Configura Approvals and checks na interface do recurso, fora do YAML. No GitHub protege o Environment correspondente. Não executes dois CDs concorrentes sobre a mesma app.

```yaml
# Fragmento Azure Pipelines: inserir após Build/Test válidos.
- stage: DeployLab
  dependsOn: Test
  jobs:
  - deployment: DeployOrders
    environment: lab-ado
    strategy:
      runOnce:
        deploy:
          steps:
          - script: echo "Substituir pelo deploy do artifact validado"
```

O fragmento só demonstra estrutura, não faz deployment. Substitui o step pelo download do artifact e AzureWebApp@1 com a service connection federada de L15. Testa approval rejeitado e aprovado.

**Checkpoint:** YAML revisto pelo Copilot, PR validation, ordem de jobs, template reutilizado e deployment que espera por um check externo ao YAML.

## L09 — Runner/agent infrastructure

1. Escreve um Architecture Decision Record comparando custo de minutos, licenças, toolchain, caching, acesso privado, patching e escalabilidade de hosted versus self-hosted.
2. Cria uma VM exclusiva de lab, sem dados partilhados. Regista um self-hosted GitHub runner em Settings → Actions → Runners OU um Azure Pipelines agent num pool dedicado, seguindo o instalador gerado pela plataforma. Usa registration token temporário sem o versionar.
3. Instala Python e ferramentas exigidas, usa labels/demands e aponta um run manual para esse runner/pool. Verifica connectivity ao GitHub/ADO, Azure e package feeds.
4. Se precisares de recursos privados, configura DNS e network path adequados. Um role RBAC correto não atravessa um firewall.
5. Restringe o pool/runner group a workflows confiáveis; não executes código de forks desconhecidos com secrets ou acesso interno. Prefere processos efémeros e limpa workspace entre jobs.
6. Simula runner offline, observa queue time e restaura-o. Documenta atualização, revogação e capacidade para dois jobs.

**Checkpoint:** um run com sucesso no agent dedicado, evidência de isolamento e remoção do registo no fim. Não deixes a VM a gerar custo quando terminar.

## L10 — GitHub Agentic Workflows

**Conceito:** Workflow determinístico executa steps fixos; Agentic Workflow permite decisões do modelo dentro de ferramentas e limites configurados. Nenhum dos dois substitui autorização.

1. Numa branch, segue o [quickstart oficial](https://github.github.com/gh-aw/setup/quick-start/) e instala a extensão `gh extension install github/gh-aw`. Usa o wizard/template atual para um report manual de repository status; configura a engine e billing exigidos pelo teu plano.
2. Define trigger manual e prompt: resumir CI failures/PRs sem alterar código. Restringe tools e rede e começa read-only. Não atribuas acesso ao Boards sem configurar explicitamente esse MCP.
3. Se precisares de criar um issue de relatório, configura apenas o safe output apropriado, com limites. Safe output pode executar escrita automática e não significa aprovação humana.
4. Executa `gh aw compile`; revê Markdown e `.lock.yml` gerado. Mantém ambos versionados. Confirma job permissions e os controlos da versão instalada na [referência de compilação](https://github.github.com/gh-aw/reference/compilation-process/).
5. Abre PR, faz review, executa manualmente e recolhe logs. Acrescenta um texto fictício de prompt injection numa issue de teste pedindo exfiltração e verifica que o workflow não recebe credenciais nem ferramentas para a fazer. Um teste isolado não prova imunidade.

**Checkpoint:** report real, inputs/outputs auditáveis, ausência de merge/deploy automático e schedules desativados no fim.

## L11 — Estratégias de deployment e hotfix

| Estratégia | Como funciona | Quando usar / risco |
|---|---|---|
| Blue-green | Dois environments, tráfego muda entre eles | Rollback rápido de tráfego; custo duplicado e DB partilhada exigem cuidado |
| Canary | Pequena percentagem recebe versão nova | Deteta regressão antes da expansão; precisa métricas e sample size |
| Ring | Grupos/coortes sucessivos | Internal → early adopters → geral; grupos devem ser representativos |
| Progressive exposure | Aumentar exposição com gates | Combina tráfego, tempo e métricas |
| Feature flag | Controla comportamento sem redeploy | Permite desligar feature; exige gestão e remoção de flags antigas |
| A/B testing | Compara variantes e resultado de negócio | Precisa hipótese, atribuição estável e análise estatística |
| Rolling | Substitui instâncias gradualmente | Limita capacidade indisponível; coexistência exige compatibilidade |

1. Cria um environment separado com App Service Plan Standard suportado e uma cópia da app. Não alteres o tier partilhado de outros projetos. No Portal → Deployment slots cria `staging`.
2. Publica o artifact revisto em staging, configura slot settings apropriadas (secrets/endpoints específicos do ambiente) e aquece `/health` e `/orders`. Confirma identidade e Key Vault references por slot; não assumes que são partilhadas.
3. Faz Swap preview quando suportado, revê as configurações e executa swap. Observa requests durante a operação. Troca novamente para demonstrar rollback e mede o tempo; não prometas zero downtime sem evidência.
4. Numa segunda passagem usa routing do slot para uma pequena percentagem, gera requests suficientes e compara error rate/p95 antes de aumentar. Define um stop automático ou manual explícito. Reverte tráfego se exceder threshold.
5. Implementa uma flag fictícia `FEATURE_NEW_TOTAL` com default false; testa os dois caminhos e desliga sem novo artifact. Para A/B usa atribuição estável a dados fictícios e separa métricas por variante. Desenha rings para internal/early/general; se não os executares, regista como simulado.
6. Escreve hotfix runbook: criar branch da versão em produção, fix mínimo, testes/scan, artifact imutável, aprovação acelerada identificada, deployment observado e merge/cherry-pick para branches suportadas. Urgência não justifica apagar evidência.

**Checkpoint:** staging validado, swap e reverse swap com evidência; plano de canary/rings/flag/A-B e critérios de parada. Consulta preço do tier antes do exercício e elimina o environment adicional depois.

## L12 — Containers, scripts, binaries, database e resilience

1. Pede ao Copilot um multi-stage Dockerfile da Orders API; usa runtime compatível, non-root user e dependencies lockadas. Faz build local, inicia container e testa `/orders`. Scan da imagem antes de publicar; deploy por digest, não só `latest`.
2. Compara com ZIP deployment do starter (scripts + requirements). Para praticar binary artifact cria um package wheel Python; instala-o num virtual environment limpo e regista checksum. Não afirmes que o ZIP do starter é um executable compilado.
3. Cria uma base de dados descartável local e duas migrations: adicionar coluna nullable e preenchê-la. Aplica a mesma migration duas vezes com ferramenta que registe versões e valida que a segunda não duplica dados.
4. Desenha e implementa numa cópia de teste a sequência **expand schema → deploy compatível → backfill → validar → contract em release posterior**. Enquanto coexistem versões antiga/nova, ambas devem funcionar.
5. Na pipeline ordena infra → DB expand → app → smoke → promoção. Impede duas migrations concorrentes com lock/concurrency control. Migration falhada bloqueia app deployment; não faz rollback destrutivo automático de dados.
6. Introduz uma falha temporária de rede num script de teste. Aplica timeout, retries limitados com backoff e idempotency key quando houver efeito repetível. Não repitas uma operação de pagamento sem contrato de idempotência.
7. Em ambiente Kubernetes de treino, se disponível, configura RollingUpdate, readiness probe, maxUnavailable/maxSurge e acompanha rollout. Sem cluster, documenta manifesto e sequência como simulação; App Service slot swap não demonstra Kubernetes rolling.

**Checkpoint:** container e wheel validados, migrations repetíveis, deployment bloqueado quando uma dependência falha, estratégia de restore de dados testada com cópia fictícia. Define RTO/RPO e distingue rollback de código de recovery da DB.

## L13 — IaC e configuration management

**Conceitos:** IaC descreve infraestrutura versionada; configuration management mantém o estado do software/configuração. Idempotência significa que reaplicar o estado desejado não cria efeitos adicionais indevidos. Drift é divergência entre real e declarado.

1. No `infra/main.bicep` existente, identifica app, plan B1, runtime, TLS, managed identity e outputs. Pede ao Copilot explicação antes de pedir alterações.
2. Cria parameters por environment e extrai um módulo reutilizável de app. Valida `az bicep build --file infra/main.bicep` e usa `az deployment group what-if` no resource group de lab antes do apply.
3. Inspeciona especialmente alterações delete/replace e app settings. A lista declarada de app settings pode afetar configuração adicionada manualmente; incorpora o estado desejado no código ou escolhe um mecanismo explícito de gestão.
4. Faz deployment duas vezes e verifica recursos/outputs. Muda uma configuração fictícia manualmente, executa what-if, identifica drift e volta a aplicar o estado aprovado.
5. Para uma VM de treino, compara cloud-init/bootstrap com Azure Machine Configuration ou outra ferramenta de desired state. Define quem deteta drift e quem pode remediar. Um script que corre uma vez não garante compliance contínua.
6. Pede tradução de um comando Azure CLI para PowerShell, revê parâmetros e testa só uma consulta read-only primeiro. Confirma subscription, scope, quoting e error handling antes de qualquer mutação.

**Checkpoint:** módulo Bicep compilado, what-if revisto, reaplicação e drift documentados. AI gera uma proposta; o diff e o deployment validam-na.

## L14 — Pipeline health e retention

1. Recolhe pelo menos cinco runs com duração, queue time, status, retry count e testes intermitentes. Calcula failure rate com denominador explícito; separa falhas de produto, infraestrutura e flaky tests.
2. Adiciona cache de dependencies com chave baseada em OS/runtime/lockfile. Compara cold/warm runs mantendo os mesmos testes. Cache acelera download; artifact preserva output aprovado.
3. Paraleliza só tarefas independentes e cancela runs obsoletos de branches quando seguro. Limita concurrency por environment para evitar deployments sobrepostos.
4. Configura artifact retention de curta duração para PRs e uma política maior para releases/auditoria. Em Azure Pipelines usa project pipeline settings e retenção dos runs críticos; em GitHub configura retention por artifact/workflow conforme limites do plano. No feed configura cleanup sem remover versões ainda consumidas.
5. Simula rollback após expirar um artifact de treino: documenta que não é possível depender dele e garante que release artifacts aprovados ficam preservados. Não apagues o único artifact conhecido como saudável.
6. Configura alert/subscription para pipeline failure e verifica com run deliberadamente vermelho. Envia apenas para ti.

**Checkpoint:** comparação antes/depois de tempo e custo, owner para flaky tests e política com retenção, justificação e exceção para releases.

## L15 — Authentication, authorization e estrutura de acesso

**Conceitos:** Authentication prova identidade; authorization define ações permitidas. Managed identity é gerida pelo Azure; service principal representa uma aplicação. Federation troca um token confiável por acesso temporário e evita client secret persistente.

1. No Azure DevOps confirma teams, Area Paths, membership e access levels; Basic/Stakeholder controlam funcionalidades, enquanto permissions controlam ações. No GitHub configura teams numa organization se disponível; numa conta pessoal documenta essa limitação e usa collaborators com menor role necessário.
2. Cria Azure Resource Manager service connection com workload identity federation em Project Settings → Service connections. Limita scope à app/resource group do lab e autoriza apenas o pipeline necessário. Não marques acesso global a todos os pipelines.
3. No GitHub configura OIDC seguindo o [guia oficial](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure). No job usa `contents: read` e `id-token: write`; define audience e federated subject que correspondam aos claims realmente emitidos. Repositories novos/renomeados podem usar formatos de subject diferentes: verifica a documentação vigente em vez de copiar cegamente o subject antigo do README.
4. Testa login e uma operação Azure permitida, depois uma consulta fora do scope que deva falhar. Não concedas Owner para resolver um 403. Revê RBAC, scope, propagation e network separadamente.
5. Compara credenciais: GITHUB_TOKEN para o job/repository; GitHub App installation token para automação com scopes próprios; fine-grained PAT quando necessário e suportado, com expiry e scope mínimo. PAT pessoal herda dependência do utilizador e exige rotação/revogação.
6. Para estudar PAT ADO, cria um token temporário limitado a leitura num project de treino, testa uma consulta via cliente seguro e revoga-o. Não guardes token no histórico/ficheiros/logs. Compara-o com a service connection federada usada para Azure.

**Checkpoint:** duas identidades distintas para deployment e runtime, operação autorizada/negada, scopes documentados e zero Azure client secret no repository.

## L16 — Secrets, keys, certificates e leak prevention

1. Executa a integração Key Vault do README com dados fictícios. Confirma RBAC data-plane, runtime identity e estado de resolução da reference. Para pipelines, liga variable group ao vault ou usa AzureKeyVault task; no Actions autentica com OIDC e lê só o secret necessário.
2. Cria duas versões do secret e testa rotação usando reference sem versão quando esse comportamento for pretendido. Confirma atualização efetiva, cache e reinício/refresh suportado; não assumes consumo instantâneo.
3. Distingue secret (valor confidencial), key (operações criptográficas, idealmente sem exportar private material) e certificate (identidade/TLS com ciclo de emissão/renovação). Desenha renewal e ownership de cada um.
4. Em Pipelines → Library → Secure files carrega um ficheiro fictício de certificado de teste, autoriza só a pipeline de treino e usa DownloadSecureFile. Não uses uma private key real no exercício. No GitHub usa secrets e ficheiros temporários apenas quando necessário, com cleanup e permissions restritas.
5. Revê logs: sem `set -x`, sem dumps de env, sem secret em argumentos visíveis ou artifacts. Masking não garante proteção de valores transformados/fragmentados.
6. Testa leak prevention com um canary fictício, marcando-o como secret no job e validando redaction. Não esperes que secret scanning reconheça qualquer string arbitrária; essa é uma função diferente do log masking.

**Checkpoint:** secret consumido sem impressão, rotation comprovada, secure file restrito e checklist de incident response: revogar → rodar → investigar uso → limpar histórico/artifacts conforme necessidade.

## L17 — Scanning e Defender for Cloud

1. No GitHub ativa dependency alerts, code scanning/CodeQL e secret scanning/push protection conforme licença. Em Azure DevOps ativa as capacidades equivalentes de GitHub Advanced Security para Azure DevOps e configura scanning nas pipelines do repo de treino.
2. Compara SAST/code scanning, dependency/SCA, secret scanning e image scanning. Um resultado limpo num scanner não prova ausência de vulnerabilidades nos outros domínios.
3. Num branch de treino introduz uma dependency com advisory conhecido usando apenas uma aplicação fictícia, observa finding, atualiza para uma versão corrigida e demonstra rescan. Não publiques a versão vulnerável na app acessível externamente.
4. Define gate para severity, política de exceção com owner/expiry e monitorização de novas vulnerabilidades após a release. Dependabot alerts não são automaticamente um required release gate; implementa o check e demonstra bloqueio.
5. Em Defender for Cloud → Environment settings adiciona os connectors DevOps para GitHub e Azure DevOps com a autorização necessária. Seleciona apenas repositories do lab, espera discovery e revê inventory/recommendations. Consulta [Defender for DevOps](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-devops-introduction).
6. Cria uma Task para um finding com severity, asset, evidência, owner, deadline e verificação de correção. Não trates aceitar risco como corrigir vulnerabilidade.

**Checkpoint:** finding → PR → scan limpo → item encerrado. Regista separadamente integrações/licenças não disponíveis, sem as dar como executadas.

## L18 — Telemetry, KQL e platform monitoring

1. Executa o cenário HTTP logs/alert do README. Confirma Log Analytics workspace, Diagnostic settings e destination table mode. Pipeline logs não entram automaticamente no workspace: para analisar ADO/GitHub ali, recolhe eventos/API por um collector controlado e Log Ingestion API com Data Collection Rule, ou usa um connector suportado. Regista o schema e uma amostra sem secrets; se não implementares o collector, marca a integração como pendente.
2. Para praticar queries antes de haver dados, executa este dataset sintético no Log Analytics. Não é evidência de ingestion real.

```kusto
datatable(TimeGenerated:datetime, Endpoint:string, Code:int, DurationMs:real)
[
 datetime(2026-11-08T10:00:00Z), '/orders', 200, 120,
 datetime(2026-11-08T10:01:00Z), '/orders', 500, 900,
 datetime(2026-11-08T10:02:00Z), '/health', 200, 10
]
| summarize Requests=count(), Errors=countif(Code >= 500), P95=percentile(DurationMs,95) by Endpoint
| extend ErrorRatePct=100.0*Errors/Requests
```

3. No App Service metrics abre CPU/memory/network disponíveis para o plano e scope. Para disk/VM performance usa o recurso e coleta apropriados; não assumes que todas as métricas existem em todos os serviços. Relaciona saturação, throughput e latency, sem concluir causalidade só por correlação.
4. Cria Workbook/dashboard com requests, error rate, p95, deployments e incidents em UTC. Adiciona flow/cycle/lead/recovery aos dashboards de equipa usando fontes adequadas; não confundas work item data com application telemetry.
5. Configura Action Group próprio, thresholds, evaluation window e resolução. Produz erro no lab, valida fired/resolved e corrige uma alert demasiado ruidosa. Documenta sampling, ingestion delay, retention e custo.

**Checkpoint:** distingue logs, metrics e traces; demonstra uma alert de pipeline e outra de workload; preserva query, resource scope e intervalo em cada evidência.

## L19 — Application Insights e distributed tracing

1. Cria Application Insights ligado ao workspace. Segue a configuração Python atual da [Azure Monitor OpenTelemetry Distro](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview): adiciona a dependency e inicializa instrumentação antes de servir requests, com connection string em configuração protegida.
2. Instrumenta uma dependency real de teste (HTTP para um serviço de lab ou DB local). Adiciona spans e atributos não sensíveis, como versão da aplicação; não registres dados pessoais nem secret values.
3. Gera um request a `/orders`, usa transaction search/application map e segue o mesmo operation/trace ID entre request e dependency. Mede a duração de cada span para localizar o bottleneck.
4. Introduz atraso apenas na dependency de teste e compara traces antes/depois. Aumentar CPU da app não resolve necessariamente latência de um downstream.
5. Em workspace-based Application Insights experimenta:

```kusto
AppRequests
| where TimeGenerated > ago(30m)
| summarize Requests=count(), Failed=countif(Success == false), P95Ms=percentile(DurationMs,95) by Name
```

```kusto
AppDependencies
| where TimeGenerated > ago(30m)
| summarize Calls=count(), P95Ms=percentile(DurationMs,95) by Target, Type
```

Se consulta pela interface clássica do Application Insights, os nomes podem ser `requests`/`dependencies` e campos diferentes. Usa o schema browser; não copies uma query entre contextos sem adaptação.

**Checkpoint:** um trace real com request e dependency correlacionados, comparação de performance e explicação de sampling/dados ausentes.

## L20 — Observability Agent, SRE Agent e incident response

1. Em Azure Monitor abre Azure Copilot Observability Agent para chat/investigation com o recurso do lab e intervalo UTC definido. Na superfície atual, chat/investigation não requer criar um resource próprio; autonomous operations requer configuração adicional. Segue a [documentação atual](https://learn.microsoft.com/en-us/azure/azure-monitor/aiops/observability-agent-overview) para disponibilidade e criação do resource de autonomous operations, instructions e scope, quando disponível.
2. Pergunta: `Compare error rate and p95 before and after this deployment. Cite the resource, time window and supporting queries. Separate evidence from hypotheses.` Executa as queries propostas e verifica se os dados sustentam a conclusão. Regista a configuração e os resultados, não apenas um screenshot da resposta.
3. Para SRE Agent usa um resource group próprio para o agent e associa apenas os recursos de lab. Escolhe região suportada, valida connectivity e roles; começa read-only, adicionando apenas o necessário para remediation aprovada. Segue [setup requirements](https://learn.microsoft.com/en-us/training/modules/optimize-azure-reliability-with-sre-agent/5-setup-deployment).
4. Liga repository e telemetry sources. Repete `SIMULATE_FAILURE=true` no environment de treino. Pede triage e diagnosis com evidência e uma proposta de remediation; compara com logs e mudança de configuração conhecida.
5. Revê e aprova a ação específica de recuperar a configuração, caso suportada e autorizada; alternativamente executa manualmente o runbook. Confirma HTTP 200 e alert resolved. Não declares resolução só porque o agent disse que concluiu.
6. Guarda timeline: fault → detection → investigation → approval → remediation → validation. Calcula time to recovery e redige post-incident review sem culpabilização, com ação preventiva no Boards.
7. Para Copilot recolhe o log/session history disponível na superfície usada (VS Code Output/diagnostics para troubleshooting; Actions/agent session logs para execuções na plataforma). Guarda run/session ID, tool calls, resultado e versão do artifact. Logs locais de chat, audit log e agent run logs não são a mesma fonte. Define redaction, access e retention, evitando upload automático de prompts sensíveis.
8. Pede ao agent uma query KQL e compara resultado com natural language summary. Testa uma janela sem dados: a resposta deve reconhecer ausência de evidência, sem inventar causa.

**Checkpoint:** ambos os agents configurados/investigados ou explicitamente pendentes; incidente confirmado e resolvido por telemetry; agent logs com controlo de acesso.

## Avaliação prática final

Implementa uma feature de Orders API a partir de uma story sem usar main diretamente. Entrega PR protegido, testes e scan, package versionado, IaC what-if, artifact imutável, deployment aprovado e um incidente de lab resolvido com evidência. Faz uma migration num destino de treino e demonstra rollback do artifact sem rebuild. Explica as decisões em dez minutos usando apenas os artifacts produzidos.

Concluído significa evidência verificada, não apenas ficheiros criados. Revê cada linha do mapa inicial e mantém pendentes os serviços que não executaste. Uma simulação é útil para conceitos, mas não demonstra experiência com o serviço.

## Cleanup

Lista recursos e custos por resource group antes de apagar. Elimina apenas grupos exclusivos deste curso, com confirmação interativa (`az group delete --name '<LAB_ONLY_RG>'`), após guardar evidências sem secrets. Não apagues o project/repository existente. Remove VMs, plans adicionais, agent resources noutros groups, registrations de runners, service hooks, schedules, connectors de treino e credenciais temporárias. Revoga PATs, remove federated credentials sem uso e verifica retenção de Key Vault em soft-delete. Confirma no Cost Management que não ficaram recursos a cobrar.

## Questionário — original practice questions

Choose the single best answer unless the question states otherwise. Suggested time: 60 minutes. Training target: 80%; this is not a conversion to Microsoft's exam scoring.

**1.** A team wants to prove that a production change satisfies a business requirement. What is the strongest evidence?
A. A commit message saying “done”
B. Links from the work item to the reviewed PR, successful run, immutable artifact and deployment
C. The number of commits on main
D. A screenshot of the backlog

**2.** Deployment frequency increases while customer incidents also increase. What should you do?
A. Measure only frequency
B. Disable monitoring
C. Evaluate change failure rate and recovery time alongside frequency
D. Count more story points

**3.** A model claims it updated an Azure Boards Task, but there is no tool call. What should you conclude?
A. The update is verified
B. The claim requires verification through the service/tool result
C. MCP is unnecessary for all integrations
D. Azure RBAC guarantees the Task was updated

**4.** Which control actually restricts an agent's repository privileges?
A. Asking politely in a prompt
B. Giving it Owner
C. Scoped credentials and enforced repository policies
D. Increasing its context window

**5.** A team needs frequent integration and has no need for long release stabilization. Which is usually the best fit?
A. Short-lived branches integrated into a deployable trunk
B. A permanent branch per developer
C. Never merging until year-end
D. Deleting all tests

**6.** A bad commit has already been shared. Which action normally preserves a transparent history?
A. Force-push a rewritten main without coordination
B. Delete the repository
C. Use git revert and review the new commit
D. Remove the local clone

**7.** Why must a pre-commit hook be backed by CI?
A. Hooks always run on the server
B. Local hooks can be bypassed
C. CI cannot run tests
D. Hooks replace branch policies

**8.** A mirror migration succeeds. What still needs separate treatment?
A. Git commits only
B. All commit SHAs
C. PR discussions, service connections and branch policies
D. Nothing

**9.** Which version change best represents a backward-incompatible API change under SemVer?
A. 1.4.2 to 1.4.3
B. 1.4.2 to 1.5.0
C. 1.4.2 to 2.0.0
D. Reusing 1.4.2

**10.** How should a validated Azure Artifacts package reach approved consumers?
A. Overwrite the same version
B. Promote the tested version to an approved view
C. Disable feed permissions
D. Publish secrets in its metadata

**11.** A pipeline cache and a release artifact serve which purposes respectively?
A. Approved output; dependency acceleration
B. Dependency acceleration; preserved output for deployment
C. Authentication; authorization
D. Monitoring; encryption

**12.** Tests execute 98% of lines but miss an incorrect financial calculation. What does this demonstrate?
A. Coverage proves correctness
B. More runners guarantee correctness
C. Coverage is useful but does not establish assertion quality
D. Unit tests should be removed

**13.** Which test most directly measures latency under concurrent traffic?
A. License check
B. Load test
C. Git hook installation
D. Tag creation

**14.** A private deployment target is unreachable from a hosted runner. What must you evaluate first?
A. Network path and DNS, then identity/permissions as separate concerns
B. Grant Owner to everyone
C. Disable all tests
D. Rebuild the same artifact repeatedly

**15.** A production approval must remain outside ordinary YAML edits. Where should you configure it in Azure Pipelines?
A. A script that always returns zero
B. A commit message
C. Approvals and checks on the protected resource/environment
D. A local shell alias

**16.** Which design supports “build once, promote many”?
A. Rebuild independently for each environment
B. Deploy the same verified artifact with environment-specific configuration
C. Use an untracked local ZIP
D. Deploy whichever latest tag is present

**17.** In Azure Repos, what typically enforces PR build validation?
A. Only a GitHub workflow_dispatch trigger
B. A branch policy with build validation
C. A personal README note
D. A package version

**18.** A reusable YAML template primarily helps with what?
A. Shared, reviewable pipeline logic
B. Unlimited permissions
C. Automatic production approval
D. Disabling all drift

**19.** Why is a persistent self-hosted runner dangerous for untrusted PRs?
A. It cannot execute scripts
B. It always has no network
C. Untrusted code may access residual credentials or internal resources
D. It automatically fixes vulnerabilities

**20.** What distinguishes GitHub Agentic Workflows from a fixed-step workflow?
A. Agentic execution can choose actions within configured tools and limits
B. It never uses runners
C. It needs no permissions review
D. It cannot produce logs

**21.** Does a configured safe output necessarily imply a human approved its content?
A. Yes, always
B. No; it can perform a constrained automated write
C. Only for Markdown
D. Only when the output is small

**22.** A team wants early regression detection with limited traffic exposure. Which strategy best fits?
A. Immediate global replacement without monitoring
B. Canary with measurable promotion/abort gates
C. Deleting the previous artifact
D. Disabling health checks

**23.** You must disable a newly released behavior without deploying a new binary. What is most suitable?
A. Feature flag
B. Git tag deletion
C. Force push
D. Longer build retention

**24.** Why can rolling back application code fail to recover a release?
A. Code rollback always restores all data
B. Database or configuration changes may be incompatible with the previous code
C. Artifacts never contain code
D. Monitoring prevents rollback

**25.** What is the safest general ordering for a compatible schema evolution?
A. Drop old columns before any compatible app exists
B. Expand, deploy compatible code, backfill, then contract later
C. Run all migrations concurrently without tracking
D. Restore a random backup

**26.** What must be considered before retrying a failed operation that charges a customer?
A. Only runner size
B. Idempotency and whether the previous attempt already committed
C. README formatting
D. Number of tags

**27.** What does Bicep what-if provide?
A. A preview of expected infrastructure changes to review
B. A guarantee that every runtime test will pass
C. Automatic approval from security
D. A database backup

**28.** What is configuration drift?
A. A Git branch name
B. A mismatch between desired and actual configuration
C. A short test duration
D. A package checksum

**29.** What does id-token: write permit in GitHub Actions?
A. Writing to every Azure resource
B. Requesting an OIDC token; Azure access still depends on federation and RBAC
C. Bypassing environment protection
D. Deleting protected branches

**30.** Authentication succeeds but an Azure operation returns 403. What should you inspect?
A. Only the model temperature
B. The identity's RBAC assignment, scope and applicable resource restrictions
C. The license file only
D. The commit author's display name

**31.** Which identity is generally preferable for supported Azure workload-to-resource access?
A. A shared administrator password
B. A hard-coded PAT in source
C. A managed identity with least-privilege roles
D. An unexpired client secret printed in logs

**32.** What should you do first after a real credential is committed publicly?
A. Merely delete the file in a later commit
B. Revoke/rotate the credential and investigate exposure
C. Add a CODEOWNERS file only
D. Rename the branch

**33.** Why does log masking not guarantee secret safety?
A. Transformed values, artifacts or other channels may still expose data
B. Masking grants Owner
C. All scanners use the same mechanism
D. Masking prevents all network access

**34.** Which scanner primarily identifies vulnerable third-party libraries?
A. Dependency/SCA scanning
B. Branch name validation
C. Work item query
D. UI screenshot comparison

**35.** A pipeline passes CodeQL but a leaked token remains in a file. What is the correct interpretation?
A. Code scanning proves there are no secrets
B. Code scanning and secret scanning address different risks
C. Token rotation is unnecessary
D. Coverage will remove the token

**36.** A single incoming request calls several downstream services. What best supports end-to-end diagnosis?
A. Correlated distributed traces and spans
B. Commit counts alone
C. A feed view
D. An annotated tag alone

**37.** CPU is low but request p95 increased after a dependency change. What is a useful next step?
A. Assume CPU is the root cause
B. Examine dependency latency and correlated traces
C. Disable instrumentation
D. Increase retries indefinitely

**38.** An agent proposes a root cause without telemetry for the incident interval. What should you do?
A. Treat it as proven
B. Label it a hypothesis and collect supporting evidence
C. Automatically grant write access
D. Delete the incident record

**39.** Which is a sound SRE Agent adoption pattern?
A. Unlimited subscription-wide writes from day one
B. Scoped read access, verified telemetry, then controlled remediation with approval
C. No logs to reduce complexity
D. Skip post-remediation validation

**40.** Which statement about pipeline logs and Log Analytics is correct?
A. Every GitHub/ADO log automatically appears in any workspace
B. An explicit supported collection/integration path and schema are required
C. OIDC alone imports all logs
D. Work item links create telemetry tables

### Answer key and explanations

1 **B** — Linked evidence establishes the requirement-to-runtime chain; a statement alone is insufficient.
2 **C** — Delivery speed must be assessed with stability and recovery outcomes.
3 **B** — Generated text is not proof of a completed service operation.
4 **C** — Authorization and platform policy enforce capability; instructions alone do not.
5 **A** — Small, frequent integrations reduce long-lived divergence when the team can keep trunk deployable.
6 **C** — Revert adds a compensating commit without silently rewriting shared history.
7 **B** — Local execution can be skipped; required server checks provide central enforcement.
8 **C** — Git transfers versioned objects, not the surrounding service configuration and collaboration history.
9 **C** — A major increment signals incompatible changes under SemVer.
10 **B** — Views expose approved versions without rebuilding or overwriting them.
11 **B** — Cache accelerates repeat work; artifacts preserve outputs that can be promoted.
12 **C** — Executed lines do not prove meaningful assertions or correct requirements.
13 **B** — A load test evaluates behavior at specified concurrency and throughput.
14 **A** — Connectivity and authorization solve different problems.
15 **C** — Protected resource owners manage checks outside the ordinary YAML change path.
16 **B** — The same verified output reduces environment-specific rebuild differences.
17 **B** — Azure Repos PR validation is normally enforced through branch policies.
18 **A** — Reuse centralizes reviewed logic while preserving explicit inputs and access control.
19 **C** — Persistent state and network access increase the impact of untrusted code execution.
20 **A** — Agentic execution introduces bounded decision-making; it does not remove CI infrastructure.
21 **B** — A constrained write mechanism is not equivalent to human content approval.
22 **B** — Canary limits initial exposure and uses evidence to promote or stop.
23 **A** — Flags decouple behavioral activation from the code deployment lifecycle.
24 **B** — Data and configuration have independent compatibility and recovery requirements.
25 **B** — Expand/contract supports coexistence of old and new versions during rollout.
26 **B** — A timeout does not prove that the original side effect failed to commit.
27 **A** — What-if previews changes; runtime correctness still needs validation.
28 **B** — Drift is divergence from the declared desired state.
29 **B** — Token issuance is separate from Azure resource authorization.
30 **B** — Successful authentication does not imply permission to perform the requested operation.
31 **C** — Managed identities avoid maintaining a long-lived workload secret where supported.
32 **B** — History cleanup alone cannot invalidate a compromised credential.
33 **A** — Redaction is a defense layer, not a substitute for avoiding disclosure.
34 **A** — SCA evaluates dependencies and known vulnerability information.
35 **B** — Different scanners provide complementary coverage and require separate validation.
36 **A** — Trace correlation connects timing and failures across service boundaries.
37 **B** — Downstream latency can dominate response time even without CPU saturation.
38 **B** — Evidence must support causal claims; missing data must be acknowledged.
39 **B** — Start with verified visibility and introduce narrowly scoped write capability under control.
40 **B** — Platform telemetry requires a deliberate collection path, destination and schema.

### Additional scenario questions

**41. Choose TWO.** A hotfix must reach production quickly while retaining auditability. Which actions fit?
A. Create the hotfix from the deployed version and produce a tested immutable artifact.
B. Delete the required checks permanently.
C. Use an identified expedited approval path and propagate the fix to supported branches.
D. Rebuild arbitrary local code directly on production.

**42. Ordering.** Put these steps in order for a protected release: (A) promote the artifact; (B) build and test; (C) review/approve the release evidence; (D) validate production health. Assume source review is already complete.

**43. Case study.** A GitHub job uses an Environment; its federation trust was copied from a branch-only example. Login fails before deployment. Give three checks before changing Azure roles.

**44. Case study.** A team reports MTTR from one incident and wants to compare it to another team's monthly average. What must be clarified?

**45. Case study.** A clean security scan is required before release, but scans merely publish informational reports. Explain the missing control and a validation experiment.

**46. Case study.** A feature flag rollout succeeds for internal users but fails globally. Give three reasons the internal ring may not have represented the wider audience.

**47. Case study.** A runner accesses a private database using a long-lived PAT intended for Azure DevOps API calls. Identify two independent design problems.

**48. Case study.** After a slot swap, a Key Vault reference fails. What should you verify before rolling back the application code?

**49. Case study.** An autonomous agent keeps retrying an unsuccessful infrastructure deployment. Define four loop controls you would add.

**50. Case study.** You must retain incident and Copilot agent logs without exposing sensitive prompts. Propose a minimal governance design.

**41: A, C.** Preserve verification and traceability while shortening a documented approval path.
**42: B → C → A → D.** Verify the output, approve evidence, promote the same output, then confirm actual health.
**43:** Check the actual token subject format, exact issuer/audience, and whether the Environment/branch/repository context matches the federated credential. Authentication failures should not be “fixed” by excessive RBAC.
**44:** Define detection/start/end boundaries, timezone, incident population and observation window. One recovery duration is not a representative mean; definitions must match before comparison.
**45:** Configure an enforced required check/release gate with explicit severity/exception policy. Introduce a safe known finding in a training branch and prove that promotion is blocked until remediation or authorized exception.
**46:** Differences may include traffic volume, geography/network, account/data characteristics, dependency versions and feature interactions. Choose representative cohorts and monitor before expansion.
**47:** A PAT for one service is not a general database/Azure credential; use the database's supported identity. Separately, private connectivity/DNS must exist, and long-lived credentials need replacement or lifecycle controls.
**48:** Slot-specific settings, slot identity, vault data-plane roles, secret URI/version, network access and reference resolution/cache. Code rollback does not automatically restore these states.
**49:** Retry budget, timeout/cost budget, idempotency and state checks, explicit stop/escalation conditions, artifact validation and approval before risky mutations. Any four appropriate controls earn credit.
**50:** Collect only necessary session/run IDs, tool actions, timestamps and results; redact sensitive content, restrict access, define retention/deletion and preserve an audit trail. Keep local diagnostic logs, platform audit logs and agent run logs distinguishable.

## Fontes e manutenção

As duas fontes de âmbito são o [AZ-401 study guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-401) e o [learning path de agentic DevOps](https://learn.microsoft.com/en-us/training/paths/optimize-devops-ai-agents-azure/). Os exercícios, critérios de aceitação, datasets e perguntas deste guia são criações didáticas próprias. Os links técnicos nos laboratórios orientam a configuração vigente de cada serviço. Antes da prova, compara novamente os objetivos oficiais e atualiza o mapa; completar estes exercícios não garante aprovação.

