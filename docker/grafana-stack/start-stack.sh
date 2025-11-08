#!/bin/bash
# Start HPC Monitoring Stack - Grafana Community Edition Full Stack

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Starting HPC Monitoring Stack"
echo "=========================================="

cd "$SCRIPT_DIR"

# Pull latest images
echo "Pulling latest Docker images..."
docker-compose pull

# Start the stack
echo "Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 10

# Check health
echo ""
echo "Checking service health..."

check_service() {
    local service=$1
    local url=$2
    if curl -s "$url" > /dev/null 2>&1; then
        echo "✓ $service is healthy"
    else
        echo "✗ $service is not responding"
    fi
}

check_service "Grafana" "http://localhost:3000/api/health"
check_service "Prometheus" "http://localhost:9090/-/healthy"
check_service "Loki" "http://localhost:3100/ready"
check_service "Alertmanager" "http://localhost:9093/-/healthy"

echo ""
echo "=========================================="
echo "HPC Monitoring Stack Started!"
echo "=========================================="
echo ""
echo "Services:"
echo "  Grafana:        http://localhost:3000 (admin/admin)"
echo "  Prometheus:     http://localhost:9090"
echo "  Loki:           http://localhost:3100"
echo "  Tempo:          http://localhost:3200"
echo "  Alertmanager:   http://localhost:9093"
echo ""
echo "Exporters:"
echo "  Node Exporter:  http://localhost:9100/metrics"
echo "  cAdvisor:       http://localhost:8080"
echo "  Pushgateway:    http://localhost:9091"
echo "  Blackbox:       http://localhost:9115"
echo "  SNMP:           http://localhost:9116"
echo ""
echo "Management:"
echo "  View logs:      docker-compose logs -f"
echo "  Stop stack:     docker-compose down"
echo "  Restart:        docker-compose restart"
echo "=========================================="
