output "alb_dns" {
  value = "${aws_alb.public.dns_name}"
}

output "dns_record" {
  value = "${aws_route53_record.app.fqdn}"
}
