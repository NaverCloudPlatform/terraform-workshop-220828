resource "ncloud_login_key" "loginkey" {
  key_name = "key-workshop"
}

resource "local_file" "private_key" {
  filename        = format("./%s.pem", ncloud_login_key.loginkey.key_name)
  content         = ncloud_login_key.loginkey.private_key
  file_permission = "0400"
}