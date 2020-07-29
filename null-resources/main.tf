resource "null_resource" "res_a" {
}
resource "null_resource" "res_b" {
  depends_on = [null_resource.res_a]
}
resource "null_resource" "res_c" {
  depends_on = [null_resource.res_b]
}

resource "null_resource" "res_d" {
  depends_on = [
      null_resource.res_b,
      null_resource.res_c,
  ]
}