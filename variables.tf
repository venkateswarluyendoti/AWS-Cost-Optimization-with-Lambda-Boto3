# EC2 Instances
resource "aws_instance" "test_ec2" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "test-instance-${count.index + 1}"
  }
}

# EBS Snapshots
resource "aws_ebs_snapshot" "test_snapshot" {
  count     = var.instance_count
  volume_id = aws_instance.test_ec2[count.index].root_block_device_volume_id
  description = "Test snapshot for volume ${aws_instance.test_ec2[count.index].root_block_device_volume_id}"
}

# Variables
variable "instance_count" {
  description = "Number of EC2 instances to create"
  default     = 5
}

variable "ami_id" {
  description = "AMI ID for Ubuntu Server 24.04 LTS"
  default     = "ami-0c55b159cbfafe1f0" # Replace with correct AMI ID for your region
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  default     = null # Set to your key pair name or leave null
}