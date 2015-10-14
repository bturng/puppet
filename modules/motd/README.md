mit-motd Puppet Module
======================

  This Puppet module is used to automate the system's motd file. When 
  initialized, it will create a new motd file with the standard legal
  disclaimer for the system. After initialization, it is easy to add 
  and remove text from the motd file by using the enclosed motd script. 
  
  The motd script is installed in /usr/local/bin and it manages files 
  placed in /etc/motd.d. The following is the motd manpage. 


NAME
----
  motd - Script to automate /etc/motd

SYNOPSIS
--------
    motd init
    motd generate|gen
    motd list
    motd [--priority|-p] add LABEL [FILE | MESG]
    motd delete|del LABEL
    motd enable|ena LABEL
    motd disable|dis LABEL

DESCRIPTION
-----------
The motd script is used to manage parts of the motd file and build the
system's motd file from the parts stored in /etc/motd.d. Once
initialized, it is easy to quickly add and remove text from the system's
motd file.

By executing "motd init", the /etc/motd.d directory is created and the
legal disclaimer is added to the directory at priority level 00 so that
it will be the first part added to the motd file. Each motd part stored
in /etc/motd.d is assigned a priority level (00 - 99) which specifies
the order that the parts will be added to the motd file. The parts can
be listed by using the "list" subcommand.

Once initialized, administrators are able to add new messages to the
motd file with the "add" subcommand, remove messages with the "delete"
subcommand or enable/disable messages with the "enable/disable"
subcommands. The "add" subcommand requires a label (alphanumeric text to
associate with the text) to be specified, but the remaining subcommands
can specify the label or the priority of the message.

When adding a message, the message priority can be specified with the
"--priority" option. If the priority is not specified, then the priority
will be automatically be assigned starting at 30 and increasing by 5
until a priority level is found that is not assigned. This allows
messages to be written to the motd in date order quickly without needing
to specify a priority.

OPTIONS
-------

--priority |-prio | -p NUM
>    Specify the priority level for the motd label being created.

--help | -h
>    Display the commands help.


Using the Puppet Module
=======================

The motd class can be activated by including motd as one fo the classes specified by the ENC or by including the class in your role Puppet module. 

The motd module is a paramatized class and will take the following parameters when called directly. 

* enable: set to 'enable' to update the motd with system status
* schedule: set the cron minute schedule. defaults to 0,5,10,15,20,25,30,35,40,45,50,55
* status_template: ERB template to use for system status of motd

Using the Puppet module to add component files to motd is as easy as including the motd class and specifying motd::file classes. The following is a typical example. 

```ruby
include motd

motd::file{'node-function':
    level    => 20,
    source   => "puppet:///modules/${module_name}/node-function.txt",
}
```

This example will create the /etc/motd.d/20-node-function file and regenerate the motd file. The motd::file class will accept either a source or a content directive to populate the motd component file. The level directive can be specified as an integer or a string. 


Change Log
----------

| Version | Date       | Change                                           |
|:-------:|:----------:|--------------------------------------------------|
| 1.0     | 11/2/2012  | Added system-stats.erb                           |
| 1.1     | 11/4/2012  | Restructed motd command structure                |
| 1.2     | 12/5/2012  | Fixed motd generation problem                    |
| 1.3     | 12/5/2012  | Added ebay legal disclaimer                      |
| 1.4     | 12/5/2012  | Removed references to invalid facts              |
| 1.5     | 2/25/2013  | Fixed obsolete fact names                        |
| 1.6     | 10/4/2013  | Solaris support and cron updates                 |
| 1.7     | 1/10/2014  | Rspec tests, parameterized class                 |
| 1.7.1   | 1/24/2014  | Fixed identification of disabled MOTD files      |
| 1.7.3   | 10/3/2014  | Updated ref to git repo / added CentOS tests     |



Contact
=======

Gerard Hickey
gerard.hickey@audiencescience.com