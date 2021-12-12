Guacamole loads authentication extensions in order of priority, and evaluates
authentication attempts in this same order. This has implications for how the
Guacamole login process behaves when an SSO extension is present:

If the SSO extension has priority:
: Users that are not yet authenticated
  will be immediately redirected to the configured identity provider. They will
  not see a Guacamole login screen.

If a non-SSO extension has priority:
: Users that are not yet authenticated
  will be presented with a Guacamole login screen. Additionally, links to the
  configured identity provider(s) will be available for users that wish to log
  in using SSO.

The default priority of extensions is dictated by their filenames, with
extensions that sort earlier alphabetically having higher priority than others.
This can be overridden [by setting the `extension-priority` property within
`guacamole.properties`](initial-setup).

