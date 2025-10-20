Write-Host "====================================" -ForegroundColor Green
Write-Host " Iniciando Proyecto Fullstack" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

# Verificar si Node.js está instalado
try {
    $nodeVersion = node --version
    Write-Host "Node.js detectado: $nodeVersion" -ForegroundColor Cyan
} catch {
    Write-Host "Error: Node.js no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "Por favor instala Node.js desde https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "Iniciando Backend..." -ForegroundColor Yellow

# Iniciar Backend
$backendPath = Join-Path $PSScriptRoot "backend"
Start-Process -WindowStyle Normal -WorkingDirectory $backendPath -FilePath "cmd" -ArgumentList "/k", "npm run dev"

Write-Host "Backend iniciado en segundo plano" -ForegroundColor Green

Write-Host ""
Write-Host "Esperando 3 segundos antes de iniciar el Frontend..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Iniciando Frontend..." -ForegroundColor Yellow

# Iniciar Frontend
$frontendPath = Join-Path $PSScriptRoot "frontend"
Start-Process -WindowStyle Normal -WorkingDirectory $frontendPath -FilePath "cmd" -ArgumentList "/k", "npm start"

Write-Host "Frontend iniciado en segundo plano" -ForegroundColor Green

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host " Ambos servicios iniciados:" -ForegroundColor Green
Write-Host " - Backend: http://localhost:5000" -ForegroundColor Cyan
Write-Host " - Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Los servicios se están ejecutando en ventanas separadas." -ForegroundColor White
Write-Host "Para detenerlos, cierra las ventanas de terminal correspondientes." -ForegroundColor White
Write-Host ""
Read-Host "Presiona Enter para salir"