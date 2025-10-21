# Scripts de Gestión del Backend - Cotizador VSS

## 📋 Scripts Disponibles

### 🚀 `start-backend.sh`
Inicia el servidor backend del cotizador VSS.

**Características:**
- ✅ Verifica si ya hay un backend ejecutándose
- ✅ Detecta conflictos de puerto
- ✅ Instala dependencias automáticamente si es necesario
- ✅ Crea archivo `.env` básico si no existe
- ✅ Crea directorio de logs automáticamente
- ✅ Muestra información del entorno

**Uso:**
```bash
./start-backend.sh
```

### 🛑 `stop-backend.sh`
Detiene el servidor backend de manera segura.

**Características:**
- ✅ Detección automática del proceso backend
- ✅ Cierre graceful (SIGTERM) primero
- ✅ Terminación forzada (SIGKILL) si es necesario
- ✅ Verificación de puerto ocupado
- ✅ Confirmación interactiva para acciones destructivas
- ✅ Verificación final del estado

**Uso:**
```bash
./stop-backend.sh
```

### 📊 `status-backend.sh`
Verifica el estado completo del backend.

**Características:**
- ✅ Verifica procesos activos
- ✅ Comprueba estado del puerto 3001
- ✅ Prueba conectividad HTTP
- ✅ Verifica endpoints API
- ✅ Muestra información de logs
- ✅ Resumen del estado con recomendaciones

**Uso:**
```bash
./status-backend.sh
```

## 🔧 Instalación y Configuración

### 1. Hacer los scripts ejecutables
```bash
chmod +x *.sh
```

### 2. Verificar dependencias
Los scripts requieren:
- `curl` (para pruebas de conectividad)
- `lsof` (para verificar puertos)
- `ps` (para verificar procesos)

### 3. Estructura de archivos
```
backend/
├── start-backend.sh
├── stop-backend.sh
├── status-backend.sh
├── server.js
├── config/
│   └── logger.js
├── logs/
│   ├── combined.log
│   ├── error.log
│   └── http.log
└── .env
```

## 🎯 Casos de Uso Comunes

### Iniciar el backend
```bash
./start-backend.sh
```

### Verificar estado
```bash
./status-backend.sh
```

### Detener el backend
```bash
./stop-backend.sh
```

### Reiniciar el backend
```bash
./stop-backend.sh
./start-backend.sh
```

## 🔍 Solución de Problemas

### Puerto ocupado por otro proceso
```bash
# Ver qué está usando el puerto
lsof -i :3001

# Detener proceso específico
kill [PID]

# O usar el script
./stop-backend.sh
```

### Backend no responde
```bash
# Verificar estado
./status-backend.sh

# Ver logs
tail -f logs/error.log
tail -f logs/combined.log
```

### Dependencias faltantes
```bash
# Reinstalar dependencias
rm -rf node_modules
npm install
```

## 📝 Logs y Monitoreo

### Ver logs en tiempo real
```bash
# Todos los logs
tail -f logs/combined.log

# Solo errores
tail -f logs/error.log

# Solo requests HTTP
tail -f logs/http.log
```

### Rotar logs (para producción)
```bash
# Comprimir logs antiguos
gzip logs/*.log

# Limpiar logs antiguos
find logs/ -name "*.log" -mtime +7 -delete
```

## 🚨 Señales del Sistema

Los scripts manejan las siguientes señales:
- **SIGTERM**: Cierre graceful
- **SIGINT**: Interrupción (Ctrl+C)
- **SIGKILL**: Terminación forzada

## 🔒 Seguridad

- Los scripts solicitan confirmación para acciones destructivas
- Verifican permisos antes de ejecutar comandos
- Manejan errores de manera segura
- No ejecutan comandos peligrosos sin confirmación

## 📞 Soporte

Si encuentras problemas:
1. Ejecuta `./status-backend.sh` para diagnóstico
2. Revisa los logs en `logs/`
3. Verifica que todas las dependencias estén instaladas
4. Asegúrate de tener permisos de ejecución en los scripts
