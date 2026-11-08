# Antes dos labs: pré-requisitos e preparação

Comece por executar os checks locais. Só avance para cloud depois de confirmar conta, scope e custos. O portal é um guia de estudo; não está ligado à sua subscription e não executa estes scripts no navegador.

## 1. O que precisa de saber

- Terminal, ficheiros, variáveis de ambiente e permissões básicas.
- Git básico: clone, branch, commit e pull request. O L04 aprofunda as estratégias.
- HTTP/JSON e Python básico para compreender a Orders API.
- Conceitos de resource group, Azure subscription, identity e RBAC.
- Fundamentos de generative AI e GitHub Copilot para os labs agentic.

Se ainda não conhece um conceito, faça o starter com os passos fornecidos e registe a dúvida. Não precisa de configurar todos os serviços no primeiro dia.

## 2. Máquina e ferramentas

| Requisito | Para que serve | Quando é necessário |
|---|---|---|
| Windows 11 com PowerShell 5.1+ ou Linux com Bash | Executar os scripts de preparação | Todos os labs locais |
| Ubuntu 24.04, nativo ou WSL2 | Base suportada pelo instalador Linux opcional | Só para `--install-tools` no Linux |
| Git | Clone, branches, PRs e migration | Preparação e L04–L05 |
| Python 3.12 com pip/venv | Orders API e testes; versão do starter | Preparação, CI e app |
| GitHub CLI (`gh`) | Login GitHub e operações de repository | Recomendado para clone privado; L10 exige CLI/extensão |
| Azure CLI (`az`) + Bicep | Consultas, IaC e deployment | A partir das práticas Azure |
| Node.js 20+ suportado pelo MCP instalado | Azure DevOps MCP Server e ferramentas do portal | L03 e regeneração do portal; prefira LTS suportada |
| VS Code + GitHub Copilot | Plan mode, MCP, instructions e agent workflows | Labs agentic |
| Docker Engine/Desktop | Build e execução de containers | L06/L12; não é necessário para iniciar |
| Browser e acesso HTTPS aos serviços | Portais Azure/ADO/GitHub e packages | Todos os serviços remotos |

Recomendação prática: 8 GB RAM para app/testes; 16 GB se usar Docker/WSL/VMs. Reserve espaço para venv, clones e imagens. Estes valores são orientações de conforto, não requisitos oficiais do exame. Acesso a PyPI é necessário para instalar as dependencies.

No Windows nativo use Flask para desenvolvimento. Gunicorn é usado no runtime Linux do App Service; não use `gunicorn` como servidor local Windows. Não partilhe o mesmo `.venv` entre Windows e WSL; use clones separados.

## 3. Contas, permissões e custos

| Serviço | Acesso a confirmar | Validação prática |
|---|---|---|
| GitHub privado `lfernandesc/az401-lab` | Leitura para clone; write para branches/PRs; admin para rules e environments | Abra o repo autenticado; teste `gh auth status` |
| Azure DevOps `lucasfernandesc/az401-lab` | Basic access para o percurso e permissions adequadas para Boards, Repos e Pipelines | Abra Boards e confirme que consegue criar uma Task |
| Azure subscription | Criar recursos no resource group do lab; atribuição de roles exige permissão adicional | `az account show` e Access control no scope |
| GitHub Actions / Azure Pipelines | Minutes/parallel jobs e permissão para executar workflows | Um CI run com sucesso |
| GitHub Copilot | Plano ativo, quota e autorização da organization para models/MCP | Um pedido no Chat e descoberta de tools |
| Security e agents | Licença/plano, região, disponibilidade e permissions específicas | Confirme no portal do serviço antes do lab |

Contributor sozinho não atribui roles RBAC. Peça apoio de um administrador ou use um role de gestão de acesso no menor scope necessário. Não dê Owner ao agent nem a todos os pipelines. A access level de Azure DevOps não substitui permissions.

Crie budget/alert em Cost Management antes de provisionar. Budget não interrompe consumo. App Service B1, Standard/slots, VM/runners, Log Analytics ingestion, agents e AI podem cobrar. O starter B1 não oferece deployment slots: o L11 exige environment adicional num tier compatível. Não altere um plan partilhado com outros sistemas. No fim elimine apenas recursos exclusivos do lab.

## 4. Escolha o seu caminho

**Windows nativo:** use `setup-windows.ps1` para app e testes com PowerShell. Os comandos dos labs estão em Bash: use WSL2 para os executar sem tradução, ou traduza conscientemente variáveis, quoting e loops para PowerShell.

**Windows + WSL2:** instale WSL pela documentação Microsoft e reinicie quando pedido. Dentro do Ubuntu use o script Linux e instale as ferramentas Linux; ter `az` ou Python apenas no Windows não equivale à configuração do ambiente WSL. Guarde o clone no filesystem Linux, por exemplo `~/az401-lab`.

**Linux:** Bash + Git + Python 3.12. O instalador opcional de pacotes base suporta Ubuntu 24.04; noutras distribuições instale ferramentas pelos canais oficiais e execute o mesmo bootstrap sem `--install-tools`.

## 5. Windows: instalar, verificar e preparar

Descarregue `setup-windows.ps1` pelo botão desta página, guarde numa pasta sua e leia-o antes de executar. Se a política local o bloquear por ter vindo da Internet, use `Unblock-File` apenas nesse ficheiro depois da revisão. Não é necessário alterar ExecutionPolicy da máquina nem ativar o virtual environment.

```powershell
# Opcional: instala Git, gh, Python 3.12, Node LTS, Azure CLI e VS Code via WinGet.
# Pode pedir elevação/consentimento. Não instala Docker nem cria recursos Azure.
.\setup-windows.ps1 -InstallTools
```

Feche e reabra o terminal após instalar. Depois:

```powershell
# Só verificar; não instala, clona, cria venv nem faz login.
.\setup-windows.ps1 -CheckOnly

# Autentique-se manualmente para o repository privado.
gh auth login
gh auth status

# Use o clone existente ou deixe o script clonar para uma pasta nova.
.\setup-windows.ps1 -RepoPath "$env:USERPROFILE\az401-lab"
```

O script confirma o repository, cria `.venv`, instala `requirements-dev.txt` e executa pytest com coverage ≥90%. Não faz pull, checkout, commit, push ou deployment. Não sobrescreve um destino existente sem `.git` nem recria um venv incompatível. Não passa a sua sessão para outra subscription.

```powershell
cd "$env:USERPROFILE\az401-lab"
.\.venv\Scripts\python.exe -m flask --app app run --host 127.0.0.1 --port 5000
# Num segundo terminal:
Invoke-RestMethod http://127.0.0.1:5000/health
Invoke-RestMethod http://127.0.0.1:5000/orders
```

Pare o servidor com Ctrl+C. Use apenas localmente: o servidor Flask de desenvolvimento não é o servidor de produção.

## 6. Linux/WSL: instalar, verificar e preparar

Descarregue `setup-linux.sh`, leia-o e execute com Bash. Não precisa de `chmod` quando usa `bash ficheiro.sh`. Se editar no Windows, guarde com line endings LF.

```bash
# Opcional, apenas Ubuntu 24.04: Git, Python 3.12/venv e utilitários base.
# Usa sudo e apt. Não instala Azure CLI, gh, Node, VS Code ou Docker.
bash setup-linux.sh --install-tools

# Só verificar Git/Python; ferramentas cloud são reportadas separadamente.
bash setup-linux.sh --check-only
```

Instale gh para o login ao repository privado seguindo o canal oficial GitHub CLI. Em Ubuntu, pode usar o package manager da distribuição se disponibilizar uma versão adequada. Se já tem Git autenticado, o clone também funciona sem gh.

```bash
gh auth login
gh auth status
bash setup-linux.sh --repo-path "$HOME/az401-lab"
cd "$HOME/az401-lab"
.venv/bin/python -m flask --app app run --host 127.0.0.1 --port 5000
# Num segundo terminal:
curl --fail http://127.0.0.1:5000/health
curl --fail http://127.0.0.1:5000/orders
```

O bootstrap não instala automaticamente as ferramentas cloud Linux. Instale Azure CLI, Node LTS, gh e VS Code pelas fontes oficiais listadas no fim. Essa separação evita assumir que os repositories de cada distribuição têm as mesmas versões. Os scripts indicam o que falta; `CHECK OK` significa apenas que Git/Python locais estão prontos, não que a subscription está autorizada.

## 7. Preparar acesso Azure e AI

Execute manualmente no mesmo ambiente de terminal em que fará o lab:

```bash
az login
az account list --output table
az account set --subscription '<SUBSCRIPTION_ID_DO_LAB>'
az account show --query '{name:name,id:id,tenant:tenantId}' --output table
az bicep install
az bicep version
gh auth status
node --version
```

Estes comandos servem também no PowerShell, substituindo o placeholder. `az login` pode abrir o browser; em contexto sem browser use a opção de device-code suportada e autorizada no seu tenant. Nunca cole tokens no portal/chat nem os guarde em scripts. Login bem-sucedido não prova acesso RBAC a cada recurso.

No VS Code instale/ative GitHub Copilot, complete o sign-in e confirme que o plano permite as capacidades usadas. Só então configure `.vscode/mcp.json` do L03. Descubra as tools e execute uma leitura antes de permitir uma escrita. Não existe token embutido nestes downloads.

## 8. Checklist de entrada

- Git e Python 3.12 encontrados no terminal escolhido.
- Clone correto do repository privado; dependencies instaladas em `.venv`.
- Testes verdes, coverage mínimo e `/health` e `/orders` com HTTP 200.
- GitHub/ADO acessíveis e permissões de trabalho confirmadas.
- Subscription e tenant corretos; budget criado antes de recursos pagos.
- CLI Bicep e Copilot/MCP prontos antes dos labs que os usam.
- Licenças/regiões verificadas para scanning, slots e agents.

Use o starter abaixo para os primeiros recursos/deployments e depois siga para L01–L20. Os scripts não configuram budgets, service connections, OIDC, Key Vault, pipelines, agents nem recursos Azure: essas tarefas são parte dos exercícios.

## 9. Troubleshooting

| Sintoma | Como resolver |
|---|---|
| Python abre Microsoft Store | Instale Python 3.12 real; reabra terminal; confirme `py -3.12 --version` |
| Access denied / repository not found | Confirme conta em `gh auth status` e acesso ao repo privado; não coloque PAT no URL |
| `.venv` incompatível | Use clone separado por OS; o script não apaga ambientes existentes |
| `No module named venv` | Ubuntu 24.04: instale `python3.12-venv`; outras distros: pacote equivalente |
| Proxy/TLS/PyPI bloqueado | Configure proxy/certificados corporativos aprovados; não desative validação TLS |
| WinGet acabou, mas comando não existe | Feche e reabra terminal para atualizar PATH |
| Gunicorn falha no Windows | Inicie com `python -m flask`; Gunicorn fica no runtime Linux |
| Testes vermelhos | Corrija causa antes de avançar; não reduza coverage para passar |
| Subscription vazia/errada | Verifique conta, tenant, acesso e `az account set` |
| Node abaixo do mínimo | Instale LTS suportada antes de MCP; não é bloqueante para testes Flask |

## Fontes de instalação

- [Azure CLI Windows](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows)
- [Azure CLI Linux](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux)
- [Instalar WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Python venv](https://docs.python.org/3.12/library/venv.html)
- [GitHub CLI: canais oficiais](https://github.com/cli/cli#installation)
- [Node.js: downloads oficiais](https://nodejs.org/en/download)
- [VS Code: instalação](https://code.visualstudio.com/docs/setup/setup-overview)

