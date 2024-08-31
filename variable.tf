# variable for access key 

variable "access_key" {
  type        = string
  default     = ""
  description = "this variable is for access key"  
}

# variable fo secret key 

variable "secret_key" {
  type        = string
  default     = ""
  description = "this variable is for decret key"
  
}


# variable for region

variable "region" {
  type        = string
  default     = "us-west-1"
  description = "this variable is for region value"
}


# variable for cidr

variable "cidr" {
  type        = string
  default     = "160.160.0.0/16"
  description = "this variable is for cidr value"
}


# variable for public cidr

variable "publiccidr" {
  type        = string
  default     = "160.160.1.0/24"
  description = "this variable is for public cidr value"
}


# variable for pvt cidr

variable "pvtcidr" {
  type        = string
  default     = "160.160.2.0/24"
  description = "this variable is for pvt cidr value"
}

# variable for pvt cide database

variable "pvtcidrdb" {
  type        = string
  default     = "160.160.3.0/24"
  description = "this variable is for pvt cidr db value"
}

