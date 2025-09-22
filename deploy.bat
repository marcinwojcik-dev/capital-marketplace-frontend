@echo off
setlocal enabledelayedexpansion

REM Capital Marketplace Frontend - Docker Deployment Script for Windows
REM Usage: deploy.bat [dev|prod|stop|logs|clean]

set "COMMAND=%~1"
if "%COMMAND%"=="" set "COMMAND=dev"

REM Colors (using echo for Windows)
set "INFO=[INFO]"
set "SUCCESS=[SUCCESS]"
set "WARNING=[WARNING]"
set "ERROR=[ERROR]"

REM Function to check if Docker is running
:check_docker
docker info >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Docker is not running. Please start Docker Desktop and try again.
    exit /b 1
)
goto :eof

REM Function to check if .env.local exists
:check_env
if not exist ".env.local" (
    echo %WARNING% .env.local not found. Creating from template...
    if exist "env.example" (
        copy "env.example" ".env.local" >nul
        echo %WARNING% Please edit .env.local with your actual values before deploying.
    ) else (
        echo %ERROR% env.example not found. Please create .env.local manually.
        exit /b 1
    )
)
goto :eof

REM Function for development deployment
:deploy_dev
echo %INFO% Starting development deployment...
call :check_docker
if errorlevel 1 exit /b 1
call :check_env
if errorlevel 1 exit /b 1

echo %INFO% Building and starting containers...
docker-compose -f docker-compose.dev.yml up --build -d
if errorlevel 1 (
    echo %ERROR% Failed to start containers
    exit /b 1
)

echo %SUCCESS% Development deployment completed!
echo %INFO% Application is running at: http://localhost:3000
echo %INFO% Health check: http://localhost:3000/api/health
echo %INFO% To view logs: deploy.bat logs
goto :eof

REM Function for production deployment
:deploy_prod
echo %INFO% Starting production deployment with nginx...
call :check_docker
if errorlevel 1 exit /b 1
call :check_env
if errorlevel 1 exit /b 1

echo %INFO% Building and starting production containers...
docker-compose -f docker-compose.prod.yml up --build -d
if errorlevel 1 (
    echo %ERROR% Failed to start production containers
    exit /b 1
)

echo %SUCCESS% Production deployment completed!
echo %INFO% Application is running at: http://localhost (port 80)
echo %INFO% Health check: http://localhost/api/health
echo %INFO% To view logs: deploy.bat logs
goto :eof

REM Function to stop containers
:stop_containers
echo %INFO% Stopping all containers...
docker-compose -f docker-compose.dev.yml down 2>nul
docker-compose -f docker-compose.prod.yml down 2>nul
echo %SUCCESS% All containers stopped!
goto :eof

REM Function to show logs
:show_logs
echo %INFO% Showing container logs (Press Ctrl+C to exit)...
REM Try to show logs from whichever compose file is running
docker-compose -f docker-compose.dev.yml ps -q >nul 2>&1
if not errorlevel 1 (
    docker-compose -f docker-compose.dev.yml logs -f
) else (
    docker-compose -f docker-compose.prod.yml ps -q >nul 2>&1
    if not errorlevel 1 (
        docker-compose -f docker-compose.prod.yml logs -f
    ) else (
        echo %WARNING% No containers are currently running
    )
)
goto :eof

REM Function to clean up
:clean_up
echo %INFO% Cleaning up Docker resources...
docker-compose -f docker-compose.dev.yml down -v --remove-orphans 2>nul
docker-compose -f docker-compose.prod.yml down -v --remove-orphans 2>nul
docker system prune -f
echo %SUCCESS% Cleanup completed!
goto :eof

REM Function to show status
:show_status
echo %INFO% Container status:
echo Development containers:
docker-compose -f docker-compose.dev.yml ps 2>nul || echo No dev containers running
echo.
echo Production containers:
docker-compose -f docker-compose.prod.yml ps 2>nul || echo No prod containers running

echo.
echo %INFO% Health check:
curl -f http://localhost:3000/api/health >nul 2>&1
if errorlevel 1 (
    echo %WARNING% Application health check failed or not running
) else (
    echo %SUCCESS% Application is healthy!
)
goto :eof

REM Function to show help
:show_help
echo Capital Marketplace Frontend - Docker Deployment Script for Windows
echo.
echo Usage: %~nx0 [COMMAND]
echo.
echo Commands:
echo   dev     Deploy for development (port 3000)
echo   prod    Deploy for production with nginx (port 80)
echo   stop    Stop all containers
echo   logs    Show container logs
echo   clean   Stop containers and clean up Docker resources
echo   status  Show container status and health
echo   help    Show this help message
echo.
echo Examples:
echo   %~nx0 dev      # Start development environment
echo   %~nx0 prod     # Start production environment
echo   %~nx0 logs     # View logs
echo   %~nx0 stop     # Stop all containers
goto :eof

REM Main script logic
if "%COMMAND%"=="dev" goto deploy_dev
if "%COMMAND%"=="prod" goto deploy_prod
if "%COMMAND%"=="stop" goto stop_containers
if "%COMMAND%"=="logs" goto show_logs
if "%COMMAND%"=="clean" goto clean_up
if "%COMMAND%"=="status" goto show_status
if "%COMMAND%"=="help" goto show_help
if "%COMMAND%"=="-h" goto show_help
if "%COMMAND%"=="--help" goto show_help

echo %ERROR% Unknown command: %COMMAND%
call :show_help
exit /b 1
