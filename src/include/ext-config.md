Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

If you have installed Guacamole natively under [Apache Tomcat](https://tomcat.apache.org/) or similar:
: Modifying the configuration of a native installation of Guacamole involves
  modifying the contents of `GUACAMOLE_HOME` ([Guacamole's configuration
  directory](guacamole-home)), which is located at `/etc/guacamole` by default.

If you have installed Guacamole using the provided Docker images:
: The modifications to `GUACAMOLE_HOME` are instead managed for you by the
  Docker image based on environment variables supplied when the Docker container
  was created.
