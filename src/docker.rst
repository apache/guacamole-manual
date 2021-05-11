.. _guacamole-docker:

Installing Guacamole with Docker
================================

Guacamole can be deployed using Docker, removing the need to build
guacamole-server from source or configure the web application manually.
The Guacamole project provides officially-supported Docker images for
both Guacamole and guacd which are kept up-to-date with each release.

A typical Docker deployment of Guacamole will involve three separate
containers, linked together at creation time:

``guacamole/guacd``
   Provides the guacd daemon, built from the released guacamole-server
   source with support for VNC, RDP, SSH, telnet, and Kubernetes.

``guacamole/guacamole``
   Provides the Guacamole web application running within Tomcat 8 with
   support for WebSocket. The configuration necessary to connect to
   guacd, MySQL, PostgreSQL, LDAP, etc. will be generated automatically
   when the image starts based on Docker links or environment variables.

``mysql`` or ``postgresql``
   Provides the database that Guacamole will use for authentication and
   storage of connection configuration data.

This separation is important, as it facilitates upgrades and maintains
proper separation of concerns. With the database separate from Guacamole
and guacd, those containers can be freely destroyed and recreated at
will. The only container which must persist data through upgrades is the
database.

.. _guacd-docker-image:

Running the guacd Docker image
------------------------------

The guacd Docker image is built from the released guacamole-server
source with support for VNC, RDP, SSH, telnet, and Kubernetes. Common
pitfalls like installing the required dependencies, installing fonts for
SSH, telnet, or Kubernetes, and ensuring the FreeRDP plugins are
installed to the correct location are all taken care of. It will simply
just work.

.. _guacd-docker-guacamole:

Running guacd for use by the Guacamole Docker image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When running the guacd image with the intent of linking to a Guacamole
container, no ports need be exposed on the network. Access to these
ports will be handled automatically by Docker during linking, and the
Guacamole image will properly detect and configure the connection to
guacd.

.. container:: informalexample

   ::

      $ docker run --name some-guacd -d guacamole/guacd

When run in this manner, guacd will be listening on its default port
4822, but this port will only be available to Docker containers that
have been explicitly linked to ``some-guacd``.

The log level of guacd can be controlled with the ``GUACD_LOG_LEVEL``
environment variable. The default value is ``info``, and can be set to
any of the valid settings for the guacd log flag (-L).

.. container:: informalexample

   ::

      $ docker run -e GUACD_LOG_LEVEL=debug -d guacamole/guacd

.. _guacd-docker-external:

Running guacd for use by services outside Docker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are not going to use the Guacamole image, you can still leverage
the guacd image for ease of installation and maintenance. By exposing
the guacd port, 4822, services external to Docker will be able to access
guacd.

.. important::

   *Take great care when doing this* - guacd is a passive proxy and does
   not perform any kind of authentication.

   If you do not properly isolate guacd from untrusted parts of your
   network, malicious users may be able to use guacd as a jumping point
   to other systems.

.. container:: informalexample

   ::

      $ docker run --name some-guacd -d -p 4822:4822 guacamole/guacd

guacd will now be listening on port 4822, and Docker will expose this
port on the same server hosting Docker. Other services, such as an
instance of Tomcat running outside of Docker, will be able to connect to
guacd directly.

.. _guacamole-docker-image:

The Guacamole Docker image
--------------------------

The Guacamole Docker image is built on top of a standard Tomcat 8 image
and takes care of all configuration automatically. The configuration
information required for guacd and the various authentication mechanisms
are specified with environment variables or Docker links given when the
container is created.

.. important::

   If using `PostgreSQL <#guacamole-docker-postgresql>`__ or
   `MySQL <#guacamole-docker-mysql>`__ for authentication, *you will
   need to initialize the database manually*. Guacamole will not
   automatically create its own tables, but SQL scripts are provided to
   do this.

Once the Guacamole image is running, Guacamole will be accessible at
http://:8080/guacamole/, where <HOSTNAME> is the hostname or address of
the machine hosting Docker.

.. _guacamole-docker-config-via-env:

Configuring Guacamole when using Docker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When running Guacamole using Docker, the traditional approach to
configuring Guacamole by editing ``guacamole.properties`` is less
convenient. When using Docker, you may wish to make use of the
``enable-environment-properties`` configuration property, which allows
you to specify values for arbitrary Guacamole configuration properties
using environment variables. This is covered in `Configuring
Guacamole <#configuring-guacamole>`__.

.. _guacamole-docker-guacd:

Connecting Guacamole to guacd
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Guacamole Docker image needs to be able to connect to guacd to
establish remote desktop connections, just like any other Guacamole
deployment. The connection information needed by Guacamole will be
provided either via a Docker link or through environment variables.

If you will be using Docker to provide guacd, and you wish to use a
Docker link to connect the Guacamole image to guacd, the connection
details are implied by the Docker link:

.. container:: informalexample

   ::

      $ docker run --name some-guacamole \
          --link some-guacd:guacd        \
          ...
          -d -p 8080:8080 guacamole/guacamole

   If you are not using Docker to provide guacd, you will need to
   provide the network connection information yourself using additional
   environment variables:

   +-------------+--------------------------------------------------------+
   | Variable    | Description                                            |
   +=============+========================================================+
   | ``GUACD     | The hostname of the guacd instance to use to establish |
   | _HOSTNAME`` | remote desktop connections. *This is required if you   |
   |             | are not using Docker to provide guacd.*                |
   +-------------+--------------------------------------------------------+
   | ``G         | The port that Guacamole should use when connecting to  |
   | UACD_PORT`` | guacd. This environment variable is optional. If not   |
   |             | provided, the standard guacd port of 4822 will be      |
   |             | used.                                                  |
   +-------------+--------------------------------------------------------+

   The ``GUACD_HOSTNAME`` and, if necessary, ``GUACD_PORT`` environment
   variables can thus be used in place of a Docker link if using a
   Docker link is impossible or undesirable:

   ::

      $ docker run --name some-guacamole \
          -e GUACD_HOSTNAME=172.17.42.1  \
          -e GUACD_PORT=4822             \
          ...
          -d -p 8080:8080 guacamole/guacamole

*A connection to guacd is not the only thing required for Guacamole to
work*; some authentication mechanism needs to be configured, as well.
`MySQL <#guacamole-docker-mysql>`__,
`PostgreSQL <#guacamole-docker-postgresql>`__, and
`LDAP <#guacamole-docker-ldap>`__ are supported for this, and are
described in more detail in the sections below. If the required
configuration options for at least one authentication mechanism are not
provided, the Guacamole image will not be able to start up, and you will
see an error.

.. _guacamole-docker-mysql:

MySQL authentication
~~~~~~~~~~~~~~~~~~~~

To use Guacamole with the MySQL authentication backend, you will need
either a Docker container running the ``mysql`` image, or network access
to a working installation of MySQL. The connection to MySQL can be
specified using either environment variables or a Docker link.

.. _initializing-guacamole-docker-mysql:

Initializing the MySQL database
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your database is not already initialized with the Guacamole schema,
you will need to do so prior to using Guacamole. A convenience script
for generating the necessary SQL to do this is included in the Guacamole
image.

To generate a SQL script which can be used to initialize a fresh MySQL
database as documented in `Database authentication <#jdbc-auth>`__:

.. container:: informalexample

   ::

      $ docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql

Alternatively, you can use the SQL scripts included with the database
authentication.

Once this script is generated, you must:

-  Create a database for Guacamole within MySQL, such as <guacamole_db>.

-  Create a user for Guacamole within MySQL with access to this
   database, such as ``guacamole_user``.

-  Run the script on the newly-created database.

The process for doing this via the ``mysql`` utility included with MySQL
is documented in `Database authentication <#jdbc-auth>`__.

.. _guacamole-docker-mysql-connecting:

Connecting Guacamole to MySQL
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your MySQL database is provided by another Docker container, and you
wish to use a Docker link to connect the Guacamole image to your
database, the connection details are implied by the Docker link itself:

.. container:: informalexample

   ::

      $ docker run --name some-guacamole \
          --link some-guacd:guacd         \
          --link some-mysql:mysql        \
          ...
          -d -p 8080:8080 guacamole/guacamole

If you are not using Docker to provide your MySQL database, you will
need to provide the network connection information yourself using
additional environment variables:

+-------------+--------------------------------------------------------+
| Variable    | Description                                            |
+=============+========================================================+
| ``MYSQL     | The hostname of the database to use for Guacamole      |
| _HOSTNAME`` | authentication. *This is required if you are not using |
|             | Docker to provide your MySQL database.*                |
+-------------+--------------------------------------------------------+
| ``M         | The port that Guacamole should use when connecting to  |
| YSQL_PORT`` | MySQL. This environment variable is optional. If not   |
|             | provided, the standard MySQL port of 3306 will be      |
|             | used.                                                  |
+-------------+--------------------------------------------------------+

The ``MYSQL_HOSTNAME`` and, if necessary, ``MYSQL_PORT`` environment
variables can thus be used in place of a Docker link if using a Docker
link is impossible or undesirable:

.. container:: informalexample

   ::

      $ docker run --name some-guacamole \
          --link some-guacd:guacd         \
          -e MYSQL_HOSTNAME=172.17.42.1  \
          ...
          -d -p 8080:8080 guacamole/guacamole

Note that a Docker link to guacd (the ``--link some-guacd:guacd`` option above)
is not required any more than a Docker link is required for MySQL. The
connection information for guacd can be specified using environment variables,
as described in `Connecting Guacamole to <#guacamole-docker-guacd>`__.

.. _guacamole-docker-mysql-required-vars:

Required environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Using MySQL for authentication requires additional configuration
parameters specified via environment variables. These variables
collectively describe how Guacamole will connect to MySQL:

+-------------+--------------------------------------------------------+
| Variable    | Description                                            |
+=============+========================================================+
| ``MYSQL     | The name of the database to use for Guacamole          |
| _DATABASE`` | authentication.                                        |
+-------------+--------------------------------------------------------+
| ``M         | The user that Guacamole will use to connect to MySQL.  |
| YSQL_USER`` |                                                        |
+-------------+--------------------------------------------------------+
| ``MYSQL     | The password that Guacamole will provide when          |
| _PASSWORD`` | connecting to MySQL as ``MYSQL_USER``.                 |
+-------------+--------------------------------------------------------+

If any required environment variables are omitted, you will receive an
error message in the logs, and the image will stop. You will then need
to recreate the container with the proper variables specified.

.. _guacamole-docker-mysql-optional-vars:

Optional environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Additional optional environment variables may be used to override
Guacamole's default behavior with respect to concurrent connection use
by one or more users. Concurrent use of connections and connection
groups can be limited to an overall maximum and/or a per-user maximum:

+--------------------------------+-------------------------------------+
| Variable                       | Description                         |
+================================+=====================================+
| ``MY                           | The absolute maximum number of      |
| SQL_ABSOLUTE_MAX_CONNECTIONS`` | concurrent connections to allow at  |
|                                | any time, regardless of the         |
|                                | Guacamole connection or user        |
|                                | involved. If set to "0", this will  |
|                                | be unlimited. Because this limit    |
|                                | applies across all Guacamole        |
|                                | connections, it cannot be           |
|                                | overridden if set.                  |
|                                |                                     |
|                                | *By default, the absolute total     |
|                                | number of concurrent connections is |
|                                | unlimited ("0").*                   |
+--------------------------------+-------------------------------------+
| ``M                            | The maximum number of concurrent    |
| YSQL_DEFAULT_MAX_CONNECTIONS`` | connections to allow to any one     |
|                                | Guacamole connection. If set to     |
|                                | "0", this will be unlimited. This   |
|                                | can be overridden on a              |
|                                | per-connection basis when editing a |
|                                | connection.                         |
|                                |                                     |
|                                | *By default, overall concurrent use |
|                                | of connections is unlimited ("0").* |
+--------------------------------+-------------------------------------+
| ``MYSQL_D                      | The maximum number of concurrent    |
| EFAULT_MAX_GROUP_CONNECTIONS`` | connections to allow to any one     |
|                                | Guacamole connection group. If set  |
|                                | to "0", this will be unlimited.     |
|                                | This can be overridden on a         |
|                                | per-group basis when editing a      |
|                                | connection group.                   |
|                                |                                     |
|                                | *By default, overall concurrent use |
|                                | of connection groups is unlimited   |
|                                | ("0").*                             |
+--------------------------------+-------------------------------------+
| ``MYSQL_DEFA                   | The maximum number of concurrent    |
| ULT_MAX_CONNECTIONS_PER_USER`` | connections to allow a single user  |
|                                | to maintain to any one Guacamole    |
|                                | connection. If set to "0", this     |
|                                | will be unlimited. This can be      |
|                                | overridden on a per-connection      |
|                                | basis when editing a connection.    |
|                                |                                     |
|                                | *By default, per-user concurrent    |
|                                | use of connections is unlimited     |
|                                | ("0").*                             |
+--------------------------------+-------------------------------------+
| ``MYSQL_DEFAULT_MA             | The maximum number of concurrent    |
| X_GROUP_CONNECTIONS_PER_USER`` | connections to allow a single user  |
|                                | to maintain to any one Guacamole    |
|                                | connection group. If set to "0",    |
|                                | this will be unlimited. This can be |
|                                | overridden on a per-group basis     |
|                                | when editing a connection group.    |
|                                |                                     |
|                                | *By default, per-user concurrent    |
|                                | use of connection groups is limited |
|                                | to one ("1")*, to prevent a         |
|                                | balancing connection group from     |
|                                | being completely exhausted by one   |
|                                | user alone.                         |
+--------------------------------+-------------------------------------+
| ``MYSQL_AUTO_CREATE_ACCOUNTS`` | Whether or not accounts that do not |
|                                | exist in the MySQL database will be |
|                                | automatically created when          |
|                                | successfully authenticated through  |
|                                | other modules. If set to "true"     |
|                                | accounts will be automatically      |
|                                | created. Otherwise, and by default, |
|                                | accounts will not be automatically  |
|                                | created and will need to be         |
|                                | manually created in order for       |
|                                | permissions within the MySQL        |
|                                | database extension to be assigned   |
|                                | to users authenticated with other   |
|                                | modules.                            |
+--------------------------------+-------------------------------------+

.. _guacamole-docker-postgresql:

PostgreSQL authentication
~~~~~~~~~~~~~~~~~~~~~~~~~

To use Guacamole with the PostgreSQL authentication backend, you will
need either a Docker container running the ``postgres`` image, or
network access to a working installation of PostgreSQL. The connection
to PostgreSQL can be specified using either environment variables or a
Docker link.

.. _initializing-guacamole-docker-postgresql:

Initializing the PostgreSQL database
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your database is not already initialized with the Guacamole schema,
you will need to do so prior to using Guacamole. A convenience script
for generating the necessary SQL to do this is included in the Guacamole
image.

To generate a SQL script which can be used to initialize a fresh
PostgreSQL database as documented in `Database
authentication <#jdbc-auth>`__:

.. container:: informalexample

   ::

      $ docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > initdb.sql

Alternatively, you can use the SQL scripts included with the database
authentication.

Once this script is generated, you must:

-  Create a database for Guacamole within PostgreSQL, such as
   <guacamole_db>.

-  Run the script on the newly-created database.

-  Create a user for Guacamole within PostgreSQL with access to the
   tables and sequences of this database, such as ``guacamole_user``.

The process for doing this via the ``psql`` and ``createdb`` utilities
included with PostgreSQL is documented in `Database
authentication <#jdbc-auth>`__.

.. _guacamole-docker-postgresql-connecting:

Connecting Guacamole to PostgreSQL
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your PostgreSQL database is provided by another Docker container, and
you wish to use a Docker link to connect the Guacamole image to your
database, the connection details are implied by the Docker link itself:

.. container:: informalexample

   ::

      $ docker run --name some-guacamole \
          --link some-guacd:guacd         \
          --link some-postgres:postgres  \
          ...
          -d -p 8080:8080 guacamole/guacamole

If you are not using Docker to provide your PostgreSQL database, you
will need to provide the network connection information yourself using
additional environment variables:

+-------------+--------------------------------------------------------+
| Variable    | Description                                            |
+=============+========================================================+
| ``POSTGRES  | The hostname of the database to use for Guacamole      |
| _HOSTNAME`` | authentication. *This is required if you are not using |
|             | Docker to provide your PostgreSQL database.*           |
+-------------+--------------------------------------------------------+
| ``POST      | The port that Guacamole should use when connecting to  |
| GRES_PORT`` | PostgreSQL. This environment variable is optional. If  |
|             | not provided, the standard PostgreSQL port of 5432     |
|             | will be used.                                          |
+-------------+--------------------------------------------------------+

The ``POSTGRES_HOSTNAME`` and, if necessary, ``POSTGRES_PORT``
environment variables can thus be used in place of a Docker link if
using a Docker link is impossible or undesirable:

.. container:: informalexample

   ::

      $ docker run --name some-guacamole   \
          --link some-guacd:guacd           \
          -e POSTGRES_HOSTNAME=172.17.42.1 \
          ...
          -d -p 8080:8080 guacamole/guacamole

Note that a Docker link to guacd (the ``--link some-guacd:guacd`` option above)
is not required any more than a Docker link is required for PostgreSQL. The
connection information for guacd can be specified using environment variables,
as described in `Connecting Guacamole to <#guacamole-docker-guacd>`__.

.. _guacamole-docker-postgresql-required-vars:

Required environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Using PostgreSQL for authentication requires additional configuration
parameters specified via environment variables. These variables
collectively describe how Guacamole will connect to PostgreSQL:

+-------------+--------------------------------------------------------+
| Variable    | Description                                            |
+=============+========================================================+
| ``POSTGRES  | The name of the database to use for Guacamole          |
| _DATABASE`` | authentication.                                        |
+-------------+--------------------------------------------------------+
| ``POST      | The user that Guacamole will use to connect to         |
| GRES_USER`` | PostgreSQL.                                            |
+-------------+--------------------------------------------------------+
| ``POSTGRES  | The password that Guacamole will provide when          |
| _PASSWORD`` | connecting to PostgreSQL as ``POSTGRES_USER``.         |
+-------------+--------------------------------------------------------+

If any required environment variables are omitted, you will receive an
error message in the logs, and the image will stop. You will then need
to recreate the container with the proper variables specified.

.. _guacamole-docker-postgresql-optional-vars:

Optional environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Additional optional environment variables may be used to override
Guacamole's default behavior with respect to concurrent connection use
by one or more users. Concurrent use of connections and connection
groups can be limited to an overall maximum and/or a per-user maximum:

+--------------------------------+-------------------------------------+
| Variable                       | Description                         |
+================================+=====================================+
| ``POSTG                        | The absolute maximum number of      |
| RES_ABSOLUTE_MAX_CONNECTIONS`` | concurrent connections to allow at  |
|                                | any time, regardless of the         |
|                                | Guacamole connection or user        |
|                                | involved. If set to "0", this will  |
|                                | be unlimited. Because this limit    |
|                                | applies across all Guacamole        |
|                                | connections, it cannot be           |
|                                | overridden if set.                  |
|                                |                                     |
|                                | *By default, the absolute total     |
|                                | number of concurrent connections is |
|                                | unlimited ("0").*                   |
+--------------------------------+-------------------------------------+
| ``POST                         | The maximum number of concurrent    |
| GRES_DEFAULT_MAX_CONNECTIONS`` | connections to allow to any one     |
|                                | Guacamole connection. If set to     |
|                                | "0", this will be unlimited. This   |
|                                | can be overridden on a              |
|                                | per-connection basis when editing a |
|                                | connection.                         |
|                                |                                     |
|                                | *By default, overall concurrent use |
|                                | of connections is unlimited ("0").* |
+--------------------------------+-------------------------------------+
| ``POSTGRES_D                   | The maximum number of concurrent    |
| EFAULT_MAX_GROUP_CONNECTIONS`` | connections to allow to any one     |
|                                | Guacamole connection group. If set  |
|                                | to "0", this will be unlimited.     |
|                                | This can be overridden on a         |
|                                | per-group basis when editing a      |
|                                | connection group.                   |
|                                |                                     |
|                                | *By default, overall concurrent use |
|                                | of connection groups is unlimited   |
|                                | ("0").*                             |
+--------------------------------+-------------------------------------+
| ``POSTGRES_DEFA                | The maximum number of concurrent    |
| ULT_MAX_CONNECTIONS_PER_USER`` | connections to allow a single user  |
|                                | to maintain to any one Guacamole    |
|                                | connection. If set to "0", this     |
|                                | will be unlimited. This can be      |
|                                | overridden on a per-connection      |
|                                | basis when editing a connection.    |
|                                |                                     |
|                                | *By default, per-user concurrent    |
|                                | use of connections is unlimited     |
|                                | ("0").*                             |
+--------------------------------+-------------------------------------+
| ``POSTGRES_DEFAULT_MA          | The maximum number of concurrent    |
| X_GROUP_CONNECTIONS_PER_USER`` | connections to allow a single user  |
|                                | to maintain to any one Guacamole    |
|                                | connection group. If set to "0",    |
|                                | this will be unlimited. This can be |
|                                | overridden on a per-group basis     |
|                                | when editing a connection group.    |
|                                |                                     |
|                                | *By default, per-user concurrent    |
|                                | use of connection groups is limited |
|                                | to one ("1")*, to prevent a         |
|                                | balancing connection group from     |
|                                | being completely exhausted by one   |
|                                | user alone.                         |
+--------------------------------+-------------------------------------+
| ``P                            | Whether or not accounts that do not |
| OSTGRES_AUTO_CREATE_ACCOUNTS`` | exist in the PostgreSQL database    |
|                                | will be automatically created when  |
|                                | successfully authenticated through  |
|                                | other modules. If set to "true",    |
|                                | accounts will be automatically      |
|                                | created. Otherwise, and by default, |
|                                | accounts will not be automatically  |
|                                | created and will need to be         |
|                                | manually created in order for       |
|                                | permissions within the PostgreSQL   |
|                                | database extension to be assigned   |
|                                | to users authenticated with other   |
|                                | modules.                            |
+--------------------------------+-------------------------------------+

Optional environment variables may also be used to override Guacamole's
default behavior with respect to timeouts at the database and network
level:

+--------------------------------+-------------------------------------+
| Variable                       | Description                         |
+================================+=====================================+
| ``POSTGR                       | The number of seconds the driver    |
| ES_DEFAULT_STATEMENT_TIMEOUT`` | will wait for a response from the   |
|                                | database, before aborting the       |
|                                | query. A value of 0 (the default)   |
|                                | means the timeout is disabled.      |
+--------------------------------+-------------------------------------+
| ``POSTGRES_SOCKET_TIMEOUT``    | The number of seconds to wait for   |
|                                | socket read operations. If reading  |
|                                | from the server takes longer than   |
|                                | this value, the connection will be  |
|                                | closed. This can be used to handle  |
|                                | network problems such as a dropped  |
|                                | connection to the database. Similar |
|                                | to                                  |
|                                | ``PO                                |
|                                | STGRES_DEFAULT_STATEMENT_TIMEOUT``, |
|                                | it will also abort queries that     |
|                                | take too long. A value of 0 (the    |
|                                | default) means the timeout is       |
|                                | disabled.                           |
+--------------------------------+-------------------------------------+

.. _guacamole-docker-ldap:

LDAP authentication
~~~~~~~~~~~~~~~~~~~

To use Guacamole with the LDAP authentication backend, you will need
network access to an LDAP directory. Unlike MySQL and PostgreSQL, the
Guacamole Docker image does not support Docker links for LDAP; the
connection information *must* be specified using environment variables:

+---------------+-------------------------------------------------------+
| Variable      | Description                                           |
+===============+=======================================================+
| ``LD          | The hostname or IP address of your LDAP server.       |
| AP_HOSTNAME`` |                                                       |
+---------------+-------------------------------------------------------+
| ``LDAP_PORT`` | The port your LDAP server listens on. By default,     |
|               | this will be 389 for unencrypted LDAP or LDAP using   |
|               | STARTTLS, and 636 for LDAP over SSL (LDAPS).          |
+---------------+-------------------------------------------------------+
| ``LDAP_ENCRYP | The encryption mechanism that Guacamole should use    |
| TION_METHOD`` | when communicating with your LDAP server. Legal       |
|               | values are "none" for unencrypted LDAP, "ssl" for     |
|               | LDAP over SSL/TLS (commonly known as LDAPS), or       |
|               | "starttls" for STARTTLS. If omitted, encryption will  |
|               | not be used.                                          |
+---------------+-------------------------------------------------------+

Only the ``LDAP_HOSTNAME`` variable is required, but you may also need
to specify ``LDAP_PORT`` or ``LDAP_ENCRYPTION_METHOD`` if your LDAP
directory uses encryption or listens on a non-standard port:

.. container:: informalexample

   ::

      $ docker run --name some-guacamole \
          --link some-guacd:guacd         \
          -e LDAP_HOSTNAME=172.17.42.1   \
          ...
          -d -p 8080:8080 guacamole/guacamole

Note that a Docker link to guacd (the ``--link some-guacd:guacd`` option above)
is not required.  Similar to LDAP, the connection information for guacd can be
specified using environment variables, as described in `Connecting Guacamole to
<#guacamole-docker-guacd>`__.

.. _guacamole-docker-ldap-required-vars:

Required environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Using LDAP for authentication requires additional configuration
parameters specified via environment variables. These variables
collectively describe how Guacamole will query your LDAP directory:

+-------------+--------------------------------------------------------+
| Variable    | Description                                            |
+=============+========================================================+
| ``LDAP_USE  | The base of the DN for all Guacamole users. All        |
| R_BASE_DN`` | Guacamole users that will be authenticating against    |
|             | LDAP must be descendents of this base DN.              |
+-------------+--------------------------------------------------------+

As with the other authentication mechanisms, if any required environment
variables are omitted (including those required for connecting to the
LDAP directory over the network), you will receive an error message in
the logs, and the image will stop. You will then need to recreate the
container with the proper variables specified.

.. _guacamole-docker-ldap-optional-vars:

Optional environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Additional optional environment variables may be used to configure the
details of your LDAP directory hierarchy, or to enable more flexible
searching for user accounts:

+---------------------+------------------------------------------------+
| Variable            | Description                                    |
+=====================+================================================+
| ``L                 | The base of the DN for all groups that may be  |
| DAP_GROUP_BASE_DN`` | referenced within Guacamole configurations     |
|                     | using the standard seeAlso attribute. All      |
|                     | groups which will be used to control access to |
|                     | Guacamole configurations must be descendents   |
|                     | of this base DN. *If this variable is omitted, |
|                     | the seeAlso attribute will have no effect on   |
|                     | Guacamole configurations.*                     |
+---------------------+------------------------------------------------+
| ``LD                | The DN (Distinguished Name) of the user to     |
| AP_SEARCH_BIND_DN`` | bind as when authenticating users that are     |
|                     | attempting to log in. If specified, Guacamole  |
|                     | will query the LDAP directory to determine the |
|                     | DN of each user that logs in. If omitted, each |
|                     | user's DN will be derived directly using the   |
|                     | base DN specified with ``LDAP_USER_BASE_DN``.  |
+---------------------+------------------------------------------------+
| ``LDAP_SEA          | The password to provide to the LDAP server     |
| RCH_BIND_PASSWORD`` | when binding as ``LDAP_SEARCH_BIND_DN`` to     |
|                     | authenticate other users. This variable is     |
|                     | only used if ``LDAP_SEARCH_BIND_DN`` is        |
|                     | specified. If omitted, but                     |
|                     | ``LDAP_SEARCH_BIND_DN`` is specified,          |
|                     | Guacamole will attempt to bind with the LDAP   |
|                     | server without a password.                     |
+---------------------+------------------------------------------------+
| ``LDAP_U            | The attribute or attributes which contain the  |
| SERNAME_ATTRIBUTE`` | username within all Guacamole user objects in  |
|                     | the LDAP directory. Usually, and by default,   |
|                     | this will simply be "uid". If your LDAP        |
|                     | directory contains users whose usernames are   |
|                     | dictated by different attributes, multiple     |
|                     | attributes can be specified here, separated by |
|                     | commas, but beware: *doing so requires that a  |
|                     | search DN be provided with                     |
|                     | ``LDAP_SEARCH_BIND_DN``*.                      |
+---------------------+------------------------------------------------+
| ``LD                | The base of the DN for all Guacamole           |
| AP_CONFIG_BASE_DN`` | configurations. If omitted, the configurations |
|                     | of Guacamole connections will simply not be    |
|                     | queried from the LDAP directory, and you will  |
|                     | need to store them elsewhere, such as within a |
|                     | MySQL or PostgreSQL database.                  |
+---------------------+------------------------------------------------+

As documented in `LDAP authentication <#ldap-auth>`__, Guacamole does
support combining LDAP with a MySQL or PostgreSQL database, and this can
be configured with the Guacamole Docker image, as well. Each of these
authentication mechanisms is independently configurable using their
respective environment variables, and by providing the required
environment variables for multiple systems, Guacamole will automatically
be configured to use each when the Docker image starts.

.. _guacamole-docker-header-auth:

Header Authentication
~~~~~~~~~~~~~~~~~~~~~

The header authentication extension can be used to authenticate
Guacamole through a trusted third-party server, where the authenticated
user's username is passed back to Guacamole via a specific HTTP header.
The following are valid Docker variables for enabling and configuring
header authentication:

+---------------------+------------------------------------------------+
| Variable            | Description                                    |
+=====================+================================================+
| ``HEADER_ENABLED``  | Enables authentication via the header          |
|                     | extension, which causes the extension to be    |
|                     | loaded when Guacamole starts. By default this  |
|                     | is false and the header extension will not be  |
|                     | loaded.                                        |
+---------------------+------------------------------------------------+
| `                   | Optional environment variable that, if set,    |
| `HTTP_AUTH_HEADER`` | configures the name of the HTTP header that    |
|                     | will be used used to authenticate the user to  |
|                     | Guacamole. If this is not specified the        |
|                     | default value of REMOTE_USER will be used.     |
+---------------------+------------------------------------------------+

.. _guacamole-docker-guacamole-home:

Custom extensions and ``GUACAMOLE_HOME``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have your own or third-party extensions for Guacamole which are
not supported by the Guacamole Docker image, but are compatible with the
version of Guacamole within the image, you can still use them by
providing a custom base configuration using the ``GUACAMOLE_HOME``
environment variable:

+-------------+--------------------------------------------------------+
| Variable    | Description                                            |
+=============+========================================================+
| ``GUACA     | The absolute path to the directory within the Docker   |
| MOLE_HOME`` | container to use *as a template* for the image's       |
|             | automatically-generated                                |
|             | ```GUACAMOLE_HOME`` <#guacamole-home>`__. Any          |
|             | configuration generated by the Guacamole Docker image  |
|             | based on other environment variables will be applied   |
|             | to an independent copy of the contents of this         |
|             | directory.                                             |
+-------------+--------------------------------------------------------+

You will *still* need to follow the steps required to create the
contents of ```GUACAMOLE_HOME`` <#guacamole-home>`__ specific to your
extension (placing the extension itself within
``GUACAMOLE_HOME/extensions/``, adding any properties to
``guacamole.properties``, etc.), but the rest of Guacamole's
configuration will be handled automatically, overlaid on top of a copy
of the ``GUACAMOLE_HOME`` you provide.

Because the Docker image's ``GUACAMOLE_HOME`` environment variable must
point to a directory *within the container*, you will need to expose
your custom ``GUACAMOLE_HOME`` to the container using the ``-v`` option
of ``docker run``. The container directory chosen can then be referenced
in the ``GUACAMOLE_HOME`` environment variable, and the image will
handle the rest automatically:

.. container:: informalexample

   ::

      $ docker run --name some-guacamole    \
          ...
          -v /local/path:/some-directory   \
          -e GUACAMOLE_HOME=/some-directory \
          -d -p 8080:8080 guacamole/guacamole

.. _verifying-guacamole-docker:

Verifying the Guacamole install
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once the Guacamole image is running, Guacamole should be accessible at
http://:8080/guacamole/, where <HOSTNAME> is the hostname or address of
the machine hosting Docker, and you *should* a login screen. If using
MySQL or PostgreSQL, the database initialization scripts will have
created a default administrative user called "``guacadmin``" with the
password "``guacadmin``". *You should log in and change your password
immediately.* If using LDAP, you should be able to log in as any valid
user within your LDAP directory.

If you cannot access Guacamole, or you do not see a login screen, check
Docker's logs using the ``docker logs`` command to determine if
something is wrong. Configuration parameters may have been given
incorrectly, or the database may be improperly initialized:

.. container:: informalexample

   ::

      $ docker logs some-guacamole

