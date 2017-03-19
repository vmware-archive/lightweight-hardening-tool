# HARDENING

#####Build

```./autogen.sh ; ./configure ; make dist ; rpmbuild -tb *.tar.gz```



###### Description
The main puprose of this tool is to harden/secure you server.
hardening tool was developed in a plugable way. It should be used to harden RHEL family servers. Tool uses plugins and profiles.

######1. Plugins

Plugin is a shell scipt that is used to secure some system component.

######2.Profiles

Profile includes a bunch of pluings. Each line represents a plugin. 

######3. Main

Main script for this tool is secure.sh

######4. Options

The following are general options you can use with this command.

######5. Examples

Run one cron plugin

```secure.sh --plugin=cron```

Run one cron pluign with dry option

```secure.sh --plugin=cron --dry```

Run one cron plugin with parameters

```secure.sh --plugin=cron --plugin_params='param1 param2'```

Run two plugins: cron,iptables_all

```secure.sh --plugin=cron,iptables_all```

Run profile: base

```secure.sh --plugin=base```

Run two profiles: base,profile

```secure.sh --profile=base,profile```

Run two profiles: base,profile with parameters

```secure.sh --profile=base,profile --profile_params=base:param1,param2@profile:param1```
