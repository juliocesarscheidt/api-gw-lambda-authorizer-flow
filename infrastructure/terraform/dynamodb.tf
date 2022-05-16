resource "aws_dynamodb_table" "users_tbl" {
  name           = "users_tbl_${var.env}"
  hash_key       = "email"
  stream_enabled = false
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "email"
    type = "S"
  }
}
