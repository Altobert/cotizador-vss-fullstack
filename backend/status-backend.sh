#!/bin/bash

# Script para verificar el estado del backend del cotizador VSS
# Uso: ./status-backend.sh

echo "📊 Estado del backend del cotizador VSS"
echo "======================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Buscar proceso del backend
BACKEND_PID=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $2}')

echo
log_info "🔍 Verificando procesos..."

if [ -z "$BACKEND_PID" ]; then
    log_warn "❌ No se encontró ningún proceso del backend ejecutándose"
else
    log_info "✅ Backend encontrado con PID: $BACKEND_PID"
    
    # Mostrar información del proceso
    echo
    log_debug "Información del proceso:"
    ps aux | grep "node server.js" | grep -v grep | while read line; do
        echo "  $line"
    done
fi

echo
log_info "🌐 Verificando puerto 3001..."

# Verificar puerto 3001
PORT_INFO=$(lsof -i :3001 2>/dev/null)

if [ -z "$PORT_INFO" ]; then
    log_warn "❌ El puerto 3001 está libre"
else
    log_info "✅ El puerto 3001 está en uso:"
    echo "$PORT_INFO" | while read line; do
        echo "  $line"
    done
fi

echo
log_info "🔗 Probando conectividad..."

# Probar conectividad
if curl -s http://localhost:3001/ > /dev/null 2>&1; then
    log_info "✅ Backend responde correctamente"
    
    # Obtener respuesta del endpoint
    RESPONSE=$(curl -s http://localhost:3001/)
    log_debug "Respuesta: $RESPONSE"
    
    # Probar endpoint API
    if curl -s http://localhost:3001/api/test > /dev/null 2>&1; then
        log_info "✅ Endpoint API funciona correctamente"
        API_RESPONSE=$(curl -s http://localhost:3001/api/test)
        log_debug "Respuesta API: $API_RESPONSE"
    else
        log_warn "⚠️  Endpoint API no responde"
    fi
else
    log_error "❌ Backend no responde en http://localhost:3001"
fi

echo
log_info "📁 Verificando archivos de log..."

# Verificar logs
if [ -d "logs" ]; then
    log_info "✅ Directorio de logs existe"
    
    if [ -f "logs/combined.log" ]; then
        LOG_SIZE=$(wc -l < logs/combined.log)
        log_info "📄 combined.log: $LOG_SIZE líneas"
    fi
    
    if [ -f "logs/error.log" ]; then
        ERROR_SIZE=$(wc -l < logs/error.log)
        log_info "📄 error.log: $ERROR_SIZE líneas"
    fi
    
    if [ -f "logs/http.log" ]; then
        HTTP_SIZE=$(wc -l < logs/http.log)
        log_info "📄 http.log: $HTTP_SIZE líneas"
    fi
else
    log_warn "⚠️  Directorio de logs no existe"
fi

echo
log_info "📋 Resumen del estado:"

if [ ! -z "$BACKEND_PID" ] && [ ! -z "$PORT_INFO" ] && curl -s http://localhost:3001/ > /dev/null 2>&1; then
    log_info "🟢 BACKEND FUNCIONANDO CORRECTAMENTE"
    echo "   • Proceso activo: PID $BACKEND_PID"
    echo "   • Puerto 3001: En uso"
    echo "   • Conectividad: OK"
    echo "   • Para detener: ./stop-backend.sh"
elif [ ! -z "$BACKEND_PID" ]; then
    log_warn "🟡 BACKEND PARCIALMENTE FUNCIONAL"
    echo "   • Proceso activo: PID $BACKEND_PID"
    echo "   • Puerto 3001: Verificar estado"
    echo "   • Conectividad: Verificar"
elif [ ! -z "$PORT_INFO" ]; then
    log_warn "🟡 PUERTO OCUPADO PERO SIN PROCESO BACKEND"
    echo "   • Proceso backend: No encontrado"
    echo "   • Puerto 3001: Ocupado por otro proceso"
    echo "   • Para limpiar: ./stop-backend.sh"
else
    log_error "🔴 BACKEND NO FUNCIONANDO"
    echo "   • Proceso backend: No encontrado"
    echo "   • Puerto 3001: Libre"
    echo "   • Para iniciar: ./start-backend.sh"
fi

echo
