# # define AWS Region
# variable "region" {
#   description = "This is aws region"
#   type        = string
#   default     = "us-east-1"
# }

# # define subnet variables
# variable "subnet_cidr_private" {
#   description = "cidr blocks for the private subnets"
#   default     = ["10.20.20.0/28", "10.20.20.16/28"]
#   type        = list(any)
# }

# # define availability zones
# variable "availability_zone" {
#   description = "availability zones for the private subnets"
#   default     = ["us-east-1a", "us-east-1b"]
#   type        = list(any)
# }
