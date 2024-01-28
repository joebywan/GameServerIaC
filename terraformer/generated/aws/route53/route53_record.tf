resource "aws_route53_record" "tfer--Z01039561OO2DM57CFK0S_ark-002E-ecs-002E-knowhowit-002E-com-002E-_A_" {
  name                             = "ark.ecs.knowhowit.com"
  records                          = ["1.1.1.1"]
  ttl                              = "30"
  type                             = "A"
  zone_id                          = "${aws_route53_zone.tfer--Z01039561OO2DM57CFK0S_ecs-002E-knowhowit-002E-com.zone_id}"
}

resource "aws_route53_record" "tfer--Z01039561OO2DM57CFK0S_ecs-002E-knowhowit-002E-com-002E-_NS_" {
  name                             = "ecs.knowhowit.com"
  records                          = ["ns-1431.awsdns-50.org.", "ns-1979.awsdns-55.co.uk.", "ns-534.awsdns-02.net.", "ns-59.awsdns-07.com."]
  ttl                              = "172800"
  type                             = "NS"
  zone_id                          = "${aws_route53_zone.tfer--Z01039561OO2DM57CFK0S_ecs-002E-knowhowit-002E-com.zone_id}"
}

resource "aws_route53_record" "tfer--Z01039561OO2DM57CFK0S_ecs-002E-knowhowit-002E-com-002E-_SOA_" {
  name                             = "ecs.knowhowit.com"
  records                          = ["ns-59.awsdns-07.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
  ttl                              = "900"
  type                             = "SOA"
  zone_id                          = "${aws_route53_zone.tfer--Z01039561OO2DM57CFK0S_ecs-002E-knowhowit-002E-com.zone_id}"
}

resource "aws_route53_record" "tfer--Z01039561OO2DM57CFK0S_minecraft-002E-ecs-002E-knowhowit-002E-com-002E-_A_" {
  name                             = "minecraft.ecs.knowhowit.com"
  records                          = ["13.239.118.140"]
  ttl                              = "30"
  type                             = "A"
  zone_id                          = "${aws_route53_zone.tfer--Z01039561OO2DM57CFK0S_ecs-002E-knowhowit-002E-com.zone_id}"
}

resource "aws_route53_record" "tfer--Z01039561OO2DM57CFK0S_valheim-002E-ecs-002E-knowhowit-002E-com-002E-_A_" {
  name                             = "valheim.ecs.knowhowit.com"
  records                          = ["13.210.228.63"]
  ttl                              = "30"
  type                             = "A"
  zone_id                          = "${aws_route53_zone.tfer--Z01039561OO2DM57CFK0S_ecs-002E-knowhowit-002E-com.zone_id}"
}
