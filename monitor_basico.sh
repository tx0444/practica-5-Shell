#!/bin/bash

LOG="monitor_procesos.log"
TEMP="/tmp/monitor_$$.tmp"

limpiar() {
    rm -f "$TEMP"
    echo "[INFO] Limpieza ejecutada: $(date)" >> "$LOG"
}

trap limpiar EXIT

manejar_interrupcion() {
    echo "[WARN] Interrupción recibida: $(date)" >> "$LOG"
    exit 1
}

trap manejar_interrupcion SIGINT SIGTERM


mostrar_cpu() {
    echo "=== Top 5 Procesos por CPU ===" >> "$LOG"
    if ps aux --sort=-%cpu >/dev/null 2>&1; then
        ps aux --sort=-%cpu | head -6 >> "$LOG"
    else
        ps -ef 2>/dev/null | head -6 >> "$LOG"
    fi
    echo "" >> "$LOG"
}

mostrar_memoria() {
    echo "=== Top 5 Procesos por Memoria ===" >> "$LOG"
    if ps aux --sort=-%mem >/dev/null 2>&1; then
        ps aux --sort=-%mem | head -6 >> "$LOG"
    else
        ps -ef 2>/dev/null | head -6 >> "$LOG"
    fi
    echo "" >> "$LOG"
}

buscar_proceso() {
    local proceso="$1"
    if [ -n "$proceso" ]; then
        echo "=== Búsqueda del proceso: $proceso ===" >> "$LOG"
        if command -v pgrep >/dev/null 2>&1; then
            pgrep -a "$proceso" > "$TEMP" 2>/dev/null
        else
            ps -ef 2>/dev/null | grep -i "$proceso" > "$TEMP" 2>/dev/null
        fi

        if [ -s "$TEMP" ]; then
            cat "$TEMP" >> "$LOG"
            echo "[INFO] Proceso '$proceso' encontrado." >> "$LOG"
        else
            echo "[INFO] El proceso '$proceso' no existe o no está activo." >> "$LOG"
            echo "El proceso '$proceso' no existe."
        fi
        echo "" >> "$LOG"
    fi
}


main() {
    echo "--- Inicio del monitoreo: $(date) ---" >> "$LOG"


    mostrar_cpu &
    pid_cpu=$!

    mostrar_memoria &
    pid_memoria=$!

    wait "$pid_cpu"
    wait "$pid_memoria"

    if [ $# -gt 0 ]; then
        buscar_proceso "$1"
    fi

    echo "--- Fin del reporte: $(date) ---" >> "$LOG"
    echo "Reporte generado con éxito en $LOG"
}

main "$@"