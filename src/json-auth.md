---
myst:
  substitutions:
    extArchiveName: guacamole-auth-json
    extJarName:     guacamole-auth-json
---

Encrypted JSON authentication
=============================

Guacamole supports delegating authentication to an arbitrary external service,
relying on receipt of JSON data which has been [signed using HMAC/SHA-256 and
encrypted with 128-bit AES in CBC mode](#generating-encrypted-json). This JSON
contains [all information describing the user being authenticated](#json-format),
as well as any connections they have access to, and is accepted only if the
configured secret key was used to sign and encrypt the data.

```{include} include/warn-config-changes.md
```

(json-downloading)=

Downloading and installing the JSON authentication extension
------------------------------------------------------------

```{include} include/ext-download.md
```

(json-config)=

Configuring Guacamole to accept encrypted JSON
----------------------------------------------

To verify and decrypt the received signed and encrypted JSON, a secret key must
be generated which will be shared by both the Guacamole server and systems that
will generate the JSON data. As guacamole-auth-json uses 128-bit AES, this key
must be 128 bits.

```{eval-rst}
.. tab:: Native Webapp (Tomcat)

   If deploying Guacamole natively, you will need to add a section to your
   ``guacamole.properties`` that looks like the following:

   .. literalinclude:: include/json.example.properties
      :language: ini

   There is only a single property that must be set in all cases for any
   Guacamole installation using the encrypted JSON authentication extension:

   .. include:: include/json.properties.md
      :parser: myst_parser.sphinx_

.. tab:: Container (Docker)

   If deploying Guacamole using Docker Compose, you will need to add a set of
   environment varibles to the ``environment`` section of your
   ``guacamole/guacamole`` container that looks like the following 

   .. literalinclude:: include/json.example.yml
      :language: yaml

   If instead deploying Guacamole by running ``docker run`` manually, these
   same environment variables will need to be provided using the ``-e`` option.
   For example:

   .. literalinclude:: include/json.example.txt
      :language: console

   There is only a single environment variable that must be set in all cases
   for any Guacamole installation using the encrypted JSON authentication
   extension:

   .. include:: include/json.environment.md
      :parser: myst_parser.sphinx_
```

### Additional Configuration Options

```{eval-rst}
.. tab:: Native Webapp (Tomcat)

   The following additional, optional properties may be set as desired to
   tailor the behavior of the encrypted JSON authentication:

   .. include:: include/json-optional.properties.md
      :parser: myst_parser.sphinx_

.. tab:: Container (Docker)

   The following additional, optional environment variables may be set as
   desired to tailor the encrypted JSON authentication:

   .. include:: include/json-optional.environment.md
      :parser: myst_parser.sphinx_

   You can also explicitly enable/disable use of encrypted JSON authentication
   by setting the ``JSON_ENABLED`` environment variable to ``true`` or
   ``false``:

   ``JSON_ENABLED``
      Explicitly enables or disables use of the encrypted JSON authentication
      extension. By default, the encrypted JSON extension will be installed
      only if at least one related environment variable is set.

      If set to ``true``, the encrypted JSON extension will be installed
      regardless of any other environment variables. If set to ``false``, the
      encrypted JSON extension will NOT be installed, even if other related
      environment variables have been set.
```

(completing-json-install)=

Completing the installation
---------------------------

```{include} include/ext-completing.md
```

(json-format)=

JSON format
-----------

The general format of the JSON (prior to being encrypted, signed, and sent to
Guacamole), is as follows:

    {

        "username" : "arbitraryUsername",
        "expires" : TIMESTAMP,
        "connections" : {

            "Connection Name" : {
                "protocol" : "PROTOCOL",
                "parameters" : {
                    "name1" : "value1",
                    "name2" : "value2",
                    ...
                }
            },

            ...

        }

    }

where `TIMESTAMP` is a standard UNIX epoch timestamp with millisecond
resolution (the number of milliseconds since midnight of January 1, 1970 UTC)
and `PROTOCOL` is the internal name of any of Guacamole's supported protocols,
such as `vnc`, `rdp`, or `ssh`.

The JSON will cease to be accepted as valid after the server time passes the
timestamp. If no timestamp is specified, the data will not expire.

The top-level JSON object which must be submitted to Guacamole has the
following properties:

:::{list-table}
:widths: auto
:header-rows: 1

* - Property name
  - Type
  - Description

* - `username`
  - `string`
  - The unique username of the user authenticated by the JSON. If the user is
    anonymous, this should be the empty string (`""`).

* - `expires`
  - `number`
  - The absolute time after which the JSON should no longer be accepted, even
    if the signature is valid, as a standard UNIX epoch timestamp with
    millisecond resolution (the number of milliseconds since midnight of
    January 1, 1970 UTC).

* - `connections`
  - `object`
  - The set of connections which should be exposed to the user by their
    corresponding, unique names. If no connections will be exposed to the user,
    this can simply be an empty object (`{}`).
:::

Each normal connection defined within each submitted JSON object has the
following properties:

:::{list-table}
:widths: auto
:header-rows: 1

* - Property name
  - Type
  - Description

* - `id`         
  - `string`
  - An optional opaque value which uniquely identifies this connection across
    all other connections which may be active at any given time. This property
    is only required if you wish to allow the connection to be shared or
    shadowed.

* - `protocol`   
  - `string`
  - The internal name of a supported protocol, such as `vnc`, `rdp`, or `ssh`.

* - `parameters` 
  - `object`
  - An object representing the connection parameter name/value pairs to apply
    to the connection, as documented in [](connection-configuration).

:::

Connections which share or shadow other connections use a `join` property
instead of a `protocol` property, where `join` contains the value of the `id`
property of the connection being joined:

:::{list-table}
:widths: auto
:header-rows: 1

* - Property name
  - Type
  - Description

* - `id`         
  - `string`
  - An optional opaque value which uniquely identifies this connection across
    all other connections which may be active at any given time. This property
    is only required if you wish to allow the connection to be shared or
    shadowed. (Yes, a connection which shadows another connection may itself be
    shadowed.)

* - `join`       
  - `string`
  - The opaque ID given within the `id` property of the connection being joined
    (shared / shadowed).

* - `parameters` 
  - `object`
  - An object representing the connection parameter name/value pairs to apply
    to the connection, as documented in [](connection-configuration).

    Most of the connection configuration is inherited from the connection being
    joined. In general, the only property relevant to joining connections is
    `read-only`.

:::

If a connection is configured to join another connection, that connection will
only be usable if the connection being joined is currently active. If two
connections are established having the same `id` value, only the last
connection will be joinable using the given `id`.

(generating-encrypted-json)=

Generating encrypted JSON
-------------------------

To authenticate a user with the above JSON format, the JSON must be both signed
and encrypted using the same 128-bit secret key specified with the
`json-secret-key` within `guacamole.properties`:

1. Generate JSON in the format described above
2. Sign the JSON using the secret key (the same 128-bit key stored within
   `guacamole.properties` with the `json-secret-key` property) with
   **HMAC/SHA-256**. Prepend the binary result of the signing process to the
   plaintext JSON that was signed.
3. Encrypt the result of (2) above using **AES in CBC mode**, with the initial
   vector (IV) set to all zero bytes.
4. Encode the encrypted result using base64.
5. POST the encrypted result to the `/api/tokens` REST endpoint as the value of
   an HTTP parameter named `data` (or include it in the URL of any Guacamole
   page as a query parameter named `data`).

   For example, if Guacamole is running on localhost at `/guacamole`, and
   `BASE64_RESULT` is the result of the above process, the equivalent run of
   the "curl" utility would be:

       $ curl --data-urlencode "data=BASE64_RESULT" http://localhost:8080/guacamole/api/tokens

   **NOTE:** Be sure to URL-encode the base64-encoded result prior to POSTing
   it to `/api/tokens` or including it in the URL. Base64 can contain both "+"
   and "=" characters, which have special meaning within URLs.

If the data is invalid in any way, if the signature does not match, if
decryption or signature verification fails, or if the submitted data has
expired, the REST service will return an invalid credentials error and fail
without user-visible explanation. Details describing the error that occurred
will be in the Tomcat logs, however.

Reference implementation
------------------------

The source includes a shell script, [`doc/encrypt-json.sh`](https://raw.githubusercontent.com/apache/guacamole-client/master/extensions/guacamole-auth-json/doc/encrypt-json.sh),
which uses the OpenSSL command-line utility to encrypt and sign JSON in the
manner that guacamole-auth-json requires. It is thoroughly commented and should
work well as a reference implementation, for testing, and as a point of
comparison for development. The script is run as:

    $ ./encrypt-json.sh HEX_ENCRYPTION_KEY file-to-sign-and-encrypt.json

For example, if you have a file called `auth.json` containing the following:

    {
        "username" : "test",
        "expires" : "1446323765000",
        "connections" : {
            "My Connection" : {
                "protocol" : "rdp",
                "parameters" : {
                    "hostname" : "10.10.209.63",
                    "port" : "3389",
                    "ignore-cert": "true",
                    "recording-path": "/recordings",
                    "recording-name": "My-Connection-${GUAC_USERNAME}-${GUAC_DATE}-${GUAC_TIME}"
                }
            },
            "My OTHER Connection" : {
                "protocol" : "rdp",
                "parameters" : {
                    "hostname" : "10.10.209.64",
                    "port" : "3389",
                    "ignore-cert": "true",
                    "recording-path": "/recordings",
                    "recording-name": "My-OTHER-Connection-${GUAC_USERNAME}-${GUAC_DATE}-${GUAC_TIME}"
                }
            }
        }
    }

and you run:

    $ ./encrypt-json.sh 4C0B569E4C96DF157EEE1B65DD0E4D41 auth.json

You will receive the following output:

    A2Pf5Kpmm97I2DT1PifIrfU6q3yzoGcIbNXEd60WNangT8DAVjAl6luaqwhBJnCK
    uqcf9ZZlRo3uDxTHvUM3eq1YvdghL0GbosOn8Mn38j2ydOMk+Cd15a8ggb4/ddt/
    yIBK4DxrN7MNbouZ091KYtXC6m20E6sGzLy676BlMSg1cmsENRIihOynsSLSCvo0
    diif6H7T+ZuIqF7B5SW+adGfMaHlfknlIvSpLGHhrIP4aMYE/ZU2vYNg8ez27sCS
    wDBWu5lERtfCYFyU4ysjRU5Hyov+yKa+O7jcRYpw3N+fHbCg7/dxVNW07qNOKssv
    pzUciGvDPUCPpa02WmPJNEBowwQireO1952/MNAI77cW2UepbljD/bwOiZl2THJz
    LrENo7K5acimBa+EjWEesgn7lx/WTCF3zxR6TH1CWrQM8Et1aUK1Nf8K11xEQbTy
    klyaNtCmTfyahRZ/fUPxDNrdJVpPOSELkf7RJO5tOdK/FFIFIbze3ZUyXgRq+pHY
    owpgOmudDBTBlxhXiONdutRI/RZbFM/7GBMdmI8AR/401OCV3nsI4jLhukjMXH3V
    f3pQg+xKMhi/QExHhDk8VTNYk7GurK4vgehn7HQ0oSGh8pGcmxB6W43cz+hyn6VQ
    On6i90cSnIhRO8SysZt332LwJCDm7I+lBLaI8NVHU6bnAY1Axx5oH3YTKc4qzHls
    HEAFYLkD6aHMvHkF3b798CMravjxiJV3m7hsXDbaFN6AFhn8GIkMRRrjuevfZ+q9
    enWN14s24vt5OVg69DljzALobUNKUXFx69SR8EpSBvUcKq8s/OgbDpFvKbwsDY57
    HGT4T0CuRIA0TGUI075uerKBNApVhuBA1BmWJIrI4JXw5MuX6pdBe+MYccO3vfo+
    /frazj8rHdkDa/IbueMbvq+1ozV2+UuxrbaTrV2i4jSRgd74U0QzOh9e8Q0i7vOi
    l3hnIfOfg+v1oULmZmJSeiAYWxeGvPptp+n7rNFqHGM=

The resulting base64 data above, if submitted using the `data` parameter to
Guacamole, will authenticate a user and grant them access to the connections
described in the JSON (at least until the expires timestamp is reached, at
which point the JSON will no longer be accepted).


