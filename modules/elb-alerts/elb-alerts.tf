resource "aws_cloudwatch_metric_alarm" "elb-unhealthy-host-alert" {
  alarm_name                = "${var.service_name}-${var.environment}-${var.friendly-lb-name}-elb-unhealthy-host-alert"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "${var.unhealthy-host-evaluation-periods}"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ELB"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "This metric monitors the ${var.friendly-lb-name} ELB for unhealthy hosts. Even one unhealthy host sends a non-critical alert"
  insufficient_data_actions = []

  actions_enabled = "${var.actions_enabled  != "" ? 1 : 0}"
  count           = "${var.lb-name != "" ? 1 : 0}"
  alarm_actions   = ["${data.aws_sns_topic.non-critical-alerts.arn}"]

  dimensions {
    LoadBalancerName = "${var.lb-name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "api-elb-zero-healthy-host-alert" {
  alarm_name                = "${var.service_name}-${var.environment}-${var.friendly-lb-name}-elb-healthy-host-alert"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "3"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ELB"
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = "0"
  alarm_description         = "This metric monitors the ${var.friendly-lb-name} ELB for healthy hosts. It sends a critical alert if there are no healthy hosts"
  insufficient_data_actions = []

  actions_enabled = "${var.actions_enabled  != "" ? 1 : 0}"
  count           = "${var.lb-name != "" ? 1 : 0}"
  alarm_actions   = ["${data.aws_sns_topic.critical-alerts.arn}"]

  dimensions {
    LoadBalancerName = "${var.lb-name}"
  }
}
