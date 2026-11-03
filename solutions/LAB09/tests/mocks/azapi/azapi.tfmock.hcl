# Mock values for azapi in `terraform test` - "output" is the (dynamic) ARM response.

mock_resource "azapi_resource" {
  defaults = {
    id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Network/applicationSecurityGroups/asg-mock"
    output = { properties = { provisioningState = "Succeeded" } }
  }
}

mock_data "azapi_resource" {
  defaults = {
    output = { tls = "TLS1_2", access_tier = "Hot", created_time = "2026-01-01T00:00:00Z" }
  }
}
