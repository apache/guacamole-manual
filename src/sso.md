Authenticating with Guacamole using single sign-on
==================================================

:::{toctree}
:hidden:

CAS <cas-auth>
OpenID Connect <openid-auth>
SAML <saml-auth>
:::

Single sign-on alows you to leverage a third-party authentication service that
can be shared by multiple applications, including Guacamole. This has the
benefit of streamlining and centralizing authentication when users would
otherwise need to maintain a distinct set of credentials for each application.
Guacamole supports the following single sign-on methods:

[CAS](cas-auth)
: An open source single sign-on application that implements its own
  authentication protocol.

[OpenID Connect](openid-auth) and [SAML](saml-auth)
: Widely supported open standards for single sign-on. It is extremely common
  for commercial identity providers to support at least one of these standards.

:::{hint}
OpenID Connect is commonly confused with "OAuth", with the term "OAuth"
sometimes used incorrectly to refer to OpenID Connect.
:::
