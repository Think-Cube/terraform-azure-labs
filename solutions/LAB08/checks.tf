# Checks run after every plan and apply - they warn, they do not block.
check "storage_uses_https" {
  assert {
    condition     = startswith(module.storage.primary_blob_endpoint, "https://")
    error_message = "The blob endpoint must use HTTPS."
  }
}
