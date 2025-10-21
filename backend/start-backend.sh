#!/bin/bash

# Script para iniciar el backend del cotizador VSS
# Uso: ./start-backend.sh

echo "🚀 Iniciando backend del cotizador VSS..."

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

# Verificar si ya hay un backend ejecutándose
BACKEND_PID=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $2}')

if [ ! -z "$BACKEND_PID" ]; then
    log_warn "Ya hay un backend ejecutándose con PID: $BACKEND_PID"
    read -p "¿Deseas detenerlo y reiniciar? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deteniendo backend existente..."
        kill $BACKEND_PID
        sleep 2
        
        # Verificar si se detuvo
        if kill -0 $BACKEND_PID 2>/dev/null; then
            log_warn "Forzando terminación..."
            kill -9 $BACKEND_PID
        fi
        log_info "✅ Backend anterior detenido"
    else
        log_info "Operación cancelada"
        exit 0
    fi
fi

# Verificar si el puerto 3001 está libre
if lsof -i :3001 > /dev/null 2>&1; then
    log_error "❌ El puerto 3001 está ocupado"
    log_info "Procesos usando el puerto 3001:"
    lsof -i :3001
    exit 1
fi

# Verificar que estamos en el directorio correcto
if [ ! -f "server.js" ]; then
    log_error "❌ No se encontró server.js en el directorio actual"
    log_info "Asegúrate de ejecutar este script desde el directorio backend/"
    exit 1
fi

# Verificar que node_modules existe
if [ ! -d "node_modules" ]; then
    log_warn "No se encontró node_modules"
    log_info "Instalando dependencias..."
    npm install
    if [ $? -ne 0 ]; then
        log_error "❌ Error instalando dependencias"
        exit 1
    fi
fi

# Verificar variables de entorno
if [ ! -f ".env" ]; then
    log_warn "No se encontró archivo .env"
    log_info "Creando archivo .env básico..."
    cat > .env << EOF
NODE_ENV=development
PORT=3001
LOG_LEVEL=debug
EOF
    log_info "✅ Archivo .env creado"
fi

# Mostrar información del entorno
log_info "Entorno: ${NODE_ENV:-development}"
log_info "Puerto: ${PORT:-3001}"
log_info "Nivel de log: ${LOG_LEVEL:-debug}"

# Crear directorio de logs si no existe
if [ ! -d "logs" ]; then
    log_info "Creando directorio de logs..."
    mkdir -p logs
fi

echo
log_info "🎯 Iniciando servidor backend..."
log_info "📊 Los logs se guardarán en: ./logs/"
log_info "🌐 URL: http://localhost:${PORT:-3001}"
log_info "🛑 Para detener: ./stop-backend.sh o Ctrl+C"
echo

# Iniciar el servidor
node server.js
