# Configuring Serial Console Access

Guacamole's `serial` protocol gives you browser-based access to a device's
asynchronous serial console — the local management port found on network
switches, routers, firewalls, PDUs, and similar equipment. As with SSH and
telnet, Guacamole emulates a terminal on the server side and renders it to
the browser, so color schemes, fonts, session recording, typescripts, and
copy/paste all work exactly as they do for SSH and telnet sessions.

Two connection modes are available:

**Local mode**
: guacd opens a serial device attached directly to the guacd host, such as a
  USB-to-serial console cable plugged into the machine running guacd.

**Network mode**
: guacd connects over TCP to a serial-to-network gateway, most commonly
  [ser2net](https://github.com/cminyard/ser2net), which exposes one or more
  serial ports on the network on behalf of guacd.

This chapter documents the setup required outside of Guacamole for each
mode. For the full connection parameter reference, including all serial line
settings, see [](serial-connection-parameters) in the configuration chapter.

:::{important}
Guacamole defaults to **9600 baud, 8 data bits, 1 stop bit, no parity, no
flow control** — commonly written "9600 8N1" — which is the standard console
setting used by the vast majority of network equipment, including Cisco,
Juniper, Arista, Fortinet, and APC devices. In most cases you will not need
to change the serial line settings at all.
:::

## Local mode: guacd on the same host as the device

In local mode, guacd opens the `device` given in the connection parameters
(e.g. `/dev/ttyUSB0`) as though it were any other process on the host. This
means the usual UNIX device-file permission rules apply.

### Granting guacd access to the device

Serial devices are normally owned by `root` and a group such as `dialout`
(Debian/Ubuntu) or `uucp`/`lock` (RHEL/Fedora/SUSE), with group read/write
permission. guacd should **not** be run as root, so the user guacd runs as
must be made a member of the appropriate group:

```console
# Debian/Ubuntu, guacd running as user "guacd"
$ sudo usermod -aG dialout guacd

# RHEL/Fedora/SUSE
$ sudo usermod -aG uucp guacd

# Group membership is only picked up at login/process start,
# so guacd must be restarted after this change
$ sudo systemctl restart guacd
```

Confirm the device's owning group and that guacd's user is a member of it:

```console
$ ls -l /dev/ttyUSB0
crw-rw---- 1 root dialout 188, 0 Jul 14 10:02 /dev/ttyUSB0
$ groups guacd
guacd : guacd dialout
```

:::{tip}
If you'd rather not rely on the distribution's default device group, a udev
rule can grant access explicitly. For example, to place all USB-serial
adapters in the `dialout` group with mode `0660`, create
`/etc/udev/rules.d/99-serial-console.rules`:

```
SUBSYSTEM=="tty", SUBSYSTEMS=="usb", GROUP="dialout", MODE="0660"
```

Reload udev with `sudo udevadm control --reload-rules && sudo udevadm trigger`.
:::

### Use stable device paths

Linux assigns `/dev/ttyUSB*` and `/dev/ttyACM*` names in enumeration order,
which can change across reboots or when adapters are plugged in a different
order or a different port — silently pointing a connection at the wrong
device. Wherever possible, use the stable, udev-generated symlinks under
`/dev/serial/by-id/` instead:

```console
$ ls -l /dev/serial/by-id/
lrwxrwxrwx 1 root root 13 Jul 14 10:02 usb-FTDI_TTL232R-3V3_FTGH1234-if00-port0 -> ../../ttyUSB0
```

Use the `by-id` path (e.g.
`/dev/serial/by-id/usb-FTDI_TTL232R-3V3_FTGH1234-if00-port0`) as the `device`
connection parameter rather than `/dev/ttyUSB0`.

(serial-allowed-devices)=

### Restricting which devices can be opened

Because the `device` parameter is ultimately just a filesystem path that
guacd honors directly, guacd should be configured with an explicit allowlist
of serial devices it is permitted to open, so that a Guacamole connection
cannot be used to open arbitrary device files on the guacd host. Configure
the allowlist on the guacd side (`guacd.conf`, or the equivalent
command-line option — see [](guacd.conf)) as a comma-separated list of
permitted device paths, for example:

```
[serial]

allowed_devices = /dev/serial/by-id/usb-FTDI_TTL232R-3V3_FTGH1234-if00-port0,/dev/serial/by-id/usb-FTDI_TTL232R-3V3_FTGH5678-if00-port0
```

With an allowlist configured, any connection whose `device` parameter is not
present in the list is refused, regardless of filesystem permissions. This,
combined with running guacd as an unprivileged user restricted to the
`dialout`/`uucp` group rather than root, keeps a compromised or misconfigured
connection from reading or writing arbitrary device files on the guacd host.

(serial-network-mode-setup)=

## Network mode: connecting via ser2net

In network mode, guacd does not open a local device at all; instead it
connects over TCP to a serial-to-network gateway that has the device open on
its behalf. [ser2net](https://github.com/cminyard/ser2net) is the most
common such gateway and the one documented here, but any gateway speaking
plain TCP or RFC 2217 will work.

### `raw` vs `rfc2217`

Guacamole's `network-protocol` parameter selects how the connection to the
gateway is framed:

`raw`
: A plain, transparent TCP byte pipe: every byte sent by Guacamole is
  written to the serial line, and every byte read from the serial line is
  sent back to Guacamole, with nothing else in the stream. The serial line
  settings (baud rate, parity, etc.) are whatever the gateway was configured
  with; Guacamole's `baud-rate`/`data-bits`/`stop-bits`/`parity` parameters
  have no effect on a `raw` connection. A raw connection also has no
  mechanism for carrying an out-of-band signal, so it **cannot deliver a
  [Send Break](serial-send-break)**.

`rfc2217`
: The Telnet COM Port Control option ([RFC 2217](https://www.rfc-editor.org/rfc/rfc2217)),
  which multiplexes the serial data with an in-band control channel. This
  allows Guacamole to remotely negotiate the serial line settings (baud
  rate, data bits, stop bits, parity, flow control) with the gateway, and to
  deliver a **Send Break** signal to the device. Prefer `rfc2217` whenever
  the gateway supports it.

### A complete ser2net example

The following `/etc/ser2net.yaml` exposes a single USB-serial adapter,
`/dev/ttyUSB0`, on the network twice: once as `rfc2217` on port 2001 (for
full functionality, including Send Break), and once as a plain `raw` byte
pipe on port 2002 (for clients or gateways that only speak raw TCP). Both
use the same 9600 8N1 line settings and `kickolduser: true`, which
disconnects any existing session on the port when a new client connects, so
a stale connection cannot block access indefinitely:

```yaml
%YAML 1.1
---
connection: &console-rfc2217
  accepter: telnet(rfc2217),tcp,2001
  connector: serialdev,
    /dev/ttyUSB0,
    9600n81,local
  options:
    kickolduser: true

connection: &console-raw
  accepter: tcp,2002
  connector: serialdev,
    /dev/ttyUSB0,
    9600n81,local
  options:
    kickolduser: true
```

Corresponding Guacamole connection parameters:

```xml
<!-- rfc2217: full functionality, including Send Break -->
<connection name="Switch console (rfc2217)">
    <protocol>serial</protocol>
    <param name="serial-type">network</param>
    <param name="network-protocol">rfc2217</param>
    <param name="hostname">ser2net.example.net</param>
    <param name="port">2001</param>
</connection>

<!-- raw: plain byte pipe, no Send Break -->
<connection name="Switch console (raw)">
    <protocol>serial</protocol>
    <param name="serial-type">network</param>
    <param name="network-protocol">raw</param>
    <param name="hostname">ser2net.example.net</param>
    <param name="port">2002</param>
</connection>
```

:::{warning}
ser2net endpoints, whether `raw` or `rfc2217`, are typically **unauthenticated
and unencrypted** — anyone who can reach the TCP port can read and write the
serial console, including any credentials typed at a device's login prompt.
Do not expose ser2net directly to an untrusted network. Bind it to a
dedicated management network, or place it behind an SSH tunnel, `stunnel`,
or VPN, and restrict access with firewall rules.
:::

(serial-send-break)=

## Sending a Break signal

A serial Break is a sustained line condition — not a character — held for a
brief period. Many devices watch for it during boot in order to interrupt
the normal boot sequence and enter a recovery or diagnostic mode: it drops
Cisco devices into ROMMON for password recovery, interrupts U-Boot on
embedded and networking gear, and is used by similar bootloaders on other
platforms.

guacd exposes a pipe named `serial-control` on the connection; writing the
text command `break` to this pipe causes guacd to assert a Break condition
on the line for the duration configured by the `break-duration` connection
parameter (500 ms by default).

### Sending a break from the browser

The web client exposes this as a **Send Break** action in the connection's
menu while a serial session is active. Selecting it writes the `break`
command to the `serial-control` pipe on your behalf, so in normal use you
send a break from the menu rather than writing to the pipe directly.

Break delivery requires guacd to have direct control of the line: it works
in local mode, and in network mode when `network-protocol` is `rfc2217`. A
`raw` network connection is a plain byte stream with no channel for
out-of-band signals, so **Send Break has no effect over a `raw` connection**
— use `rfc2217` if you need it.

## Common pitfalls

Permission denied opening the device
: guacd's user is not a member of the device's owning group. See
  [](serial-allowed-devices) above — add the user to `dialout`/`uucp` and
  restart guacd.

Garbage / mojibake output
: The configured serial line settings don't match the device. This is
  almost always a baud rate mismatch — 9600 and 115200 are the two most
  common console speeds, and connecting at the wrong one produces a screen
  full of unreadable characters rather than a clean error. Check the
  device's documentation for its console port speed and set `baud-rate`
  (and, if needed, `data-bits`/`stop-bits`/`parity`) to match.

Characters dropped when pasting a large configuration
: Devices with slow serial input buffers, or connections without flow
  control, can lose characters when a large block of text (such as a full
  device configuration) is pasted in faster than the device can consume it.
  Enable `flow-control` (`rts-cts` or `xon-xoff`, if the device supports
  it), or, if flow control isn't available, increase `paste-delay` to pace
  the paste out over time instead.

The console appears completely silent
: Serial consoles do not announce themselves — unlike SSH or telnet, nothing
  is sent until the device has something to say, and console output is
  often line-buffered or won't redraw until the terminal is "woken up".
  Press **Enter** a few times after connecting to activate the console and
  produce a prompt.

## System-level alternatives: USB/IP

[USB/IP](http://usbip.sourceforge.net/) (`usbip`) can, in principle, export a
USB-serial adapter from one machine and attach it as a local device
(`/dev/ttyUSB0`) on another over the network, after which it could be used as
an ordinary local-mode `device`. This is **not integrated with Guacamole and
is not recommended** for this purpose: it requires loading the `vhci-hcd`
kernel module and root privileges on the client, provides no authentication
or encryption of its own, and reconnection after a network interruption is
fragile, typically requiring the device to be manually re-attached rather
than transparently resuming. USB/IP may work if your operating system
already presents a stable local tty by some other means, but it is
unsupported for this purpose. [ser2net](serial-network-mode-setup) is the
recommended method for remote serial console access in production.
