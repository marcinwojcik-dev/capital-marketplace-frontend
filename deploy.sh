#!/bin/bash

# Capital Marketplace Frontend - Docker Deployment Script
# Usage: ./deploy.sh [dev|prod|stop|logs|clean]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to check if .env.local exists
check_env() {
    if [ ! -f ".env.local" ]; then
        print_warning ".env.local not found. Creating from template..."
        if [ -f "env.example" ]; then
            cp env.example .env.local
            print_warning "Please edit .env.local with your actual values before deploying."
        else
            print_error "env.example not found. Please create .env.local manually."
            exit 1
        fi
    fi
}

# Function for development deployment
deploy_dev() {
    print_status "Starting development deployment..."
    check_docker
    check_env
    
    # Inside the deploy_dev() function
    if [ -z "$JWT_SECRET" ]; then
        print_warning "JWT_SECRET not set. Using a fallback for development."
        export JWT_SECRET="your-dev-secret"
    fi


    print_status "Building and starting containers..."
    docker compose -f docker-compose.dev.yml up --build -d
    
    print_success "Development deployment completed!"
    print_status "Application is running at: http://localhost:3000"
    print_status "Health check: http://localhost:3000/api/health"
    print_status "To view logs: ./deploy.sh logs"
}

# Function for production deployment
# ... (inside deploy_prod function) ...

deploy_prod() {
    print_status "Starting production deployment with nginx..."
    check_docker
    check_env
    
    # Check if the secret is set before deploying
    if [ -z "$JWT_SECRET" ]; then
        print_error "JWT_SECRET environment variable is not set. Aborting."
        exit 1
    fi
    
    print_status "Building and starting production containers..."
    docker compose -f docker-compose.prod.yml up --build -d
    
    print_success "Production deployment completed!"
    # ...
}

# Function to stop containers
stop_containers() {
    print_status "Stopping all containers..."
    docker compose -f docker-compose.dev.yml down 2>/dev/null || true
    docker compose -f docker-compose.prod.yml down 2>/dev/null || true
    print_success "All containers stopped!"
}

# Function to show logs
show_logs() {
    print_status "Showing container logs (Press Ctrl+C to exit)..."
    # Try to show logs from whichever compose file is running
    if docker compose -f docker-compose.dev.yml ps -q | grep -q .; then
        docker compose -f docker-compose.dev.yml logs -f
    elif docker compose -f docker-compose.prod.yml ps -q | grep -q .; then
        docker compose -f docker-compose.prod.yml logs -f
    else
        print_warning "No containers are currently running"
    fi
}

# Function to clean up
clean_up() {
    print_status "Cleaning up Docker resources..."
    docker compose -f docker-compose.dev.yml down -v --remove-orphans 2>/dev/null || true
    docker compose -f docker-compose.prod.yml down -v --remove-orphans 2>/dev/null || true
    docker system prune -f
    print_success "Cleanup completed!"
}

# Function to show status
show_status() {
    print_status "Container status:"
    echo "Development containers:"
    docker compose -f docker-compose.dev.yml ps 2>/dev/null || echo "No dev containers running"
    echo ""
    echo "Production containers:"
    docker compose -f docker-compose.prod.yml ps 2>/dev/null || echo "No prod containers running"
    
    print_status "\nHealth check:"
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        print_success "Application is healthy!"
    else
        print_warning "Application health check failed or not running"
    fi
}

# Function to show help
show_help() {
    echo "Capital Marketplace Frontend - Docker Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  dev     Deploy for development (port 3000)"
    echo "  prod    Deploy for production with nginx (port 80)"
    echo "  stop    Stop all containers"
    echo "  logs    Show container logs"
    echo "  clean   Stop containers and clean up Docker resources"
    echo "  status  Show container status and health"
    echo "  help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev      # Start development environment"
    echo "  $0 prod     # Start production environment"
    echo "  $0 logs     # View logs"
    echo "  $0 stop     # Stop all containers"
}

# Main script logic
case "${1:-dev}" in
    "dev")
        deploy_dev
        ;;
    "prod")
        deploy_prod
        ;;
    "stop")
        stop_containers
        ;;
    "logs")
        show_logs
        ;;
    "clean")
        clean_up
        ;;
    "status")
        show_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
