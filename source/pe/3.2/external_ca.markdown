---
layout: default
title: "PE 3.2 » Deploying PE » External CA"
subtitle: "Using an External Certificate Authority with Puppet Enterprise"
canonical: "/pe/latest/external_ca.html"
---

The different parts of Puppet Enterprise (PE) use SSL certificates to communicate securely with each other. PE uses its own certificate authority (CA) to generate and verify these credentials.

However, you may already have your own CA in place and wish to use it instead of PE's integrated CA. This page will familiarize you with the certificates and security credentials signed by the PE CA, then detail the procedures for replacing them.

> ### Before You Begin
> Setting up an external certificate authority (CA) to use with PE is beyond the scope of this document; in fact, this writing assumes that you already have some knowledge of CA and security credential creation and have the ability to set up your own external CA. This document will lead you through the certs and security credentials you'll need to replace in PE. However, before beginning, we recommend you familiarize yourself with the following docs:
>
>- [SSL Configuration: External CA Support](http://docs.puppetlabs.com/puppet/latest/reference/config_ssl_external_ca.html) provides guidance on establshing an external CA that will play nice will Puppet (and therefore PE).
>
>- [ActiveMQ TLS](http://docs.puppetlabs.com/mcollective/reference/integration/activemq_ssl.html) explains MCollective’s security layer.

## Locating Certificate Files

After installing PE, you can run `puppet cert list --all` on your puppet master server to inspect the inventory of certificates signed using PE's built-in CA. It will include the following:

-  Per-node certificates for the puppet master (and any agent nodes)
- `pe-internal-broker`
- `pe-internal-dashboard`
- `pe-internal-mcolllective-servers`
- `pe-internal-peadmin-mcollective-client`
- `pe-internal-puppet-console-mcollective-client`

Each of these will need to be replaced with new certificates signed by your external CA. The steps below will explain how to find and replace these credentials.

###Locating the PE Agent Certificate and Security Credentials

Every system under PE management (including the puppet master, console, and PuppetDB) runs the puppet agent service. To determine the proper locations for the certificate and security credential files used by the puppet agent, run the following commands:

- Certificate: `puppet agent --configprint hostcert`
- Private key: `puppet agent --configprint hostprivkey`
- Public key: `puppet agent --configprint hostpubkey`
- Certificate Revocation List: `puppet agent --configprint hostcrl`
- Local copy of the CA's certificate: `puppet agent --configprint localcacert`

>**Important: Shared Certificate and Security Credentials**
>
>In Puppet Enterprise, the puppet master and the puppet agent services share the same certificate, so replacing the shared certificate will suffice for both services. In other words, if you replace the puppet master certificate, you don't need to separately replace the agent certificate.

### Locating the PE Master Certificate and Security Credentials

[inpage_locate_master]: #locating-the-pe-master-certificate-and-security-credentials
[inpage_locate_agent]: #locating-the-pe-agent-certificate-and-security-credentials

To determine the proper locations for the CA and security credential files, run the following commands with `puppet master`:

- **Certificate**: `puppet master --configprint hostcert`
- **Private key**: `puppet master --configprint hostprivkey`
- **Public key**: `puppet master --configprint hostpubkey`
- **Certificate Revocation List**: `puppet master --configprint hostcrl`
- **Local copy of the CA's certificate**: `puppet master --configprint localcacert`

>**Important: Shared Certificate and Security Credentials**
>
>In Puppet Enterprise, the puppet master and the puppet agent services share the same certificate, so replacing the shared certificate will suffice for both services. In other words, if you replace the Puppet agent certificate, you don't need to separately replace the master certificate.

>**Tip**: You will also need to [create a cert and security credentials for any agent nodes](#adding-agent-nodes-using-your-external-ca) using the same CA as you used for the puppet master. We've included instructions at the end of the doc.

###Locating the PE Console Certificate and Security Credentials

[inpage_locate_console]: #locating-the-pe-console-certificate-and-security-credentials

The PE console certificates are stored at `/opt/puppet/share/puppet-dashboard/certs/`. This directory is located on the puppet master, or on the console server in a split install.

The following files in this directory need to be replaced:

- `pe-internal-dashboard.ca_cert.pem` (replace with your CA cert)
- `pe-internal-dashboard.private_key.pem`
- `pe-internal-dashboard.ca_crl.pem` (replace with your CA CRL)
- `pe-internal-dashboard.public_key.pem`
- `pe-internal-dashboard.cert.pem`

###Locating the PuppetDB Certificate and Security Credentials

[inpage_locate_puppetdb]: #locating-the-puppetdb-certificate-and-security-credentials

The following files, located on the puppet master, or on the PuppetDB server in a split install, need to be replaced:

- `/etc/puppetlabs/puppetdb/ssl/ca.pem` (replace with your CA cert)
- `/etc/puppetlabs/puppetdb/ssl/private.pem` (replace with a copy of the PuppetDB server's private key)
- `/etc/puppetlabs/puppetdb/ssl/public.pem` (replace with a copy of the PuppetDB server's certificate)

>**Important: Shared Certificate and Security Credentials**
>
>In Puppet Enterprise, the PuppetDB service uses a copy of the puppet agent's private key and certificate. If you have a split install, you will first replace the puppet agent's private key and certificate on the PuppetDB server (`/etc/puppetlabs/puppet/ssl/private_keys/<certname>.pem` and `/etc/puppetlabs/puppet/ssl/certs/<certname>.pem`) and copy them over to the PuppetDB SSL directories listed above.

###Locating PE MCollective Certificates and Security Credentials

[inpage_locate_mcollective]: #locating-pe-mcollective-certificates-and-security-credentials

The orchestration credentials, located on the puppet master, need to be replaced.

For each of the file names below, you'll need to replace **three** files: a cert in `/etc/puppetlabs/puppet/ssl/certs`, a private key in `/etc/puppetlabs/puppet/ssl/private_keys`, and a public key in `/etc/puppetlabs/puppet/ssl/public_keys`. Look for the following files:

- `pe-internal-broker.pem` (controls the ActiveMQ server)
- `pe-internal-mcollective-servers.pem`
- `pe-internal-peadmin-mcollective-client.pem`
- `pe-internal-puppet-console-mcollective-client.pem`

These certs and security credentials are generated by the puppetlabs-pe\_mcollective module as part of the PE installation process.

##Replacing the PE Certificate Authority and Security Credentials

> **Important**: For ease of use, we recommend naming *ALL* of your certificate and security credential files exactly the same way they are named by PE and replace them as such on the puppet master; for example, use the `cp` command to overwrite the file contents of the certs generated by the PE CA. This will ensure that PE will recognize the file names and not overwrite any files when you perform Puppet runs. In addition, this will prevent you from needing to touch various config files, and thus, limit the chances of problems arising.
>
> The remainder of this doc assumes you will be using identical files names.

We recommend that once you've set up your external CA and security credentials, you first replace the files for PE master/agent nodes and the PE console, then replace the files for PuppetDB, and then replace the PE MCollective files. Remember, naming the new certs and security credentials exactly as they're named by PE will ensure the easiest path to success.

Here is a list of the things you'll do:

1. [Install PE.](./install_basic.html)
2. Choose a certificate authority option.
3. Use your external CA to generate new certificates and security credentials to replace all existing certificates and security credentials.
4. Replace the PE master and PE console certs and security credentials.
5. Replace the PE PuppetDB certs and security credentials.
6. Replace the PE MCollective certs and security credentials.


###Replace the PE master and PE Console Certificates and Security Credentials

1. Refer to [Locating the PE Master Certificate and Security Credentials][inpage_locate_master] and copy your new certs and security credentials to the relevant locations.
2. Refer to [Locating pe-internal-dashboard Certificate and Security Credentials][inpage_locate_console] and copy your new certs and security credentials to the relevant locations.
3. On the puppet master, navigate to `/etc/puppetlabs/puppet/puppet.conf`, and in the `[master]` stanza, add `ca=false`.
4. Run `service pe-httpd restart`.

Continue to the next step, where you'll replace the PuppetDB certs.

###Replace the PuppetDB Certificates and Security Credentials

1. (Optional—for split installs only) Refer to [Locating the Puppet Agent Certificate and Security Credentials](#locating-the-puppet-agent-certificate-and-security-credentials) and replace the puppet agent service files. These files will be copied to the PuppetDB SSL directory in the step 2.
2. Refer to [Locating the PuppetDB Certificate and Security Credentials](#locating-the-puppetdb-certificate-and-security-credentials) and replace the files. 
3. Run `service pe-puppetdb restart`.
4. Run puppet.

After running Puppet, you should be able to access the console, and view your new certificate in your browser. However, live management will not work; you can access that part of the console, but it won't be able to find the master node.

Now you will need to replace the MCollective certificates and security credentials.

###Replace the MCollective Certificates and Security Credentials

1. On the puppet master, ensure that you replaced the CA cert (`ca.pem`) at `/etc/puppetlabs/puppet/ssl/certs/`. (**Tip**: If you didn't, the above procedures wouldn't have worked.)
2. Refer to [Locating PE MCollective Certificates and Security Credentials][inpage_locate_mcollective]. Generate new credentials for each name, then replace the cert, private key, and public key for each of them.
3. On the puppet master, navigate to `/etc/puppetlabs/activemq/`.
4. Remove the following two files: `broker.ts` and `broker.ks`.
7. Run `puppet agent --test` to force a Puppet run in the foreground.

During this run, Puppet will copy the credentials you replaced into their final locations, regenerate the ActiveMQ truststore and keystore, and restart the `pe-activemq` and `pe-mcollective` services.

You should now see the master node in live management and be able to perform Puppet runs and other live management functions using the console.

##Adding Agent Nodes Using Your External CA

1. Install Puppet Enterprise on the node, if it isn't already installed.
1. Using the same external CA you used for the puppet master, create a cert and private key for your agent node.
2. Locate the files you will need to replace on the agent. Refer to  [Locating the PE Agent Certificate and Security Credentials][inpage_locate_agent] to find them, but you should use `puppet agent --configprint` instead of `puppet master --configprint`.
3. Copy the agent's certificate, private key, and public key into place. Do the same with the external CA's CRL and CA certificate.
4. Restart the `pe-puppet` service.

Your node should now be able to do puppet agent runs, and its reports will appear in the console. If it is a new node, it may not appear in live management for up to 30 minutes. (You can accelerate this by letting Puppet run once, waiting a few minutes for the node to be added to the MCollective group in the console, and then running `puppet agent -t`. Once the )

If you still don't see your agent node in live management, use NTP to verify that time is in sync across your PE deployment. (You should *always* do this anyway.)

