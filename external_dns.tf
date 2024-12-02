
# data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "AllowExternalDNSUpdates" {
  name        = "AllowExternalDNSUpdates"
  path        = "/"
  policy = file("${path.module}/AllowExternalDNSUpdates.json")
}

resource "aws_iam_role" "external-dns-irsa-role" {
  name = "external-dns-irsa-role"
  assume_role_policy = jsonencode({

    "Version": "2012-10-17",
    "Statement": [
        {
            Effect: "Allow",
            Principal: {
                Federated: aws_iam_openid_connect_provider.default.arn
            },
            Action: "sts:AssumeRoleWithWebIdentity",
            Condition: {
                StringEquals: {
                    "${aws_iam_openid_connect_provider.default.url}:sub": "system:serviceaccount:default:external-dns",
                    "${aws_iam_openid_connect_provider.default.url}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]

})
}

resource "aws_iam_role_policy_attachment" "external-dns-irsa-role" {
  role       = aws_iam_role.external-dns-irsa-role.name
  policy_arn = aws_iam_policy.AllowExternalDNSUpdates.arn
}