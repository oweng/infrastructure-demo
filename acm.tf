## Would love to use the ACM terraform module but it is very 
## ACM specific with no way to generate a self-signed certificate

resource "tls_private_key" "demo" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "demo" {
  private_key_pem = tls_private_key.demo.private_key_pem
  subject {
    common_name  = "demo.com"
    organization = "demo apps, Inc"
  }

  validity_period_hours = 120

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "demo" {
  private_key      = tls_private_key.demo.private_key_pem
  certificate_body = tls_self_signed_cert.demo.cert_pem
}
