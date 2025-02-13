data "local_file" "startup_script" {
  filename = "${path.module}/init.sh"
}
