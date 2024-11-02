---
myst:
  substitutions:
    extArchiveName: guacamole-auth-sso
    extJarName:     cas/guacamole-auth-sso-cas
---

CAS Authentication
==================

CAS is an open-source Single Sign On (SSO) provider that allows multiple
applications and services to authenticate against it and brokers those
authentication requests to a back-end authentication provider. This module
allows Guacamole to redirect to CAS for authentication and user services. This
module must be layered on top of other authentication extensions that provide
connection information, as it only provides user authentication.

(cas-downloading)=

Downloading and installing the CAS authentication extension
-----------------------------------------------------------

```{include} include/ext-download.md
```

Configuring Guacamole for CAS Authentication
--------------------------------------------

Guacamole's CAS support requires specifying two properties that describe the
CAS authentication server and the Guacamole deployment. These properties are
*absolutely required in all cases*, as they dictate how Guacamole should
connect to the CAS and how CAS should redirect users back to Guacamole once
their identity has been confirmed:


```{eval-rst}
.. tab:: Native Webapp (Tomcat)

   If deploying Guacamole natively, you will need to add a section to your
   ``guacamole.properties`` that looks like the following:

   .. literalinclude:: include/cas.example.properties
      :language: ini

   The properties that must be set in all cases for any Guacamole installation
   using CAS are:

   .. include:: include/cas.properties.md
      :parser: myst_parser.sphinx_

.. tab:: Container (Docker)

   If deploying Guacamole using Docker Compose, you will need to add a set of
   environment varibles to the ``environment`` section of your
   ``guacamole/guacamole`` container that looks like the following 

   .. literalinclude:: include/cas.example.yml
      :language: yaml

   If instead deploying Guacamole by running ``docker run`` manually, these
   same environment variables will need to be provided using the ``-e`` option.
   For example:

   .. literalinclude:: include/cas.example.txt
      :language: console

   The environment variables that must be set in all cases for any Docker-based
   Guacamole installation using CAS are:

   .. include:: include/cas.environment.md
      :parser: myst_parser.sphinx_
```

### Additional Configuration Options

```{eval-rst}
.. tab:: Native Webapp (Tomcat)

   Additional optional properties are available to control how CAS-related data
   is processed, including whether [CAS ClearPass](cas-clearpass) should be used
   and how user group memberships should be derived:

   .. include:: include/cas-optional.properties.md
      :parser: myst_parser.sphinx_

.. tab:: Container (Docker)

   Additional optional environment variables are available to control how
   CAS-related data is processed, including whether [CAS ClearPass](cas-clearpass)
   should be used and how user group memberships should be derived:

   .. include:: include/cas-optional.environment.md
      :parser: myst_parser.sphinx_

   You can also explicitly enable/disable use of CAS support by setting the
   ``CAS_ENABLED`` environment variable to ``true`` or ``false``:

   ``CAS_ENABLED``
      Explicitly enables or disables use of the CAS extension. By default, the
      CAS extension will be installed only if at least one CAS-related
      environment variable is set.

      If set to ``true``, the CAS extension will be installed regardless of any
      other environment variables. If set to ``false``, the CAS extension will
      NOT be installed, even if other CAS-related environment variables have
      been set.
```

### Controlling login behavior

```{include} include/sso-login-behavior.md
```

#### Automatically redirecting all unauthenticated users

To ensure users are redirected to the CAS identity provider immediately
(without a Guacamole login screen), ensure the CAS extension has priority over
all others:

```
extension-priority: cas
```

#### Presenting unauthenticated users with a login screen

To ensure users are given a normal Guacamole login screen and have the option
to log in with traditional credentials _or_ with CAS, ensure the CAS extension
does not have priority:

```
extension-priority: *, cas
```

(completing-cas-install)=

Completing the installation
---------------------------

```{include} include/ext-completing.md
```

(cas-clearpass)=

Using CAS ClearPass
-------------------

CAS has a function called ClearPass that can be used to cache the password used
for SSO authentication and make that available to services at a later time.
Configuring the CAS server for ClearPass is beyond the scope of this article -
more information can be found on the Apereo CAS wiki at the following URL:
<https://apereo.github.io/cas>.

Once you have CAS configured for credential caching, you need to configure the
service with a keypair for passing the credential securely. The public key gets
installed on the CAS server, while the private key gets configured with the
`cas-clearpass-key property`. The private key file needs to be in RSA PKCS8
format.

