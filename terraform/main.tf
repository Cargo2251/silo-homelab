provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token
  insecure = true
  ssh {
    agent = true
    username = "root"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name = "test-ubuntu"
  node_name = "pve"

  stop_on_destroy = true

  initialization {
    user_account {
      username = "user"
      password = "password"
    }
  }
  
  disk {
    datastore_id = "local-lvm"
    file_id = "local:iso/jammy-server-cloudimg-amd64.img"
    interface = "virtio0"
    iothread = true
    discard = "on"
    size = 20
  }
}


