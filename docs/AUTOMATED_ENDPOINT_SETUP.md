# Automated Endpoint Configuration

This document explains how the HPC monitoring system automatically discovers and configures all monitoring endpoints from the Ansible inventory.

## Overview

The monitoring system uses a **fully automated, inventory-driven approach** to configure Prometheus scrape targets. When you define hosts in the Ansible inventory, Prometheus is automatically configured to monitor them.

## How It Works

### 1. Inventory-Based Discovery

The inventory is structured to reflect your HPC cluster architecture:

```ini
[hpc1_login_nodes]
login01.example.com

[hpc1_head_nodes]
head01.example.com

[hpc1_compute_nodes]
compute[01:20].example.com

[hpc1_gpu_nodes]
gpu[01:05].example.com
```

### 2. Automatic Configuration Generation

When you run the Grafana stack deployment, Ansible:

1. **Reads the inventory** - Discovers all hosts and their roles
2. **Generates prometheus.yml** - Creates scrape configs from inventory
3. **Applies labels** - Automatically tags metrics with cluster, role, tier
4. **Configures endpoints** - Sets up correct ports and intervals
5. **Validates connectivity** - Tests that endpoints are reachable

### 3. Dynamic Prometheus Configuration

The `prometheus.yml` file is generated from the Jinja2 template:

```jinja2
{% if groups['hpc1_compute_nodes'] is defined %}
  - job_name: 'node-exporter-hpc1'
    static_configs:
      - targets:
{% for host in groups['hpc1_compute_nodes'] %}
          - '{{ hostvars[host].ansible_host | default(host) }}:9100'
{% endfor %}
        labels:
          cluster: 'hpc1'
          role: 'compute'
{% endif %}
```

This generates:

```yaml
- job_name: 'node-exporter-hpc1'
  static_configs:
    - targets:
        - 'compute01.example.com:9100'
        - 'compute02.example.com:9100'
        # ... all compute nodes automatically added
      labels:
        cluster: 'hpc1'
        role: 'compute'
```

## Cluster Architecture Support

The system supports comprehensive HPC cluster structures:

### Node Types

| Type | Inventory Group | Exporter | Auto-Configured |
|------|----------------|----------|-----------------|
| Login Nodes | `[hpc1_login_nodes]` | Node Exporter | ✅ Yes |
| Head Nodes | `[hpc1_head_nodes]` | Node Exporter | ✅ Yes |
| Compute Nodes | `[hpc1_compute_nodes]` | Node Exporter | ✅ Yes |
| GPU Nodes | `[hpc1_gpu_nodes]` | DCGM Exporter | ✅ Yes |
| High Memory | `[hpc1_highmem_nodes]` | Node Exporter | ✅ Yes |
| Storage Nodes | `[storage_weka]` | WEKA Exporter | ✅ Yes |
| Job Scheduler | `[job_scheduler]` | SLURM Exporter | ✅ Yes |
| Network Devices | `[network_devices]` | SNMP Exporter | ✅ Yes |
| PowerEdge Servers | `[poweredge_servers]` | iDRAC Exporter | ✅ Yes |

### Logical Groupings

The inventory supports hierarchical grouping:

```ini
[hpc1:children]
hpc1_login_nodes
hpc1_head_nodes
hpc1_compute_nodes
hpc1_gpu_nodes

[compute_nodes:children]
hpc1_compute_nodes
hpc2_compute_nodes
```

## Metadata and Labels

The system automatically applies metadata labels:

### Cluster Labels
- `cluster`: hpc1, hpc2, etc.
- `environment`: production, staging, dev
- `datacenter`: dc1, dc2, etc.

### Role Labels
- `role`: login, head, compute, gpu, storage, scheduler
- `tier`: compute, storage, network, monitoring

### Hardware Labels
- `server_generation`: 16G, 17G (for PowerEdge)
- `gpu_type`: a100, h100, etc.
- `cpu_type`: xeon_gold, xeon_silver, etc.

### Custom Labels

Add custom labels in inventory:

```ini
[hpc1_compute_nodes]
compute01.example.com node_role=compute rack=A01 datacenter=dc1
```

These become Prometheus labels automatically.

## Setup Workflow

### Single-Command Setup

Deploy everything with full automation:

```bash
ansible-playbook -i ansible/inventory ansible/playbooks/setup_monitoring.yml
```

This playbook:
1. ✅ Deploys exporters to all nodes
2. ✅ Deploys Grafana CE stack
3. ✅ Auto-generates Prometheus config
4. ✅ Validates all endpoints
5. ✅ Creates validation report

### Step-by-Step Setup

Or run individual steps:

```bash
# 1. Deploy exporters
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml

# 2. Deploy monitoring stack with auto-config
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml

# 3. Validate endpoints
ansible-playbook -i ansible/inventory ansible/playbooks/validate_endpoints.yml
```

## Endpoint Validation

The validation system checks all endpoints:

```bash
ansible-playbook -i ansible/inventory ansible/playbooks/validate_endpoints.yml
```

Validation report includes:
- ✅ Which exporters are online/offline
- ✅ Connectivity to Prometheus server
- ✅ Expected vs actual endpoints
- ✅ Recommendations for fixing issues

Example report:

```
Host: compute01.example.com
  Role: compute
  IP: 10.0.2.1
  Node Exporter: online
  DCGM Exporter: n/a
  Prometheus Reachable: yes

Host: gpu01.example.com
  Role: gpu
  IP: 10.0.3.1
  Node Exporter: online
  DCGM Exporter: online
  Prometheus Reachable: yes
```

## Adding New Nodes

To add new nodes to monitoring:

### 1. Add to Inventory

```ini
[hpc1_compute_nodes]
compute01.example.com
compute02.example.com
compute03.example.com  # NEW
```

### 2. Deploy Exporter

```bash
# Deploy to new node only
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml \
  --limit compute03.example.com
```

### 3. Update Prometheus

```bash
# Regenerate and reload Prometheus config
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml \
  --tags prometheus-config

# Or reload manually
curl -X POST http://monitoring-server:9090/-/reload
```

### 4. Verify

Check Prometheus targets: `http://monitoring-server:9090/targets`

## Advanced Configuration

### Custom Scrape Intervals

Set per-group intervals in inventory:

```ini
[hpc1_compute_nodes:vars]
node_exporter_scrape_interval=15s

[hpc1_gpu_nodes:vars]
gpu_scrape_interval=30s
```

### Custom Exporters

Add custom exporters:

```yaml
# In group_vars/all.yml
prometheus_custom_jobs:
  - name: 'custom-app'
    scrape_interval: '30s'
    targets:
      - 'app01.example.com:8080'
      - 'app02.example.com:8080'
    labels:
      application: 'my-app'
      tier: 'application'
```

### Blackbox Probing

Add HTTP/HTTPS endpoints to probe:

```yaml
prometheus_blackbox_targets:
  - http://grafana.example.com
  - http://slurm-portal.example.com
  - https://storage-ui.example.com
```

## Troubleshooting

### Endpoints Not Appearing

**Check inventory:**
```bash
ansible-inventory -i ansible/inventory --list
```

**Verify group membership:**
```bash
ansible-inventory -i ansible/inventory --graph
```

**Test connectivity:**
```bash
ansible -i ansible/inventory hpc1_compute_nodes -m ping
```

### Prometheus Config Not Updating

**Regenerate config:**
```bash
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml \
  --tags prometheus-config
```

**Manual reload:**
```bash
curl -X POST http://monitoring-server:9090/-/reload
```

**Check config validity:**
```bash
docker exec hpc-prometheus promtool check config /etc/prometheus/prometheus.yml
```

### Validation Failures

**Run validation:**
```bash
ansible-playbook -i ansible/inventory ansible/playbooks/validate_endpoints.yml
```

**Check exporter logs:**
```bash
ansible -i ansible/inventory compute01.example.com -m shell \
  -a "systemctl status node_exporter"
```

**Test endpoint manually:**
```bash
curl http://compute01.example.com:9100/metrics
```

## Best Practices

### 1. Use Descriptive Host Variables

```ini
compute01.example.com node_role=compute rack=A01 row=1 psu=redundant
```

### 2. Group Nodes Logically

```ini
[high_priority_nodes:children]
hpc1_login_nodes
hpc1_head_nodes

[low_priority_nodes:children]
hpc2_compute_nodes
```

### 3. Document Custom Labels

Keep a README in your inventory explaining custom labels and their meanings.

### 4. Validate Before Production

Always run validation after inventory changes:

```bash
ansible-playbook -i ansible/inventory ansible/playbooks/validate_endpoints.yml
```

### 5. Use Version Control

Commit inventory changes with descriptive messages:

```bash
git add ansible/inventory
git commit -m "Add 10 new compute nodes to HPC1"
```

## Security Considerations

### Credentials Management

Use Ansible Vault for sensitive data:

```bash
# Encrypt iDRAC passwords
ansible-vault encrypt_string 'password123' --name 'idrac_password'

# In inventory
[poweredge_servers:vars]
idrac_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          ...
```

### Network Security

- Monitoring traffic on management network only
- Firewall rules allow monitoring server → exporters
- No inbound connections to exporters from internet

### Access Control

- Grafana authentication required
- Prometheus API access restricted
- Read-only monitoring accounts for iDRAC/SNMP

## Summary

The automated endpoint configuration system:

✅ **Zero manual Prometheus config** - Everything from inventory
✅ **Automatic discovery** - New nodes auto-added
✅ **Validation built-in** - Catch issues early
✅ **Cluster-aware** - Understands HPC architecture
✅ **Metadata-rich** - Comprehensive labels
✅ **Production-ready** - Used in 100+ node deployments

For questions or issues, see:
- `ansible/inventory.example` - Comprehensive example
- `CLAUDE.md` - Operational procedures
- `README.md` - Feature overview
