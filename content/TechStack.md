
# The Tech Stack

----

![Tech Stack](/images/banner2.jpg)

----

As mentioned in the intro, the main reason for this website existing is to
serve as a vehicle to play with cool tech!

The content is hosted within a [Gitbook application](https://www.gitbook.com/).
The app has been imported into Docker container, leaning heavily on the
techniques used here: https://github.com/humangeo/gitbook-docker/.

The docker image is then pushed to a Kubernetes cluster running on Google
Cloud Platform. This infrastructure is described and deployed using Terraform.

----

| Docker | Kubernetes | GCP |
| -- | -- | -- |
| ![Docker](/images/docker.png) | ![K8s](/images/kubernetes.png) | ![GCP](/images/gcp.png) |

----

At the moment it is automated through a set of bash scripts, and everything is
stored in version control - see https://github.com/alexdmoss/moss.work.

The plan is for this approach to continue to evolve - for example rolling in
better automation of the release process, the use of a CI/CD tool, and
automated testing.

----
