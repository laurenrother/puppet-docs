---
layout: default
title: "Config Files: tagmail.conf"
canonical: "/puppet/latest/reference/config_file_tagmail.html"
---

[tags]: ./lang_tags.html
[tagmail_reference]: /references/3.5.latest/report.html#tagmail
[report_server]: /references/3.5.latest/configuration.html#reportserver
[report]: /references/3.5.latest/configuration.html#report
[reports]: /references/3.5.latest/configuration.html#reports
[reportfrom]: /references/3.5.latest/configuration.html#reportfrom
[smtpserver]: /references/3.5.latest/configuration.html#smtpserver
[sendmail]: /references/3.5.latest/configuration.html#sendmail
[tagmap]: /references/3.5.latest/configuration.html#tagmap


The `tagmail.conf` file configures the optional [`tagmail` report processor][tagmail_reference].

## What is the Tagmail Report Processor?

Puppet agent nodes can be configured to send reports to a puppet master server. The master will then use its configured [report processors][report]  to handle those reports.

The `tagmail` report processor sends targeted emails to different admin users whenever certain resources are changed.

## Enabling Tagmail

To enable tagmail, you must:

* **Enable reporting:** On agent nodes (and puppet apply nodes), set [`report = true`][report].
    * You can optionally specify a different puppet master for reports with the [`report_server` setting][report_server].
* **Enable the tagmail processor:** On puppet masters (and puppet apply nodes), set [`reports = tagmail`][reports].
    * Note that [the `reports` setting][reports] accepts a list, so you can enable multiple report processors.
* **Configure email:** On puppet masters (and puppet apply nodes), set the [`reportfrom`][reportfrom] email address and a value for either [`smtpserver`][smtpserver] or [`sendmail`][sendmail].
* **Configure tags:** On puppet masters (and puppet apply nodes), create a `tagmail.conf` file at the location specified in the `tagmap` setting.

## The `tagmail.conf` File

### Location

The `tagmail.conf` file is located at `$confdir/tagmail.conf` by default. Its location is configurable with the [`tagmap` setting][tagmap].

The location of the `confdir` varies; it depends on the OS, Puppet distribution, and user account. [See the confdir documentation for details.][confdir]

[confdir]: ./dirs_confdir.html

### Example

    all: log-archive@example.com
    webserver, !mailserver: httpadmins@example.com
    emerg, crit: james@example.com, zach@example.com, ben@example.com

This `tagmail.conf` file will mail any resource events tagged with `webserver` but _not_ with `mailserver` to the httpadmins group; any emergency or critical events to to James, Zach, and Ben, and all events to the log-archive group.

### Format

The `tagmail.conf` file is series of lines. Each line should consists of:

* A comma-separated list of tags and !negated tags; valid tags include:
    * Explicit [tags][]
    * Class names
    * "`all`", which is a special value matching all events
    * Any valid Puppet log level (`debug`, `info`, `notice`, `warning`, `err`, `alert`, `emerg`, `crit`, or `verbose`)
* A colon
* A comma-separated list of email addresses

The list of tags on a line defines the set of resources whose messages will be included in the mailing; each additional tag adds to the set, and each !negated tag subtracts from the set.

