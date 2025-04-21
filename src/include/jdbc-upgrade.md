If you are upgrading from an older version of Guacamole, you may need to run
one or more database schema upgrade scripts located within the
`schema/upgrade/` directory. Each of these scripts is named
{samp}`upgrade-pre-{VERSION}.sql` where `VERSION` is the version of Guacamole
where those changes were introduced. They need to be run when you are upgrading
from a version of Guacamole older than `VERSION`.

If there are no {samp}`upgrade-pre-{VERSION}.sql` scripts present in the
`schema/upgrade/` directory which apply to your existing Guacamole database,
then the schema has not changed between your version and the version your are
installing, and there is no need to run any database upgrade scripts.

These scripts are incremental and, when relevant, *must be run in order*. For
example, if you are upgrading an existing database from version
0.9.13-incubating to version 1.0.0, you would need to run the
`upgrade-pre-0.9.14.sql` script (because 0.9.13-incubating is older than
0.9.14), followed by the `upgrade-pre-1.0.0.sql` script (because
0.9.13-incubating is also older than 1.0.0).
