> **Portal interativo:** [DevOps Atlas — AZ-401](https://az401-study-lucas.saltybeach4.chatgpt.site) · [Código e instruções](portal/README.md). Acesso privado do proprietário; progresso guardado neste navegador, com export/import.

> **Percurso completo AZ-401:** começa pelo [guia com 20 laboratórios e 50 perguntas em inglês](docs/GUIA-COMPLETO-AZ401.md). O README abaixo mantém o starter prático da Orders API; o guia acrescenta os aprofundamentos e o mapa de cobertura. Usa os ambientes existentes, sem recriar o repository/project. Revê a configuração OIDC no L15 antes de copiar o exemplo antigo deste README.

# Lab guiado AZ-401 — Agentic DevOps de ponta a ponta

**Idioma:** português, com termos técnicos em English.  
**Duração estimada:** 8–12 horas, divididas em sessões. **Nível:** intermédio.  
**Referência verificada:** 4 de novembro de 2026.

O AZ-401 chama-se **Designing and Implementing Microsoft Agentic DevOps Solutions** e encontra-se em **beta** na data desta preparação. Este é um lab original de preparação, não um lab oficial nem uma reprodução do exame. [Exam AZ-401](https://learn.microsoft.com/en-us/credentials/certifications/exams/az-401/).

## 1. Cenário e resultado esperado

És responsável pela entrega da **Orders API**. A equipa precisa de rastrear requisitos, proteger alterações, automatizar testes e deployment e investigar um incidente com assistência de AI.

Percurso: **Azure Boards → GitHub repository → pull request → CI → approval → Azure App Service → Azure Monitor → incident → feedback**.

O lab trabalha as cinco áreas do exame através de exercícios próprios: processos, source control, pipelines, security e instrumentation. A componente agentic inclui GitHub Copilot, MCP, GitHub Agentic Workflows e Azure SRE Agent. Consulta o [study guide oficial](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-401) para o programa completo; este percurso não cobre todos os objetivos.

**Definition of Done:** uma alteração tem work item, PR, testes, artifact identificado por commit, deployment com OIDC e evidência de recuperação de um incidente.

## 2. Pré-requisitos e custos — 20 minutos

Prepara:

- Azure subscription para o lab; permissões para criar recursos e role assignments. Contributor isoladamente não permite criar role assignments; usa também Role Based Access Control Administrator no scope necessário ou apoio de um administrator.
- GitHub account com acesso a Actions e criação de repository. Para branch protection e environment approvals, usa um repository público apenas com os exemplos deste lab ou um plano que disponibilize estas funcionalidades em repositories privados. Confirma as opções no teu plano.
- Azure DevOps organization e project com **Basic access**, Azure Boards e Azure Pipelines. Microsoft-hosted parallel jobs podem precisar de ativação; em alternativa, usa um self-hosted agent dedicado ao lab.
- VS Code, GitHub Copilot com Agent mode autorizado, Git, GitHub CLI, Azure CLI, Node.js 20+ e Python 3.12. Os comandos abaixo usam Bash, disponível em Linux, macOS ou WSL.

**Custos:** App Service Plan B1, Log Analytics, Key Vault, AI requests e Azure SRE Agent podem gerar cobranças. Cria um budget e um alerta em Cost Management antes dos exercícios Azure; budget alerts não interrompem automaticamente o consumo. Não precisas de Azure SRE Agent para completar o core lab, mas deves executar a extensão quando tiveres acesso para praticar essa competência.

Abre um terminal na pasta extraída `az401-lab`. Em sistemas onde o comando é `python3`, usa-o para criar o virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
python -m pytest --cov=app --cov-branch --cov-fail-under=90
flask --app app run
```

Noutro terminal, testa `curl http://127.0.0.1:5000/health` e `curl http://127.0.0.1:5000/orders`. Depois termina o servidor com Ctrl+C.

**Checkpoint:** três testes passam; `/health` devolve HTTP 200 e `status: healthy`; `/orders` devolve um order com `total: 42`.

## 3. Plan, traceability e instruções para agents — 45 minutos

1. Cria um Azure DevOps project chamado `az401-lab`, com processo **Agile**.
2. Em Boards → Work Items, cria uma **User Story**: `Entregar Orders API com deployment rastreável`.
3. Adiciona acceptance criteria: `/health` e `/orders` devolvem 200; coverage ≥90%; PR obrigatório; deployment usa OIDC; incidente tem evidência de deteção e recuperação.
4. Cria Tasks para CI, deployment e monitoring. Guarda o URL da User Story.
5. Cria o repository `az401-lab` no GitHub. Não inicializes com outro README. Antes do primeiro push, cria o GitHub **Environment** `lab`: configura required reviewers, se disponível, e limita deployment branches a `main`. Se estiveres sozinho e o plano permitir, podes aceitar self-review para este exercício; regista que isso não demonstra separation of duties.
6. Versiona os ficheiros fornecidos. O primeiro workflow executará CI, mas o deployment só poderá funcionar depois de configurares Azure e as variables na etapa 6. Se chegar ao approval antes disso, cancela o run.

```bash
git init -b main
git add .
git commit -m "chore: bootstrap AZ-401 lab"
gh auth login
gh repo create az401-lab --source=. --remote=origin --private --push
```

Se precisares de repository público para as funcionalidades do teu plano, substitui `--private` por `--public`; inclui apenas o conteúdo fictício do lab.

Em `README.md`, adiciona uma secção `Traceability` com o URL do work item. Nos futuros PRs inclui o mesmo URL; escrever apenas `AB#123` não estabelece integração sem configurar a ligação entre os serviços.

Lê `.github/copilot-instructions.md`. Em Copilot Chat, pede:

> Analisa este repository e as acceptance criteria. Propõe um plano de implementação em português. Mantém os termos técnicos em English. Segue as repository instructions e apresenta a evidência necessária para cada checkpoint. Não faças alterações ainda.

**Checkpoint:** consegues seguir o caminho User Story → Task → repository. Guarda a proposta do agent em `evidence/agent-plan.md`, removendo informação sensível.

## 4. Source control e quality gates — 45 minutos

1. Deixa o primeiro CI terminar para registar o status check `build`.
2. Em Settings → Rules → Rulesets, ou Branches → Branch protection, protege `main`: require pull request, required status check `build`, block force pushes e block deletions. Exige um reviewer quando tiveres outro participante. Evita bypass para o exercício.
3. Cria uma feature branch:

```bash
git switch -c feature/order-count
```

4. Pede ao Copilot para adicionar `count` à resposta `/orders` e um teste que confirme o valor `1`, seguindo as instructions fornecidas.
5. Executa os testes, revê o diff e abre um PR. Inclui o URL da Task ou User Story na descrição.
6. Faz uma alteração temporária num teste para exigir um `total` incorreto. Confirma que o CI fica vermelho e o merge bloqueado. Corrige o teste e confirma o CI verde.
7. Faz merge depois da review necessária.

**Checkpoint:** conserva os links dos runs vermelho e verde. Explica por que razão um agent também tem de respeitar branch protection.

**Exercício Git Worktree:** cria um espaço de hotfix com `git worktree add ../az401-hotfix -b hotfix/health-copy main`. Inspeciona-o e remove-o com `git worktree remove ../az401-hotfix`. Não precisas de fazer uma alteração real para observar a separação dos working directories.

## 5. Infrastructure as Code — 45 minutos

O ficheiro `infra/main.bicep` cria um Linux App Service Plan B1 e uma Python Web App com system-assigned managed identity. O B1 deste lab não fornece deployment slots; o deployment é feito diretamente na app e pode causar uma interrupção breve.

Autentica-te, confirma a subscription e escolhe um nome de app globalmente único:

```bash
az login
az account set --subscription '<SUBSCRIPTION_ID>'
export LAB_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export LAB_RG='rg-az401-lab'
export LAB_LOCATION='westeurope'
export LAB_APP='az401-orders-SUBSTITUIR-POR-SUFIXO-UNICO'
export LAB_REPO='TEU-UTILIZADOR/az401-lab'
az group create --name "$LAB_RG" --location "$LAB_LOCATION"
az bicep build --file infra/main.bicep
az deployment group what-if --resource-group "$LAB_RG" \
  --template-file infra/main.bicep --parameters appName="$LAB_APP"
az deployment group create --resource-group "$LAB_RG" \
  --template-file infra/main.bicep --parameters appName="$LAB_APP"
```

Usa apenas letras minúsculas, números e hífen no nome escolhido. Se a região não tiver quota B1 ou runtime disponível, seleciona outra região suportada. Guarda as variables: os próximos comandos assumem o mesmo terminal.

**Checkpoint:** o deployment termina com `Succeeded`; o `what-if` corresponde aos recursos esperados. A API ainda não está publicada.

## 6. CI/CD e secretless authentication — 60 minutos

A managed identity seguinte representa o **workflow**. É diferente da system-assigned managed identity da **Web App**, usada mais tarde para Key Vault. OIDC permite autenticação do workflow sem guardar um Azure client secret. [Orientação Microsoft](https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions).

```bash
az identity create --name id-az401-deploy --resource-group "$LAB_RG"
export LAB_CLIENT_ID=$(az identity show -g "$LAB_RG" -n id-az401-deploy --query clientId -o tsv)
export LAB_PRINCIPAL_ID=$(az identity show -g "$LAB_RG" -n id-az401-deploy --query principalId -o tsv)
export LAB_TENANT_ID=$(az account show --query tenantId -o tsv)
export LAB_APP_ID=$(az webapp show -g "$LAB_RG" -n "$LAB_APP" --query id -o tsv)
az role assignment create --assignee-object-id "$LAB_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal --role 'Website Contributor' --scope "$LAB_APP_ID"
az identity federated-credential create --name github-lab \
  --identity-name id-az401-deploy --resource-group "$LAB_RG" \
  --issuer 'https://token.actions.githubusercontent.com' \
  --subject "repo:${LAB_REPO}:environment:lab" \
  --audiences 'api://AzureADTokenExchange'
```

No GitHub Environment `lab`, adiciona **Environment variables** — não precisas de as guardar como secrets:

| Variable | Valor |
|---|---|
| `AZURE_CLIENT_ID` | `$LAB_CLIENT_ID` |
| `AZURE_TENANT_ID` | `$LAB_TENANT_ID` |
| `AZURE_SUBSCRIPTION_ID` | `$LAB_SUBSCRIPTION_ID` |
| `AZURE_WEBAPP_NAME` | `$LAB_APP` |

Em Actions → lab-ci-cd → Run workflow, escolhe `main`. Revê o commit e aprova o environment quando solicitado. O workflow executa testes, publica coverage e JUnit, cria um ZIP, identifica o artifact pelo commit SHA e publica exatamente esse ZIP. `SCM_DO_BUILD_DURING_DEPLOYMENT` permite instalar as runtime dependencies no App Service.

```bash
curl --fail "https://${LAB_APP}.azurewebsites.net/health"
curl --fail "https://${LAB_APP}.azurewebsites.net/orders"
```

**Checkpoint:** deployment e smoke tests verdes, nenhum Azure client secret no repository e artifact `app-<commit SHA>` disponível por sete dias.

**Decisão para explicar:** OIDC autentica; Azure RBAC autoriza. `id-token: write` permite obter o token, mas não concede por si só acesso à Web App.

## 7. Azure Pipelines e comparação — 45 minutos

1. No Azure DevOps, abre Pipelines → New pipeline → GitHub, autoriza o repository e seleciona **Existing Azure Pipelines YAML file**, `azure-pipelines.yml`.
2. Executa o pipeline e consulta Tests e Code Coverage. O quality gate é o mesmo: coverage ≥90%.
3. Se não houver hosted parallelism, solicita a ativação ou configura um agent dedicado. Não executes PRs não confiáveis num agent com credenciais de outros ambientes.
4. Compara o artifact `source-<BuildId>` deste pipeline com o ZIP de deployment do GitHub. O primeiro é um snapshot para o exercício e pode conter ficheiros do workspace de build; não é usado para publicar a app.
5. Cria um Azure DevOps Environment `lab-ado` em Pipelines → Environments e adiciona Approvals and checks. Não há CD Azure Pipelines pré-configurado neste starter.

**Extensão:** cria uma Azure Resource Manager service connection com workload identity federation e scope limitado à app. Acrescenta um deployment job que referencia `lab-ado` e publica apenas `app.py` e `requirements.txt` com AzureWebApp@1. Valida a espera pelo approval antes do deployment. Desativa temporariamente o CD GitHub enquanto fazes esta extensão para evitar dois pipelines a publicar na mesma app.

**Checkpoint:** consegues localizar os resultados, explicar hosted versus self-hosted agents e justificar quando escolherias GitHub Actions ou Azure Pipelines.

## 8. MCP com Azure DevOps e GitHub — 45 minutos

Cria `.vscode/mcp.json`, substituindo `TUA-ORGANIZATION` pelo nome da organization, sem o URL:

```json
{
  "servers": {
    "ado": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@azure-devops/mcp", "TUA-ORGANIZATION"]
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    }
  }
}
```

Inicia os servers no VS Code e completa o sign-in de cada serviço. Se uma organization bloquear o GitHub remote MCP server, segue a configuração autorizada pelo administrator. [Azure DevOps MCP setup](https://github.com/microsoft/azure-devops-mcp/blob/main/docs/GETTINGSTARTED.md) · [GitHub MCP server](https://github.com/github/github-mcp-server).

Em Copilot Agent mode, começa com ferramentas de leitura:

> Lista as User Stories do project az401-lab e os open PRs do repository indicado. Identifica PRs sem link para work item. Mostra IDs, URLs e as ferramentas usadas. Não alteres dados.

Depois, pede uma alteração explícita:

> Adiciona à Task de CI um comentário com o URL deste run e o respetivo resultado. Antes de executar, apresenta o ID da Task e o comentário exato para eu rever.

Autoriza a tool call depois de validar o conteúdo. Confirma a alteração no Boards e guarda uma versão sem dados sensíveis em `evidence/mcp.md`.

**Checkpoint:** uma tool call real de leitura em cada serviço e uma atualização rastreável no Boards. Um texto sugerido pelo modelo sem tool call não conta como integração MCP.

## 9. Security, Key Vault e scanning — 60 minutos

1. No Azure Portal, cria um Key Vault no resource group do lab, com Azure RBAC como permission model.
2. Cria um secret fictício `orders-api-key`, com um valor que não uses noutro lugar. Não o coloques no Git.
3. Em Key Vault → Access control, atribui **Key Vault Secrets User** à system-assigned managed identity da Web App, com scope no vault. Para criar secrets com a tua conta, precisas também de um data-plane role apropriado, como **Key Vault Secrets Officer**; Contributor não basta.
4. Em App Service → Settings → Environment variables, adiciona `ORDERS_API_KEY` com uma Key Vault reference no formato `@Microsoft.KeyVault(SecretUri=https://<vault>.vault.azure.net/secrets/orders-api-key/)`.
5. Confirma que o estado da reference indica resolução bem-sucedida. Não mostres o valor nos logs. O starter não usa este secret nas respostas HTTP; o objetivo é validar a integração de configuração.
6. No GitHub → Settings → Code security, ativa Dependabot alerts, code scanning/CodeQL e secret scanning/push protection quando disponíveis no teu plano e repository. Usa o setup de Python para CodeQL e inspeciona um run concluído. Não uses uma credencial real para testar secret scanning.
7. Pede ao Copilot uma review de permissions e tratamento de secrets. Guarda a conclusão e confirma manualmente os findings.

**Checkpoint:** Key Vault reference resolvida, evidência do scanning disponível e uma explicação da diferença entre dependency scanning, code scanning e secret scanning. Regista funcionalidades indisponíveis por licença como não executadas.

## 10. Monitoring, incidente e recuperação — 60 minutos

1. Cria um Log Analytics workspace no resource group do lab.
2. Em App Service → App Service logs, ativa Web server logging quando disponível. Em Diagnostic settings, envia **AppServiceHTTPLogs** para o workspace e escolhe **Resource specific** como destination table mode.
3. Gera tráfego em `/orders` e espera pela ingestion. No workspace → Logs, executa:

```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(30m)
| summarize Requests=count(), Errors=countif(ScStatus >= 500) by bin(TimeGenerated, 1m)
| extend ErrorRatePct = 100.0 * Errors / Requests
| order by TimeGenerated desc
```

Esta query usa o schema de [AppServiceHTTPLogs](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/appservicehttplogs). Se aparecer `AzureDiagnostics`, verifica o destination table mode em vez de executar esta query sem adaptação.

4. Em Azure Monitor → Alerts, cria uma metric alert para a Web App: signal **Http Server Errors**, aggregation **Total**, threshold superior a zero, evaluation window de cinco minutos, frequency de um minuto e um Action Group com o teu email.
5. Regista a hora UTC inicial e provoca a falha apenas nesta app de lab:

```bash
az webapp config appsettings set -g "$LAB_RG" -n "$LAB_APP" --settings SIMULATE_FAILURE=true
for i in {1..20}; do curl -s -o /dev/null -w '%{http_code}\n' "https://${LAB_APP}.azurewebsites.net/orders"; done
```

6. Confirma HTTP 500, a alert e a query. A alteração de app settings pode reiniciar a app; espera pelo arranque antes de recolher a amostra.
7. Pede ao Copilot para analisar os resultados KQL que recolheste:

> Separa factos de hipóteses. Identifica o endpoint afetado e propõe uma query de validação. Não executes remediation. Não atribuas uma causa que os dados não demonstram.

8. Recupera e valida:

```bash
az webapp config appsettings set -g "$LAB_RG" -n "$LAB_APP" --settings SIMULATE_FAILURE=false
curl --fail --retry 12 --retry-delay 10 --retry-all-errors "https://${LAB_APP}.azurewebsites.net/orders"
```

9. Regista o instante do primeiro HTTP 200 e escreve `evidence/incident.md`: timeline, impacto, causa conhecida, hipótese do agent, remediation e prevenção. Calcula **time to recovery** entre o início observado da falha e a recuperação. Uma única amostra não permite calcular uma média representativa de MTTR.

**Checkpoint:** evidência HTTP 500 → alert/logs → alteração de configuração → HTTP 200. `/health` mantém-se saudável durante esta falha: explica por que um health endpoint simples não substitui a observação de business endpoints.

**Exercício de rollback do artifact:** descarrega um `app-<SHA>` anterior e conhecido como saudável em Actions → run → Artifacts. Extrai o download para obter `app.zip`. Com a tua sessão Azure CLI, executa `az webapp deploy -g "$LAB_RG" -n "$LAB_APP" --src-path app.zip --type zip`. Confirma a versão em `/health` e os smoke tests. Não faças rebuild do artifact anterior. Guarda a associação run → SHA → artifact. Este rollback de código não desfaz app settings, alterações de infraestrutura nem database migrations.

## 11. Agentic Workflows e AI operations — 60–90 minutos

### 11.1 GitHub Agentic Workflows

GitHub Actions YAML com steps fixos e GitHub Agentic Workflows têm comportamentos diferentes. Neste exercício adicionas uma automação definida em Markdown e compilada para um workflow executável.

Numa feature branch, segue o wizard oficial:

```bash
gh extension install github/gh-aw
gh aw add-wizard githubnext/agentics/repo-status
```

Escolhe GitHub Copilot como engine e configura a autenticação indicada pelo wizard para o teu plano. Revê os ficheiros e permissions antes do primeiro run. Personaliza as instruções do report para resumir PRs, falhas de CI e work items em falta, sem autorizar merge ou deployment. Não pressuponhas que o workflow tem acesso ao Boards: se não configuraste essa integração nele, deve usar apenas os links presentes nos dados GitHub.

```bash
gh aw compile
```

Faz commit do Markdown e do `.lock.yml` gerado, abre PR, faz merge e executa o workflow manualmente em Actions. Se o template acrescentar um schedule, remove-o quando terminares o exercício para evitar runs recorrentes. [Quickstart oficial](https://github.github.com/gh-aw/setup/quick-start/).

**Checkpoint:** um report produzido por um run real, os logs do agent e uma comparação entre as permissions pedidas e as realmente necessárias.

### 11.2 Azure SRE Agent — extensão com recursos adicionais

Usa a [configuração oficial do Azure SRE Agent](https://learn.microsoft.com/en-us/azure/sre-agent/create-and-set-up). Cria o agent, conecta o repository e uma telemetry source e limita o Azure scope ao resource group do lab. A criação e role assignments exigem permissões adicionais descritas nessa documentação.

Repete o incidente da etapa 10 e pede:

> Investiga o aumento de HTTP 500 na Orders API no intervalo indicado. Apresenta evidência, possíveis causas e uma proposta de remediation. Mantém a execução de alterações dependente de aprovação humana.

Confirma quais as fontes consultadas pelo agent e se os factos sustentam a hipótese. Aprova apenas a recuperação do lab depois da review. Guarda uma timeline do incident e os agent logs disponíveis.

Se não houver acesso, executa a análise manual com KQL e marca Azure SRE Agent como **não executado**. A simulação não equivale ao hands-on do serviço.

### 11.3 Desafio adicional de observability

O starter usa HTTP logs e não implementa distributed tracing. Para praticar essa área, adiciona Azure Monitor OpenTelemetry/Application Insights, gera requests e explora transaction traces. Depois, quando disponível na tua subscription, configura Azure Copilot Observability Agent seguindo a documentação atual do serviço e compara uma investigação por natural language com uma query KQL. Marca estas competências como pendentes até as executares.

## 12. Avaliação final, troubleshooting e cleanup

Sem consultar as respostas, explica:

1. Porque falha o OIDC quando o federated subject usa `ref:refs/heads/main` mas o job usa o Environment `lab`?
2. Porque pode um build passar e o deployment ser recusado pelo Azure?
3. O que acontece ao merge se o quality gate reprovar?
4. Como provas que o ZIP publicado pertence ao commit revisto?
5. Qual a diferença entre reverter código e reverter configuração?
6. Quando preferes uma managed identity a um client secret?
7. Qual a diferença entre uma sugestão do Copilot, uma MCP tool call e um Agentic Workflow?
8. Porque não deves conceder remediation ilimitada a um agent?

**Respostas esperadas:** 1) o subject emitido é específico do environment e tem de coincidir exatamente; 2) autenticação, RBAC, environment checks e deployment são etapas distintas; 3) o required check impede o merge; 4) associação do run, commit SHA e artifact usado no deployment; 5) têm estados e processos de recuperação distintos; 6) quando a plataforma suporta identity, evitando gerir uma credencial persistente; 7) proposta, interação com uma ferramenta e automação agentic executada no CI; 8) a evidência pode ser incompleta e o acesso deve ter scope e controlos proporcionais.

| Sintoma | Verificação |
|---|---|
| `AADSTS70021` ou erro de federation | Confirma issuer, audience, owner/repository e `environment:lab`; respeita maiúsculas/minúsculas |
| Deployment com 403 | Confirma role no scope da app e espera a propagação de RBAC |
| API não inicia | Consulta deployment logs e Log stream; confirma Python 3.12, requirements e startup command |
| Run sem aprovação | Confirma required reviewers, plano GitHub e environment referenciado pelo job |
| KQL sem dados | Confirma diagnostic setting, resource-specific mode, tráfego, intervalo e ingestion |
| MCP não arranca | Confirma Node.js 20+, organization, sign-in e policies da empresa |
| Azure Pipelines não inicia | Confirma parallel jobs ou o estado do self-hosted agent |

**Evidências mínimas:** work item e PR associados, CI vermelho e verde, coverage, artifact SHA, OIDC/RBAC, deployment aprovado, MCP tool calls, Key Vault reference, scanning, HTTP logs, alert e incident report. Guarda apenas dados do lab, sem tokens ou secret values.

**Assuntos para um segundo lab:** package feeds e upstream sources, SemVer/CalVer, Azure Repos → GitHub migration, Git hooks, reusable pipeline templates, blue-green/canary com deployment slots num tier adequado, load tests, database deployments e Defender for Cloud integrations. Este primeiro lab não substitui essas práticas.

Quando terminares, confirma que o resource group contém apenas recursos criados para este lab:

```bash
az resource list --resource-group "$LAB_RG" --output table
az group delete --name "$LAB_RG"
```

O último comando pede confirmação e elimina os recursos desse group. Verifica separadamente os agents criados fora dele. Desativa schedules e Agentic Workflows, remove service connections e federated credentials que tenham ficado fora do group e elimina self-hosted agents dedicados. Key Vault pode permanecer em soft-delete conforme as políticas configuradas; não faças purge de recursos partilhados.

**Validação deste material:** os ficheiros são um starter para executar nas tuas contas. A validação local é registada em `VALIDACAO.md`; deployment Azure, GitHub, MCP e serviços AI precisam de ser confirmados durante o teu hands-on.
