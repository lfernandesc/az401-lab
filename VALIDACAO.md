# Validação do starter

Verificação realizada em 4 de novembro de 2026:

- Python 3.12: **3 testes passaram**.
- Coverage de statements e branches de `app.py`: **100%**; gate mínimo de 90% passou.
- Os testes verificam health, orders e o incidente controlado HTTP 500.
- Ambos os ficheiros YAML foram carregados com um parser sem erros de sintaxe. Isto não substitui a execução nas plataformas.
- `infra/main.bicep` compilou com Bicep CLI v0.48.1 sem erros.
- Nenhum recurso Azure, repository ou serviço externo foi criado nesta preparação.
- GitHub Actions, Azure Pipelines, OIDC/RBAC, Key Vault, MCP, scanning, alerts e AI agents não foram executados em contas externas; os checkpoints indicam como validá-los durante o lab.
- As dependencies diretas estão fixadas. Não foi produzido um lock file de dependencies transitivas nem um security audit das versões.
