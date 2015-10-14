ebay-customfacts
================

This is the Puppet module used to create basic custom facts for all environments for ebay infrastructure machines. This module is designed to coexist with an environment specific custom fact module and provide helper definitions to provice a consistant installation of custom facts. 

Implementation
==============

The facts-dot-d.rb is installed to enable custom facts to be accessible from the command line as well as within a Puppet manifest. There is never a need to use a -p on the facter command line to enable displaying of a custom fact. 

Custom fact files and scripts are installed to /etc/facts.d. Even though facter greater than 1.7.0 now provide custom fact support, it has been found that there are issues with user supplied custom fact scripts having access to standard facts. 

All custom fact files and scripts installed by this module are prepended with 'customfact-'. This prevents a collision with any filename in /etc/facts.d. It is suggested that all custom fact files install in an environment be prepended with a namespace description to avoid collisions and provide a method of detemining the source of the file. For example, files and scripts installed for the Cassini environment would be prepended with 'cassini-'. 

The actual name of the custom facts should probably be registered at https://wiki.vip.corp.ebay.com/display/ConfigMgmt/Plans+for+Custom+Facts. When thinking about producing custom facts, you should probably visit this page to determine if the fact is already being produced. If the fact is already being used elsewhere, use the same fact name. Making multiple names for the same facts only leads to confusion.


How to Use this Puppet Module
=============================

This Puppet module will be applied to all infrastructure machines automatically when the agent checks in. It is *not* advised that this module be overridden in any environment, but rather another Puppet module be used to implement an environment's custom facts (using namespacing described above). 

Because the ebay-customfact module is included on every infrastructure machine, the ebay-customfact module publishes the customfact::file class to provide a standardized way of installing scripts and files into the directory used by facts-dot-d.rb. A standard use would be:

```ruby
customfact::file {'local-usefulfacts.yaml':
    source  => "puppet:///${module_name}/usefulfacts.yaml",
    mode    => '0444',
}
```

The customfact::file class will accept source or content for creating the file and optionally will accept mode for setting the permissions. If mode is not set, then it will default to '0555' assuming a script is being put in place. 


Basic Custom Facts
==================

When this Puppet module is applied to a machine, it installs the custom-fact-generator script into /usr/local/bin. This script is used to generate the basic facts for the machine. Facts are written to /etc/facts.d/asset.yaml. The custom-fact-generator script will primarily pull from three different sources of information to build its list of facts. 

It will first read in the install time settings that are saved to /var/tmp/install/my-vars.txt during the provisioning process. This file contains the bulk of the custom facts that are generated and on occasion this file can not be found on the machine. When the file is missing, the facts will not appear and the file needs to be manually copied from the DHCP servers into the /var/tmp/install directory. Once put back into place, the custom-fact-generator script can be re-executed to generate the facts.

Facts that are imported from my-vars.txt are:

   - assetid
   - datacenter
   - macaddress_ilom
   - os_profile_name
   - os_profile_version
   - interface_count
   - iaas_job_id
   - gateway_eth0
   - gateway_eth1
   - install_server_url
   - serial_console_options
   - extra_packages_url


Some of the facts are looked up in ODB, but principally rely on having the initial set of facts read from the my-vars.txt file. These facts will also be regenerated when custom-fact-generator script is executed. 

Facts that are read from ODB are:

   - tag
   - faultdomain
   - locationcode
   - ipaddress_ilom
   - ebay_hw_sku


The final source of facts produced by the custom-fact-generator script are republication of standard facter facts. Some facts are only available when facter is exeucted by root. The republication of these facts make them available to all users. 

Facts that are republished are:

   - boardmanufacturer
   - boardserialnumber
   - boardproductname
   - bios_release_date
   - bios_vendor
   - bios_version
   - manufacturer
   - productname
   - serialnumber
   - type
   - uniqueid

   
Dynamic Custom Facts Installed
==============================

In addition to all the static custom facts listed above, there are a number of scripts that are installed to give dynamic values to the facter command. They are as follows:

   - customfact-diskspace: Provide the amount of used and free diskspace for / and /ebay 
   - customfact-linkspeed: Display what the current network interface speeds are in megabits / second
   - customfact-production-status: Display the adminstatus and assetstatus for the machine. If ODB does not respond within 5 seconds, then these values will display 'timeout'
   - customfact-raid-status: Display the current RAID status on the machine. This fact will only display when facter is executed as root.
   


custom-fact-generator Options
=============================

```
% custom-fact-generator.rb --help
Usage: custom-fact-generator [options]
   -f, --file FILE                  Output file
   -t, --format TYPE                Output type (supported yaml, json, text)
   -i, --input FILE                 OS install vars (default: /var/tmp/install/my-vars.txt)
   -d, --debug
   -h, --help                       Display command line help
```


Change Log
----------

| Version | Date       | Change                                           |
|:-------:|:----------:|--------------------------------------------------|
| 1.0.0   | 1/2/2014   | First production release                         |
| 1.1.1   | 1/23/2014  | Fix for Solaris zones and no ODB relationship    |
| 1.1.2   | 1/23/2014  | Fixed production status fact when no value       |
| 1.1.3   | 2/25/2014  | Set removing puppet tmp files dependend on existance |
| 1.1.4   | 4/9/2014   | Added mcollective custom facts                   |


Author
------

Gerard Hickey
ghickey@ebay.com
425-286-2650
