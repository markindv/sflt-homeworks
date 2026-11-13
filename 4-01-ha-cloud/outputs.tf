output "vm_names" {
  description = "Names of the two VMs created with count"
  value       = yandex_compute_instance.web[*].name
}

output "vm_internal_ips" {
  description = "Internal IP addresses registered in the target group"
  value       = yandex_compute_instance.web[*].network_interface[0].ip_address
}

output "vm_external_ips" {
  description = "Temporary public IP addresses used for package installation and diagnostics"
  value       = yandex_compute_instance.web[*].network_interface[0].nat_ip_address
}

output "target_group_id" {
  description = "Network Load Balancer target group ID"
  value       = yandex_lb_target_group.web.id
}

output "load_balancer_id" {
  description = "Network Load Balancer ID"
  value       = yandex_lb_network_load_balancer.web.id
}

output "load_balancer_ip" {
  description = "External IPv4 address of the load balancer"
  value = one([
    for listener in yandex_lb_network_load_balancer.web.listener :
    one(listener.external_address_spec).address
    if listener.name == "http"
  ])
}

output "nginx_url" {
  description = "URL used to verify the default Nginx page"
  value = "http://${one([
    for listener in yandex_lb_network_load_balancer.web.listener :
    one(listener.external_address_spec).address
    if listener.name == "http"
  ])}"
}

