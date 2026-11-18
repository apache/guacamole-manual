Retrieving secrets from a vault
===============================

:::{toctree}
:hidden:

Keeper Secret Manager<keeper>
OpenBao or Hashicorp Vault<hashicorp>
:::

Guacamole supports reading secrets such as connection-specific passwords from a
key vault, automatically injecting those secrets into connection configurations
using [parameter tokens](parameter-tokens) or Guacamole configuration
properties via an additional, vault-specific configuration file analogous to
`guacamole.properties`. Guacamole supports the follow Vault providers:

[Keeper Secret Manager](keeper)
: [Keeper Secrets Manager (KSM)](https://www.keepersecurity.com/secrets-manager.html)
  is a cloud-based secrets management solution that securely stores, rotates,
  and injects credentials (API keys, passwords, certificates) into applications
  and CI/CD pipelines with strong encryption and zero-knowledge architecture.
  
[Hashicorp Vault](hashicorp)
: [HashiCorp Vault](https://www.hashicorp.com/products/vault) is a widely used
  secrets management platform that provides secure storage, dynamic secrets
  generation, encryption as a service, and fine-grained access control for
  protecting sensitive data in modern infrastructure.

[OpenBao](hashicorp)
: [OpenBao](https://openbao.org) is an open-source, community-driven fork of
  HashiCorp Vault designed to provide similar secrets management capabilities
  (secure storage, dynamic secrets, encryption) under a fully open governance
  and licensing model. It is supported by the same extension as Hashicorp
  Vault.
