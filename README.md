# Práctica N° 5: Script de Monitoreo Básico en Bash

* **Materia:** DES-103
* **Estudiante:** Kevin Rene Barea Amachuy
* **N° de Práctica:** Práctica 5
* **Entorno de Pruebas:** Git Bash / Unix Shell Environment

---

## 1. Descripción del Proyecto

El objetivo principal de esta práctica es el desarrollo y implementación de un script en Bash (`monitor_basico.sh`) diseñado para la supervisión y monitoreo de procesos del sistema operativo. El desarrollo abarca conceptos clave de programación en Shell, tales como:

* **Ejecución en segundo plano (Backgrounding):** Concurrencia mediante el operador `&`.
* **Sincronización de procesos:** Control de flujo mediante la instrucción `wait`.
* **Manejo de señales y eventos del sistema:** Captura de interrupciones con la herramienta `trap`.
* **Filtrado y consulta de procesos:** Uso de herramientas de inspección de procesos (`ps`, `pgrep`, `grep`).
* **Persistencia de datos:** Generación automática de logs (`monitor_procesos.log`) y gestión limpia de archivos temporales.

---

## 2. Arquitectura del Script (`monitor_basico.sh`)

El script está construido de forma modular utilizando funciones específicas para garantizar la limpieza, coherencia y legibilidad del código.

### Código Fuente Completo

```bash
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
    pid_memor
    wait "$pid_cpu"
    wait "$pid_memoria"

    if [ $# -gt 0 ]; then
        buscar_proceso "$1"
    fi

    echo "--- Fin del reporte: $(date) ---" >> "$LOG"
    echo "Reporte generado con éxito en $LOG"
}

main "$@"