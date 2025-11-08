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
