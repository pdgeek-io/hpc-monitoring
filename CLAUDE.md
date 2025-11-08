# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an HPC (High-Performance Computing) monitoring infrastructure repository that uses Ansible to deploy Prometheus exporters across HPC components, and Docker Compose to deploy a Grafana/Prometheus visualization stack. The system monitors compute nodes, GPUs, job schedulers (SLURM), and storage systems (WEKA).

## Key Commands

### Ansible Playbook Deployment

Deploy monitoring exporters to HPC infrastructure:
```bash
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_monitoring.yml
```

Deploy Grafana/Prometheus stack via Docker Compose:
```bash
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml
```

Target specific host groups:
```bash
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_monitoring.yml --limit hpc1
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_monitoring.yml --limit gpu_nodes
```

### Docker Compose

Manual Grafana stack deployment (if not using Ansible):
```bash
cd docker/grafana-stack
docker-compose up -d
docker-compose down
docker-compose logs -f
```

### Testing and Validation

Check exporter endpoints after deployment:
```bash
curl http://<target-host>:9100/metrics  # Node Exporter
curl http://<target-host>:9400/metrics  # DCGM Exporter (GPU)
curl http://<target-host>:9091/metrics  # SLURM Exporter
```

Verify Ansible syntax:
```bash
ansible-playbook --syntax-check -i ansible/inventory ansible/playbooks/hpc_monitoring.yml
```

## Architecture

### Component Mapping

The monitoring stack follows a standard Prometheus exporter pattern:
- **Compute Nodes (Rocky Linux)** → Node Exporter (port 9100): CPU, memory, I/O, network metrics with Rocky Linux optimization
- **GPU Nodes** → NVIDIA DCGM Exporter (port 9400): GPU performance metrics
- **Job Scheduler** → SLURM Exporter (port 9091): Job queue and scheduling metrics
- **Storage** → WEKA Exporter: Storage performance and utilization
- **Dell PowerEdge Servers** → iDRAC Redfish Exporter (port 9610): Hardware health, power consumption, cooling/thermal, memory, CPU, RAID, PSU, fans

Additional exporters available but not in main playbook:
- NSight Exporter
- SNMP Exporter
- VTune Exporter
- UFM Exporter (InfiniBand fabric manager)
- Dell ECS Exporter (for Dell ECS storage)

### Ansible Role Structure

Each exporter follows a consistent pattern:
```
ansible/roles/<exporter_name>/
├── defaults/main.yml    # Configurable variables (version, ports, URLs)
├── tasks/main.yml       # Installation and service setup tasks
└── templates/           # Systemd service templates (*.service.j2)
```

Roles typically:
1. Create a system user for the exporter
2. Download and extract the exporter binary
3. Deploy a systemd service from a Jinja2 template
4. Enable and start the service

### Inventory Structure

The `ansible/inventory` file defines host groups that map to different HPC components:
- `[hpc1]`, `[hpc2]`: Compute node clusters (Rocky Linux)
- `[gpu_nodes]`: GPU-equipped nodes
- `[job_scheduler]`: SLURM scheduler host
- `[storage_weka]`: WEKA storage nodes
- `[poweredge_servers]`: Dell PowerEdge servers for hardware monitoring via iDRAC
- `[grafana]`: Grafana/Prometheus stack host

### Grafana Integration

Pre-built dashboards are in `grafana_dashboards/`:
- `hardware_dashboard.json`: Hardware-level metrics
- `hpc_dashboard.json`: Combined HPC metrics
- `hpc_fullstack_dashboard.json`: Full-stack overview
- `hpc_job_dashboard.json`: Job scheduler metrics
- `poweredge_hardware_dashboard.json`: Dell PowerEdge hardware monitoring (health, power, cooling, memory, CPU, storage)

The Grafana stack (docker-compose.yml) deploys:
- Grafana on port 3000 (default admin/admin)
- Prometheus on port 9090
- Requires `prometheus.yml` configuration for scrape targets

## Configuration

### Adding New Hosts

1. Update `ansible/inventory` with target hosts in appropriate groups
2. Run the appropriate playbook

### Customizing Exporter Settings

Modify variables in `ansible/roles/<exporter>/defaults/main.yml`:
- Exporter version
- Download URLs
- Installation paths
- Service ports
- User/group settings

### Prometheus Configuration

The Grafana stack role expects `prometheus.yml` to exist at `docker/grafana-stack/prometheus.yml` for configuring Prometheus scrape targets. This file is referenced in the docker-compose.yml volume mount but not tracked in the repository.

## Rocky Linux Support

The Node Exporter role is fully optimized for Rocky Linux 8/9:
- Enhanced systemd service with Rocky Linux-specific collectors
- Security hardening (NoNewPrivileges, ProtectHome, ProtectSystem)
- Additional collectors enabled: systemd, processes, cpu.info, diskstats, filesystem, loadavg, meminfo, netdev, netstat, vmstat
- Automatic OS detection during deployment

## Dell PowerEdge Hardware Monitoring

### iDRAC Exporter Configuration

The iDRAC exporter monitors Dell PowerEdge servers using the Redfish API. Key features:
- **Health Monitoring**: Overall system health status
- **Power**: Real-time power consumption and PSU capacity
- **Thermal**: Temperature sensors across all components
- **Cooling**: Fan speeds and status
- **Compute**: CPU utilization per processor
- **Memory**: DIMM health and status
- **Storage**: RAID controller and drive status

### Configuring iDRAC Credentials

Edit `ansible/roles/idrac_exporter/defaults/main.yml` to set iDRAC connection details:

```yaml
idrac_hosts:
  - host: "idrac1.example.com"
    username: "monitor"
    password: "your_password"
  - host: "idrac2.example.com"
    username: "monitor"
    password: "your_password"
```

**Security Note**: For production, use Ansible Vault to encrypt credentials:
```bash
ansible-vault encrypt_string 'your_password' --name 'password'
```

### iDRAC User Setup

Create a read-only monitoring user in iDRAC:
1. Log into iDRAC web interface
2. Navigate to Users → Add New User
3. Set username (e.g., "monitor")
4. Assign "Read Only" privilege level
5. Enable user account

## HPC Full-Stack Monitoring Solution

### Unified Monitoring Architecture

This repository now includes a comprehensive unified monitoring solution that wraps around:
- **WEKA**: Distributed parallel filesystem
- **MooseFS**: Distributed fault-tolerant filesystem
- **SLURM**: HPC job scheduler and resource manager
- **Rocky Linux**: Enterprise Linux compute nodes

Use the `hpc_fullstack_monitoring.yml` playbook for complete deployment:
```bash
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml
```

### MooseFS Monitoring

The MooseFS exporter (port 9105) monitors:
- Master server status and health
- Total/available/used filesystem space
- Chunk server count and status
- Connected clients
- Files and directories count
- Read/write operations

Configuration: `ansible/roles/moosefs_exporter/defaults/main.yml`

### Generational Hardware Comparison

The monitoring system supports tracking and comparing different hardware generations (e.g., Dell PowerEdge 16G vs 17G):

1. Tag servers in inventory with generation metadata:
   ```ini
   poweredge1.example.com  # gen=16G
   poweredge2.example.com  # gen=17G
   ```

2. Use Grafana to compare metrics across generations for:
   - Performance differences
   - Power efficiency improvements
   - Thermal characteristics
   - CPU feature availability (AVX, AVX2, AVX-512)

### CPU Extended Features Monitoring

Node Exporter on Rocky Linux includes CPU feature detection for:
- AVX (Advanced Vector Extensions)
- AVX2
- AVX-512
- SSE, SSE2, SSE3, SSE4
- AES-NI
- Hardware virtualization (VT-x, AMD-V)

Access via: `node_cpu_info` metric with labels for CPU features

### Job Operations Monitoring

SLURM exporter provides comprehensive job monitoring:
- Pending, running, completed, failed jobs
- Queue wait times
- Resource utilization per job
- Node allocation status
- Partition performance metrics

Use the unified dashboard (`hpc_unified_fullstack_dashboard.json`) for complete visibility.

### Deployment Tags

The full-stack playbook supports granular deployment via tags:
- `compute`: Rocky Linux nodes only
- `gpu`: GPU nodes only
- `slurm`, `scheduler`, `jobs`: SLURM monitoring
- `weka`, `moosefs`, `storage`, `filesystem`: Storage systems
- `poweredge`, `idrac`, `hardware`, `dell`: PowerEdge hardware
- `baseline`: Essential compute monitoring

Example:
```bash
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml --tags storage,slurm
```
