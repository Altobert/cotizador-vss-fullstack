const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config({ quiet: true });

// Importar configuración de logging
const { logger, httpLogger } = require('./config/logger');

const app = express();
const PORT = process.env.PORT || 3001;

// Log de inicio del servidor
logger.info('Iniciando servidor backend...');
logger.info(`Entorno: ${process.env.NODE_ENV || 'development'}`);
logger.info(`Puerto: ${PORT}`);

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Middleware de logging HTTP con Morgan personalizado
const morganFormat = ':method :url :status :res[content-length] - :response-time ms';
app.use(morgan(morganFormat, {
  stream: {
    write: (message) => {
      httpLogger.http(message.trim());
    }
  }
}));

// Middleware para logging de requests personalizado
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logData = {
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip || req.connection.remoteAddress,
      userAgent: req.get('User-Agent')
    };
    
    if (res.statusCode >= 400) {
      logger.warn(`HTTP ${res.statusCode} - ${req.method} ${req.url}`, logData);
    } else {
      logger.info(`HTTP ${res.statusCode} - ${req.method} ${req.url}`, logData);
    }
  });
  
  next();
});

// Rutas básicas
app.get('/', (req, res) => {
  logger.info('Acceso a endpoint raíz');
  res.json({ message: 'Backend funcionando correctamente!' });
});

app.get('/api/test', (req, res) => {
  logger.info('Acceso a endpoint de prueba API');
  const response = { 
    message: 'API funcionando', 
    timestamp: new Date().toISOString() 
  };
  logger.debug('Respuesta del endpoint /api/test:', response);
  res.json(response);
});

// Middleware de manejo de errores
app.use((err, req, res, next) => {
  logger.error('Error no manejado:', {
    error: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip || req.connection.remoteAddress,
    userAgent: req.get('User-Agent')
  });
  
  res.status(500).json({ 
    error: 'Algo salió mal!',
    timestamp: new Date().toISOString()
  });
});

// Middleware para rutas no encontradas
app.use((req, res) => {
  logger.warn(`Ruta no encontrada: ${req.method} ${req.url}`, {
    ip: req.ip || req.connection.remoteAddress,
    userAgent: req.get('User-Agent')
  });
  
  res.status(404).json({ 
    error: 'Ruta no encontrada',
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  logger.info(`🚀 Servidor iniciado exitosamente en puerto ${PORT}`);
  logger.info(`📊 Logs disponibles en: ./logs/`);
  logger.info(`🌐 Entorno: ${process.env.NODE_ENV || 'development'}`);
});

// Manejo de señales del sistema para cierre graceful
process.on('SIGTERM', () => {
  logger.info('SIGTERM recibido, cerrando servidor gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT recibido, cerrando servidor gracefully...');
  process.exit(0);
});

process.on('uncaughtException', (err) => {
  logger.error('Excepción no capturada:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Promesa rechazada no manejada:', { reason, promise });
});