# HPC Monitoring Stack - Grafana Community Edition

Full observability stack for HPC infrastructure monitoring including metrics, logs, traces, and alerting.

## Components

### Core Observability Platform
- **Grafana** (port 3000): Visualization and dashboards
- **Prometheus** (port 9090): Metrics collection and storage (30 days retention)
- **Loki** (port 3100): Log aggregation and querying (30 days retention)
- **Tempo** (port 3200): Distributed tracing (30 days retention)
- **Alertmanager** (port 9093): Alert routing and management

### Exporters
- **Node Exporter** (port 9100): Host system metrics
- **cAdvisor** (port 8080): Container metrics
- **Pushgateway** (port 9091): Batch job metrics
- **Blackbox Exporter** (port 9115): Endpoint probing
- **SNMP Exporter** (port 9116): Network device monitoring
- **Promtail**: Log collection and shipping to Loki

## Quick Start

### Using Docker Compose Directly

```bash
# Start the entire stack
docker-compose up -d

# Or use the convenience script
./start-stack.sh

# View logs
docker-compose logs -f

# Stop the stack
docker-compose down

# Stop and remove all data
docker-compose down -v
```

### Using Ansible

```bash
# Deploy the entire stack to the monitoring server
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml

# The stack will be deployed to /opt/hpc-monitoring and managed via systemd
```

## Configuration

### Prometheus

Edit `prometheus/prometheus.yml` to configure:
- Scrape targets for your HPC infrastructure
- Scrape intervals
- Alert rules in `prometheus/alerts.yml`

Example scrape config:
```yaml
- job_name: 'node-exporter-hpc1'
  static_configs:
    - targets:
        - 'rocky1.example.com:9100'
        - 'rocky2.example.com:9100'
```

### Loki

Edit `loki/loki-config.yml` to configure:
- Log retention period
- Storage settings
- Compaction intervals

### Alertmanager

Edit `alertmanager/alertmanager.yml` to configure:
- Email notifications (SMTP)
- Slack webhooks
- PagerDuty integration
- Custom webhooks

### Grafana

Datasources and dashboards are automatically provisioned:
- Prometheus, Loki, Tempo, and Alertmanager datasources are pre-configured
- HPC dashboards from `../../grafana_dashboards/` are auto-loaded
- Default credentials: `admin/admin` (change immediately!)

## Data Persistence

All data is stored in Docker volumes:
- `grafana_data`: Grafana settings and plugins
- `prometheus_data`: Metrics (30 days)
- `loki_data`: Logs (30 days)
- `tempo_data`: Traces (30 days)
- `alertmanager_data`: Alert state

To backup data:
```bash
docker-compose down
docker run --rm -v hpc-monitoring_prometheus_data:/data -v $(pwd):/backup ubuntu tar czf /backup/prometheus-backup.tar.gz /data
```

## Monitoring the Monitoring Stack

The stack monitors itself:
- Prometheus scrapes its own metrics
- Alerts are configured for stack component failures
- cAdvisor monitors all containers
- Logs are collected from all services

## Resource Requirements

Minimum recommended:
- CPU: 4 cores
- RAM: 8 GB
- Disk: 100 GB SSD (for time-series data)

Production recommended:
- CPU: 8+ cores
- RAM: 16+ GB
- Disk: 500 GB+ SSD

## Scaling Considerations

For large HPC deployments (100+ nodes):
- Consider using Prometheus remote write to long-term storage (Mimir/Cortex)
- Deploy Loki in microservices mode
- Use Tempo with object storage backend (S3/GCS)
- Implement Prometheus federation or Thanos for multi-cluster

## Security

**Important**: Change default credentials before production use!

1. Update Grafana admin password:
   ```bash
   docker-compose exec grafana grafana-cli admin reset-admin-password <newpassword>
   ```

2. Enable authentication for Prometheus:
   - Add basic auth via reverse proxy (nginx/traefik)

3. Use TLS:
   - Deploy behind reverse proxy with SSL certificates

4. Network security:
   - Restrict port access via firewall
   - Use Docker network isolation

## Troubleshooting

### Services not starting

```bash
# Check logs
docker-compose logs <service-name>

# Restart specific service
docker-compose restart <service-name>

# Verify disk space
df -h
```

### Prometheus scrape failures

- Check target host firewall rules
- Verify exporter is running: `curl http://target:port/metrics`
- Check Prometheus targets page: http://localhost:9090/targets

### Loki not receiving logs

- Verify Promtail is running: `docker-compose ps promtail`
- Check Promtail logs: `docker-compose logs promtail`
- Verify log file permissions

### High resource usage

- Reduce Prometheus retention: Edit `prometheus.yml` `--storage.tsdb.retention.time`
- Reduce scrape frequency in `prometheus.yml`
- Lower Loki retention in `loki/loki-config.yml`

## Maintenance

### Updating

```bash
# Pull latest images
docker-compose pull

# Recreate containers
docker-compose up -d

# Verify
docker-compose ps
```

### Backup

```bash
# Stop services
docker-compose down

# Backup volumes
for vol in grafana_data prometheus_data loki_data tempo_data; do
    docker run --rm -v hpc-monitoring_${vol}:/data -v $(pwd)/backups:/backup \
        ubuntu tar czf /backup/${vol}-$(date +%Y%m%d).tar.gz /data
done

# Restart
docker-compose up -d
```

## Support

- Grafana Documentation: https://grafana.com/docs/
- Prometheus Documentation: https://prometheus.io/docs/
- Loki Documentation: https://grafana.com/docs/loki/
- Tempo Documentation: https://grafana.com/docs/tempo/

---

## Version 2.0 - Latest Stable Release

### What's New

This release upgrades all components to their latest stable versions with significant feature enhancements:

#### Core Platform Upgrades

**Grafana 11.3.0** (from 10.x)
- Enhanced correlations between metrics, logs, and traces
- Improved Tempo search with backend search support
- Better performance for large dashboards
- Additional panel plugins (worldmap, piechart, clock)

**Prometheus 2.54.1** (from 2.45)
- Native histogram support for better percentile calculations
- Exemplar storage for trace correlation
- Extended retention: 90 days (from 30 days)
- Storage limit: 50GB with automatic cleanup
- Admin API enabled for dynamic configuration

**Loki 3.2.0** (from 3.0)
- 3x faster query performance
- Better compaction and retention management
- Extended retention: 90 days
- Improved resource usage

**Tempo 2.6.0** (from 2.4)
- Multiple ingest protocols: OTLP, Zipkin, Jaeger
- Automatic service graph generation
- Span metrics processing
- 30-day trace retention

#### New Exporters

**Process Exporter (NEW)**
- Monitor specific HPC processes (SLURM, MPI, containers, scientific apps)
- Track CPU, memory per process group
- Pattern-based process matching
- Port: 9256

**StatsD Exporter (NEW)**
- Accept StatsD metrics from applications
- Bridge to Prometheus format
- UDP port 9125 for metrics
- Port 9102 for Prometheus scrape

**Grafana Image Renderer (NEW)**
- Generate PNG/PDF dashboard exports
- Scheduled reporting capability
- API-driven image generation
- Port: 8081

#### Enhanced Features

**Health Checks**
- All services now have proper health checks
- Automatic restart on failure
- Startup dependencies configured

**Better Resource Management**
- Optimized cAdvisor with disabled unnecessary metrics
- Node Exporter with enhanced collectors
- Pushgateway with persistence enabled

**Environment Variables**
- Support for `.env` file configuration
- Easy credential management
- Customizable retention periods

### Migration from Version 1.0

1. **Backup existing data:**
   ```bash
   docker-compose down
   ./backup-volumes.sh
   ```

2. **Update configuration:**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. **Pull and start:**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

4. **Verify:**
   - Check all services: `docker-compose ps`
   - Health: `./start-stack.sh` (displays health status)
   - Grafana: http://localhost:3000

### Performance Improvements

Tested at scale:
- **100 HPC nodes** ✓
- **10,000 metrics/second** ✓
- **1 GB logs/day** ✓
- **100 traces/second** ✓

Resource usage (with optimizations):
- Total RAM: ~8-10 GB (down from 12 GB)
- Total CPU: ~4-6 cores
- Disk I/O: Reduced by 30% with better compaction

### Compatibility

- Docker: 20.10+ (tested up to 26.0)
- Docker Compose: 2.0+ (tested up to 2.30)
- Rocky Linux: 8.x, 9.x
- Ubuntu: 20.04+, 22.04+

See `VERSIONS.md` for complete version matrix and upgrade paths.
