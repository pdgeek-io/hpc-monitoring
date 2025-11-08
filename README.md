# HPC Monitoring

This repository configures HPC components to export performance metrics to Prometheus and visualize them in Grafana. It uses Ansible to deploy and configure exporters across your HPC environment.

## Components and Exporters

Below is a list of components and their corresponding exporters/integrations:

<table>
  <tr>
    <th>Component</th>
    <th>Exporter/Integration</th>
    <th>Purpose</th>
  </tr>
  <tr>
    <td>Compute Nodes (Rocky Linux)</td>
    <td>Node Exporter</td>
    <td>Monitor CPU, Memory, IO Wait, Storage Utilization, and Network Performance</td>
  </tr>
  <tr>
    <td>GPUs</td>
    <td>Nvidia DCGM Exporter</td>
    <td>Monitor GPU performance and related metrics</td>
  </tr>
  <tr>
    <td>Job Scheduler (SLURM)</td>
    <td>SLURM Exporter</td>
    <td>Gather HPC job and queue performance statistics</td>
  </tr>
  <tr>
    <td>Storage (WEKA Environment)</td>
    <td>WEKA Exporter</td>
    <td>Monitor storage performance and utilization</td>
  </tr>
  <tr>
    <td>Dell PowerEdge Servers</td>
    <td>iDRAC Redfish Exporter</td>
    <td>Monitor hardware health, power consumption, cooling/thermal, memory, CPU, RAID, PSU, and fans via iDRAC</td>
  </tr>
</table>

## Repository Structure

Below is the repository structure:

<pre>
.
├── ansible
│   ├── inventory
│   ├── playbooks
│   │   ├── hpc_monitoring.yml
│   │   └── grafana_stack.yml
│   └── roles
│       ├── node_exporter          (Rocky Linux optimized)
│       ├── nvidia_dcgm_exporter
│       ├── slurm_exporter
│       ├── wekafs_exporter
│       ├── idrac_exporter          (NEW - Dell PowerEdge monitoring)
│       └── grafana_stack
├── docker
│   └── grafana-stack
│       └── docker-compose.yml
└── grafana_dashboards
    ├── hardware_dashboard.json
    ├── hpc_dashboard.json
    ├── hpc_job_dashboard.json
    ├── hpc_fullstack_dashboard.json
    └── poweredge_hardware_dashboard.json  (NEW - PowerEdge monitoring)
</pre>

## Usage

1. **Inventory Update:**  
   Update the `ansible/inventory` file with your target hostnames for each group (e.g., HPC clusters, GPU nodes, job scheduler, WEKA storage, and Grafana host).

2. **Customize Variables:**  
   Adjust exporter-specific variables in the defaults files under `ansible/roles/`.

3. **Deploy Monitoring Agents:**  
   Run the following playbook to deploy the monitoring agents on your HPC hosts:
   ```bash
   ansible-playbook -i ansible/inventory ansible/playbooks/hpc_monitoring.yml
   ```

4. **Deploy Grafana Stack:**
   Run the following playbook to deploy Grafana and Prometheus:
   ```bash
   ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml
   ```

## Dell PowerEdge Hardware Monitoring

The repository now includes comprehensive Dell PowerEdge server monitoring via iDRAC using the Redfish API.

### What's Monitored

The iDRAC exporter provides detailed hardware health metrics:
- **System Health**: Overall hardware health status
- **Power Consumption**: Real-time power usage and PSU capacity
- **Thermal**: Temperature sensors across all components
- **Cooling**: Fan speeds and operational status
- **CPU**: Per-processor utilization metrics
- **Memory**: DIMM health and status for all memory modules
- **Storage**: RAID controller and individual drive status
- **PSU**: Power supply unit status and metrics

### Setup Instructions

1. **Add PowerEdge Servers to Inventory:**
   Edit `ansible/inventory` and add your Dell PowerEdge server hostnames to the `[poweredge_servers]` group.

2. **Configure iDRAC Credentials:**
   Edit `ansible/roles/idrac_exporter/defaults/main.yml` and update the `idrac_hosts` list with your iDRAC IP addresses and credentials:
   ```yaml
   idrac_hosts:
     - host: "idrac1.yourdomain.com"
       username: "monitor"
       password: "your_password"
   ```

3. **Create iDRAC Monitoring User (Recommended):**
   - Log into each iDRAC web interface
   - Create a new user with "Read Only" privileges
   - Use these credentials in the configuration above

4. **Deploy the Exporter:**
   ```bash
   ansible-playbook -i ansible/inventory ansible/playbooks/hpc_monitoring.yml --limit poweredge_servers
   ```

5. **Import Dashboard:**
   Import `grafana_dashboards/poweredge_hardware_dashboard.json` into Grafana to visualize PowerEdge metrics.

### Security Note

For production environments, encrypt iDRAC passwords using Ansible Vault:
```bash
ansible-vault encrypt_string 'your_password' --name 'password'
```

## Rocky Linux Support

The Node Exporter role has been optimized for Rocky Linux 8 and 9:

- **Enhanced Metrics Collection**: Additional collectors enabled (systemd, processes, cpu.info, diskstats, filesystem, loadavg, meminfo, netdev, netstat, vmstat)
- **Security Hardening**: Systemd service includes NoNewPrivileges, ProtectHome, and ProtectSystem
- **Automatic Detection**: Playbook automatically detects Rocky Linux and applies appropriate configurations
- **Full Compatibility**: Tested and verified on Rocky Linux 8.x and 9.x

The existing `node_exporter` role works seamlessly on Rocky Linux compute nodes without any additional configuration.

## HPC Full-Stack Unified Monitoring

The repository includes a comprehensive unified monitoring solution that provides complete visibility into your HPC infrastructure.

### Integrated Components

- **Rocky Linux Compute Nodes**: CPU, memory, I/O, network, and extended CPU features
- **SLURM Job Scheduler**: Job queues, operations, and resource utilization
- **WEKA Distributed Filesystem**: Storage capacity, performance, and I/O operations
- **MooseFS Distributed Filesystem**: Master/chunk servers, clients, space utilization
- **Dell PowerEdge Hardware**: Health, power, thermal, memory, CPU, RAID via iDRAC
- **NVIDIA GPUs**: GPU performance metrics via DCGM

### Quick Start - Full-Stack Deployment

Deploy the entire monitoring stack with a single command:

```bash
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml
```

### Selective Deployment with Tags

Deploy only specific components:

```bash
# Deploy only compute node and storage monitoring
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml --tags compute,storage

# Deploy only job scheduler monitoring
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml --tags slurm

# Deploy only PowerEdge hardware monitoring
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml --tags poweredge
```

### Available Tags

- `compute`: Rocky Linux compute nodes
- `gpu`: NVIDIA GPU nodes
- `slurm`, `scheduler`, `jobs`: SLURM job scheduler
- `weka`, `moosefs`, `storage`, `filesystem`: Storage systems
- `poweredge`, `idrac`, `hardware`, `dell`: PowerEdge servers
- `baseline`: Essential compute monitoring

### Unified Dashboard

Import `grafana_dashboards/hpc_unified_fullstack_dashboard.json` for complete HPC infrastructure visualization including:

- Infrastructure health overview
- Compute node performance (CPU, memory, network)
- SLURM job queue status and trends
- WEKA and MooseFS storage metrics
- Cross-component correlation

### Monitoring Endpoints

After deployment, metrics are available at:

| Component | Port | Endpoint |
|-----------|------|----------|
| Node Exporter (Rocky Linux) | 9100 | http://host:9100/metrics |
| NVIDIA DCGM | 9400 | http://host:9400/metrics |
| SLURM Exporter | 9091 | http://host:9091/metrics |
| WEKA Exporter | 9101 | http://host:9101/metrics |
| MooseFS Exporter | 9105 | http://host:9105/metrics |
| iDRAC Exporter | 9610 | http://host:9610/metrics |

## MooseFS Monitoring Setup

### Prerequisites

MooseFS should be installed and running on your master and chunk servers.

### Configuration

1. **Add MooseFS Servers to Inventory:**
   ```ini
   [storage_moosefs]
   moosefs-master.example.com
   moosefs-chunk1.example.com
   moosefs-chunk2.example.com
   ```

2. **Configure MooseFS Master Connection:**
   Edit `ansible/roles/moosefs_exporter/defaults/main.yml`:
   ```yaml
   moosefs_master_host: "moosefs-master.example.com"
   moosefs_master_port: 9421
   ```

3. **Deploy:**
   ```bash
   ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml --tags moosefs
   ```

### Metrics Collected

- Total/available/used/trash filesystem space
- Number of chunk servers (total and online)
- Total chunks
- Files and directories count
- Read/write operations
- Connected clients

## Hardware Generational Comparison

Track and compare performance across different hardware generations (e.g., Dell PowerEdge 16G vs 17G):

### Setup

1. **Tag Servers by Generation in Inventory:**
   ```ini
   [poweredge_servers]
   poweredge-16g-01.example.com  # gen=16G
   poweredge-17g-01.example.com  # gen=17G
   ```

2. **Enable CPU Features Monitoring:**
   The Node Exporter role automatically deploys a CPU features collector that tracks:
   - AVX, AVX2, AVX-512 (Foundation, DQ, BW, VL, VNNI)
   - AES-NI encryption instructions
   - SSE4.2
   - FMA (Fused Multiply-Add)
   - BMI1/BMI2 (Bit Manipulation Instructions)
   - Hardware virtualization support

3. **Query in Grafana:**
   Use `node_cpu_feature` metrics to compare feature availability:
   ```promql
   node_cpu_feature{feature="avx512_vnni"}
   ```

### Research Use Cases

- **Performance Analysis**: Compare job execution times across generations
- **Feature Adoption**: Track which nodes support newer instruction sets
- **Upgrade Planning**: Identify which workloads benefit from newer hardware
- **Power Efficiency**: Compare power consumption for same workload across generations

## Job Operations Monitoring

SLURM integration provides comprehensive job and operations monitoring:

### Metrics Available

- Pending jobs by partition
- Running jobs by partition
- Completed and failed jobs
- Queue wait times
- Node allocation and utilization
- Resource consumption per job

### Dashboard Usage

The unified dashboard shows:
- Real-time job queue status table
- Job trends over time (running vs pending)
- Cross-correlation with compute node resource usage
- Storage I/O patterns during job execution

Query example for jobs research:
```promql
# Average queue wait time
rate(slurm_queue_jobs_pending[5m])

# Job completion rate
rate(slurm_jobs_completed_total[5m])
```

This enables researchers to:
- Understand scheduler behavior
- Optimize job submission strategies
- Identify bottlenecks in the HPC pipeline
- Correlate job patterns with resource utilization

---

# 🚀 Docker-Based Deployment (Recommended)

## Grafana Community Edition Full Stack

The monitoring stack has been upgraded to run as Docker containers with the complete Grafana CE observability platform.

### What's Included

**Full Observability Stack:**
- ✅ **Grafana**: Dashboards and visualization
- ✅ **Prometheus**: Metrics collection and 30-day retention
- ✅ **Loki**: Log aggregation with 30-day retention
- ✅ **Tempo**: Distributed tracing for 30 days
- ✅ **Alertmanager**: Intelligent alert routing
- ✅ **Promtail**: Automatic log collection

**Built-in Exporters:**
- ✅ Node Exporter (host metrics)
- ✅ cAdvisor (container metrics)
- ✅ Pushgateway (batch jobs)
- ✅ Blackbox Exporter (endpoint probing)
- ✅ SNMP Exporter (network devices/iDRAC)

### Quick Deployment

#### Option 1: Ansible (Production)

```bash
# Deploy to monitoring server defined in inventory
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml

# Stack deployed to /opt/hpc-monitoring with systemd integration
# Manage with: systemctl status hpc-monitoring-stack
```

#### Option 2: Docker Compose (Development/Testing)

```bash
cd docker/grafana-stack

# Start everything
./start-stack.sh

# Or manually
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

### Access Points

After deployment, access services at:

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | http://your-server:3000 | admin/admin |
| Prometheus | http://your-server:9090 | - |
| Loki | http://your-server:3100 | - |
| Tempo | http://your-server:3200 | - |
| Alertmanager | http://your-server:9093 | - |

**⚠️ Change default Grafana password immediately!**

### Configuration

#### Update Prometheus Targets

Edit `docker/grafana-stack/prometheus/prometheus.yml` to add your HPC nodes:

```yaml
- job_name: 'node-exporter-hpc1'
  static_configs:
    - targets:
        - 'rocky1.example.com:9100'
        - 'rocky2.example.com:9100'
```

#### Configure Alerts

Add notification channels in `docker/grafana-stack/alertmanager/alertmanager.yml`:

```yaml
receivers:
  - name: 'email'
    email_configs:
      - to: 'team@example.com'
        from: 'alerts@example.com'
        smarthost: 'smtp.example.com:587'
```

#### Adjust Retention

Edit retention periods in respective config files:
- Prometheus: `--storage.tsdb.retention.time=30d` in docker-compose.yml
- Loki: `retention_period: 30d` in loki-config.yml
- Tempo: `block_retention: 720h` in tempo.yml

### Architecture

```
┌─────────────────────────────────────────────────────┐
│         Monitoring Server (Docker Host)              │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ Grafana  │  │Prometheus│  │   Loki   │          │
│  │  :3000   │  │  :9090   │  │  :3100   │          │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘          │
│       │             │               │                │
│  ┌────┴─────┐  ┌───┴──────┐  ┌────┴─────┐          │
│  │  Tempo   │  │Alertmgr  │  │ Promtail │          │
│  │  :3200   │  │  :9093   │  │          │          │
│  └──────────┘  └──────────┘  └──────────┘          │
│                                                      │
│  Local Exporters:                                   │
│  • Node Exporter :9100                              │
│  • cAdvisor :8080                                   │
│  • Pushgateway :9091                                │
│  • Blackbox :9115                                   │
│  • SNMP :9116                                       │
└─────────────────────────────────────────────────────┘
                       │
                       │ Scrapes metrics from
                       ▼
┌─────────────────────────────────────────────────────┐
│              HPC Infrastructure                      │
│                                                      │
│  Rocky Linux Nodes → Node Exporter :9100            │
│  GPU Nodes → DCGM Exporter :9400                    │
│  SLURM → SLURM Exporter :9091                       │
│  WEKA → WEKA Exporter :9101                         │
│  MooseFS → MooseFS Exporter :9105                   │
│  PowerEdge → iDRAC Exporter :9610                   │
└─────────────────────────────────────────────────────┘
```

### Data Persistence

All data stored in Docker volumes:
```bash
# List volumes
docker volume ls | grep hpc-monitoring

# Backup volumes
docker-compose down
docker run --rm -v hpc-monitoring_prometheus_data:/data \
    -v $(pwd)/backups:/backup ubuntu \
    tar czf /backup/prometheus-$(date +%Y%m%d).tar.gz /data

# Restore
docker run --rm -v hpc-monitoring_prometheus_data:/data \
    -v $(pwd)/backups:/backup ubuntu \
    tar xzf /backup/prometheus-YYYYMMDD.tar.gz -C /
```

### Resource Requirements

**Minimum (Testing):**
- CPU: 4 cores
- RAM: 8 GB
- Disk: 100 GB SSD

**Recommended (Production):**
- CPU: 8+ cores
- RAM: 16+ GB
- Disk: 500 GB+ SSD

### Integrated Observability

The stack provides complete observability with:

1. **Metrics** (Prometheus)
   - All HPC infrastructure metrics
   - 30-day retention
   - PromQL queries

2. **Logs** (Loki)
   - System logs, application logs, SLURM logs
   - Log correlation with metrics
   - LogQL queries

3. **Traces** (Tempo)
   - Distributed application tracing
   - Integration with logs and metrics
   - Performance analysis

4. **Dashboards** (Grafana)
   - Pre-built HPC dashboards
   - Auto-provisioned datasources
   - Unified view of metrics, logs, traces

5. **Alerts** (Alertmanager)
   - HPC-specific alert rules
   - Multi-channel notifications
   - Intelligent alert grouping

### Troubleshooting

**Services won't start:**
```bash
# Check logs
docker-compose logs <service-name>

# Verify disk space
df -h

# Check ports
sudo netstat -tlnp | grep -E '3000|9090|3100|3200|9093'
```

**High memory usage:**
- Reduce Prometheus scrape intervals
- Lower retention periods
- Add more RAM

**Missing metrics:**
- Verify Prometheus targets: http://your-server:9090/targets
- Check exporter accessibility: `curl http://target:port/metrics`
- Review firewall rules

See `docker/grafana-stack/README.md` for comprehensive documentation.

---

# 📈 Version 2.0 - Latest Stable

## Major Version Upgrades

All components have been upgraded to their latest stable versions:

| Component | Old Version | New Version | Key Improvements |
|-----------|-------------|-------------|------------------|
| Grafana | 10.x | **11.3.0** | Better correlations, faster dashboards |
| Prometheus | 2.45 | **2.54.1** | Native histograms, 90-day retention |
| Loki | 3.0 | **3.2.0** | 3x faster queries, 90-day retention |
| Tempo | 2.4 | **2.6.0** | Multi-protocol ingest, service graphs |
| Node Exporter | 1.5.0 | **1.8.2** | More collectors, better accuracy |
| NVIDIA DCGM | 2.4.10 | **3.3.9** | H100 support, better metrics |

## New Features

### 🎯 Process Monitoring
Track specific HPC processes (SLURM, MPI, scientific apps) with the new **Process Exporter**

### 📊 StatsD Support
Applications can now send metrics via StatsD protocol (UDP 9125)

### 🖼️ Dashboard Exports
Generate PNG/PDF reports automatically with **Grafana Image Renderer**

### ⚡ Performance Gains
- **3x faster** log queries (Loki 3.2)
- **90-day retention** for metrics and logs (from 30 days)
- **50GB storage cap** with auto-cleanup
- **Native histograms** for accurate percentiles

### 🔗 Better Integration
- Enhanced trace-to-logs correlation
- Automatic service graph generation
- Improved Tempo backend search

## Upgrade Instructions

### Quick Upgrade

```bash
# Backup first!
cd docker/grafana-stack
docker-compose down
docker-compose pull
docker-compose up -d
```

### With Environment Variables

```bash
# Copy and customize
cp docker/grafana-stack/.env.example docker/grafana-stack/.env
vim docker/grafana-stack/.env

# Deploy
cd docker/grafana-stack
docker-compose up -d
```

### Via Ansible

```bash
# Automatically pulls latest versions
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml
```

## What's Included Now

### Core Platform
- Grafana 11.3.0
- Prometheus 2.54.1 (90d retention, 50GB cap)
- Loki 3.2.0 (90d retention, 3x faster)
- Tempo 2.6.0 (30d retention, multi-protocol)
- Alertmanager 0.27.0

### Exporters (14 total)
- Node Exporter 1.8.2
- cAdvisor 0.49.1
- Pushgateway 1.9.0
- Blackbox 0.25.0
- SNMP 0.26.0
- **Process Exporter 0.8.3** ⭐ NEW
- **StatsD Exporter 0.27.1** ⭐ NEW
- **Image Renderer 3.11.3** ⭐ NEW

## Breaking Changes

None - this is a backward-compatible upgrade. All existing dashboards, alerts, and configurations continue to work.

## Full Details

See `VERSIONS.md` for:
- Complete version matrix
- Compatibility information
- Detailed upgrade paths
- Rollback procedures
- Performance benchmarks
