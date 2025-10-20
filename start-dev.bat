@echo off
echo ====================================
echo  Iniciando Proyecto Fullstack
echo ====================================
echo.

REM Verificar si Node.js está instalado
node --version >nul 2>&1
if errorlevel 1 (
    echo Error: Node.js no está instalado o no está en el PATH
    echo Por favor instala Node.js desde https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js detectado: 
node --version

echo.
echo Iniciando Backend en segundo plano...
cd /d "%~dp0backend"
start "Backend - Node.js Server" cmd /k "npm run dev"

echo.
echo Esperando 3 segundos antes de iniciar el Frontend...
timeout /t 3 /nobreak >nul

echo.
echo Iniciando Frontend...
cd /d "%~dp0frontend"
start "Frontend - React App" cmd /k "npm start"

echo.
echo ====================================
echo  Ambos servicios iniciados:
echo  - Backend: http://localhost:5000
echo  - Frontend: http://localhost:3000
echo ====================================
echo.
echo Presiona cualquier tecla para salir...
pause >nul