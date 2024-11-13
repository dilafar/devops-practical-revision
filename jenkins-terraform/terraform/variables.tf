variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
    default = "10.0.10.0/24"
}
variable "availability_zone" {
    default = "eu-west-3a"
}
variable "env_prefix" {
    default = "dev"
}
variable "my_ip" {
    default = "175.157.42.171/32"
}
variable "jenkins_ip" {
    default = "139.40.56.134/32"
}
variable "instance_type" {
    default = "t2.micro"
}
