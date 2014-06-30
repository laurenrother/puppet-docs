---
layout: default
title: "Installing Puppet: Microsoft Windows"
---

[downloads]: http://downloads.puppetlabs.com/windows
[peinstall]: /pe/latest/install_windows.html
[pre_install]: ./pre_install.html
[puppet.conf]: /puppet/latest/reference/config_file_main.html
[environment]: /puppet/latest/reference/environments.html
[confdir]: /puppet/latest/reference/dirs_confdir.html
[vardir]: /puppet/latest/reference/dirs_vardir.html

> **Note:** This document covers open source releases of Puppet. [See here for instructions on installing Puppet Enterprise.][peinstall]

First
-----

Before installing Puppet, make sure you've looked at the [pre-install tasks.](./pre_install.html)

Supported Versions
-----

{% include platforms_windows.markdown %}

To install on other operating systems, see the pages linked in the navigation sidebar.


Step 1: Configure a Puppet Master Server
-----

Windows machines can't act as puppet master servers. Before installing any Windows agent nodes, be sure that you have a \*nix puppet master installed and configured, and that you know its permanent hostname.

If you haven't done this yet, go back to the [pre-install tasks][pre_install], make any necessary decisions, and follow the install instructions and post-install tasks for your puppet master's OS.

Step 2: Download Package
-----

[Puppet Labs' Windows packages can be found here.][downloads] You will need the most recent `puppet-<VERSION>.msi` package. (This package bundles all of Puppet's prerequisites, so you don't need to download anything else.)

The list of Windows packages includes release candidates, whose filenames have something like `-rc1` after the version number. Only use these if you want to test upcoming Puppet versions.

Step 3: Install Puppet
-----

You can install Puppet [with a graphical wizard](#graphical-installation) or [on the command line](#automated-installation). If you install on the command line, you will have more configuration options.

### Graphical Installation

[server]: ./images/wizard_server.png

Double-click the MSI package you downloaded, and follow the graphical wizard. The installer must be run with elevated privileges. Installing Puppet does not require a system reboot.

During installation, you will be asked for the hostname of your puppet master server. This must be a \*nix node configured to act as a puppet master.

For standalone Puppet nodes that won't be connecting to a master, use the default hostname (`puppet`). You may also want to install on the command line and set the agent startup mode to `Disabled`.

![Puppet master hostname selection][server]

Once the installer finishes, Puppet will be installed, running, and at least partially configured. You should now [look at the post-install tasks](./post_install.html) --- many of them don't apply to Windows nodes, but you will need to sign node certificates and you may want to configure some additional settings.

### Automated Installation

Use the `msiexec` command to install the Puppet package:

    msiexec /qn /i puppet-<VERSION>.msi

If you don't specify any further options, this is the same as installing graphically with the default puppet master hostname (`puppet`).

You can specify `/l*v install.txt` to log the progress of the installation to a file.

You can also set several MSI properties to pre-configure Puppet as you install it. For example:

    msiexec /qn /i puppet.msi PUPPET_MASTER_SERVER=puppet.example.com

See the next heading for info about these MSI properties.

Once the installer finishes, Puppet will be installed, running, and at least partially configured. You should now [look at the post-install tasks](./post_install.html) --- many of them don't apply to Windows nodes, but you will need to sign node certificates and you may want to configure some additional settings.

### MSI Properties

These options are only available when installing Puppet on the command line (see above).

The following MSI properties are available:

MSI Property                                                   | Puppet Setting     | Introduced in
---------------------------------------------------------------|--------------------|-------------------------
[`INSTALLDIR`](#installdir)                                    | n/a                | Puppet 2.7.12 / PE 2.5.0
[`PUPPET_MASTER_SERVER`](#puppetmasterserver)                  | [`server`][s]      | Puppet 2.7.12 / PE 2.5.0
[`PUPPET_CA_SERVER`](#puppetcaserver)                          | [`ca_server`][c]   | Puppet 2.7.12 / PE 2.5.0
[`PUPPET_AGENT_CERTNAME`](#puppetagentcertname)                | [`certname`][r]    | Puppet 2.7.12 / PE 2.5.0
[`PUPPET_AGENT_ENVIRONMENT`](#puppetagentenvironment)          | [`environment`][e] | Puppet 3.3.1  / PE 3.1.0
[`PUPPET_AGENT_STARTUP_MODE`](#puppetagentstartupmode)         | n/a                | Puppet 3.4.0  / PE 3.2
[`PUPPET_AGENT_ACCOUNT_USER`](#puppetagentaccountuser)         | n/a                | Puppet 3.4.0  / PE 3.2
[`PUPPET_AGENT_ACCOUNT_PASSWORD`](#puppetagentaccountpassword) | n/a                | Puppet 3.4.0  / PE 3.2
[`PUPPET_AGENT_ACCOUNT_DOMAIN`](#puppetagentaccountdomain)     | n/a                | Puppet 3.4.0  / PE 3.2

[s]: /references/latest/configuration.html#server
[c]: /references/latest/configuration.html#caserver
[r]: /references/latest/configuration.html#certname
[e]: /references/latest/configuration.html#environment



#### `INSTALLDIR`

Where Puppet and its dependencies should be installed.

**Default:**

OS type  | Default Install Path
---------|---------------------
32-bit   | `C:\Program Files\Puppet Labs\Puppet`
64-bit   | `C:\Program Files (x86)\Puppet Labs\Puppet`

The Program Files directory can be located using the `PROGRAMFILES` environment variable on 32-bit versions of Windows or the `PROGRAMFILES(X86)` variable on 64-bit versions.

#### `PUPPET_MASTER_SERVER`

The hostname where the puppet master server can be reached. This will set a value for [the `server` setting][s] in the `[main]` section of [puppet.conf][].

**Default:** `puppet`

**Note:** If you set a _non-default_ value for this property, the installer will **replace** any existing value in puppet.conf. Also, the next time you upgrade, the installer will re-use your previous value for this property unless you set a new value on the command line. So if you've used this property once, you shouldn't change the `server` setting directly in puppet.conf; you should re-run the installer and set a new value there instead.

#### `PUPPET_CA_SERVER`

The hostname where the CA puppet master server can be reached, if you are using multiple masters and only one of them is acting as the CA. This will set a value for [the `ca_server` setting][c] in the `[main]` section of [puppet.conf][].

**Default:** the value of the `PUPPET_MASTER_SERVER` property

**Note:** If you set a _non-default_ value for this property, the installer will **replace** any existing value in puppet.conf. Also, the next time you upgrade, the installer will re-use your previous value for this property unless you set a new value on the command line. So if you've used this property once, you shouldn't change the `ca_server` setting directly in puppet.conf; you should re-run the installer and set a new value there instead.

#### `PUPPET_AGENT_CERTNAME`

The node's certificate name, and the name it uses when requesting catalogs. This will set a value for [the `certname` setting][r] in the `[main]` section of [puppet.conf][].

For best compatibility, you should limit the value of `certname` to only use lowercase letters, numbers, periods, underscores, and dashes. (That is, it should match `/\A[a-z0-9._-]+\Z/`.)

**Default:** the node's fully-qualified domain name, as discovered by `facter fqdn`.

**Note:** If you set a _non-default_ value for this property, the installer will **replace** any existing value in puppet.conf. Also, the next time you upgrade, the installer will re-use your previous value for this property unless you set a new value on the command line. So if you've used this property once, you shouldn't change the `certname` setting directly in puppet.conf; you should re-run the installer and set a new value there instead.

#### `PUPPET_AGENT_ENVIRONMENT`

The node's [environment][]. This will set a value for [the `environment` setting][e] in the `[main]` section of [puppet.conf][].

**Default:** `production`

**Note:** If you set a _non-default_ value for this property, the installer will **replace** any existing value in puppet.conf. Also, the next time you upgrade, the installer will re-use your previous value for this property unless you set a new value on the command line. So if you've used this property once, you shouldn't change the `environment` setting directly in puppet.conf; you should re-run the installer and set a new value there instead.

#### `PUPPET_AGENT_STARTUP_MODE`

Whether the puppet agent service should run (or be allowed to run). Allowed values:

* `Automatic` (**default**) --- puppet agent will start with Windows and stay running in the background.
* `Manual` --- puppet agent won't run by default, but can be started in the services console or with `net start` on the command line.
* `Disabled` --- puppet agent will be installed but disabled. You will have to change its start up type in the services console before you can start the service.


#### `PUPPET_AGENT_ACCOUNT_USER`

Which Windows user account the puppet agent service should use. This is important if puppet agent will need to access files on UNC shares, since the default `LocalService` account cannot access these network resources.

* This user account **must already exist,** and may be a local or domain user. (The installer will allow domain users even if they have not accessed this machine before.)
* If the user isn't already a local administrator, the installer will add it to the `Administrators` group.
* The installer will also grant [`Logon as Service`](http://msdn.microsoft.com/en-us/library/ms813948.aspx) to the user.

This property should be combined with `PUPPET_AGENT_ACCOUNT_PASSWORD` and `PUPPET_AGENT_ACCOUNT_DOMAIN`. For example, to assign the agent to a domain user `ExampleCorp\bob`, you would install with:

    msiexec /qn /i puppet-<VERSION>.msi PUPPET_AGENT_ACCOUNT_DOMAIN=ExampleCorp PUPPET_AGENT_ACCOUNT_USER=bob PUPPET_AGENT_ACCOUNT_PASSWORD=password

**Default:** `LocalSystem`

#### `PUPPET_AGENT_ACCOUNT_PASSWORD`

The password to use for puppet agent's user account. See the notes about users above.

**Default:** no value.

#### `PUPPET_AGENT_ACCOUNT_DOMAIN`

The domain of puppet agent's user account. See the notes about users above.

**Default:** `.`


### Upgrading

**Note:** Be sure to read our [tips on upgrading](./upgrading.html) before upgrading your whole Puppet deployment.

To upgrade to the latest version of Puppet, download the new MSI package and run the installer again. The installer will automatically restart the puppet agent service.

As noted above, there are several settings that will be remembered by the installer if they were set during the install. If you used those MSI properties in a previous installation and later changed those settings in puppet.conf, you will need to specify your new values when upgrading.

### Uninstalling

Puppet can be uninstalled through the "Add or Remove Programs" interface or from the command line.

To uninstall from the command line, you must have the original MSI file or know the <a href="http://msdn.microsoft.com/en-us/library/windows/desktop/aa370854(v=vs.85).aspx">ProductCode</a> of the installed MSI:

    msiexec /qn /x puppet-3.5.1.msi
    msiexec /qn /x <PRODUCT CODE>

Uninstalling will remove Puppet's program directory, the puppet agent service, and all related registry keys. It will leave the [confdir][] and [vardir][] intact, including any SSL keys. To completely remove Puppet from the system, the confdir and vardir can be manually deleted.


Next
----

Once the installer finishes, Puppet will be installed, running, and at least partially configured. You should now [look at the post-install tasks](./post_install.html) --- many of them don't apply to Windows nodes, but you will need to sign node certificates and you may want to configure some additional settings.

