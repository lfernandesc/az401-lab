#requires -Version 5.1
<# Local bootstrap only. No Azure resources, account changes or credential storage. #>
[CmdletBinding()]
param(
    [string]$RepoPath = (Join-Path $env:USERPROFILE 'az401-lab'),
    [switch]$CheckOnly,
    [switch]$InstallTools
)
$ErrorActionPreference = 'Stop'
if ($CheckOnly -and $InstallTools) { throw 'Use -CheckOnly ou -InstallTools, nao ambos.' }
function Invoke-Checked {
    param([string]$Executable, [string[]]$Arguments)
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Falhou: $Executable (exit $LASTEXITCODE)." }
}
if ($InstallTools) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'Instale App Installer/WinGet pela Microsoft Store e repita.' }
    foreach ($id in @('Git.Git', 'GitHub.cli', 'Python.Python.3.12', 'OpenJS.NodeJS.LTS', 'Microsoft.AzureCLI', 'Microsoft.VisualStudioCode')) {
        Write-Host "Instalar/verificar $id (pode pedir consentimento ou elevacao)..."
        & winget install --exact --id $id --source winget
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) { throw "WinGet falhou para $id. Resolva o erro e repita." }
    }
    Write-Host 'Instalacao concluida. Feche e reabra o terminal, depois execute este script sem -InstallTools.'
    return
}
$missing = @()
if (Get-Command git -ErrorAction SilentlyContinue) { Invoke-Checked 'git' @('--version') } else { $missing += 'Git' }
$python = $null
foreach ($candidate in @('py', 'python', 'python3')) {
    if (-not (Get-Command $candidate -ErrorAction SilentlyContinue)) { continue }
    $candidateArgs = @('-c', 'import sys; print(sys.executable)')
    if ($candidate -eq 'py') { $candidateArgs = @('-3.12') + $candidateArgs }
    try {
        $resolvedPython = & $candidate @candidateArgs 2>$null
        if ($LASTEXITCODE -eq 0 -and $resolvedPython) {
            $resolvedPython = [string]($resolvedPython | Select-Object -Last 1)
            & $resolvedPython -c 'import sys; sys.exit(0 if sys.version_info[:2] == (3,12) else 1)'
            if ($LASTEXITCODE -eq 0) { $python = $resolvedPython; break }
        }
    } catch { continue }
}
if ($python) { Invoke-Checked $python @('--version') } else { $missing += 'Python 3.12 (instalacao real, nao apenas o alias da Store)' }
foreach ($tool in @('gh', 'az', 'node', 'code', 'docker')) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "[ENCONTRADO] $tool"
        if ($tool -eq 'node') {
            & node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 20 ? 0 : 1)'
            if ($LASTEXITCODE -ne 0) { Write-Warning 'Node.js abaixo de 20: atualize antes de usar MCP.' }
        }
    } else { Write-Warning "$tool ausente: veja a matriz de pre-requisitos no portal. Nao impede os testes locais." }
}
if ($missing.Count) { throw ('Pre-requisitos locais em falta: ' + ($missing -join ', ') + '. Use -InstallTools ou instale-os manualmente.') }
if ($CheckOnly) { Write-Host 'CHECK OK: Git e Python 3.12. Nenhum clone, venv, login ou recurso Azure criado.'; return }
$destination = [System.IO.Path]::GetFullPath($RepoPath)
if (Test-Path -LiteralPath $destination) {
    if (-not (Test-Path -LiteralPath (Join-Path $destination '.git'))) { throw 'O destino ja existe sem .git. Escolha outro -RepoPath; nada sera sobrescrito.' }
} else {
    Write-Host 'Clonar repository privado. Precisa de acesso e autenticacao Git/GitHub ja configurada.'
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Invoke-Checked 'gh' @('repo', 'clone', 'lfernandesc/az401-lab', $destination)
    } else { Invoke-Checked 'git' @('clone', 'https://github.com/lfernandesc/az401-lab.git', $destination) }
}
Push-Location -LiteralPath $destination
try {
    $remote = & git remote get-url origin
    if ($LASTEXITCODE -ne 0 -or $remote -notmatch 'github\.com[:/]lfernandesc/az401-lab(?:\.git)?$') { throw 'O destino nao e o repository az401-lab esperado.' }
    foreach ($file in @('app.py', 'requirements-dev.txt', 'requirements.txt')) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Falta $file no repository." }
    }
    $venvPython = Join-Path $destination '.venv\Scripts\python.exe'
    if (Test-Path -LiteralPath '.venv') {
        if (-not (Test-Path -LiteralPath $venvPython)) { throw '.venv existente incompativel. Use um clone separado para Windows; nao partilhe venv com WSL.' }
        Invoke-Checked $venvPython @('-c', 'import sys; sys.exit(0 if sys.version_info[:2] == (3,12) else 1)')
    } else { Invoke-Checked $python @('-m', 'venv', '.venv') }
    Invoke-Checked $venvPython @('-m', 'pip', 'install', '-r', 'requirements-dev.txt')
    Invoke-Checked $venvPython @('-m', 'pytest', '--cov=app', '--cov-branch', '--cov-fail-under=90')
    Write-Host 'SETUP LOCAL OK. Nenhum recurso Azure foi criado. Nenhum login foi feito pelo script.'
    Write-Host "cd `"$destination`""
    Write-Host '.\.venv\Scripts\python.exe -m flask --app app run --host 127.0.0.1 --port 5000'
    Write-Host 'Noutro terminal: Invoke-RestMethod http://127.0.0.1:5000/health'
    Write-Host 'Autenticacao manual para cloud: gh auth login; az login; az account set --subscription <ID>'
} finally { Pop-Location }

