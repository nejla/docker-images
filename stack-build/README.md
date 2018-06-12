# Base image for building stack-based Haskell projects

This image is based in Debian and comes with the following packages installed:

* libicu (dependency of text library)
* libpq (dependency of postgres libraries)
* libtinfo-dev (required by stack)
* msmtp-mta (for email handling)
* netbase (dependency of stack)
* xz-utils (dependency of stack)
* msmtp-mta (email handling)
* locales
* git
* stack
* docker-ce
* ssh
