This repository documents the infrastructure and configuration behind a 
self-hosted production environment running on a bare-metal Proxmox hypervisor. 
It serves dual purpose: a platform for hands-on DevOps practice with real 
operational stakes, and a personal cloud running services I depend on daily 
— giving me full ownership over my data and tooling.

## Architecture

### Physical host

| | |
|---|---|
| Machine | HP Omen Laptop |
| CPU | Intel Core i7-7700HQ (4c/8t) |
| RAM | 12GB |
| Storage | 256GB NVMe (Proxmox OS) + 1TB HDD (VM storage) |
| Hypervisor | Proxmox VE |

### Virtual machines

| VM | Role | CPU | RAM | Storage | State |
|---|---|---|---|---|---|
| `silo_server` | Production | 4 vCPU | 6GB | 32GB | Always on |
| `tester` | Staging | 4 vCPU | 4GB | 32GB | On-demand |

Both VMs use Proxmox-bridged networking with static IPs reserved at the 
router gateway. `silo_server` runs the GitHub Actions self-hosted runner 
and all production workloads.

### Networking & security

All inbound traffic enters exclusively via **Tailscale** — no ports are 
exposed to the public internet except 80 and 443 on `silo_server`, which 
are consumed by Nginx Proxy Manager.

All containers are isolated on a dedicated Docker network (`proxy_net`). 
No container is directly accessible — every request must pass through NPM.

Cloudflare DNS records for each service resolve to the Tailscale IP, 
meaning services are unreachable without an active Tailscale connection.
```
Client (Tailscale) → Cloudflare DNS → Tailscale IP
                   → NPM (80/443) → proxy_net → container
```

### How a deployment works

1. A change is pushed to `main` in this repo
2. The self-hosted GitHub Actions runner on `silo_server` detects the push
3. The runner pulls the updated config and redeploys only the affected stack
4. Services are reachable within seconds via their Tailscale-routed DNS names

### Security model

All external access is Tailscale-gated at the network layer — no services 
are reachable from the public internet. NPM acts as the sole ingress point; 
all containers sit on an isolated `proxy_net` and are unreachable directly.

Host-level controls:
- SSH key authentication only — no password login, no new user creation
- Proxmox web UI restricted to local network only
- GitHub Actions runner scoped to push events for deployment workflows - CI lint checks run on pull requests, deployment workflows do not
- Registration disabled on all internet-facing services (Vaultwarden, Nextcloud)


## Active workloads

All services run as containers on `silo_server`, managed via Docker Compose 
and deployed through the GitOps pipeline. Every service is routed through 
NPM and accessible only over Tailscale.

### Monitoring & observability
| Service | Purpose |
|---|---|
| Prometheus + Node Exporter + cAdvisor | Metrics collection — host, container, and process level |
| Grafana | Metrics visualisation and alerting |
| Uptime Kuma | Service uptime monitoring and status pages |
| Speedtest Tracker | Scheduled ISP performance logging |
| Diun | Container image update notifications |
| Dozzle | Real-time container log viewer |

### Infrastructure & routing
| Service | Purpose |
|---|---|
| Nginx Proxy Manager | Sole ingress point — reverse proxies all container traffic |
| Dockge | Compose stack management UI |
| Homepage | Internal service dashboard |

### Core services
| Service | Purpose |
|---|---|
| Vaultwarden | Self-hosted password manager (Bitwarden-compatible) |
| Nextcloud | Self-hosted file sync and collaboration |
| CouchDB | Database backend for Obsidian LiveSync |
| docker-volume-backup | Automated container volume backups |
| postgres-backup-local | Automated PostgreSQL backups |

## Roadmap & Trajectory

### Completed
- [x] CD pipeline via GitHub Actions self-hosted runner
- [x] Idempotent Ansible playbook for zero-touch Docker provisioning
- [x] OS hardening playbook (SSH, UFW, Fail2ban)
- [x] Monitoring stack (Prometheus, Grafana, cAdvisor, Node Exporter)
- [x] Tailscale + Cloudflare DNS network architecture

### In progress
- [ ] CI pipeline — linting and syntax validation on Ansible 
      playbook and Bash script push (ansible-lint, shellcheck)
- [ ] Extract monitoring stack to standalone repo
- [ ] Extract Ansible playbooks to standalone repo

### Next
- [ ] Terraform — provision Proxmox VMs declaratively, 
      replacing manual VM creation
- [ ] Cloud foundations — deploy existing stack to AWS EC2, 
      map homelab concepts to cloud equivalents
- [ ] AWS Cloud Practitioner certification

### Long term
- [ ] Kubernetes — migrate appropriate workloads to K3s
- [ ] Expand to multi-node architecture
