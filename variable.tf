variable "env" {
  default = "dev"
}

variable "ami" {
  default = "ami-0220d79f3f480ecf5"
}
variable "type" {
  default = "t3.small"
}
variable "vpc_security_group_ids" {
  default = [ "sg-099eff6e665cecd4a" ]
}
variable "record_type" {
  default = "A"
}
variable "zone_id" {
  default = "Z06404431NXHJ1IDZF7W2"
}

variable "components" {
  default = {
	mongodb   = " "
	redis     = " "
	mysql     = " "
	rabbitmq  = " "
  }
}