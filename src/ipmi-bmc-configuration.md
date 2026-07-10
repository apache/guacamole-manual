# Configuring BMCs for IPMI Serial-over-LAN

Guacamole's `ipmi` protocol connects to a server's **Baseboard Management
Controller (BMC)** over IPMI 2.0 (RMCP+) and attaches to its **Serial-over-LAN
(SOL)** console, giving you the machine's serial console — BIOS/UEFI, the
bootloader, and the OS console — from the browser, plus out-of-band chassis
power control.

Before a connection can succeed, the BMC itself must have **IPMI-over-LAN** and
**Serial-over-LAN** enabled, and you must use a cipher suite the BMC accepts.
These are configured on the BMC, not in Guacamole. This chapter documents the
validated procedure for the most common vendors and gives ready-to-use
Guacamole connection examples for each.

:::{important}
The single most common reason an IPMI connection fails is that **IPMI-over-LAN
is disabled by default** on modern BMCs (notably Dell iDRAC 9+, HPE iLO 5+, and
Lenovo XCC). If a connection times out or reports that no RMCP+ session could be
established, verify IPMI-over-LAN is enabled on the BMC first.
:::

(ipmi-cipher-suites)=

## Cipher suites and encryption

IPMI 2.0 negotiates cryptography via a numeric **cipher suite ID**. Only some
provide confidentiality (payload encryption):

| Cipher suite | Authentication | Integrity | Confidentiality | Encrypted? |
| ------------ | -------------- | --------- | --------------- | ---------- |
| **0**        | none           | none      | none            | ❌ (avoid) |
| 1 / 2        | HMAC-SHA1      | none/SHA1 | none            | ❌         |
| **3**        | HMAC-SHA1      | SHA1-96   | AES-CBC-128     | ✅         |
| **17**       | HMAC-SHA256    | SHA256-128| AES-CBC-128     | ✅         |

Guacamole defaults to **cipher suite 3** and to `encryption-policy=required`,
which refuses any non-encrypting suite (0, 1, 2, 6, 7, 8, 11, 15). Different
vendors support different suites — see each vendor below.

:::{warning}
Cipher suite 0 provides **no authentication, integrity, or encryption**. It is
refused by default and should never be used outside an isolated lab.
:::

## Dell iDRAC (7 / 8 / 9)

**IPMI-over-LAN is disabled by default.** Validated on an iDRAC 9 (firmware
7.20.30.00).

### Via the racadm CLI (SSH into the iDRAC)

```console
# Enable IPMI-over-LAN and Serial-over-LAN
racadm set iDRAC.IPMILan.Enable Enabled
racadm set iDRAC.IPMISOL.Enable Enabled

# Verify
racadm get iDRAC.IPMILan.Enable          # -> Enable=Enabled
racadm get iDRAC.IPMISOL.Enable          # -> Enable=Enabled

# Confirm the login user has an IPMI privilege of 4 (Administrator)
racadm get iDRAC.Users.2.IpmiLanPrivilege
```

### Via the iDRAC web UI

`iDRAC Settings` → `Connectivity` → `Network` → `IPMI Settings` →
check **Enable IPMI Over LAN**, set **Channel Privilege Level Limit** to
`Administrator`.

### Guacamole connection

iDRAC accepts cipher suite **3** or **17**:

```xml
<connection name="Dell iDRAC — SOL">
    <protocol>ipmi</protocol>
    <param name="hostname">192.168.201.138</param>
    <param name="username">root</param>
    <param name="password">********</param>
    <param name="cipher-suite">3</param>
    <param name="encryption-policy">required</param>
    <param name="workaround-flags">dell</param>
</connection>
```

## Lenovo XClarity Controller (XCC) / IMM2

IPMI-over-LAN may be disabled by default on ThinkSystem XCC. **XCC requires
cipher suite 17** — validated on XCC firmware 2.03, where cipher suite 3 was
rejected with `invalid authentication algorithm`.

### Enabling IPMI-over-LAN

- **Web UI:** `BMC Configuration` → `Network` → `Service Enablement and Port
  Assignment` → enable **IPMI over LAN**. Then `BMC Configuration` → `Serial
  Port` and verify **Serial over LAN** / CLI mode.
- **CLI (OneCLI / ASU):**
  `OneCli.exe config set IMM.IPMIoverLAN Enabled` (adjust to your XCC's setting
  name and version).

:::{note}
In XCC **CNSA / high-security** compliance mode, IPMI 2.0 is disabled entirely
because RMCP+ is not considered CNSA-compliant. Use Redfish/SSH on those hosts
instead — IPMI SOL will not be available.
:::

### Guacamole connection

```xml
<connection name="Lenovo XCC — SOL">
    <protocol>ipmi</protocol>
    <param name="hostname">192.168.1.17</param>
    <param name="username">USERID</param>
    <param name="password">********</param>
    <param name="cipher-suite">17</param>
    <param name="encryption-policy">required</param>
</connection>
```

## Supermicro (ATEN / X10–X12)

**IPMI-over-LAN is typically enabled by default.** Validated on a Supermicro
BMC using cipher suite **3** (cipher suites 0 and 17 were not available on the
tested unit).

### Enabling / verifying SOL

- **Web UI:** `Configuration` → `BMC Settings`; SOL is enabled by default.
- **CLI (from any host that can reach the BMC):**

```console
# Confirm SOL is enabled on channel 1, then verify a session establishes
ipmitool -I lanplus -H <bmc-ip> -U ADMIN -P <password> -C 3 sol info 1
ipmitool -I lanplus -H <bmc-ip> -U ADMIN -P <password> -C 3 chassis status
```

### Guacamole connection

Supermicro BMCs frequently need vendor workarounds for reliable RMCP+/SOL; the
`supermicro` preset applies the commonly-required set:

```xml
<connection name="Supermicro — SOL">
    <protocol>ipmi</protocol>
    <param name="hostname">10.2.0.153</param>
    <param name="username">ADMIN</param>
    <param name="password">********</param>
    <param name="cipher-suite">3</param>
    <param name="encryption-policy">required</param>
    <param name="workaround-flags">supermicro</param>
</connection>
```

(ipmi-workaround-flags)=

## Workaround flags

Some BMCs deviate from the IPMI 2.0 spec and need FreeIPMI workarounds. The
`workaround-flags` parameter accepts a comma-separated list of vendor **presets**
and/or individual **flag tokens**:

| Preset         | Expands to |
| -------------- | ---------- |
| `supermicro`   | `supermicro20,opensesspriv,integritycheckvalue,solpayloadsize,solport,solstatus` |
| `intel`        | `intel20,opensesspriv,integritycheckvalue` |
| `sun`          | `sun20,authcap,opensesspriv,solpayloadsize` |
| `dell`         | `opensesspriv,solpayloadsize` |
| `hpe`, `lenovo`| _(none; modern firmware generally needs no workarounds)_ |

Individual tokens (combine freely, e.g. `supermicro20,nochecksumcheck`):
`authcap`, `intel20`, `supermicro20`, `sun20`, `opensesspriv`,
`integritycheckvalue`, `nochecksumcheck`, `serialalertsdeferred`,
`solpacketseq`, `solpayloadsize`, `solport`, `solstatus`, `channelpayload`.

## Quick reference

| Vendor          | IPMI-over-LAN default | Cipher suite | `workaround-flags` |
| --------------- | --------------------- | ------------ | ------------------ |
| Dell iDRAC 7–9  | **Disabled**          | 3 or 17      | `dell`             |
| Lenovo XCC/IMM2 | Often disabled        | **17** (3 rejected) | _(none)_    |
| Supermicro      | Enabled               | 3            | `supermicro`       |
| HPE iLO 5/6     | **Disabled**          | 17 (high-security) | _(none)_     |

## Troubleshooting

`Unable to establish RMCP+ session` / connection times out
: IPMI-over-LAN is almost certainly **disabled** on the BMC. Enable it (see the
  vendor sections above).

`invalid authentication algorithm`
: The BMC does not support the chosen `cipher-suite`. Try `17` (Lenovo XCC, HPE
  iLO high-security) or `3` (older Supermicro/Dell).

`IPMI connection aborted: cipher suite N does not provide confidentiality`
: The BMC only offers non-encrypting suites and `encryption-policy` is
  `required`. Use an encrypting suite (3 or 17), or, only on a trusted isolated
  network, set `encryption-policy=preferred` (warns) or `none` (allows).

Session establishes but no output appears
: The BMC's SOL payload is not enabled, or BIOS/OS serial console redirection
  is not configured to the BMC's SOL. Enable SOL on the BMC and configure serial
  console redirection in BIOS/UEFI.
