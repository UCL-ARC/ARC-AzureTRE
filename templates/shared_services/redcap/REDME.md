# REDCap Shared service

The REDCap shared service requires a docker image to run the webapp.
Due to the [licencing conditions](https://projectredcap.org/partners/termsofuse/)
this cannot be pushed to a public registry. Therefore, to deploy a REDCap shared service
you must download the source code as a .zip file from the [community website](https://redcap.vanderbilt.edu/community/)
once you have a login and plaze the zip file in [/app](./app/) in this directory, then
in the root of this repositroy run

```bash
make build-and-push-redcap-app
```

Note: this requires deployment of the bootstrap infrastructure, namly the Azure container registry.
