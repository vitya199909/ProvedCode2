variable "proxmox_host" {
  type = string
}
variable "proxmox_api_token_id" {
  type      = string
}
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}
variable "proxmox_username" {
  type      = string
}
variable "proxmox_password" {
  type      = string
  sensitive = true
}
variable "proxmox_disk" {
  type      = string
}


variable "vmid_jenkins" {
  type      = number
}
variable "gateway_ip" {
  type      = string
}
variable "jenkins_ip" {
  type      = string
}
variable "node_pass_jenkins" {
  type      = string
  sensitive = true
}