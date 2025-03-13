resource "aws_key_pair" "ec2_access_key" {
  key_name   = "ec2_key"
  public_key = var.ssh_public_key  # Define this variable
}
