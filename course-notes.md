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

Then, run a `terraform plan` to get what the expect output of the manifest
will be once Terraform is done working:

```plaintext
:~/gitroot/terraform_linux_academy$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + docker_image.linux_academy
      id:     <computed>
      latest: <computed>
      name:   "ghost:latest"


Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Then, run `terraform apply` to execute the manifest:

```plaintext
:~/gitroot/terraform_linux_academy$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + docker_image.linux_academy
      id:     <computed>
      latest: <computed>
      name:   "ghost:latest"


Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_image.linux_academy: Creating...
  latest: "" => "<computed>"
  name:   "" => "ghost:latest"
docker_image.linux_academy: Still creating... (10s elapsed)
docker_image.linux_academy: Still creating... (20s elapsed)
docker_image.linux_academy: Creation complete after 28s (ID: sha256:7d38940f80950d104de4dfb4ed60259e...c13803800700099b1de9e3a06bghost:latest)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Once completed, you can run `terraform show` and it will display all the
artifact information:

```plaintext
:~/gitroot/terraform_linux_academy$ terraform show
docker_image.linux_academy:
  id = sha256:7d38940f80950d104de4dfb4ed60259e20ba00c13803800700099b1de9e3a06bghost:latest
  latest = sha256:7d38940f80950d104de4dfb4ed60259e20ba00c13803800700099b1de9e3a06b
  name = ghost:latest
```

So, the four commands are:

- `terraform init` - Processes the manifest and downloads any providers
  necessary to perform the action
- `terraform plan` - Like a `noop` in Puppet, it will do a test flight of the
  manifest and return the expected output
- `terraform apply` - Runs the manifest commands against the environment(s)
- `terraform show` - Lists all the artifacts that resulted from `terraform` 
  `apply`

