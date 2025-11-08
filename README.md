```
 __  __ ____   ____   __  __             _ _             _
|  \/  |  _ \ / ___| |  \/  | ___  _ __ (_) |_ ___  _ __(_)_ __   __ _
| |\/| | |_) | |     | |\/| |/ _ \| '_ \| | __/ _ \| '__| | '_ \ / _` |
| |  | |  __/| |___  | |  | | (_) | | | | | || (_) | |  | | | | | (_| |
|_|  |_|_|    \____| |_|  |_|\___/|_| |_|_|\__\___/|_|  |_|_| |_|\__, |
                                                                   |___/
   _____ _    _ _      _         _____ _             _
  |  ___| |  | | |    / |       / ____| |           | |
  | |_  | |  | | |    | |______| (___ | |_ __ _  ___| | __
  |  _| | |  | | |    | |______|\___ \| __/ _` |/ __| |/ /
  | |   | |__| | |____| |       ____) | || (_| | (__|   <
  |_|    \____/|______|_|      |_____/ \__\__,_|\___|_|\_\

```

<div align="center">

**🚀 The Ultimate HPC Observability Platform 🚀**

[![Grafana](https://img.shields.io/badge/Grafana-11.3.0-orange?logo=grafana)](https://grafana.com)
[![Prometheus](https://img.shields.io/badge/Prometheus-2.54.1-red?logo=prometheus)](https://prometheus.io)
[![Docker](https://img.shields.io/badge/Docker-Powered-blue?logo=docker)](https://docker.com)
[![Ansible](https://img.shields.io/badge/Ansible-Automated-black?logo=ansible)](https://ansible.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*Because if you can't measure it, is it even computing?* 🤓

[Quick Start](#-one-command-deployment) • [Architecture](#-the-full-stack) • [Features](#-what-youre-monitoring) • [Dashboards](#-pre-built-dashboards)

---

</div>

## 🎯 What Is This?

Your HPC cluster is doing **amazing** things. But without monitoring, you're flying blind! This repo gives you:

- 📊 **Real-time metrics** from every component in your HPC stack
- 🎨 **Beautiful dashboards** that make your ops team look like wizards
- 🔔 **Smart alerts** so you know about problems before your users do
- 🤖 **Fully automated** deployment because ain't nobody got time for manual setup
- 🐳 **Docker-powered** observability stack that Just Works™

**The best part?** One command deploys the entire monitoring infrastructure. Then sit back and watch the metrics roll in! 📈

## 🔭 What You're Monitoring

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        YOUR HPC EMPIRE                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  🖥️  COMPUTE NODES (Rocky Linux)           →  📈 Node Exporter          │
│      └─ CPU, RAM, I/O, Network, Disk                                    │
│                                                                          │
│  🎮 GPU NODES (NVIDIA)                     →  ⚡ DCGM Exporter          │
│      └─ GPU Util, Memory, Power, Temp              (H100 ready!)        │
│                                                                          │
│  📋 JOB SCHEDULER (SLURM)                  →  📊 SLURM Exporter         │
│      └─ Queue depth, Running jobs, Wait times, Node allocation          │
│                                                                          │
│  💾 PARALLEL STORAGE                       →  🗄️  Multiple Exporters    │
│      ├─ WEKA (distributed parallel FS)                                  │
│      └─ MooseFS (fault-tolerant FS)                                     │
│                                                                          │
│  🏭 DELL POWEREDGE SERVERS                 →  🔌 iDRAC Exporter         │
│      └─ Hardware health, Power, Thermal, RAID, PSU, Fans                │
│                                                                          │
│  🌐 INFINIBAND FABRIC                      →  📡 UFM Exporter           │
│      └─ Topology, bandwidth, errors                                     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 📊 Port Reference Card

Keep this handy when troubleshooting!

| 🎯 Component | 🚪 Port | 📍 Endpoint | 💡 What It Does |
|--------------|---------|-------------|-----------------|
| **Node Exporter** | `9100` | `/metrics` | System vitals (CPU, RAM, disk) |
| **NVIDIA DCGM** | `9400` | `/metrics` | GPU go brrrr metrics |
| **SLURM Exporter** | `9091` | `/metrics` | Job queue stats |
| **WEKA Exporter** | `9101` | `/metrics` | Parallel storage perf |
| **MooseFS Exporter** | `9105` | `/metrics` | Distributed FS health |
| **iDRAC Exporter** | `9610` | `/metrics` | Hardware health check |
| **Grafana** | `3000` | `/` | The pretty dashboards ✨ |
| **Prometheus** | `9090` | `/graph` | Time series database |
| **Loki** | `3100` | `/` | Log aggregation |
| **Tempo** | `3200` | `/` | Distributed tracing |

## 🗂️ Repository Structure

```
hpc-monitoring/
│
├── 🤖 ansible/                         # Automation magic happens here
│   ├── 📋 inventory                    # Your infrastructure map
│   ├── 📚 playbooks/
│   │   ├── setup_monitoring.yml        # 🚀 THE BIG ONE - deploys everything!
│   │   ├── hpc_fullstack_monitoring.yml # Full HPC stack
│   │   ├── grafana_stack.yml           # Observability platform
│   │   └── validate_endpoints.yml      # Health check everything
│   └── 🎭 roles/
│       ├── node_exporter/              # Rocky Linux + CPU feature detection
│       ├── nvidia_dcgm_exporter/       # GPU metrics (H100 ready!)
│       ├── slurm_exporter/             # Job scheduler insights
│       ├── wekafs_exporter/            # Parallel storage metrics
│       ├── moosefs_exporter/           # Distributed FS monitoring
│       ├── idrac_exporter/             # Dell hardware health
│       └── grafana_stack/              # The full observability stack
│
├── 🐳 docker/
│   └── grafana-stack/                  # Containerized monitoring platform
│       ├── docker-compose.yml          # One file to rule them all
│       ├── prometheus/                 # Metrics database config
│       ├── loki/                       # Log aggregation config
│       ├── tempo/                      # Distributed tracing config
│       └── provisioning/               # Auto-setup datasources & dashboards
│
└── 📊 grafana_dashboards/              # Pre-built dashboard collection
    ├── hpc_unified_fullstack_dashboard.json  # ⭐ THE MEGA DASHBOARD
    ├── hpc_job_dashboard.json          # SLURM job queue analysis
    ├── poweredge_hardware_dashboard.json # Dell server health
    └── hardware_dashboard.json         # General hardware metrics
```

## ⚡ One-Command Deployment

**TL;DR:** Deploy the entire monitoring stack in one shot:

```bash
# The nuclear option - deploys EVERYTHING! 🚀
ansible-playbook -i ansible/inventory ansible/playbooks/setup_monitoring.yml
```

This single command will:
- ✅ Deploy exporters to all HPC nodes
- ✅ Launch Grafana CE observability stack
- ✅ Auto-generate Prometheus configuration from your inventory
- ✅ Validate all endpoints are reachable
- ✅ Generate a health check report

Then open `http://your-monitoring-server:3000` and **BAM** - instant visibility! 🎉

---

## 📋 Step-by-Step Setup

### 1️⃣ Define Your Infrastructure

Edit `ansible/inventory` to map your HPC empire:

```ini
[hpc1_compute_nodes]
compute[01:20].example.com    # Your compute army

[hpc1_gpu_nodes]
gpu[01:08].example.com        # The big iron 🎮

[hpc1_head_nodes]
head01.example.com            # The brain

[storage_weka]
weka[01:04].example.com       # Fast storage

[grafana]
monitor.example.com           # Mission control
```

💡 **Pro tip:** Use range notation `node[01:99]` to avoid typing 99 lines!

### 2️⃣ Deploy Exporters to HPC Nodes

```bash
# Deploy to everything
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml

# Or be selective
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml \
  --limit gpu_nodes

# Or use tags for granular control
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml \
  --tags compute,storage
```

Available tags: `compute`, `gpu`, `slurm`, `weka`, `moosefs`, `poweredge`, `baseline`

### 3️⃣ Launch the Observability Stack

```bash
# Deploy Grafana CE full stack with Docker
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml
```

This deploys on your `[grafana]` host:
- Grafana (dashboards)
- Prometheus (metrics)
- Loki (logs)
- Tempo (traces)
- Alertmanager (notifications)

### 4️⃣ Validate Everything Works

```bash
# Health check all the things!
ansible-playbook -i ansible/inventory ansible/playbooks/validate_endpoints.yml
```

Check the report at `/tmp/hpc_endpoint_validation_report.txt` for any issues.

---

## 🏭 Dell PowerEdge Hardware Monitoring

**Keep tabs on your metal!** Monitor server hardware health via iDRAC Redfish API.

```
┌─────────────────────────────────────────────────────────────┐
│         🔌 Dell PowerEdge Health Dashboard                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ System Health    │ CPU Temp 🌡️  │ Fan RPM 🌀          │
│  ⚡ Power Usage      │ DIMM Status 💾 │ RAID Health 💿      │
│  🔥 Thermal Zones    │ PSU Status 🔋  │ Network NICs 🌐     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### What Gets Monitored

| Component | Metrics | Why You Care |
|-----------|---------|--------------|
| 🔋 **Power** | Consumption, PSU capacity, efficiency | Catch power issues before UPS failover |
| 🌡️ **Thermal** | CPU/GPU/Inlet temps, thermal margins | Prevent thermal throttling |
| 🌀 **Cooling** | Fan speeds, status, redundancy | Know before a fan dies |
| 🧠 **CPU** | Per-socket utilization, features | Balance workloads |
| 💾 **Memory** | DIMM health, correctable errors | Catch failing DIMMs early |
| 💿 **Storage** | RAID status, drive health, predictive failures | No surprise disk failures! |
| 🔌 **PSU** | Redundancy, output power, health | Power supply peace of mind |

### Quick Setup

```bash
# 1. Add servers to inventory
cat >> ansible/inventory << EOF
[poweredge_servers]
poweredge[01:10].example.com
EOF

# 2. Configure iDRAC credentials
vim ansible/roles/idrac_exporter/defaults/main.yml
# Add your iDRAC IPs and credentials

# 3. Deploy!
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml --tags poweredge
```

### 🔒 Security Best Practice

**Don't hardcode passwords!** Use Ansible Vault:

```bash
# Encrypt your iDRAC password
ansible-vault encrypt_string 'SuperSecretPassword' --name 'password'

# Paste the encrypted output into defaults/main.yml
```

Create a read-only iDRAC user for monitoring:
1. Login to iDRAC web interface
2. Users → Add New User
3. Username: `monitoring` (or whatever you like)
4. Privilege: **Read Only**
5. Enable account ✅

---

## 🐧 Rocky Linux Love

This stack is **optimized** for Rocky Linux 8/9 (because RHEL clones deserve monitoring too!):

- ✅ **Enhanced collectors** - systemd, processes, cpu.info, diskstats, filesystem, and more
- 🔒 **Security hardened** - NoNewPrivileges, ProtectHome, ProtectSystem
- 🎯 **Auto-detection** - Knows when it's running on Rocky
- 🧬 **CPU features** - Detects AVX, AVX2, AVX-512, AES-NI, SSE4.2, FMA

Perfect for comparing 16G vs 17G PowerEdge hardware or tracking which nodes support what instruction sets!

---

## 🎯 The Full Stack

**Everything. Everywhere. All at once.**

```
     ┌──────────────────────────────────────────────────────┐
     │         🎯 UNIFIED HPC MONITORING STACK              │
     └──────────────────────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
     ┌────▼────┐      ┌────▼────┐      ┌────▼────┐
     │ COMPUTE │      │   GPU   │      │ STORAGE │
     └─────────┘      └─────────┘      └─────────┘
      Rocky 9          NVIDIA            WEKA +
      AVX-512          DCGM 3.3         MooseFS
         │                 │                 │
     ┌────▼─────────────────▼─────────────────▼────┐
     │           📊 PROMETHEUS                      │
     │           📚 LOKI (logs)                     │
     │           🔍 TEMPO (traces)                  │
     └────────────────┬─────────────────────────────┘
                      │
                 ┌────▼────┐
                 │ GRAFANA │ ← You are here!
                 └─────────┘
```

### Deploy the Universe

```bash
# Everything in one command
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml
```

### Surgical Strikes (Tag-Based Deployment)

```bash
# Just compute nodes
ansible-playbook ... --tags compute

# Storage + scheduler
ansible-playbook ... --tags storage,slurm

# The works
ansible-playbook ... --tags baseline,gpu,storage,poweredge
```

**Available tags:**
- `compute` → Rocky Linux nodes
- `gpu` → NVIDIA GPUs
- `slurm`, `scheduler`, `jobs` → Job queue
- `weka`, `moosefs`, `storage`, `filesystem` → Parallel filesystems
- `poweredge`, `idrac`, `hardware`, `dell` → Server health
- `baseline` → Essential monitoring only

### 📊 Pre-Built Dashboards

We've done the hard work for you! Import these pre-built Grafana dashboards:

| Dashboard | What It Shows | When to Use |
|-----------|---------------|-------------|
| 🎯 **hpc_unified_fullstack_dashboard.json** | THE BIG ONE - everything! | Daily operations, full visibility |
| 📋 **hpc_job_dashboard.json** | SLURM queue deep dive | Job performance analysis |
| 🏭 **poweredge_hardware_dashboard.json** | Dell server hardware health | Hardware troubleshooting |
| 🖥️ **hardware_dashboard.json** | General compute metrics | Node performance tuning |

**Import via:** Configuration → Dashboards → Import → Upload JSON file

---

## 💾 Storage System Monitoring

### MooseFS - Distributed Filesystem

```
  🧀 MooseFS Metrics
  ┌─────────────────────────────────────┐
  │ Master: ✅ Online                   │
  │ Chunks: 12,456  Servers: 4/4        │
  │ Space: 2.4 PB / 3.0 PB used         │
  │ I/O: 12.3 GB/s read, 8.1 GB/s write │
  │ Clients: 142 connected              │
  └─────────────────────────────────────┘
```

**Quick setup:**
```bash
# 1. Add to inventory
[storage_moosefs]
moosefs-master.example.com
moosefs-chunk[01:04].example.com

# 2. Configure master endpoint
vim ansible/roles/moosefs_exporter/defaults/main.yml
# Set: moosefs_master_host and moosefs_master_port

# 3. Deploy
ansible-playbook -i ansible/inventory ansible/playbooks/hpc_fullstack_monitoring.yml --tags moosefs
```

**Metrics tracked:** Space (total/used/available/trash), chunk servers, files/dirs, I/O ops, connected clients

### WEKA - Parallel Filesystem

Deploy with `--tags weka` - same simple process!

---

## 🧬 Hardware Generation Comparison

**Got old and new hardware?** Track performance differences between server generations!

```
  📊 16G vs 17G Comparison
  ┌──────────────────────────────────────────────────┐
  │                 16G          17G      Δ          │
  │ AVX-512 VNNI:   ❌           ✅       +40% perf  │
  │ Power/Job:      285W         210W     -26%       │
  │ Thermal:        72°C         65°C     -7°C       │
  │ Job Time:       142s         98s      -31%       │
  └──────────────────────────────────────────────────┘
```

### CPU Features Tracked

The Node Exporter automatically detects and reports:
- **AVX, AVX2, AVX-512** (Foundation, DQ, BW, VL, VNNI)
- **AES-NI** - Hardware encryption
- **SSE4.2** - Streaming SIMD Extensions
- **FMA** - Fused Multiply-Add
- **BMI1/BMI2** - Bit Manipulation
- **VT-x/AMD-V** - Virtualization support

Query in Grafana:
```promql
node_cpu_feature{feature="avx512_vnni"}
```

**Research use cases:** Performance analysis, upgrade planning, power efficiency comparison, workload optimization

---

## 📋 SLURM Job Monitoring

**Know your queue!** Track every job from submission to completion.

```
  SLURM Queue Status
  ┌────────────────────────────────────┐
  │ Running:   142  Pending:    67     │
  │ Completed: 1.2K Failed:     3      │
  │ Avg Wait:  4m   Nodes: 94/120     │
  └────────────────────────────────────┘
```

### Metrics You Get

✅ Pending/running/completed/failed jobs
✅ Queue wait times per partition
✅ Node allocation and utilization
✅ Resource consumption per job
✅ Cross-correlation with compute metrics

### Example Queries

```promql
# How backed up is the queue?
rate(slurm_queue_jobs_pending[5m])

# Job success rate
rate(slurm_jobs_completed_total[5m]) / rate(slurm_jobs_total[5m])

# Average queue wait time trending
avg_over_time(slurm_queue_wait_seconds[1h])
```

**Use it to:** Optimize job submission, identify bottlenecks, understand scheduler behavior, predict resource needs

---

# 🚀 Docker-Based Deployment (Recommended)

## Grafana CE Full Observability Stack

**The whole enchilada in containers!** 🌯

```
╔═══════════════════════════════════════════════════════════════════╗
║              🐳 DOCKER-BASED MONITORING STACK                     ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   📊 GRAFANA 11.3.0          →  :3000   Dashboards & Viz         ║
║   📈 PROMETHEUS 2.54.1       →  :9090   Metrics (90d retention)  ║
║   📚 LOKI 3.2.0              →  :3100   Logs (90d, 3x faster!)   ║
║   🔍 TEMPO 2.6.0             →  :3200   Traces (30d)             ║
║   🔔 ALERTMANAGER 0.27.0     →  :9093   Smart alerting           ║
║   📝 PROMTAIL                →         Log shipping              ║
║                                                                   ║
║   Built-in Exporters:                                            ║
║   • Node Exporter 1.8.2      • cAdvisor 0.49.1                   ║
║   • Pushgateway 1.9.0        • Blackbox 0.25.0                   ║
║   • SNMP 0.26.0              • Process Exporter 0.8.3 ⭐         ║
║   • StatsD 0.27.1 ⭐         • Image Renderer 3.11.3 ⭐          ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

### 🎯 Deploy Options

**Option A: Ansible (Production)**
```bash
# One command to rule them all
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml

# Gets deployed to: /opt/hpc-monitoring
# Systemd service: hpc-monitoring-stack
# Manage with: systemctl status hpc-monitoring-stack
```

**Option B: Docker Compose (Dev/Test)**
```bash
cd docker/grafana-stack

./start-stack.sh                    # 🚀 Launch!
docker-compose logs -f grafana      # 👀 Watch the magic
docker-compose down                 # 🛑 Stop everything
```

### 🌐 Access Your Stack

| Service | URL | Login | What It Does |
|---------|-----|-------|--------------|
| 📊 **Grafana** | `http://server:3000` | admin/admin | Your command center |
| 📈 **Prometheus** | `http://server:9090` | - | Query metrics |
| 📚 **Loki** | `http://server:3100` | - | Search logs |
| 🔍 **Tempo** | `http://server:3200` | - | Trace requests |
| 🔔 **Alertmanager** | `http://server:9093` | - | Manage alerts |

> ⚠️ **FIRST THING:** Change the default Grafana password! (admin/admin is so 2010)

### ⚙️ Configuration

**Prometheus targets auto-configured from inventory!** But if you need manual edits:

```bash
# Edit Prometheus config
vim docker/grafana-stack/prometheus/prometheus.yml

# Add your nodes
- job_name: 'my-hpc-cluster'
  static_configs:
    - targets: ['node01:9100', 'node02:9100', 'gpu01:9400']
      labels:
        cluster: 'production'
        tier: 'compute'
```

**Setup alerting:**
```bash
# Configure notification channels
vim docker/grafana-stack/alertmanager/alertmanager.yml

# Example: Slack notifications
receivers:
  - name: 'slack-hpc-ops'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
        channel: '#hpc-alerts'
        title: '🚨 HPC Alert'
```

**Tweak retention:**
- **Prometheus**: 90 days, 50GB cap (in docker-compose.yml)
- **Loki**: 90 days (in loki-config.yml)
- **Tempo**: 30 days (in tempo.yml)

### 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│            🐳 MONITORING SERVER (Docker Host)                │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐                │
│   │ GRAFANA │◄───┤PROMETHEU│◄───┤  LOKI   │                │
│   │  :3000  │    │  :9090  │    │  :3100  │                │
│   └────┬────┘    └────┬────┘    └────┬────┘                │
│        │              │              │                       │
│   ┌────▼────┐    ┌───▼─────┐   ┌───▼─────┐                │
│   │  TEMPO  │    │ALERTMGR │   │PROMTAIL │                │
│   │  :3200  │    │  :9093  │   │         │                │
│   └─────────┘    └─────────┘   └─────────┘                │
│                                                              │
│   Built-in Exporters (monitoring this server):              │
│   • Node :9100  • cAdvisor :8080  • Blackbox :9115         │
│   • SNMP :9116  • Pushgateway :9091                        │
└──────────────────────────────────────────────────────────────┘
                           │
        ╔══════════════════╧═══════════════════╗
        ║    Scrapes metrics from all nodes    ║
        ╚══════════════════╤═══════════════════╝
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                   🖥️ HPC INFRASTRUCTURE                      │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  🐧 Compute Nodes ───────────► Node Exporter :9100          │
│  🎮 GPU Nodes ───────────────► DCGM Exporter :9400          │
│  📋 SLURM Scheduler ─────────► SLURM Exporter :9091         │
│  💾 WEKA Storage ────────────► WEKA Exporter :9101          │
│  🧀 MooseFS ─────────────────► MooseFS Exporter :9105       │
│  🏭 Dell PowerEdge ──────────► iDRAC Exporter :9610         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 💾 Data Persistence & Backup

**All your data lives in Docker volumes - protect it!**

```bash
# See what you've got
docker volume ls | grep hpc-monitoring

# Backup everything (do this regularly!)
cd docker/grafana-stack
docker-compose down
docker run --rm \
  -v hpc-monitoring_prometheus_data:/data \
  -v $(pwd)/backups:/backup \
  ubuntu tar czf /backup/prometheus-backup-$(date +%Y%m%d).tar.gz /data

# Restore from backup
docker run --rm \
  -v hpc-monitoring_prometheus_data:/data \
  -v $(pwd)/backups:/backup \
  ubuntu tar xzf /backup/prometheus-backup-20250108.tar.gz -C /
docker-compose up -d
```

**Pro tip:** Set up a cron job to backup daily!

### 💪 Resource Requirements

| Environment | CPU | RAM | Disk | Notes |
|-------------|-----|-----|------|-------|
| **Testing/Dev** | 4 cores | 8 GB | 100 GB SSD | Good for kicking the tires |
| **Small HPC** | 8 cores | 16 GB | 500 GB SSD | <100 nodes |
| **Production** | 16+ cores | 32+ GB | 1+ TB SSD | For serious clusters |

💡 **Scale tip:** Prometheus needs ~2KB per metric per scrape. A 200-node cluster with 1000 metrics/node = ~400MB per scrape!

### 🎯 The Three Pillars of Observability

```
┌────────────────────────────────────────────────────┐
│  📊 METRICS        📚 LOGS         🔍 TRACES       │
│  (Prometheus)      (Loki)          (Tempo)         │
├────────────────────────────────────────────────────┤
│  What's broken?    Why is it       Where's the     │
│  Performance       broken?         bottleneck?     │
│  trends            Error msgs      Request flow    │
│  Resource usage    Debugging       Latency         │
└────────────────────────────────────────────────────┘
                      ▼
            ┌──────────────────┐
            │  🎨 GRAFANA      │
            │  Unified View    │
            └──────────────────┘
```

**You get:**
1. 📈 **Metrics** - All HPC infrastructure, 90-day retention, PromQL queries
2. 📚 **Logs** - System/app/SLURM logs, correlated with metrics, LogQL
3. 🔍 **Traces** - Distributed tracing, integrated with logs & metrics
4. 🎨 **Dashboards** - Pre-built HPC dashboards, auto-provisioned
5. 🚨 **Alerts** - HPC-specific rules, multi-channel notifications

### 🔧 Troubleshooting

**Stack won't start?**
```bash
# Check what's wrong
docker-compose logs <service-name>

# Disk full?
df -h

# Port conflicts?
sudo netstat -tlnp | grep -E '3000|9090|3100'
```

**Missing metrics?**
```bash
# Check Prometheus targets
curl http://your-server:9090/targets

# Test exporter directly
curl http://compute-node:9100/metrics

# Firewall blocking?
sudo firewall-cmd --list-all
```

**High memory usage?**
- ⬇️ Reduce scrape intervals (15s → 30s)
- 📉 Lower retention (90d → 30d)
- 💰 Add more RAM (it's 2025, RAM is cheap!)

**Loki queries slow?**
- 🏷️ Use better label filtering
- ⏰ Narrow time ranges
- 🔍 Check `loki-config.yml` for indexing

For more help: `docker/grafana-stack/README.md`

---

# 🎉 Version 2.0 - ALL THE UPGRADES!

```
╔════════════════════════════════════════════════════════════════╗
║                    🚀 VERSION 2.0 IS HERE! 🚀                  ║
║         Everything upgraded. Everything better. ™              ║
╚════════════════════════════════════════════════════════════════╝
```

## 🆙 Major Version Upgrades

**We went through ALL the release notes so you don't have to!**

| Component | Before | After | 🎁 What You Get |
|-----------|--------|-------|-----------------|
| **Grafana** | 10.x | **11.3.0** | Faster dashboards, better correlations |
| **Prometheus** | 2.45 | **2.54.1** | Native histograms, 90d retention |
| **Loki** | 3.0 | **3.2.0** | **3x faster** queries! 🚀 |
| **Tempo** | 2.4 | **2.6.0** | Multi-protocol ingest, service graphs |
| **Node Exporter** | 1.5.0 | **1.8.2** | More collectors, better accuracy |
| **NVIDIA DCGM** | 2.4.10 | **3.3.9** | H100 support! 🎮 |

## ✨ What's New

### ⭐ New Exporters

| Exporter | What It Does | Why You Want It |
|----------|--------------|-----------------|
| **Process Exporter 0.8.3** | Track SLURM, MPI, scientific apps | See what's consuming resources |
| **StatsD Exporter 0.27.1** | UDP metrics (port 9125) | Easy app instrumentation |
| **Image Renderer 3.11.3** | Auto-generate PNG/PDF reports | Email dashboards to management |

### 🚀 Performance Gains

```
Before:  [████████████████████] 10s query time
After:   [█████] 3s query time    ← 3x faster! (Loki 3.2)
```

- ⚡ **3x faster log queries** - Loki 3.2 is screaming fast
- 📦 **90-day retention** - Up from 30 days (metrics & logs)
- 💾 **50GB storage cap** - Auto-cleanup prevents disk fill
- 📊 **Native histograms** - Accurate percentiles in Prometheus
- 🔗 **Better trace-to-log correlation** - Find issues faster
- 📈 **Automatic service graphs** - See your architecture

## 🔄 Upgrade Now

**Option 1: The "I Trust You" Method**
```bash
cd docker/grafana-stack
docker-compose down          # 🛑 Stop everything
docker-compose pull          # ⬇️  Get new versions
docker-compose up -d         # 🚀 Launch!
```

**Option 2: The Ansible Way (Recommended)**
```bash
# Automatically pulls latest, backs up configs
ansible-playbook -i ansible/inventory ansible/playbooks/grafana_stack.yml
```

**Option 3: With Custom Config**
```bash
# Customize first
cp docker/grafana-stack/.env.example docker/grafana-stack/.env
vim .env                     # Set your preferences

# Then deploy
cd docker/grafana-stack && docker-compose up -d
```

> 💡 **No breaking changes!** All dashboards, alerts, and configs work as-is.

## 📦 Complete Stack (14 Components)

**Core Platform:**
- Grafana 11.3.0
- Prometheus 2.54.1 (90d, 50GB cap)
- Loki 3.2.0 (90d, 3x speed boost)
- Tempo 2.6.0 (30d retention)
- Alertmanager 0.27.0
- Promtail (latest)

**Built-in Exporters:**
- Node Exporter 1.8.2
- cAdvisor 0.49.1
- Pushgateway 1.9.0
- Blackbox 0.25.0
- SNMP 0.26.0
- Process Exporter 0.8.3 ⭐
- StatsD Exporter 0.27.1 ⭐
- Image Renderer 3.11.3 ⭐

See `VERSIONS.md` for complete details, compatibility info, and rollback procedures.

---

## 🎓 Getting Help

**Documentation:**
- 📚 Main docs: This README (you are here!)
- 🐳 Docker stack: `docker/grafana-stack/README.md`
- 📝 Detailed setup: `docs/AUTOMATED_ENDPOINT_SETUP.md`
- 🔖 Version info: `VERSIONS.md`
- 💡 Examples: `ansible/inventory.example`

**Quick Checks:**
```bash
# Validate your setup
ansible-playbook -i ansible/inventory ansible/playbooks/validate_endpoints.yml

# Check Prometheus targets
curl http://your-server:9090/targets | jq

# Test an exporter
curl http://compute-node:9100/metrics | grep node_cpu
```

**Common Issues:**
- Firewall blocking ports → Check iptables/firewalld
- Exporters not running → Check systemd status
- High memory usage → Reduce scrape frequency or retention
- Missing metrics → Verify inventory and Prometheus config

---

## 🏆 Why This Monitoring Stack Rocks

✅ **One-command deployment** - `setup_monitoring.yml` does it all
✅ **Auto-configuration** - Prometheus config from Ansible inventory
✅ **Latest versions** - Grafana 11.3, Prometheus 2.54, Loki 3.2
✅ **Full observability** - Metrics, logs, traces in one place
✅ **HPC-optimized** - Built for SLURM, GPUs, parallel storage
✅ **Pre-built dashboards** - Import and go!
✅ **Rocky Linux ready** - Optimized for RHEL clones
✅ **H100 support** - Latest NVIDIA DCGM exporter
✅ **Security hardened** - Ansible Vault for secrets
✅ **Highly available** - Docker volumes, easy backups
✅ **Battle-tested** - Proven on production HPC clusters

---

## 🤝 Contributing

Got improvements? Found a bug? Want to add a new exporter?

1. Fork it
2. Create a feature branch
3. Make your changes
4. Submit a PR

**We love contributions!** Especially dashboards and alert rules.

---

## 📄 License

MIT License - See LICENSE file

---

<div align="center">

**Built with ❤️ for HPC teams everywhere**

*Now go forth and monitor all the things!* 📊

</div>
