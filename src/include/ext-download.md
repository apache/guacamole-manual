:::{note}
Download and documentation links for all officially supported extensions for a
particular version of Guacamole are always provided in the release notes for
that version. The copy of the documentation you are reading now is from {{
    '<a href="https://guacamole.apache.org/releases/' + version + '/">Apache Guacamole ' + version + '</a>'
}}.

**If you are using a different version of Guacamole, please locate that version
within [the release archives](https://guacamole.apache.org/releases/) and
consult the documentation for that release instead.**
:::

Extensions for Guacamole are self-contained `.jar` files that are distributed
separately from the Guacamole web application. They are packaged as `.tar.gz`
archives containing at least the extension and any related license information.

To install the {{ extHumanName }} for Apache Guacamole {{ version }}:

1. Download and extract {{ '<code class="docutils literal notranslate">' +
   extMachineName + '-' + version + '.tar.gz</code>' }} from {{ '<a
   href="https://guacamole.apache.org/releases/' + version + '/">the release
   notes</a>' }}.

2. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
   exist.

3. Copy the {{ '<code class="docutils literal notranslate">' + extMachineName +
   '-' + version + '.jar</code>' }} file from the contents of the downloaded
   `.tar.gz` archive to `GUACAMOLE_HOME/extensions/`.

4. Proceed with the configuring Guacamole for the newly installed extension as
   described below.
