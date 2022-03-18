resource "aws_cloudwatch_log_group" "diploma-lg" {
  name              = "/aws/eks/${var.entity_name}/cluster"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "fluentbit-lg" {
  name              = "/aws/eks/${var.entity_name}/fluentbit"
  retention_in_days = 7
}

resource "aws_cloudwatch_dashboard" "diploma-dashboard" {
  dashboard_name = "${var.entity_name}"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 16,
            "y": 0,
            "width": 8,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "${aws_lb.diploma-alb.arn_suffix}" ]
                ],
                "region": "${var.region}",
                "title": "ELB: 5xx errors"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 8,
            "width": 8,
            "height": 4,
            "properties": {
                "metrics": [
                    [ { "expression": "METRICS()/5", "label": "Request", "id": "e1" } ],
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "${aws_lb_target_group.diploma-app-prod-tg.arn_suffix}", "LoadBalancer", "${aws_lb.diploma-alb.arn_suffix}", { "id": "m1", "visible": false, "yAxis": "left", "label": "Rate" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "stat": "Average",
                "period": 300,
                "title": "Prod: request rate"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 8,
            "height": 4,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "${aws_lb_target_group.diploma-app-prod-tg.arn_suffix}", "LoadBalancer", "${aws_lb.diploma-alb.arn_suffix}" ]
                ],
                "region": "${var.region}",
                "title": "Prod: 5xx errors"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 4,
            "width": 8,
            "height": 4,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${aws_lb_target_group.diploma-app-prod-tg.arn_suffix}", "LoadBalancer", "${aws_lb.diploma-alb.arn_suffix}" ]
                ],
                "region": "${var.region}",
                "title": "Prod: Latency"
            }
        },
        {
            "type": "metric",
            "x": 16,
            "y": 6,
            "width": 8,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RejectedConnectionCount", "LoadBalancer", "${aws_lb.diploma-alb.arn_suffix}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "title": "ELB: Saturation",
                "period": 300,
                "stat": "Sum"
            }
        },
        {
            "type": "metric",
            "x": 8,
            "y": 0,
            "width": 8,
            "height": 4,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", "${aws_lb_target_group.diploma-app-stg-tg.arn_suffix}", "LoadBalancer", "${aws_lb.diploma-alb.arn_suffix}" ]
                ],
                "region": "${var.region}",
                "title": "Staging: 5xx errors",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 8,
            "y": 4,
            "width": 8,
            "height": 4,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", "${aws_lb_target_group.diploma-app-stg-tg.arn_suffix}", "LoadBalancer", "${aws_lb.diploma-alb.arn_suffix}" ]
                ],
                "region": "${var.region}",
                "title": "Staging: Latency",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 8,
            "y": 8,
            "width": 8,
            "height": 4,
            "properties": {
                "metrics": [
                    [ { "expression": "METRICS()/5", "label": "Request", "id": "e1", "region": "${var.region}" } ],
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "${aws_lb_target_group.diploma-app-stg-tg.arn_suffix}", "LoadBalancer", "${aws_lb.diploma-alb.arn_suffix}", { "id": "m1", "visible": false, "yAxis": "left", "label": "Rate" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "stat": "Average",
                "period": 300,
                "title": "Prod: request rate"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 12,
            "width": 24,
            "height": 7,
            "properties": {
                "query": "SOURCE '/aws/eks/nr-devops-diploma/fluentbit' | fields @timestamp, kubernetes.pod_name, log\n| sort @timestamp desc\n| filter (kubernetes.namespace_name = \"production\")\n| limit 10",
                "region": "${var.region}",
                "stacked": false,
                "title": "Production latest logs",
                "view": "table"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 19,
            "width": 24,
            "height": 7,
            "properties": {
                "query": "SOURCE '/aws/eks/nr-devops-diploma/fluentbit' | fields @timestamp, kubernetes.pod_name, log\n| sort @timestamp desc\n| filter (kubernetes.namespace_name = \"staging\")\n| limit 10",
                "region": "${var.region}",
                "stacked": false,
                "title": "Staging latest logs",
                "view": "table"
            }
        }
    ]
}
EOF
}