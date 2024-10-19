---
myst:
  substitutions:
    extArchiveName: guacamole-auth-ban
    extJarName:     guacamole-auth-ban
---

Securing Guacamole against brute-force attacks
==============================================

Version 1.6.0 of Guacamole introduces an extension that allows you to detect
and block brute-force login attacks. When installed, the extension will track
the IP addresses of failed authentication attempts. Once the threshold of
failed logins is reached for a particular IP address, further logins from that
address will be temporarily banned:

![](images/too-many-failed-logins.png)


```{include} include/warn-config-changes.md
```

Downloading and installing brute-force authentication detection
---------------------------------------------------------------

```{include} include/ext-download.md
```

(auth-ban-config)=

Configuring Guacamole for brute-force authentication detection
--------------------------------------------------------------

This extension has no required properties. So long as you are satisfied with
the default threshold and limits noted below, this extension requires no
configuration beyond installation.

:::{list-table} Default brute-force authentication detection threshold and limits
:stub-columns: 1
* - Maximum invalid attempts (authentication failures)
  - 5
* - Address ban duration
  - 300 (5 minutes)
* - Maximum addresses tracked
  - 10485670
:::


```{eval-rst}
.. tab:: Native Webapp (Tomcat)

   If you wish to override the defaults, additional properties may be specified
   within ``guacamole.properties``:

   .. include:: include/ban.properties.md
      :parser: myst_parser.sphinx_

.. tab:: Container (Docker)

   **Brute-force authentication detection is enabled by default when using the
   Docker image.** If you wish to override the defaults, additional environment
   variables may be set:

   .. include:: include/ban.environment.md
      :parser: myst_parser.sphinx_

   You can also explicitly enable/disable use brute-force authentication
   detection by setting the ``BAN_ENABLED`` environment variable to ``true`` or
   ``false``:

   ``BAN_ENABLED``
      Explicitly enables or disables use of brute-force authentication
      detection. By default, brute-force authentication detection is enabled.

      If set to ``true``, the brute-force authentication detection extension
      will be installed regardless of any other environment variables. If set
      to ``false``, the brute-force authentication detection extension will NOT
      be installed, regardless of any other environment variables.
```

:::{important}
Because the extension tracks authentication failures based on the client
IP address, it is important to make sure that Guacamole is receiving the
correct IP addresses for the clients. This is particularly noteworthy
when Guacamole is behind a reverse proxy. See the manual page on
[proxying Guacamole](reverse-proxy) for more details on configuring
Guacamole behind a proxy.
:::

(completing-auth-ban-install)=

Completing the installation
---------------------------

```{include} include/ext-completing.md
```

