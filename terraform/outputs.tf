output "instance_ips" {
  value = {
    for i, name in var.env_names : name => aws_instance.my_servers[i].public_ip
  }
}