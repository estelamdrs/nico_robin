# rodar_ferramenta.ps1
# Script para Windows - configura Python, venv, pandas e executa nico_robin.py

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "======================================="
Write-Host "  Script automático do relatório (Windows)"
Write-Host "======================================="
Write-Host ""

# Permite execução de script só nesta sessão
try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force | Out-Null
} catch {
    Write-Host "Aviso: não foi possível alterar a ExecutionPolicy. Se der erro de permissão, rode este script como Administrador."
}

# 1) Ir para o diretório do script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir
Write-Host "Diretório do projeto: $ScriptDir"
Write-Host ""

# 2) Verificar se winget existe
$wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
$hasWinget = $null -ne $wingetCmd

if ($hasWinget) {
    Write-Host "winget encontrado: $($wingetCmd.Source)"
} else
{
    Write-Host "winget não encontrado. Se for necessário instalar/atualizar Python, pode ser preciso fazer manualmente."
}
Write-Host ""

function Ensure-Python {
    param(
        [string]$PackageId = "Python.Python.3"
    )

    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    $pyCmd     = Get-Command py -ErrorAction SilentlyContinue

    if (-not $pythonCmd -and -not $pyCmd) {
        Write-Host "Python 3 não encontrado no sistema."

        if ($hasWinget) {
            Write-Host "Instalando Python 3 com winget..."
            winget install -e --id $PackageId -h
        } else {
            Write-Host ""
            Write-Host "Erro: Python 3 não encontrado e o winget não está disponível."
            Write-Host "Instale o Python 3 manualmente em: https://www.python.org/downloads/"
            Write-Host "Depois, abra o PowerShell nesta pasta e rode novamente:"
            Write-Host "  .\WINDOWS_rodar_ferramenta.ps1"
            exit 1
        }
    } else {
        Write-Host "Python já encontrado."
        if ($hasWinget) {
            Write-Host "Tentando atualizar Python 3 via winget..."
            try {
                winget upgrade -e --id $PackageId -h
            } catch {
                Write-Host "Não foi possível atualizar o Python via winget (pode não estar instalado por ele)."
            }
        }
    }
}

# 3) Garante que o Python está instalado
Ensure-Python

# 4) Descobre o comando Python que vamos usar
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$pyCmd     = Get-Command py -ErrorAction SilentlyContinue

if ($pythonCmd) {
    $pythonExe = $pythonCmd.Path
} elseif ($pyCmd) {
    # Usa "py -3" se só o launcher existir
    $pythonExe = "py"
} else {
    Write-Host "Python ainda não está disponível nesta sessão."
    Write-Host "Feche e abra o PowerShell de novo nesta pasta e rode:"
    Write-Host "  .\WINDOWS_rodar_ferramenta.ps1"
    exit 1
}

Write-Host "Usando Python: $pythonExe"
Write-Host ""

# 5) Criar / usar ambiente virtual
if (-not (Test-Path ".venv")) {
    Write-Host "Criando ambiente virtual (.venv)..."
    if ($pythonExe -eq "py") {
        py -3 -m venv .venv
    } else {
        & $pythonExe -m venv .venv
    }
} else {
    Write-Host "Ambiente virtual (.venv) já existe. Usando ele."
}

# 6) Ativar ambiente virtual
$venvActivate = Join-Path ".venv" "Scripts\Activate.ps1"
if (-not (Test-Path $venvActivate)) {
    Write-Host "Erro: não foi possível encontrar o script de ativação do ambiente virtual:"
    Write-Host "  $venvActivate"
    exit 1
}

Write-Host "Ativando ambiente virtual..."
. $venvActivate

Write-Host ""
Write-Host "Ambiente virtual ativado."
Write-Host "Python dentro da venv: $(python --version)"
Write-Host ""

# 7) Instalar dependências
Write-Host "Atualizando pip e instalando pandas..."
python -m pip install --upgrade pip
python -m pip install pandas

Write-Host ""
Write-Host "Dependências instaladas."
Write-Host ""

# 8) Executar o script Python
if (-not (Test-Path "nico_robin.py")) {
    Write-Host "Erro: o arquivo nico_robin.py não foi encontrado no diretório:"
    Write-Host "  $ScriptDir"
    exit 1
}

Write-Host "Executando a Nico Robin..."
python nico_robin.py

Write-Host ""
Write-Host "======================================="
Write-Host "  Processo concluído!"
Write-Host "  Verifique o arquivo gerado em:"
Write-Host "  $ScriptDir"
Write-Host "======================================="
Write-Host ""
