# Linux Academy Terraform Notes

After you create your `main.tf` file in your Terraform folder, run `terraform`
`init` and it will download the required plugins for the provider(s) configured
in the `main.tf` file.

Additionally, a message will show up that will recommend or caution that if
you need to version lock a provider, it should be added to the provider config
inside of the `.tf` file.  The sample Terraform code looks as follows:

```terraform
resource "docker_image" "linux_academy" {
    name = "ghost:latest"
}
```

The plugins for the folder will be downloaded into the `.terraform/` directory
where `main.tf` lives.  Navigate the folder structure 