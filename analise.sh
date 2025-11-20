#!/bin/bash

##########################################
#      ANTI-CHEAT FF PREMIUM - NOEL
#      by: Seu Projeto no Github
##########################################

ROOT="/storage/emulated/0"
RASTROS="$ROOT/rastros"
LOGS="$RASTROS/logs"

mkdir -p "$RASTROS"
mkdir -p "$LOGS"

##########################################
# LISTA PREMIUM DE PALAVRAS-CHAVE
##########################################

KEYWORDS=(
"cheat" "hack" "mod" "modmenu" "ffh4x" "aimbot" "aimlock" "unlock" "inject"
"injector" "config" "lua" "recoil" "norecoil" "esp" "wallhack" "antena"
"speed" "sens" "sensimax" "autohead" "apkmod" "painel" "gerador" "dll"
"bypass" "anti-ban" "diamond" "script" "frod" "vip" "premium"
)

##########################################
# Função: Barra estética
##########################################
bar() {
    echo "-------------------------------------------"
}

##########################################
# Função: Cálculo de risco
##########################################
calcular_risco() {
    nome="$1"
    risco="BAIXO"

    if [[ "$nome" == *"ffh4x"* || "$nome" == *"aimbot"* || "$nome" == *"inject"* ]]; then
        risco="ALTO"
    elif [[ "$nome" == *"lua"* || "$nome" == *"config"* ]]; then
        risco="MÉDIO"
    fi

    echo "$risco"
}

##########################################
# Função: Scan Premium
##########################################
scan_profundo() {
clear
echo "🔍 INICIANDO ANÁLISE PREMIUM DO SISTEMA..."
bar

FOUND=0
declare -a RASTRO_LISTA=()

for WORD in "${KEYWORDS[@]}"; do
    echo "🔎 Procurando: $WORD ..."

    # Arquivos e pastas comuns
    ARQ=$(find "$ROOT" -type f -iname "*$WORD*" 2>/dev/null)
    DIR=$(find "$ROOT" -type d -iname "*$WORD*" 2>/dev/null)

    # ZIP/APK
    ZIP=$(find "$ROOT" -type f \( -iname "*.zip" -o -iname "*.apk" \) 2>/dev/null)

    
    # ----- RESULTADOS -----

    # Arquivos normais
    if [[ ! -z "$ARQ" ]]; then
        FOUND=1
        while IFS= read -r file; do
            risco=$(calcular_risco "$file")
            echo "🚨 [$risco] $file"
            RASTRO_LISTA+=("$(dirname "$file")")
            cp "$file" "$RASTROS" 2>/dev/null
        done <<< "$ARQ"
    fi

    # Pastas normais
    if [[ ! -z "$DIR" ]]; then
        FOUND=1
        while IFS= read -r pasta; do
            risco=$(calcular_risco "$pasta")
            echo "🚨 [$risco] $pasta"
            RASTRO_LISTA+=("$pasta")
            cp -r "$pasta" "$RASTROS" 2>/dev/null
        done <<< "$DIR"
    fi

    # ZIP e APK
    for z in $ZIP; do
        conteudo=$(unzip -l "$z" 2>/dev/null | grep -i "$WORD")
        if [[ ! -z "$conteudo" ]]; then
            FOUND=1
            risco=$(calcular_risco "$z")
            echo "📦 ZIP/APK Suspeito [$risco]: $z"
            RASTRO_LISTA+=("$(dirname "$z")")
            cp "$z" "$RASTROS" 2>/dev/null
        fi
    done

    bar
done

echo ""
echo "📄 ANÁLISE GERAL"
bar

if [[ $FOUND -eq 0 ]]; then
    echo "✔ Nenhum rastro encontrado."
else
    echo "⚠ RASTROS ENCONTRADOS EM:"
    echo ""

    UNIQUE=($(printf "%s\n" "${RASTRO_LISTA[@]}" | sort -u))

    for pasta in "${UNIQUE[@]}"; do
        echo "📌 $pasta"
    done

    echo ""
    echo "📁 Todos os rastros foram movidos para:"
    echo "$RASTROS"
fi

# LOG
DATA=$(date +"%d-%m-%Y_%H-%M-%S")
LOGFILE="$LOGS/log-$DATA.txt"

printf "%s\n" "${UNIQUE[@]}" > "$LOGFILE"
echo ""
echo "📜 Log salvo em:"
echo "$LOGFILE"

}

##########################################
# MENU
##########################################
menu() {
clear
echo "🔥 ANTI-CHEAT FF PREMIUM"
bar
echo "[1] Fazer análise completa"
echo "[2] Ver pastas de rastros"
echo "[3] Ver logs"
echo "[4] Atualizar ferramenta"
echo "[0] Sair"
bar
echo -n "Escolha: "
read opc

case "$opc" in
    1) scan_profundo; read -p "Enter para voltar..."; menu ;;
    2) termux-open "$RASTROS"; menu ;;
    3) termux-open "$LOGS"; menu ;;
    4) git pull --rebase; echo "Atualizado!"; sleep 1; menu ;;
    0) exit ;;
    *) echo "Opção inválida"; sleep 1; menu ;;
esac
}

menu