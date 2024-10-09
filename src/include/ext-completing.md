::::{tab} Native Webapp (Tomcat)
Guacamole will only reread its configuration and load newly-installed
extensions during startup, so Tomcat will need to be restarted before these
changes can take effect. Restart Tomcat and give the new functionality a try.

*You do not need to restart guacd*.

:::{hint}
If Guacamole does not come back online after restarting Tomcat, **check the
logs**. Configuration problems may prevent Guacamole from starting up, and any
such errors will be recorded in Tomcat's logs.
:::
::::

::::{tab} Container (Docker)
The environment variables that configure the behavior of Docker can only be set
at the time the Docker container is created. To apply these configuration
changes, you will need to recreate the container.

If your Guacamole container was deployed using Docker Compose:
: Simply making the desired changes to your `docker-compose.yml` and running
  `docker compose up` is sufficient. Docker Compose will automatically
  recognize that the environment variables of the container have changed and
  recreate it.

If your Guacamole container was deployed manually (using `docker run`):
: You wll need to manually use `docker rm` to remove the old container and then
  manually recreate it with `docker run` and the new environment variables.

:::{hint}
If Guacamole does not come back online after recreating the container, **check
the Docker logs**. Configuration problems may prevent Guacamole from starting
up, and any such errors will be recorded in the Docker logs for the Guacamole
container.
:::
::::
