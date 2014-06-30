---
layout: default
title: "Configuring a Puppet Master Server with Passenger and Apache"
---


Puppet includes a basic puppet master web server based on Ruby's WEBrick library. (This is what Puppet uses if you run `puppet master` on the command line or use most `puppetmaster` init scripts.)

You **cannot** use this default server for real-life loads, as it can't handle concurrent connections; it is only suitable for small tests with ten nodes or fewer. You must configure a production quality web server before you start managing your nodes with Puppet.

Any Rack-based application server stack will work with a puppet master, but if you don't have any particular preference, you should use Passenger combined with Apache. This guide shows how to configure Puppet with this software.


What is Passenger?
------------------

[Passenger](http://www.modrails.com/) (AKA mod\_rails or mod\_rack)
is an Apache 2.x module which lets you run Rails or Rack
applications inside a general purpose web server, like
[Apache httpd](http://httpd.apache.org/) or [nginx](http://nginx.org/).

### Relevant Pages in the Passenger Docs

[passenger_apache_guide]: http://www.modrails.com/documentation/Users%20guide%20Apache.html

* [The Apache version of the Passenger user's guide][passenger_apache_guide] covers the Passenger-specific configuration directives we use below in much greater detail.


Install Apache and Passenger
-----

Make sure `puppet master` has been run at least once (or
`puppet agent`, if this master is not the CA), so that all required
SSL certificates are in place.

### Install Apache 2

Debian/Ubuntu:

    $ sudo apt-get install apache2 ruby1.8-dev rubygems
    $ sudo a2enmod ssl
    $ sudo a2enmod headers

RHEL/CentOS (needs the Puppet Labs repository enabled, or the
[EPEL](https://fedoraproject.org/wiki/EPEL) repository):

    $ sudo yum install httpd httpd-devel mod_ssl ruby-devel rubygems gcc

### Install Rack/Passenger

    $ sudo gem install rack passenger
    $ sudo passenger-install-apache2-module

Configure Apache
-----

To configure Apache to run the puppet master application, you must:

* Install the puppet master Rack application, by creating a directory for it and copying the `config.ru` file from the Puppet source.
* Create a virtual host config file for the puppet master application, and install/enable it.

### Install the Puppet Master Rack Application

Your copy of Puppet includes a `config.ru` file, which tells Rack how to spawn puppet master processes. To install this Rack application in a form Passenger can use, you'll need to:

* Create three directories for the application (a parent directory, a "public" directory, and a "tmp" directory)
* Copy the `ext/rack/config.ru` file from the Puppet source code into the parent directory
* Set the ownership of the config.ru file

> **Note:** The `chown` step is important --- the owner of this file is the user the puppet master process will run under. This should usually be `puppet`, but may be different in your deployment.
>
> Also, make sure the Apache user (which may vary by platform) can both read and traverse all three directories, can traverse all of its parent directories, and can write to the "tmp" directory.

These steps will look something like this:

    $ sudo mkdir -p /usr/share/puppet/rack/puppetmasterd
    $ sudo mkdir /usr/share/puppet/rack/puppetmasterd/public /usr/share/puppet/rack/puppetmasterd/tmp
    $ sudo cp /usr/share/puppet/ext/rack/config.ru /usr/share/puppet/rack/puppetmasterd/
    $ sudo chown puppet:puppet /usr/share/puppet/rack/puppetmasterd/config.ru

The location of the Puppet source will vary by OS, and the packages you installed with might have excluded the files from `ext/`. If so, you can [download the config.ru file directly from GitHub](https://raw.github.com/puppetlabs/puppet/stable/ext/rack/config.ru).

### Create and Enable the Puppet Master Vhost

See ["Example Vhost Configuration" below](#example-vhost-configuration) for the contents of this vhost file. Note that the vhost's `DocumentRoot` directive refers to the Rack application directory you created above.

Debian/Ubuntu:

See "Example Vhost Configuration" below for the contents of the `puppetmaster` file

    $ sudo cp puppetmaster /etc/apache2/sites-available/
    $ sudo a2ensite puppetmaster

RHEL/CentOS:

See "Example Vhost Configuration" below for the contents of the `puppetmaster.conf` file.

    $ sudo cp puppetmaster.conf /etc/httpd/conf.d/

#### Example Vhost Configuration

This Apache Virtual Host configures the puppet master on the default
puppetmaster port (8140). You can also see a similar file at `ext/rack/example-passenger-vhost.conf` in the Puppet source.

    # You'll need to adjust the paths in the Passenger config depending on which OS
    # you're using, as well as the installed version of Passenger.

    # Debian/Ubuntu:
    #LoadModule passenger_module /var/lib/gems/1.8/gems/passenger-4.0.x/ext/apache2/mod_passenger.so
    #PassengerRoot /var/lib/gems/1.8/gems/passenger-4.0.x
    #PassengerRuby /usr/bin/ruby1.8

    # RHEL/CentOS:
    #LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-4.0.x/ext/apache2/mod_passenger.so
    #PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-4.0.x
    #PassengerRuby /usr/bin/ruby

    # And the passenger performance tuning settings:
    PassengerHighPerformance On
    # Set this to about 1.5 times the number of CPU cores in your master:
    PassengerMaxPoolSize 12
    # Recycle master processes after they service 1000 requests
    PassengerMaxRequests 1000
    # Stop processes if they sit idle for 10 minutes
    PassengerPoolIdleTime 600

    Listen 8140
    <VirtualHost *:8140>
        SSLEngine On

        # Only allow high security cryptography. Alter if needed for compatibility.
        SSLProtocol             All -SSLv2
        SSLCipherSuite          HIGH:!ADH:RC4+RSA:-MEDIUM:-LOW:-EXP
        SSLCertificateFile      /var/lib/puppet/ssl/certs/puppet-server.example.com.pem
        SSLCertificateKeyFile   /var/lib/puppet/ssl/private_keys/puppet-server.example.pem
        SSLCertificateChainFile /var/lib/puppet/ssl/ca/ca_crt.pem
        SSLCACertificateFile    /var/lib/puppet/ssl/ca/ca_crt.pem
        SSLCARevocationFile     /var/lib/puppet/ssl/ca/ca_crl.pem
        SSLCARevocationCheck 	chain
        SSLVerifyClient         optional
        SSLVerifyDepth          1
        SSLOptions              +StdEnvVars +ExportCertData
        
        # Apache 2.4 introduces the SSLCARevocationCheck directive and sets it to none
    	# which effectively disables CRL checking. If you are using Apache 2.4+ you must
        # specify 'SSLCARevocationCheck chain' to actually use the CRL.

        # These request headers are used to pass the client certificate
        # authentication information on to the puppet master process
        RequestHeader set X-SSL-Subject %{SSL_CLIENT_S_DN}e
        RequestHeader set X-Client-DN %{SSL_CLIENT_S_DN}e
        RequestHeader set X-Client-Verify %{SSL_CLIENT_VERIFY}e

        DocumentRoot /usr/share/puppet/rack/puppetmasterd/public

        <Directory /usr/share/puppet/rack/puppetmasterd/>
          Options None
          AllowOverride None
          # Apply the right behavior depending on Apache version.
          <IfVersion < 2.4>
            Order allow,deny
            Allow from all
          </IfVersion>
          <IfVersion >= 2.4>
            Require all granted
          </IfVersion>
        </Directory>

        ErrorLog /var/log/httpd/puppet-server.example.com_ssl_error.log
        CustomLog /var/log/httpd/puppet-server.example.com_ssl_access.log combined
    </VirtualHost>

If this puppet master is not the certificate authority, you will
need to use different paths to the CA certificate and CRL:

    SSLCertificateChainFile /var/lib/puppet/ssl/certs/ca.pem
    SSLCACertificateFile    /var/lib/puppet/ssl/certs/ca.pem
    SSLCARevocationFile     /var/lib/puppet/ssl/crl.pem

For additional details about enabling and configuring Passenger, see the
[Passenger install guide](http://www.modrails.com/install.html) and the [Apache version of the Passenger user's guide][passenger_apache_guide].

> ### Notes on DocumentRoot and PassengerAppRoot
>
> Passenger usually uses Apache's DocumentRoot directive to guess where to find its config.ru file --- it assumes config.ru will be right beside the `public` directory.
>
> This generally works fine, but some users have seen Passenger fail to guess. If Passenger fails to load the puppet master app and is displaying a generic error message, our first suggestion is to double-check the directory permissions (remember the Apache user must be able to read and traverse all puppet master application directories), but you can also try explicitly telling Passenger where to find the config.ru file with the PassengerAppRoot directive:
>
>     PassengerAppRoot /usr/share/puppet/rack/puppetmasterd

> ### Notes on SSL Verification
>
> When an agent node makes a request to the puppet master, Apache's `mod_ssl` performs the verification of its certificate, and the puppet master application will trust `mod_ssl`'s judgment. The two systems communicate via environment variables --- Apache must set two variables containing the client's subject DN and its verification status, and the puppet master must know which variables to check when it receives a request.
>
> Puppet uses the [`ssl_client_header`][client] and [`ssl_client_verify_header`][clientverify] settings to find these variables; the default values are `HTTP_X_CLIENT_DN` and `HTTP_X_CLIENT_VERIFY`, respectively.
>
> In our example vhost config above, Apache uses the `SSLOptions +StdEnvVars` directive to make several SSL-related environment variables available; a [full list of these variables is available here][sslvars]. It then uses these variables to construct several `RequestHeader set` directives, which put the information into the `X-Client-DN` and `X-Client-Verify` HTTP headers. The common gateway interface (CGI) standard converts all HTTP headers to environment variables and munges their names (an `HTTP_` prefix is added, dashes are converted to underscores, and all letters are uppercased), and Puppet uses these environment variables, which have become the default names we mentioned above (`HTTP_X_CLIENT_DN` and `HTTP_X_CLIENT_VERIFY`).
>
> Alternately, you could leave off the `RequestHeader` directives and use the `SSL_CLIENT_S_DN` and `SSL_CLIENT_VERIFY` variables directly, but this is a less standard way to do it, is tied specifically to Apache and `mod_ssl`, and requires changing your puppet.conf.



[sslvars]: http://httpd.apache.org/docs/2.2/mod/mod_ssl.html#envvars
[client]: /references/latest/configuration.html#sslclientheader
[clientverify]: /references/latest/configuration.html#sslclientverifyheader


Start or Restart the Apache service
-----

Ensure that any WEBrick puppet master process is stopped before starting
the Apache service; only one can be bound to TCP port 8140.

Debian/Ubuntu:

    $ sudo /etc/init.d/apache2 restart

RHEL/CentOS:

    $ sudo /etc/init.d/httpd restart

If all works well, you'll want to make sure the WEBrick service no longer starts on boot:

Debian/Ubuntu:

    $ sudo update-rc.d -f puppetmaster remove

RHEL/CentOS:

    $ sudo chkconfig puppetmaster off
    $ sudo chkconfig httpd on
