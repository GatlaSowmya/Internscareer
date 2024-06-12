variable "aws_region" {
    type = string
}
variable "key_name" {
    type = string
}
variable "tag" {
    type = list
}
variable "instance_type" {
    type = string
}
variable "ami" {
    type = string
}
variable "vpc_security_group_id" {
    type = string
}

variable "aws_lb" {
    type = string
}
variable "load_balancer_type" {
    type = string
}
variable "subnet_id" {
    type = list
}
variable "aws_lb_target_group" {
    type = string
}
variable "vpc_id" {
    type = string
}

