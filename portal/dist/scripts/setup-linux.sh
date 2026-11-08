#!/usr/bin/env bash
# Linux/WSL bootstrap. No Azure deployment, tokens or automatic account changes.
set -Eeuo pipefail
trap 'printf "Erro na linha %s. Corrija a causa e execute novamente.\n" "$LINENO" >&2' ERR
repo_path="${HOME}/az401-lab"
check_only=false
install_tools=false
while (($#)); do
  case "$1" in
    --repo-path) [[ $# -ge 2 && -n "$2" ]] || { echo 'Falta o valor de --repo-path' >&2; exit 2; }; repo_path="$2"; shift 2 ;;
    --check-only) check_only=true; shift ;;
    --install-tools) install_tools=true; shift ;;
    --help) echo 'Uso: bash setup-linux.sh [--repo-path PATH] [--check-only | --install-tools]'; exit 0 ;;
    *) echo "Opcao desconhecida: $1" >&2; exit 2 ;;
  esac
done
if $check_only && $install_tools; then echo 'Escolha apenas um modo.' >&2; exit 2; fi
if $install_tools; then
  # Only the supported base OS packages. Cloud/AI tooling is explained in the portal.
  [[ -f /etc/os-release ]] || { echo 'Distribuicao nao identificada.' >&2; exit 1; }
  . /etc/os-release
  [[ "${ID:-}" == ubuntu && "${VERSION_ID:-}" == 24.04 ]] || { echo '--install-tools suporta Ubuntu 24.04. Noutras distros, instale Git e Python 3.12 manualmente.' >&2; exit 1; }
  command -v sudo >/dev/null || { echo 'sudo necessario para instalar pacotes do sistema.' >&2; exit 1; }
  sudo apt-get update
  sudo apt-get install -y git python3.12 python3.12-venv ca-certificates curl unzip
  echo 'Ferramentas locais instaladas. Repita sem --install-tools. Azure CLI, GitHub CLI e Node.js sao configurados separadamente no portal.'
  exit 0
fi
missing=0
if command -v git >/dev/null; then git --version; else echo 'FALTA: Git' >&2; missing=1; fi
python_bin=''
for candidate in python3.12 python3 python; do
  if command -v "$candidate" >/dev/null && "$candidate" -c 'import sys; sys.exit(0 if sys.version_info[:2] == (3,12) else 1)' 2>/dev/null; then python_bin="$candidate"; break; fi
done
if [[ -z "$python_bin" ]]; then echo 'FALTA: Python 3.12 com venv' >&2; missing=1; else "$python_bin" --version; fi
for tool in gh az node code docker; do
  if command -v "$tool" >/dev/null; then
    printf '[ENCONTRADO] %s\n' "$tool"
    if [[ "$tool" == node ]] && ! node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 20 ? 0 : 1)'; then echo 'Node.js abaixo de 20: atualize antes do MCP.' >&2; fi
  else printf '[OPCIONAL PARA LOCAL] %s ausente; consulte a matriz de pre-requisitos.\n' "$tool"; fi
done
[[ "$missing" == 0 ]] || { echo 'Instale as ferramentas em falta; Ubuntu 24.04 pode usar --install-tools.' >&2; exit 1; }
if $check_only; then echo 'CHECK OK: Git e Python 3.12. Nenhuma alteracao executada.'; exit 0; fi
if [[ -e "$repo_path" ]]; then
  [[ -e "$repo_path/.git" ]] || { echo 'Destino existente sem .git. Escolha outro --repo-path; nada sera sobrescrito.' >&2; exit 1; }
else
  echo 'Clonar repository privado: configure antes a autenticacao Git/GitHub.'
  if command -v gh >/dev/null; then gh repo clone lfernandesc/az401-lab "$repo_path"; else git clone https://github.com/lfernandesc/az401-lab.git "$repo_path"; fi
fi
cd -- "$repo_path"
remote="$(git remote get-url origin)"
[[ "$remote" =~ github\.com[:/]lfernandesc/az401-lab(\.git)?$ ]] || { echo 'O destino nao e o repository az401-lab esperado.' >&2; exit 1; }
for file in app.py requirements.txt requirements-dev.txt; do [[ -f "$file" ]] || { echo "Falta $file no repository." >&2; exit 1; }; done
if [[ -e .venv ]]; then
  [[ -x .venv/bin/python ]] || { echo '.venv existente incompativel. Use clone separado de Windows/WSL.' >&2; exit 1; }
  .venv/bin/python -c 'import sys; sys.exit(0 if sys.version_info[:2] == (3,12) else 1)'
else "$python_bin" -m venv .venv; fi
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python -m pytest --cov=app --cov-branch --cov-fail-under=90
echo 'SETUP LOCAL OK. Nenhum recurso Azure criado; nenhum login executado pelo script.'
printf 'Diretorio: %s\n' "$PWD"
echo 'Iniciar: .venv/bin/python -m flask --app app run --host 127.0.0.1 --port 5000'
echo 'Noutro terminal: curl --fail http://127.0.0.1:5000/health'
echo 'Cloud (manual): gh auth login; az login; az account set --subscription <ID>'

