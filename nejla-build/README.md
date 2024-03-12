# Base image for building nejla projects

This image is based in Debian and comes with the following packages installed:

* libicu (dependency of text)
* libpq (dependency of PostgreSQL libraries)
* libtinfo-dev (dependency of Stack)
* msmtp-mta (for email handling)
* netbase (dependency of Stack)
* xz-utils (dependency of Stack)
* msmtp-mta (email handling)
* locales
* git
* stack (for building haskell projects)
* docker-ce
* ssh
* rustup (for building rust projects)
