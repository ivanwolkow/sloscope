variable "domain" {
  type    = string
  default = "sloscope.eu"
}

variable "web_records" {
  description = "Explicitly managed A, AAAA and CNAME records. Import existing records before applying."
  type = map(object({
    type    = string
    name    = string
    ttl     = optional(number, 3600)
    address = optional(string)
    cname   = optional(string)
  }))

  validation {
    condition = alltrue([
      for record in values(var.web_records) :
      contains(["A", "AAAA", "CNAME"], record.type) &&
      record.ttl >= 60 && record.ttl <= 3600 &&
      (record.type == "CNAME" ? record.cname != null && record.address == null : record.address != null && record.cname == null)
    ])
    error_message = "Use A/AAAA with address or CNAME with cname, and TTL between 60 and 3600."
  }
}
