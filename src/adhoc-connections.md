---
myst:
  substitutions:
    extArchiveName: guacamole-auth-quickconnect
    extJarName:     guacamole-auth-quickconnect
---

Ad-hoc Connections
==================

The quickconnect extension provides a connection bar on the Guacamole Client
home page that allows users to type in the URI of a server to which they want
to connect and the client will parse the URI and immediately establish the
connection. The purpose of the extension is to allow situations where
administrators want to allow users the flexibility of establishing their own
connections without having to grant them access to edit connections or even to
have to create the connections at all, aside from typing the URI.

:::{important}
There are several implications of using this extension that should be
well-understood by administrators prior to implementing it:

* Connections established with this extension are created in-memory and only
  persist until the Guacamole session ends.

* Connections created with this extension are not accessible to other users,
  and cannot be shared with other users.

* This extension provides no functionality for authenticating users - it does
  not allow anonymous logins, and requires that users are successfully
  authenticated by another authentication module before it can be used.

* The extension provides users the ability not only to establish connections,
  but also to set any of the parameters for a connection. There are security
  implications for this - for example, RDP file sharing can be used to pass
  through any directory available on the server running guacd to the remote
  desktop. This should be taken into consideration when enabling this extension
  and making sure that guacd is configured in a way that does not compromise
  sensitive system files by allowing access to them.
:::

```{include} include/warn-config-changes.md
```

(quickconnect-downloading)=

Downloading and installing the quickconnect extension
-----------------------------------------------------

```{include} include/ext-download.md
```

(guac-quickconnect-config)=

Configuring Guacamole for the quickconnect extension
----------------------------------------------------

```{eval-rst}
.. tab:: Native Webapp (Tomcat)

   The quickconnect extension has two configuration properties that allow for
   controlling what connection parameters can be used in the URIs that are
   opened with the quickconnect extension:

   .. include:: include/quickconnect.properties.md
      :parser: myst_parser.sphinx_

.. tab:: Container (Docker)

   If deploying Guacamole using Docker Compose, you will need to add at least
   one quickconnect-related environment variable to the ``environment`` section
   of your ``guacamole/guacamole`` container, such as the ``QUICKCONNECT_ENABLED``
   environment variable:

   .. code-block:: yaml

      QUICKCONNECT_ENABLED: "true"

   If instead deploying Guacamole by running ``docker run`` manually, this same
   environment variable will need to be provided using the ``-e`` option. For
   example:

   .. code-block:: console

      $ docker run --name some-guacamole \
          -e QUICKCONNECT_ENABLED="true" \
          -d -p 8080:8080 guacamole/guacamole

   The quickconnect extension has two environment variables that allow for
   controlling what connection parameters can be used in the URIs that are
   opened with the quickconnect extension:

   .. include:: include/quickconnect.environment.md
      :parser: myst_parser.sphinx_

   You can also explicitly enable/disable use the quickconnect extension by
   setting the ``QUICKCONNECT_ENABLED`` environment variable to ``true`` or
   ``false``:

   ``QUICKCONNECT_ENABLED``
      Explicitly enables or disables use of the quickconnect extension. By
      default, the quickconnect extension will be installed only if at least
      one quickconnect-related environment variable is set.

      If set to ``true``, the quickconnect extension will be installed
      regardless of any other environment variables. If set to ``false``, the
      quickconnect extension will NOT be installed, even if other
      quickconnect-related environment variables have been set.
```

(completing-quickconnect-install)=

Completing the installation
---------------------------

```{include} include/ext-completing.md
```

(using-quickconnect)=

Using the quickconnect extension
--------------------------------

The quickconnect extension provides a field on the home page that allows you to
enter a Uniform Resource Identifier (URI) to create a connection. A URI is in
the form:

{samp}`{protocol}://{username}:{password}@{host}:{port}/?{parameters}`

The `protocol` field can have any of the protocols supported by Guacamole, as
documented in [](configuring-guacamole). Many of the protocols define a default
`port` value, with the exception of VNC. The `parameters` field can specify any
of the protocol-specific parameters as documented on the configuration page.

To establish a connection, simply type in a valid URI and either press "Enter"
or click the connect button. This extension will parse the URI and create a new
connection, and immediately start that connection in the current browser.

Here are a few examples of URIs:

`ssh://linux1.example.com/`
: Connect to the server linux1.example.com using the SSH protocol on the
  default SSH port (22). This will result in prompting for both username and
  password.

`vnc://linux1.example.com:5900/`
: Connect to the server linux1.example.com using the VNC protocol and
  specifying the port as 5900.

`rdp://localuser@windows1.example.com/?security=rdp&ignore-cert=true&disable-audio=true&enable-drive=true&drive-path=/mnt/usb`
: Connect to the server windows1.example.com using the RDP protocol and the
  user "localuser". This URI also specifies several RDP-specific parameters on
  the connection, including forcing security mode to RDP (security=rdp), ignoring
  any certificate errors (ignore-cert=true), disabling audio pass-through
  (disable-audio=true), and enabling filesystem redirection (enable-drive=true)
  to the /mnt/usb folder on the system running guacd (drive-path=/mnt/usb).

