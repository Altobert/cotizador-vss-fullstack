#!/bin/bash

# Script para detener el backend del cotizador VSS
# Uso: ./stop-backend.sh

echo "🛑 Deteniendo backend del cotizador VSS..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes con colores
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Buscar proceso del backend
BACKEND_PID=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $2}')

if [ -z "$BACKEND_PID" ]; then
    log_warn "No se encontró ningún proceso del backend ejecutándose"
    
    # Verificar si hay algo en el puerto 3001
    PORT_PID=$(lsof -t -i:3001 2>/dev/null)
    if [ ! -z "$PORT_PID" ]; then
        log_warn "Se encontró un proceso en el puerto 3001 (PID: $PORT_PID)"
        read -p "¿Deseas detenerlo? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deteniendo proceso en puerto 3001..."
            kill $PORT_PID
            sleep 2
            
            # Verificar si se detuvo
            if ! kill -0 $PORT_PID 2>/dev/null; then
                log_info "✅ Proceso detenido exitosamente"
            else
                log_warn "Proceso no respondió, forzando terminación..."
                kill -9 $PORT_PID
                log_info "✅ Proceso terminado forzosamente"
            fi
        else
            log_info "Operación cancelada"
        fi
    else
        log_info "✅ El puerto 3001 está libre"
    fi
    exit 0
fi

log_info "Backend encontrado con PID: $BACKEND_PID"

# Intentar detención suave primero
log_info "Enviando señal SIGTERM (cierre graceful)..."
kill $BACKEND_PID

# Esperar un momento para que termine gracefully
sleep 3

# Verificar si el proceso aún existe
if kill -0 $BACKEND_PID 2>/dev/null; then
    log_warn "El proceso no respondió a SIGTERM"
    read -p "¿Deseas forzar la terminación? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Enviando SIGKILL (terminación forzada)..."
        kill -9 $BACKEND_PID
        sleep 1
        
        if ! kill -0 $BACKEND_PID 2>/dev/null; then
            log_info "✅ Backend terminado forzosamente"
        else
            log_error "❌ No se pudo terminar el proceso"
            exit 1
        fi
    else
        log_info "Operación cancelada. El proceso sigue ejecutándose."
        exit 0
    fi
else
    log_info "✅ Backend detenido exitosamente (cierre graceful)"
fi

# Verificación final
echo
log_info "Verificando estado final..."

# Verificar proceso
if ps aux | grep "node server.js" | grep -v grep > /dev/null; then
    log_error "❌ El backend aún está ejecutándose"
    exit 1
fi

# Verificar puerto
if lsof -i :3001 > /dev/null 2>&1; then
    log_warn "⚠️  El puerto 3001 aún está en uso"
    lsof -i :3001
else
    log_info "✅ El puerto 3001 está libre"
fi

echo
log_info "🎉 Backend detenido correctamente"
log_info "Para reiniciar: cd backend && node server.js"
