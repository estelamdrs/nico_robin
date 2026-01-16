#!/usr/bin/env bash
set -e

echo ""
echo "======================================="
echo "  Script automático do relatório"
echo "======================================="
echo ""

# Descobre a pasta onde o script está e vai pra lá
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "Diretório do projeto: $REPO_DIR"
echo ""

########################################
# 1) Verificar / instalar Homebrew
########################################
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew não encontrado. Instalando Homebrew..."
  echo "Isso pode pedir a senha do Mac e levar alguns minutos."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Inicializa o brew na sessão atual
  if [ -d "/opt/homebrew/bin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -d "/usr/local/bin" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew encontrado: $(brew --version | head -n 1)"
fi

echo ""

########################################
# 2) Verificar / instalar / atualizar Python 3
########################################

if command -v python3 >/dev/null 2>&1; then
  echo "Python 3 encontrado: $(python3 --version)"
  echo "Tentando atualizar Python 3 via Homebrew (se for gerenciado pelo brew)..."
  brew install python || true
  brew upgrade python || true
else
  echo "Python 3 não encontrado. Instalando Python 3 com Homebrew..."
  brew install python
fi

# Garante que python3 existe depois disso
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
else
  echo "Erro: Python 3 ainda não está disponível após a instalação."
  echo "Por favor, instale o Python 3 manualmente e rode o script novamente."
  exit 1
fi

echo "Usando Python: $PYTHON_BIN ($($PYTHON_BIN --version))"
echo ""

########################################
# 3) Criar / usar ambiente virtual
########################################

if [ ! -d ".venv" ]; then
  echo "Criando ambiente virtual (.venv)..."
  $PYTHON_BIN -m venv .venv
else
  echo "Ambiente virtual (.venv) já existe. Usando ele."
fi

# Ativa o ambiente virtual
# shellcheck disable=SC1091
source ".venv/bin/activate"

echo ""
echo "Ambiente virtual ativado."
echo "Python dentro da venv: $(python --version)"
echo ""

########################################
# 4) Instalar dependências (pandas)
########################################

echo "Atualizando pip e instalando dependências..."
python -m pip install --upgrade pip
python -m pip install pandas

echo ""
echo "Dependências instaladas."
echo ""

########################################
# 5) Executar o script Python
########################################

echo "Executando a Nico Robin.py..."
python nico_robin.py

echo ""
echo "======================================="
echo "  Processo concluído!"
echo "  Verifique o arquivo gerado no diretório:"
echo "  $REPO_DIR"
echo "======================================="
echo ""
