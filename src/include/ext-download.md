Guacamole is configured differently depending on whether Guacamole was
[installed natively](installing-guacamole) or [using the provided Docker
images](guacamole-docker). The documentation here covers both methods.

If you have installed Guacamole natively under [Apache Tomcat](https://tomcat.apache.org/) or similar:
: You will need to modify the
  contents of `GUACAMOLE_HOME` ([Guacamole's configuration
  directory](guacamole-home)), which is located at `/etc/guacamole` by default
  and may need to be created first.

  1. Download {{ '<code class="docutils literal notranslate">' +
     extArchiveName + '-' + version + '.tar.gz</code>' }} from {{ '<a
     href="https://guacamole.apache.org/releases/' + version + '/">the release
     notes</a>' }} and extract it.

  2. Create the `GUACAMOLE_HOME/extensions` directory, if it does not already
     exist.

  3. Copy the {{ '<code class="docutils literal notranslate">' + extJarName +
     '-' + version + '.jar</code>' }} file from the contents of the archive to
     `GUACAMOLE_HOME/extensions/`.

  4. Proceed with the configuring Guacamole for the newly installed extension as
     described below. The extension will be loaded after Guacamole has been
     restarted.

If you have installed Guacamole using the provided Docker images:
: There is no need to download anything! The `guacamole/guacamole` Docker image
  bundles all supported extensions and automatically manages `GUACAMOLE_HOME`
  for you based on environment variables.

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


