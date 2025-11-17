resource "null_resource" "run_remote_script" {
  depends_on = [
    yandex_compute_instance.proxy,
    null_resource.get_master_fqdn,
    data.local_file.master_fqdn
  ]

  provisioner "remote-exec" {
    inline = [
      "echo 'Debug: Master FQDN is: ${trimspace(data.local_file.master_fqdn.content)}'",
      "echo 'Checking SSH key availability...'",
      "ls -la /home/ubuntu/.ssh/",
      "echo 'Executing script on master node via SSH...'",
      "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/ubuntu/.ssh/dataproc_key ubuntu@${trimspace(data.local_file.master_fqdn.content)} '/home/ubuntu/upload_data_to_hdfs.sh'",
      "EXIT_CODE=$?",
      "echo 'Remote script execution completed with exit code: $EXIT_CODE'",
      "exit $EXIT_CODE"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = yandex_compute_instance.proxy.network_interface[0].nat_ip_address
    }
  }
}