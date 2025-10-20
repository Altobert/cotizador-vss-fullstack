@echo off
echo ====================================
echo  Deteniendo Proyecto Fullstack
echo ====================================
echo.

echo Buscando y cerrando procesos de Node.js...

REM Matar procesos de Node.js que están ejecutando los servidores
taskkill /f /im node.exe 2>nul
if %errorlevel% equ 0 (
    echo Procesos de Node.js terminados correctamente.
) else (
    echo No se encontraron procesos de Node.js ejecutándose.
)

echo.
echo Buscando y cerrando procesos npm...
taskkill /f /im npm.cmd 2>nul
taskkill /f /im npm.exe 2>nul

echo.
echo ====================================
echo  Limpieza completada
echo ====================================
echo.
echo Todos los procesos del proyecto han sido detenidos.
echo.
pause