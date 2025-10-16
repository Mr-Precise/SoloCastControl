#!/bin/bash

# HyperX SoloCast Control script for Linux

# Проверка наличия amixer
# Checking for amixer availability
if ! command -v amixer >/dev/null 2>&1; then
    echo "Error: 'amixer' not found. Please install alsa-utils."
    exit 1
fi

# Установка имен элементов управления (можно переопределить через переменные окружения)
# Setting control names (can be overridden via environment variables)
MIC_VOLUME_CONTROL=${MIC_VOLUME_CONTROL:-"Microphone Capture Volume"}
MIC_SWITCH_CONTROL=${MIC_SWITCH_CONTROL:-"Microphone Capture Switch"}

# Цвета для вывода (надеюсь везде будет работать?..)
# Colors for output (I hope it will work everywhere?..)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Найти номер карты, содержащей 'SoloCast'
# Find the card number containing 'SoloCast'
CARD_ID=$(grep -i "SoloCast" /proc/asound/cards | awk '{print $1}' | head -n1)

# Если SoloCast не найден, показать другие звуковухи и запросить выбор
# If SoloCast is not found, show other sound cards and ask for a choice
if [[ -z "$CARD_ID" ]]; then
    echo "HyperX SoloCast not found. Available sound cards:"
    cat /proc/asound/cards
    read -p "Enter card ID: " CARD_ID
    if [[ ! "$CARD_ID" =~ ^[0-9]+$ ]]; then
        echo "Invalid card ID."
        exit 1
    fi
fi

case "$1" in
    on)
        # Включить микрофон
        # Turn on the microphone
        amixer -c "$CARD_ID" cset name="$MIC_SWITCH_CONTROL" on >/dev/null
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to set microphone state."
            exit 1
        fi
        echo -e "${GREEN}Microphone on${NC}"
        ;;
    off)
        # Выключить микрофон
        # Turn off the microphone
        amixer -c "$CARD_ID" cset name="$MIC_SWITCH_CONTROL" off >/dev/null
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to set microphone state."
            exit 1
        fi
        echo -e "${RED}Microphone off${NC}"
        ;;
    toggle)
        # Возможность циклически включать/выключать микрофон
        # Ability to toggle the microphone on/off
        STATE=$(amixer -c "$CARD_ID" cget name="$MIC_SWITCH_CONTROL" | grep ': values=' | awk -F= '{print $2}' | head -n1 | tr -d '[:space:]')
        if [[ "$STATE" == "on" ]]; then
            amixer -c "$CARD_ID" cset name="$MIC_SWITCH_CONTROL" off >/dev/null
            if [[ $? -ne 0 ]]; then
                echo "❗ Error: Failed to set microphone state."
                exit 1
            fi
            echo -e "${RED}Microphone off${NC}"
        else
            amixer -c "$CARD_ID" cset name="$MIC_SWITCH_CONTROL" on >/dev/null
            if [[ $? -ne 0 ]]; then
                echo "Error: Failed to set microphone state."
                exit 1
            fi
            echo -e "${GREEN}Microphone on${NC}"
        fi
        ;;
    set)
        if [[ -z "$2" || "$2" -lt 0 || "$2" -gt 100 ]]; then
            echo "Usage: $0 set <0-100>"
            exit 1
        fi
        # Получаем максимальное значение громкости
        # Get the maximum volume value
        MAX_VOL=$(amixer -c "$CARD_ID" cget name="$MIC_VOLUME_CONTROL" | grep 'max=' | sed -E 's/.*max=([0-9]+).*/\1/' | head -n1 | tr -d '[:space:]')
        if [[ -z "$MAX_VOL" || ! "$MAX_VOL" =~ ^[0-9]+$ ]]; then
            echo "Error: Could not retrieve max volume. MAX_VOL='$MAX_VOL'"
            exit 1
        fi
        NEW_VOL=$(( MAX_VOL * $2 / 100 ))
        amixer -c "$CARD_ID" cset name="$MIC_VOLUME_CONTROL" "$NEW_VOL" >/dev/null
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to set volume."
            exit 1
        fi
        echo "Volume set to $2% ($NEW_VOL/$MAX_VOL)"
        ;;
    up)
        # Возможность увеличивать громкость на шаг +10%
        # Ability to increase volume by +10%
        VALUE=$(amixer -c "$CARD_ID" cget name="$MIC_VOLUME_CONTROL" | grep ': values=' | awk -F= '{print $2}' | head -n1 | tr -d '[:space:]')
        MAX_VOL=$(amixer -c "$CARD_ID" cget name="$MIC_VOLUME_CONTROL" | grep 'max=' | sed -E 's/.*max=([0-9]+).*/\1/' | head -n1 | tr -d '[:space:]')
        if [[ -z "$VALUE" || -z "$MAX_VOL" || ! "$VALUE" =~ ^[0-9]+$ || ! "$MAX_VOL" =~ ^[0-9]+$ ]]; then
            echo "Error: Could not retrieve volume information."
            exit 1
        fi
        CURRENT_PERCENT=$(( 100 * VALUE / MAX_VOL ))
        NEW_PERCENT=$(( CURRENT_PERCENT + 10 ))
        if [[ "$NEW_PERCENT" -gt 100 ]]; then
            NEW_PERCENT=100
        fi
        NEW_VOL=$(( MAX_VOL * NEW_PERCENT / 100 ))
        amixer -c "$CARD_ID" cset name="$MIC_VOLUME_CONTROL" "$NEW_VOL" >/dev/null
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to set volume."
            exit 1
        fi
        echo "Volume increased to $NEW_PERCENT% ($NEW_VOL/$MAX_VOL)"
        ;;
    down)
        # Возможность уменьшать громкость на шаг -10%
        # Ability to decrease volume by -10%
        VALUE=$(amixer -c "$CARD_ID" cget name="$MIC_VOLUME_CONTROL" | grep ': values=' | awk -F= '{print $2}' | head -n1 | tr -d '[:space:]')
        MAX_VOL=$(amixer -c "$CARD_ID" cget name="$MIC_VOLUME_CONTROL" | grep 'max=' | sed -E 's/.*max=([0-9]+).*/\1/' | head -n1 | tr -d '[:space:]')
        if [[ -z "$VALUE" || -z "$MAX_VOL" || ! "$VALUE" =~ ^[0-9]+$ || ! "$MAX_VOL" =~ ^[0-9]+$ ]]; then
            echo "Error: Could not retrieve volume information."
            exit 1
        fi
        CURRENT_PERCENT=$(( 100 * VALUE / MAX_VOL ))
        NEW_PERCENT=$(( CURRENT_PERCENT - 10 ))
        if [[ "$NEW_PERCENT" -lt 0 ]]; then
            NEW_PERCENT=0
        fi
        NEW_VOL=$(( MAX_VOL * NEW_PERCENT / 100 ))
        amixer -c "$CARD_ID" cset name="$MIC_VOLUME_CONTROL" "$NEW_VOL" >/dev/null
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to set volume."
            exit 1
        fi
        echo "Volume decreased to $NEW_PERCENT% ($NEW_VOL/$MAX_VOL)"
        ;;
    get)
        # Получаем состояние микрофона (on/off)
        # Get the microphone status (on/off)
        STATE=$(amixer -c "$CARD_ID" cget name="$MIC_SWITCH_CONTROL" | grep ': values=' | awk -F= '{print $2}' | head -n1 | tr -d '[:space:]')
        
        # Получаем текущую громкость
        # Get the current volume
        VALUE=$(amixer -c "$CARD_ID" cget name="$MIC_VOLUME_CONTROL" | grep ': values=' | awk -F= '{print $2}' | head -n1 | tr -d '[:space:]')
        
        # Получаем максимально возможное значение громкости
        # Obtain the maximum possible volume value
        MAX_VOL=$(amixer -c "$CARD_ID" cget name="$MIC_VOLUME_CONTROL" | grep 'max=' | sed -E 's/.*max=([0-9]+).*/\1/' | head -n1 | tr -d '[:space:]')
        
        # Проверяем корректность значений
        # Check the correctness of the values
        if [[ -z "$VALUE" || -z "$MAX_VOL" || ! "$VALUE" =~ ^[0-9]+$ || ! "$MAX_VOL" =~ ^[0-9]+$ ]]; then
            echo "Error: Could not retrieve volume information. VALUE='$VALUE', MAX_VOL='$MAX_VOL'"
            exit 1
        fi
        
        # Вычисляем процент
        # Calculating the percentage
        PERCENT=$(( 100 * VALUE / MAX_VOL ))
        if [[ "$STATE" == "on" ]]; then
            echo -e "${GREEN}Microphone status: $STATE${NC}"
        else
            echo -e "${RED}Microphone status: $STATE${NC}"
        fi
        echo "Volume: $PERCENT% ($VALUE/$MAX_VOL)"
        ;;
    *)
        # Справка
        # Usage
        echo "Usage:"
        echo "  $0 on            # Turn on microphone"
        echo "  $0 off           # Turn off microphone"
        echo "  $0 toggle        # Toggle microphone state"
        echo "  $0 set <0-100>   # Set volume in %"
        echo "  $0 up            # Increase volume by +10%"
        echo "  $0 down          # Decrease volume by -10%"
        echo "  $0 get           # Get status"
        exit 1
        ;;
esac
