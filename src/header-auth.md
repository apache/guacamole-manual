---
myst:
  substitutions:
    extArchiveName: guacamole-auth-header
    extJarName:     guacamole-auth-header
---

HTTP header authentication
==========================

Guacamole supports delegating authentication to an arbitrary external service,
relying on the presence of an HTTP header which contains the username of the
authenticated user. This authentication method must be layered on top of some
other authentication extension, such as those available from the main project
website, in order to provide access to actual connections.

:::{danger}
**All external requests must be properly sanitized if this extension is used.**
The chosen HTTP header must be stripped from untrusted requests, such that the
authentication service is the _only_ possible source of that header.

**If such sanitization is not performed, it will be trivial for malicious users
to add this header manually, and thus gain unrestricted access.**
:::


```{include} include/warn-config-changes.md
```

(header-downloading)=

Downloading and installing the HTTP header authentication extension
-------------------------------------------------------------------

```{include} include/ext-download.md
```

(guac-header-config)=

### Configuring Guacamole for HTTP header authentication

This extension has no required properties. So long as you are satisfied with
the default values noted below, this extension requires no configuration beyond
installation.

:::{list-table} Default HTTP header authentication configuration
:stub-columns: 1
* - HTTP header name
  - `REMOTE_USER`
* - Case-sensitive usernames
  - [System-wide global default](global-case-sensitive-usernames)
:::

```{eval-rst}
.. tab:: Native Webapp (Tomcat)

   If you wish to override the defaults, additional properties may be specified
   within ``guacamole.properties``:

   .. include:: include/http-auth.properties.md
      :parser: myst_parser.sphinx_

.. tab:: Container (Docker)

   If deploying Guacamole using Docker Compose, you will need to add at least
   one HTTP header authentication-related environment variable to the
   ``environment`` section of your ``guacamole/guacamole`` container, such as
   the ``HTTP_AUTH_ENABLED`` environment variable:

   .. code-block:: yaml

      HTTP_AUTH_ENABLED: "true"

   If instead deploying Guacamole by running ``docker run`` manually, this same
   environment variable will need to be provided using the ``-e`` option. For
   example:

   .. code-block:: console

      $ docker run --name some-guacamole \
          -e HTTP_AUTH_ENABLED="true" \
          -d -p 8080:8080 guacamole/guacamole

   If you wish to override the defaults, additional environment variables may
   be set:

   .. include:: include/http-auth.environment.md
      :parser: myst_parser.sphinx_

   You can also explicitly enable/disable use brute-force authentication
   detection by setting the ``HTTP_AUTH_ENABLED`` environment variable to ``true``
   or ``false``:

   ``HTTP_AUTH_ENABLED``
      Explicitly enables or disables use of brute-force authentication
      detection. By default, brute-force authentication detection is enabled.

      If set to ``true``, the brute-force authentication detection extension
      will be installed regardless of any other environment variables. If set
      to ``false``, the brute-force authentication detection extension will NOT
      be installed, regardless of any other environment variables.
```

(completing-header-install)=

### Completing the installation

```{include} include/ext-completing.md
```

