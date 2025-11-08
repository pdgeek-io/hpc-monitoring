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
