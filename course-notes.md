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

## Interpolation Notes

Reference the official Terraform docs for more specific information.  This could
be considered some side homework to reference but it also lists built-in
functions that can be used in a manifest:

https://www.terraform.io/docs/configuration/interpolation.html

This is used to explain how variables are used in the `main.tf`.  Here's the
snippet:

```plaintext
image = "${docker_image.la_docker_image.latest}"
```

In the above, the value for `docker_image.la_docker_image.latest` can be shown
using `terraform show`:

```plaintext
docker_image.la_docker_image:
  id = sha256:7d38940f80950d104de4dfb4ed60259e20ba00c13803800700099b1de9e3a06bghost:latest
  latest = sha256:7d38940f80950d104de4dfb4ed60259e20ba00c13803800700099b1de9e3a06b
  name = ghost:latest
```

The above value is derived from the namespace of that Terraform object
`docker_image.la_docker_image`'s property of `latest`.  That is reflected when
doing a `terraform show` after doing an apply action and it succeeding:

```plaintext
[...]
docker_container.la_docker_container:
[...]
  image = sha256:7d38940f80950d104de4dfb4ed60259e20ba00c13803800700099b1de9e3a06b
[...]
```

Finally, the `terraform destroy` command is introduced to demonstrate the
teardown of an environment based on the objects Terraform is managing.

## Tainting and Updating Resources

`terraform taint <resourceId>` will force a resource to be refreshed when the next
`terraform apply` is executed against the manifest *only if the resource
requires a refreshed resource to stay compliant with the manifest*

`terraform untaint <resourceId>` will undo the resource marked for a forced
change

A sample workflow to demonstrate this would be:

- Run sample `main.tf` to build container with first image
- Change image to a different image; Run `terraform plan` to see it reference
  the asset be upgraded in-place
- Image is updated in-place; Container built in previous `apply` does not take
  new image; `terraform taint <resourceId>` to point at the container(s) to be
  refreshed
- `terraform apply` to refresh the containers and accept the new image
  configured in an earlier step

## Terraform Console and Output

`terraform show` lists all the deployed objects and their attributes

To test the interpolation of an object's attribute, use `terraform console`.
The Terraform Console is an interactive way of testing the interpolation of
items in an inventory.  I'm thinking of it as either a due diligence step
when in doubt about the format of something that needs to be interpolated as
well as a good debugging tool.



