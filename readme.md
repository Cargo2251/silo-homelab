# 🏗️ Silo Homelab: DevOps Infrastructure & Learning Playground

Welcome to my central infrastructure repository. This project serves as my active homelab and a hands-on playground for mastering modern DevOps practices, Infrastructure as Code (IaC), and Continuous Integration/Continuous Deployment (CI/CD).

The overarching goal of this environment is to transition from single-node manual administration to a fully automated, highly available Kubernetes cluster.

## 📐 Architecture Overview

The physical foundation is a bare-metal hypervisor running **Proxmox VE**, managing virtualized Ubuntu nodes with strict resource allocation to optimize memory and compute overhead.

### Current Node Topology
* **`silo_server` (Production):** The primary Docker engine hosting the main data plane, monitoring stack, and edge routing.
* **`tester` (Staging):** An isolated, dynamically provisioned environment for safely testing Ansible playbooks and deployment strategies before pushing to production.

## ⚙️ Infrastructure as Code (IaC)

All node provisioning and configuration management is handled declaratively via **Ansible**. 

* **Zero-Touch Provisioning:** Playbooks (like `docker-engine.yml`) are engineered for strict idempotency, capable of bootstrapping a blank Ubuntu VM into a baseline, correctly permissioned Docker host in seconds.
* **Secret Management:** Sensitive credentials and privilege escalation passwords are encrypted using `ansible-vault`, utilizing a `host_vars` architecture to isolate node-specific secrets.


## 🚀 Continuous Deployment & GitOps 

Deployments and configuration updates are driven by a GitOps methodology. The repository utilizes a **GitHub Self-Hosted Runner** residing on the infrastructure. When code is pushed to the `main` branch, the runner detects the drift and automatically pulls the latest configurations down to the production environment.

## 📦 Active Workloads

The current production node runs a robust stack of containerized services managed via standard deployment pipelines.

**Monitoring & Observability:**
* Grafana, Prometheus, Node Exporter, cAdvisor
* Uptime Kuma, Speedtest-Tracker
* Diun (Docker Image Update Notifier)

**Infrastructure & Routing:**
* NPM (Nginx Proxy Manager)
* Dockge (Stack management)
* Homepage (Internal dashboard)
* Dozzle (Real-time log viewer)

**Core Services & Data:**
* Vaultwarden
* Nextcloud
* CouchDB - For Obsidian LiveSync
* Automated local and volume backups (`docker-volume-backup`, `postgres-backup-local`)

## 🗺️ Roadmap & Trajectory

This environment is continuously evolving. The current trajectory includes:

- [x] Establish CD pipeline via GitHub Runners.
- [x] Engineer idempotent Ansible playbooks for zero-touch Docker provisioning.
- [ ] Engineer `harden-os.yml` playbook for automated OS security (SSH hardening, UFW, Fail2ban).
- [ ] Implement Continuous Integration (CI) with GitHub Actions for Ansible linting and syntax validation.
- [ ] Deploy secondary and tertiary Ubuntu nodes to establish a distributed architecture.
- [ ] Migrate standalone Docker workloads into a High-Availability **K3s / Kubernetes** cluster.

---
*This repository reflects active learning and architectural experimentation.*
