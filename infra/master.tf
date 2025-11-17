resource "null_resource" "get_master_fqdn" {
  triggers = {
    cluster_id = yandex_dataproc_cluster.dataproc_cluster.id
  }

  provisioner "local-exec" {
    command = <<EOT
      yc compute instance list --format json | jq -r '.[] | select(.labels.subcluster_role == "masternode") | .fqdn' > ${path.module}/master_fqdn.txt
    EOT
  }
}

data "local_file" "master_fqdn" {
  filename = "${path.module}/master_fqdn.txt"
  depends_on = [null_resource.get_master_fqdn]
}

output "dataproc_master_fqdn" {
  description = "FQDN мастер-ноды Dataproc кластера"
  value       = trimspace(data.local_file.master_fqdn.content)
}