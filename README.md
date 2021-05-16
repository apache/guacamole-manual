About this README
=================

This README is intended to document the build process of the Apache Guacamole
manual for technical users who wish to contribute or who simply wish to build
the manual themselves.

The [latest version of the manual](http://guacamole.apache.org/doc/gug/) is
provided on the [Guacamole web site](http://guacamole.apache.org/), and
snapshot copies of each release are included in the [release
archives](http://guacamole.apache.org/releases/).


What is guacamole-manual?
=========================

The guacamole-manual package is the base documentation for the entire Guacamole
stack. It is written in [the "MyST" flavor of Markdown](https://myst-parser.readthedocs.io/en/latest/index.html).
MyST was chosen because:

 * As a variant of Markdown, it will be widely approachable and familiar.
 * It is supported by Sphinx.
 * It provides additional syntax for the features of reStructuredText that are
   absent from standard Markdown (like admonitions).
 * It provides the features of Markdown that are absent from reStructuredText
   (like nested inline formatting, including formatting within links or links
   within formatted text).

The build process involves running the Guacamole manual source through the
tooling provided by the Sphinx project, in particular "sphinx-build".


Building the manual
===================

1. Ensure [Sphinx](https://pypi.org/project/Sphinx/), the [Sphinx ReadTheDocs
   theme](https://pypi.org/project/sphinx-rtd-theme/),
   [sphinx-inline-tabs](https://pypi.org/project/sphinx-inline-tabs/), and the
   [MyST parser](https://pypi.org/project/myst-parser/) are installed. These can
   be installed using "pip":

   ```console
   $ pip install sphinx sphinx-rtd-theme sphinx-inline-tabs myst-parser
   ```

2. Run make:

   ```console
   $ make
   ```

   The manual will now be built using Sphinx. Once complete, the entire
   HTML version of the manual will be available within the `build/html/`
   directory in the root directory of the source tree.

Building and viewing the manual using Docker
============================================

The guacamole-manual package includes a `Dockerfile` that can be used to build
an Apache httpd Docker image that contains the Guacamole user manual.

By building and running the resulting container, a developer can work on the 
user manual without the need to install Sphinx on their workstation. The
resulting container can also be used to serve the  manual to Guacamole users on
a network.

**Docker CE version 1.6 or later is required to build the image.**

Build the Guacamole manual container image by running the following command in
the directory that contains this Dockerfile:

```console
$ docker image build -t guacamole/manual .
```

Run the resulting container using the following command:

```console
$ docker container run -p 8080:80 guacamole/manual
```

You'll see some startup messages from Apache httpd on your terminal when you 
start up the container. Once the container is running you can then view the 
HTML version of the manual by accessing http://localhost:8080 using your web 
browser.

If another process on the host is already using port 8080, you will need to 
change the corresponding argument in the command used to start the container.

As a developer working on the documentation, it will be necessary to stop the
container and run the build again each time you wish to see changes you've 
made to the documentation source.


Reporting problems
==================

Please report any bugs encountered by opening a new issue in the JIRA system
hosted at:

<https://issues.apache.org/jira/browse/GUACAMOLE>

