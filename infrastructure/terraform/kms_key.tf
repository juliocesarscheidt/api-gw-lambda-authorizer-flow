# resource "aws_kms_key" "customer_key" {
#   deletion_window_in_days = 7
#   key_usage = "ENCRYPT_DECRYPT"
#   is_enabled = true
#   tags = merge(var.tags, {
#     "Name" = "customer-key-${var.env}"
#   })
# }

# resource "aws_kms_alias" "customer_key_alias" {
#   name          = "alias/customer-key-${var.env}"
#   target_key_id = aws_kms_key.customer_key.key_id
# }
