---
layout: default
title: "Configuration: Short List of Important Settings"
canonical: "/puppet/latest/reference/config_important_settings.html"
---

<!-- TODO: replace these -->
[cli_settings]: ./config_about_settings.html


[trusted_and_facts]: ./lang_facts_and_builtin_vars.html
[config_environments]: ./environments_classic.html
[config_reference]: /references/3.5.latest/configuration.html
[environments]: /guides/environment.html
[future]: ./experiments_future.html
[multi_master]: /guides/scaling_multiple_masters.html
[enc]: /guides/external_nodes.html
[meta_noop]: /references/3.5.latest/metaparameter.html#noop
[meta_schedule]: /references/3.5.latest/metaparameter.html#schedule
[lang_tags]: ./lang_tags.html
[modulepath_dir]: ./dirs_modulepath.html
[manifest_dir]: ./dirs_manifest.html
[report_reference]: /references/3.5.latest/report.html
[write_reports]: /guides/reporting.html#writing-custom-reports
[passenger_headers]: /guides/passenger.html#notes-on-ssl-verification
[puppetdb_install]: /puppetdb/latest/connect_puppet_master.html
[static_compiler]: /references/3.5.latest/indirection.html#staticcompiler-terminus
[ssl_autosign]: ./ssl_autosign.html

[trusted_node_data]: /references/3.5.latest/configuration.html#trustednodedata
[immutable_node_data]: /references/3.5.latest/configuration.html#immutablenodedata
[strict_variables]: /references/3.5.latest/configuration.html#strictvariables
[stringify_facts]: /references/3.5.latest/configuration.html#stringifyfacts
[structured_facts]: /references/3.5.latest/configuration.html#structuredfacts
[ordering]: /references/3.5.latest/configuration.html#ordering
[reports]: /references/3.5.latest/configuration.html#reports
[parser]: /references/3.5.latest/configuration.html#parser
[server]: /references/3.5.latest/configuration.html#server
[ca_server]: /references/3.5.latest/configuration.html#caserver
[report_server]: /references/3.5.latest/configuration.html#reportserver
[certname]: /references/3.5.latest/configuration.html#certname
[node_name_fact]: /references/3.5.latest/configuration.html#nodenamefact
[node_name_value]: /references/3.5.latest/configuration.html#nodenamevalue
[environment]: /references/3.5.latest/configuration.html#environment
[noop]: /references/3.5.latest/configuration.html#noop
[priority]: /references/3.5.latest/configuration.html#priority
[report]: /references/3.5.latest/configuration.html#report
[tags]: /references/3.5.latest/configuration.html#tags
[trace]: /references/3.5.latest/configuration.html#trace
[profile]: /references/3.5.latest/configuration.html#profile
[graph]: /references/3.5.latest/configuration.html#graph
[show_diff]: /references/3.5.latest/configuration.html#showdiff
[usecacheonfailure]: /references/3.5.latest/configuration.html#usecacheonfailure
[ignoreschedules]: /references/3.5.latest/configuration.html#ignoreschedules
[prerun_command]: /references/3.5.latest/configuration.html#preruncommand
[postrun_command]: /references/3.5.latest/configuration.html#postruncommand
[pluginsync]: /references/3.5.latest/configuration.html#pluginsync
[runinterval]: /references/3.5.latest/configuration.html#runinterval
[waitforcert]: /references/3.5.latest/configuration.html#waitforcert
[splay]: /references/3.5.latest/configuration.html#splay
[splaylimit]: /references/3.5.latest/configuration.html#splaylimit
[daemonize]: /references/3.5.latest/configuration.html#daemonize
[onetime]: /references/3.5.latest/configuration.html#onetime
[dns_alt_names]: /references/3.5.latest/configuration.html#dnsaltnames
[basemodulepath]: /references/3.5.latest/configuration.html#basemodulepath
[modulepath]: /references/3.5.latest/configuration.html#modulepath
[manifest]: /references/3.5.latest/configuration.html#manifest
[ssl_client_header]: /references/3.5.latest/configuration.html#sslclientheader
[ssl_client_verify_header]: /references/3.5.latest/configuration.html#sslclientverifyheader
[node_terminus]: /references/3.5.latest/configuration.html#nodeterminus
[external_nodes]: /references/3.5.latest/configuration.html#externalnodes
[storeconfigs]: /references/3.5.latest/configuration.html#storeconfigs
[storeconfigs_backend]: /references/3.5.latest/configuration.html#storeconfigsbackend
[catalog_terminus]: /references/3.5.latest/configuration.html#catalogterminus
[config_version]: /references/3.5.latest/configuration.html#configversion
[ca]: /references/3.5.latest/configuration.html#ca
[ca_ttl]: /references/3.5.latest/configuration.html#cattl
[autosign]: /references/3.5.latest/configuration.html#autosign

Puppet has about 230 settings, all of which are listed in the [configuration reference][config_reference]. Most users can ignore about 200 of those.

This page lists the most important ones. (We assume here that you're okay with default values for things like the port Puppet uses for network traffic.) The link for each setting will go to the long description in the configuration reference.

> **Why so many settings?** There are a lot of settings that are rarely useful but still make sense, but there are also at least a hundred that shouldn't be configurable at all.
>
> This is basically a historical accident. Due to the way Puppet's code is arranged, the settings system was always the easiest way to publish global constants that are dynamically initialized on startup. This means a lot of things have crept in there regardless of whether they needed to be configurable.

Getting New Features Early
-----

We've added improved behavior to Puppet over the course of the 3.x series, but some of it can't be enabled by default until a major version boundary, since it changes things that some users might be relying on. But if you know your site won't be affected, you can enable some of it today.

### Recommended and Safe

* [`trusted_node_data = true`][trusted_node_data] (puppet master/apply only) --- This enables [the `$trusted` and `$facts` hashes][trusted_and_facts], so you can start using them in your own code.
    * And then the `$facts` variable can be independently disabled with the [`immutable_node_data`][immutable_node_data] setting, but you probably want both.
* [`stringify_facts = false`][stringify_facts] (all nodes) --- This enables [structured facts][structured_facts], allowing facts to contain arrays, hashes, and booleans instead of just strings. This requires Facter 2.0, and none of the core facts use this yet, but enabling it will let you take advantage of structured facts as they are gradually released.
* [`ordering = manifest`][ordering] (all nodes) --- This causes unrelated resources to be applied in the order they are written, instead of in effectively random order. It allows you to be "lazy" in small classes and write resources in chronological order instead of specifying dependencies. But be careful when writing manifests like this, since it makes it harder to share code with other users.

### Possibly Disruptive

Both of these only affect the puppet master (and puppet apply nodes).

* [`parser = future`][parser] (puppet master/apply only) --- This enables the future parser, which is explained in more detail on [the future parser page][future]. Since it swaps out the entire Puppet language, there's a good chance you'll find something in your code it doesn't like, but it now runs at a decent speed and lets you explore what's eventually coming in Puppet 4.
* [`strict_variables = true`][strict_variables] (puppet master/apply only) --- This makes uninitialized variables cause parse errors, which can help squash difficult bugs by failing early instead of carrying undef values into places that don't expect them. This one has a strong chance of causing problems when you turn it on, so be wary, but it will eventually improve the general quality of Puppet code.



Settings for Agents (All Nodes)
-----

Roughly in order of importance. Most of these can go in either `[main]` or `[agent]`, or be [specified on the command line][cli_settings].

### Basics

* [`server`][server] --- The puppet master server to request configurations from. Defaults to `puppet`; change it if that's not your server's name.
    * [`ca_server`][ca_server] and [`report_server`][report_server] --- If you're using multiple masters, you'll need to centralize the CA; one of the ways to do this is by configuring `ca_server` on all agents. [See the multiple masters guide][multi_master] for more details. The `report_server` setting works about the same way, although whether you need to use it depends on how you're processing reports.
* [`certname`][certname] --- The node's certificate name, and the name it uses when requesting catalogs; defaults to the fully qualified domain name.
    * For best compatibility, you should limit the value of `certname` to only use letters, numbers, periods, underscores, and dashes. (That is, it should match `/\A[a-z0-9._-]+\Z/`.)
    * The special value `ca` is reserved, and can't be used as the certname for a normal node.
    * (Yes, it's also possible to re-use certificates/certnames and then set the name used in requests via the [`node_name_fact`][node_name_fact] / [`node_name_value`][node_name_value] settings. Don't do this unless you know exactly what you're doing, because it changes Puppet's whole security model. For most users, certname = only name.)
* [`environment`][environment] --- The [environment][environments] to request when contacting the puppet master. It's only a request, though; the master's [ENC][] can override this if it chooses. Defaults to `production`.

### Run Behavior

These settings affect the way Puppet applies catalogs.

* [`noop`][noop] --- If enabled, the agent won't do any work; instead, it will look for changes that _should_ be made, then report to the master about what it would have done. This can be overridden per-resource with the [`noop` metaparameter][meta_noop].
* [`priority`][priority] --- Allows you to "nice" puppet agent so it won't starve other applications of CPU resources while it's applying a catalog.
* [`report`][report] --- Whether to send reports. Defaults to true; usually shouldn't be disabled, but you might have a reason.
* [`tags`][tags] --- Lets you limit the Puppet run to only include resources with certain [tags][lang_tags].
* [`trace`][trace], [`profile`][profile],  [`graph`][graph], and [`show_diff`][show_diff] --- Tools for debugging or learning more about an agent run. Extra-useful when combined with the `--test` and `--debug` CLI options.
* [`usecacheonfailure`][usecacheonfailure] --- Whether to fall back to the last known good catalog if the master fails to return a good catalog. The default behavior is good, but you might have a reason to disable it.
* [`ignoreschedules`][ignoreschedules] --- If you use [schedules][meta_schedule], this can be useful when doing an initial Puppet run to set up new nodes.
* [`prerun_command`][prerun_command] and [`postrun_command`][postrun_command] --- Commands to run on either side of a Puppet run.
* [`pluginsync`][pluginsync] --- This defaults to true these days, so you don't need it in your config file. But you might see it in default config files still, because in versions ≤2.7 you had to turn it on yourself.

### Service Behavior

These settings affect the way puppet agent acts when running as a long-lived service.

* [`runinterval`][runinterval] --- How often to do a Puppet run, when running as a service.
* [`waitforcert`][waitforcert] --- Whether to keep trying back if the agent can't initially get a certificate. The default behavior is good, but you might have a reason to disable it.

### Useful When Running Agent from Cron

* [`splay`][splay] and [`splaylimit`][splaylimit] --- Together, these allow you to spread out agent runs. When running the agent as a daemon, the services will usually have been started far enough out of sync to make this a non-issue, but it's useful with cron agents. For example, if your agent cron job happens on the hour, you could set `splay = true` and `splaylimit = 60m` to keep the master from getting briefly hammered and then left idle for the next 50 minutes.
* [`daemonize`][daemonize] --- Whether to daemonize. Set this to false when running the agent from cron.
* [`onetime`][onetime] --- Whether to exit after finishing the current Puppet run. Set this to true when running the agent from cron.

Settings for Puppet Master Servers
-----

Many of these settings are also important for standalone puppet apply nodes, since they act as their own puppet master.

These settings should usually go in `[master]`. However, if you're using puppet apply in production, put them in `[main]` instead.

### Basics

* [`dns_alt_names`][dns_alt_names] --- A list of hostnames the server is allowed to use when acting as a puppet master. The hostname your agents use in their `server` setting **must** be included in either this setting or the master's `certname` setting. Note that this setting is only used when initially generating the puppet master's certificate --- if you need to change the DNS names, you must:
    * Turn off the puppet master service (or Rack server).
    * Run `sudo puppet cert clean <MASTER'S CERTNAME>`.
    * Run `sudo puppet cert generate <MASTER'S CERTNAME> --dns_alt_names <ALT NAME 1>,<ALT NAME 2>,...`.
    * Re-start the puppet master service.
* [`basemodulepath`][basemodulepath] --- A list of directories containing Puppet modules that can be used in all environments. [See the modulepath page][modulepath_dir] for details.
    * The [`modulepath`][modulepath] setting controls the final modulepath, and can be set for each environment (when using [config file environments][config_environments]). Starting with Puppet 3.5, though, we recommend setting `basemodulepath` and letting `modulepath` take care of itself.
* [`manifest`][manifest] --- The main entry point for compiling catalogs. Defaults to a single site.pp file, but can also point to a directory of manifests. [See the manifest page][manifest_dir] for details.
* [`reports`][reports] --- Which report handlers to use. For a list of available report handlers, see [the report reference][report_reference]. You can also [write your own report handlers][write_reports]. Note that the report handlers might require settings of their own, like `tagmail`'s various email settings.

### Rack-Related Settings

* [`ssl_client_header`][ssl_client_header] and [`ssl_client_verify_header`][ssl_client_verify_header] --- These are used when running puppet master as a Rack application (e.g. under Passenger), which you should definitely be doing. See [the Passenger setup guide][passenger_headers] for more context about how these settings work; depending on how you configure your Rack server, you can usually leave these settings with their default values.

### Extensions

These features configure add-ons and optional features.

* [`node_terminus`][node_terminus] and [`external_nodes`][external_nodes] --- The ENC settings. If you're using an [ENC][], set these to `exec` and the path to your ENC script, respectively.
* [`storeconfigs`][storeconfigs] and [`storeconfigs_backend`][storeconfigs_backend] --- Used for setting up PuppetDB. See [the PuppetDB docs for details.][puppetdb_install]
* [`catalog_terminus`][catalog_terminus] --- This can enable the optional static compiler. If you have lots of `file` resources in your manifests, the static compiler lets you sacrifice some extra CPU work on your puppet master to gain faster configuration and reduced HTTPS traffic on your agents. [See the "static compiler" section of the indirection reference][static_compiler] for details.
* [`config_version`][config_version] --- The "config version" is an ID string included in catalogs and reports. Usually it's just the time at which the catalog was compiled, but this setting can specify a command to run to generate that ID. Some people use this to get, e.g., the current git HEAD in their modules directory.

### CA Settings

* [`ca`][ca] --- Whether to act as a CA. **There should only be one CA at a Puppet deployment.** If you're using [multiple puppet masters][multi_master], you'll need to set `ca = false` on all but one of them.
* [`ca_ttl`][ca_ttl] --- How long newly signed certificates should be valid for.
* [`autosign`][autosign] --- Whether (and how) to autosign certificates. See [the autosigning page][ssl_autosign] for details.

