# Sistema de Logging - Backend VSS

## Descripción
Sistema de logging profesional implementado con Winston y Morgan para el backend del cotizador VSS.

## Características

### Niveles de Log
- **error**: Errores críticos del sistema
- **warn**: Advertencias y situaciones anómalas
- **info**: Información general del sistema
- **http**: Requests HTTP (con Morgan)
- **debug**: Información detallada para desarrollo

### Archivos de Log
- `logs/combined.log`: Todos los logs en formato JSON
- `logs/error.log`: Solo errores en formato JSON
- `logs/http.log`: Requests HTTP en formato JSON

### Configuración
El sistema se configura automáticamente según el entorno:
- **Development**: Logs en consola con colores y nivel debug
- **Production**: Solo logs importantes (warn+) y archivos

## Variables de Entorno
```bash
NODE_ENV=development|production
LOG_LEVEL=error|warn|info|http|debug
```

## Uso en el Código

### Logger Principal
```javascript
const { logger } = require('./config/logger');

// Diferentes niveles
logger.error('Error crítico:', { error: err.message });
logger.warn('Advertencia:', { data: someData });
logger.info('Información general');
logger.debug('Información detallada:', { debugData });
```

### Logger HTTP
```javascript
const { httpLogger } = require('./config/logger');

httpLogger.http('Request procesado');
```

## Middleware Automático
- **Morgan**: Logging automático de requests HTTP
- **Request Logger**: Información detallada de cada request
- **Error Handler**: Captura y log de errores no manejados
- **404 Handler**: Log de rutas no encontradas

## Información Capturada
- Timestamp de cada evento
- IP del cliente
- User Agent
- Duración de requests
- Stack traces de errores
- Método HTTP y URL
- Códigos de estado

## Monitoreo
Los logs se pueden monitorear en tiempo real:
```bash
# Ver logs en tiempo real
tail -f logs/combined.log

# Ver solo errores
tail -f logs/error.log

# Ver requests HTTP
tail -f logs/http.log
```

## Rotación de Logs
Para producción, se recomienda configurar rotación de logs con herramientas como:
- `logrotate` (Linux)
- `winston-daily-rotate-file` (Node.js)
