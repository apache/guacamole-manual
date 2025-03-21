Database authentication
=======================

Guacamole supports authentication via MySQL, PostgreSQL, or SQL Server
databases through extensions available from the project website. Using a
database for authentication provides additional features, such as the ability
to use load balancing groups of connections and a web-based administrative
interface.

While most authentication extensions function independently, the database
authentication can act in a subordinate role, allowing users and user groups
from other authentication extensions to be associated with connections within
the database. Users and groups are considered identical to those within the
database if they have the same names, and the authentication result of another
extension will be trusted if it succeeds. A user with an account under multiple
systems will thus be able to see data from each system after successfully
logging in. For more information on using the database authentication alongside
other mechanisms, see [](ldap-and-database) within [](ldap-auth).

:::{toctree}
:caption: Supported Databases
:name: databases
:maxdepth: 1

MariaDB / MySQL <mysql-auth>
PostgreSQL <postgresql-auth>
SQL Server <sqlserver-auth>
:::

:::{toctree}
:hidden:

jdbc-auth-schema
:::
