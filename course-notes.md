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

## Terraform Variables

**NOTE**: Please reference the Terraform docs for more thorough information
on Terraform variables

The syntax for a variable in a `.tf.` file is as follows:

```terraform
variable "image" {
    description = "image for container"
}
```

The above syntax does not have any value(s) assigned to the variable beyond a
description so when a `terraform apply` is ran, it will prompt a use for a value
at runtime:

```plaintext
:~/gitroot/terraform_linux_academy$ terraform apply
var.image
  image for container

  Enter a value: 
```

Specifying `default` inside of the variable resource will fill the variable with
a value if another one is not provided at runtime.

## Breaking Out Our Variables and Outputs

Any file with the `.tf` suffix will be used by Terraform when running a
`terraform apply`.

As part of this exercise, the original `main.tf` file will have its variables
and outputs sections moved into their own discreet `.tf` files in the project.

When you run a `terraform apply` after that, it still runs the same way it
would if it was the original `main.tf` monolith but except now it's in a more
manageable fashion.

## Introduction to Modules

This introduces the idea of breaking out a Terraform project into modules to
make the assets more manageable.  The resultant base structure would look
similar to this:

```plaintext
.
├── container
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── image
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── main.tf
├── outputs.tf
└── variables.tf
```

## The Image Module

This exercise consisted of moving the `image` resources out of `main.tf` and
into its own module.  Within the module, you'll need to also do a 
`terraform init` to prepare the module with the appropriate resources.

Here's the diff output from git demonstrating the components of the image module
and the contents that were added:

```diff
:~/gitroot/terraform_linux_academy$ git diff --cached
diff --git a/image/main.tf b/image/main.tf
index e69de29..2fa8fe3 100644
--- a/image/main.tf
+++ b/image/main.tf
@@ -0,0 +1,4 @@
+# Download the latest Ghost image
+resource "docker_image" "la_docker_image" {
+    name = "${var.image}"
+}
diff --git a/image/outputs.tf b/image/outputs.tf
index e69de29..3499f27 100644
--- a/image/outputs.tf
+++ b/image/outputs.tf
@@ -0,0 +1,3 @@
+output "image_out" {
+    value = "${docker_image.la_docker_image.latest}"
+}
\ No newline at end of file
diff --git a/image/variables.tf b/image/variables.tf
index e69de29..37e2ce0 100644
--- a/image/variables.tf
+++ b/image/variables.tf
@@ -0,0 +1,3 @@
+variable "image" {
+    description = "image for container"
+}
\ No newline at end of file
```

## The Container Module

This module is the same as the `image` module.  The diff of the project will
be placed into the notes as a reference:

```diff
:~/gitroot/terraform_linux_academy$ git diff --cached
diff --git a/container/main.tf b/container/main.tf
index e69de29..7990bb5 100644
--- a/container/main.tf
+++ b/container/main.tf
@@ -0,0 +1,9 @@
+# Start the Container
+resource "docker_container" "la_docker_container" {
+    name = "${var.container_name}"
+    image = "${var.image}"
+    ports {
+        internal = "${var.container_port_internal}"
+        external = "${var.container_port_external}"
+    }
+}
\ No newline at end of file
diff --git a/container/outputs.tf b/container/outputs.tf
index e69de29..093e592 100644
--- a/container/outputs.tf
+++ b/container/outputs.tf
@@ -0,0 +1,8 @@
+# Output the IP Address of the Container
+output "ipv4_addr" {
+    value = "${docker_container.la_docker_container.ip_address}"
+}
+
+output "container_name" {
+    value = "${docker_container.la_docker_container.name}"
+}
diff --git a/container/variables.tf b/container/variables.tf
index e69de29..0dff3e8 100644
--- a/container/variables.tf
+++ b/container/variables.tf
@@ -0,0 +1,15 @@
+variable "image" {
+    description = "name for container"
+}
+
+variable "container_name" {
+    description = "name for container"
+}
+
+variable "container_port_internal" {
+    description = "container port mapping"
+}
+
+variable "container_port_external" {
+    description = "host port mapping to container port"
+}
\ No newline at end of file
diff --git a/main.tf b/main.tf
index 6961112..d3f5a12 100755
--- a/main.tf
+++ b/main.tf
@@ -1,9 +1 @@
-# Start the Container
-resource "docker_container" "la_docker_container" {
-    name = "${var.container_name}"
-    image = "${docker_image.la_docker_image.latest}"
-    ports {
-        internal = "${var.container_port_internal}"
-        external = "${var.container_port_external}"
-    }
-}
+^M
```

## The Root Module

The root module ends up acting as the binder for the modules that exist as
child folders.

We learn that using the interpolation syntax, we now use the `module.` inside
of the curly braces to reference `outputs` from the module.

Here's the new `main.tf` in the root:

```terraform
# Download the latest Ghost image
module "image" {
    source = "./image"
    image = "${var.image}"
}

# Start the Container

module "container" {
    source = "./container"
    image = "${module.image.image_out}"
    container_name = "${var.container_name}"
    container_port_internal = "${var.container_port_internal}"
    container_port_external = "${var.container_port_external}"
}
```

The above shows the transpositioning of values between modules.  The variables
defined in the modules are the attributes that need to be populated in `main.tf`

The `variables.tf` in the root will be the central point of management of values
for the project while the `variables.tf` in 

I'm shortcutting some of the finer detail because a lot of these patterns were
learned from using Puppet.

For completeness, the diff of the project will reflect all of the changes made
to show the transition from `main.tf` monolith to a modularized implementation.

```diff
:~/gitroot/terraform_linux_academy$ git diff --cached
diff --git a/container/variables.tf b/container/variables.tf
index 0dff3e8..8dc51ac 100644
--- a/container/variables.tf
+++ b/container/variables.tf
@@ -1,15 +1,4 @@
-variable "image" {
-    description = "name for container"
-}
-
-variable "container_name" {
-    description = "name for container"
-}
-
-variable "container_port_internal" {
-    description = "container port mapping"
-}
-
-variable "container_port_external" {
-    description = "host port mapping to container port"
-}
\ No newline at end of file
+variable "image" {}
+variable "container_name" {}
+variable "container_port_internal" {}
+variable "container_port_external" {}
diff --git a/main.tf b/main.tf
index d3f5a12..9367690 100755
--- a/main.tf
+++ b/main.tf
@@ -1 +1,15 @@
+# Download the latest Ghost image^M
+module "image" {^M
+    source = "./image"^M
+    image = "${var.image}"^M
+}^M
 
+# Start the Container^M
+^M
+module "container" {^M
+    source = "./container"^M
+    image = "${module.image.image_out}"^M
+    container_name = "${var.container_name}"^M
+    container_port_internal = "${var.container_port_internal}"^M
+    container_port_external = "${var.container_port_external}"^M
+}
\ No newline at end of file
diff --git a/outputs.tf b/outputs.tf
index d33dc15..5bd0997 100644
--- a/outputs.tf
+++ b/outputs.tf
@@ -1,8 +1,8 @@
 # Output the IP Address of the Container
 output "IP Address" {
-    value = "${docker_container.la_docker_container.ip_address}"
+    value = "${module.container.ipv4_addr}"
 }
 
-output "Container Name" {
-    value = "${docker_container.la_docker_container.name}"
-}
+output "container_name" {
+    value = "${module.container.container_name}"
+}
\ No newline at end of file
diff --git a/variables.tf b/variables.tf
index 4ec7a3f..0dff3e8 100644
--- a/variables.tf
+++ b/variables.tf
@@ -1,14 +1,15 @@
+variable "image" {
+    description = "name for container"
+}
+
 variable "container_name" {
     description = "name for container"
-    default = "blog"
 }
 
 variable "container_port_internal" {
     description = "container port mapping"
-    default = "2368"
 }
 
 variable "container_port_external" {
     description = "host port mapping to container port"
-    default = "80"
-}
+}
\ No newline at end of file
```

## Maps and Lookups

Maps is a synonym to a dictionary (key/value pair[s])

Lesson introduces a few things:

- The syntax of a map declaration in `variables.tf` would look something like
  this:

```teraform
variable "image" {
    description = "image for container"
    type = "map"
    default = {
        dev = "ghost:latest"
        prod = "ghost:alpine"
    }
}
```

Note that it's still a `variable` resource but the type has been changed to be
a map.  The default values with the curly braces are the values that are selected
dependent upon the key that is passed to the map.

The syntax to look up a map is:

```terraform
${lookup(var.input, var.mapToLookup)}
```

The `lookup()` method takes an input for a key in the first parameter and then
the map to look into in the second parameter.

The end of the lesson brings up a suggestion on how to troubleshoot any
Terraform issues you may encounter by defining a `TF_VAR_[variableName]` in the
system's environment variables.  Then, use `terraform console` after the var(s)
you're looking to troubleshoot are set.

More information about environment variables for Terraform can be found in the
official docs here:

https://www.terraform.io/docs/configuration/environment-variables.html

## Terraform Workspaces

Much like in Python with `virtualenv`, Terraform has the concept of workspaces
that allow for multiple environments to be deployed in the same Terraform
folder.

This is done by tracking states unique to each workspace.

The following is a quick list of commands to manage workspaces:

- `terraform workspace new [name]` - Creates a new workspace with the specified
  name
- `terraform workspace select [name]` - Changes the current workspace to the
  specified name
  - `default` is the name of the default workspace
- `terraform workspace list` - Lists all the current workspaces in the Terraform
  folder
- `terraform workspace delete [name]` - Deletes the named workspace

## Breaking Out Our Variable Definitions

This introduces the `variables.tfvars` file.  This file allows for sensitive
information to live in a separate file that doesn't have to be shared with the
project while not impacting project reuse or repurposing.

This requires the following for a project that already has values assigned in a
`variables.tf` file:

1. Create the `variables.tfvars` file
2. If applicable, remove any `default` values from variables in the list
  1. Those will likely need to be copied out to put into the next step
3. Enter the values removed from `variables.tf` into `variables.tfvars`
  1. Ensure that the format for the input values for the variable type defined
     in `variables.tf` match the format entered into `variables.tfvars`
4. For security, add a line in `.gitignore` to not version any `.tfvars` file

## Null Resources and Local-Exec

Null Resources allow for scripts to be ran against an environment without having
to redeploy anything.

`null_resource` is a resource type in a `.tf` file.

This lesson also introduces the `provisioner` keyword for a `.tf` file and this
lesson uses `local-exec` to run local commands on the system Terraform is being
executed from.

More information on the `null_resource` and other `provisioner` types can be
found in the official docs:

Providers will have resources associated with them.  For all of these lessons so
far, we've been using the `docker` provider.  Below is the config for resources
and provisioners:

Resources: https://www.terraform.io/docs/configuration/resources.html
Provisioners: https://www.terraform.io/docs/provisioners/index.html

## AWS and Cloud9 Setup

This just ran through setting up an environment in Cloud9 for later lessons.
No learning materials for Terraform were reviewed here

## Terraform Installation on Cloud9

Just goes over installing Terraform in the Cloud9 environment.  It's the same
process as if you were installing it on premise.

- Download the zip file
- Unpack the zip file to `/usr/local/bin/`
  - It should just be a single binary file
- Run `terraform` from the shell to spot check its availability in the shell

## What We're Going to Deploy

The infrastructure to be deployed will be:

- 2 Availability Zones; In each AZ
  - A web server will be deployed; It will echo its subnet out onto its page
- Route tables
  - One public
  - One private
- An S3 bucket

The github repo that these notes have been kept in now includes a `cloud9-env`
folder.  Here's the file and folder hierarchy:

```plaintext
:~/environment/terraform_linux_academy/cloud9-env (master) $ tree
.
├── compute
│   ├── main.tf
│   ├── outputs.tf
│   ├── userdata.tpl
│   └── variables.tf
├── main.tf
├── networking
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── outputs.tf
├── storage
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── variables.tf
```

The `userdata.tpl` file in the `compute` folder is a template file we'll learn
to utilize later on.

## Storage Part 1: The S3 Bucket and Random ID

Since these later sections are assuming work will be happening on Cloud9, the
notes will likely be added as comments into the `.tf` files themselves.

For this section, the `storage` module was started and introduced some new
resources.  Direct links to the documentation for those resources have been
added to the module's source code via comments.

## Storage Part 2: Root Module Files

This lesson focused on bringing the storage module's resources into the root
module.  We did a `terraform destroy` on the standalone `storage` deployment to
to confirm the redeployment of the storage module from the root so that the
state may be tracked there.

