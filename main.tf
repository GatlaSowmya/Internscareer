provider "aws" { 
 region = var.aws_region
} 
terraform {
  cloud {
    organization = "GSowmya"

    workspaces {
      name = "internscareer"
    }
  }
} 

resource "aws_key_pair" "test" { 
 key_name = var.key_name
 public_key = file("./prod.pub") 
} 
resource "aws_instance" "interns1" { 
 ami = var.ami
 instance_type = var.instance_type
 subnet_id = var.subnet_id[1]
 key_name = aws_key_pair.test.key_name 
 vpc_security_group_ids = [var.vpc_security_group_id]
 tags = { 
 Name = var.tag[0]
 } 
 connection {
 type = "ssh" 
 user = "ubuntu" 
 private_key = file("./prod")  
 host = self.public_ip 
 timeout = "1m" 
 agent = false 
 } 
 provisioner "remote-exec" { 
 inline = [ 
 "sudo apt-get update", 
 "sudo apt-get install nginx -y",
 "touch index.nginx-debian.html",
 "echo '<h1> This is My Web Application 1 </h1>' | tee index.nginx-debian.html",
 "sudo mv index.nginx-debian.html /var/www/html/index.nginx-debian.html",
 "sudo systemctl restart nginx.service"
 ] 
 } 
} 
resource "aws_instance" "interns2" { 
 ami = var.ami
 instance_type = var.instance_type
 subnet_id = var.subnet_id[0]
 key_name = aws_key_pair.test.key_name 
 vpc_security_group_ids = [var.vpc_security_group_id]
 tags = { 
 Name = var.tag[1] 
 } 
 connection {
 type = "ssh" 
 user = "ubuntu" 
 private_key = file("./prod")   
 host = self.public_ip 
 timeout = "1m" 
 agent = false 
 } 
 provisioner "remote-exec" { 
 inline = [ 
 "sudo apt-get update", 
 "sudo apt-get install nginx -y",
 "touch index.nginx-debian.html",
 "echo '<h1> This is My Web Application </h1>' | tee index.nginx-debian.html",
 "sudo mv index.nginx-debian.html /var/www/html/index.nginx-debian.html",
 "sudo systemctl restart nginx.service"
 ] 
 } 
}
resource "aws_lb" "alb" {
  name               = var.aws_lb
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.vpc_security_group_id]
  subnets            = var.subnet_id[*]
  tags = {
    Name = var.aws_lb
  }
}

resource "aws_lb_target_group" "alb" {
  name     = var.aws_lb_target_group
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    interval            = 15
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
  tags = {    
    Name = var.aws_lb_target_group
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

resource "aws_lb_target_group_attachment" "interns1" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_instance.interns1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "interns2" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_instance.interns2.id
  port             = 80
}
