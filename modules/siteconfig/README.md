# siteconfig

#### Table of Contents

1. [Overview](#overview)
3. [Setup - The basics of getting started with siteconfig](#setup)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

The siteconfig module implements Puppet functions to return information concerning the environment that the host resides in. This is to provide an abstraction between the actual network topology and the physical location of the host (i.e. data center / POD)

## Setup

In `lib/puppet/parser/functions/asci_defs.rb`, there is a mapping of network (specified in CIDR form) to site, bubble and COS labels. This mapping needs to be kept upto date as changes are made to the network infrastructure. 

### What siteconfig affects

* The siteconfig module does not affect anything. It is simply a collection point for functions to discover data about the environment.

## Usage

The principle use of siteconfig is to obtain the site label for a host. There are three functions defined to provide infomation about a host: 

* asci_site_label()
* asci_bubble_label()
* asci_cos_label()

Each of these functions can take one optional parameter: true or false. False is the default value and does not need to be specified. A true value will cause each function to silently squelch the Puppet::Error exception when the host's IP address can not be found in the network map. Normally, It is desirable to have the function signal failure by throwing the exception. The "silent" nature can be useful for situations where the site label may not be able to be determined, but the calling Puppet module can supply values of last resort. 

### asci_site_label()

This is used as a normal function and will return a string to represent the ASCI site label. Typical return values are 'DC1', 'PD1', 'PD5', etc. 

Example uses:

    $site = asci_site_label()

or 

    if asci_site_label() == 'DC1' {
      <resources defined for hosts in DC1> 
    }

### asci_bubble_label()

The bubble label usually refers to a physical or logical division of hosts. In a POD, the bubble really does not have much meaning and will return the subdomain the POD is in (e.g. 'sea1', 'ewr1', 'dc01', etc.). In a data center, the bubble will provide information for big environments in the data center such as hadoop. Today most of the datacenter hosts will return 'dc01'. 

In the case of AWS, the bubble is defined as the VPC level with labels beinge defined for each VPC. Currently 'cm_test' and 'metrics' are defined._

Example uses:

    $site = asci_bubble_label()

or 

    if asci_bubble_label() == 'hadoop' {
      <resources defined for hosts in a hadoop environment> 
    }


### asci_cos_label()

The COS (class of service) labels allows one to make a decision on the level of service that the host should receive. Today the COS levels are defined as 'PROD', 'DEV', 'QA', and 'TEST'.
Example uses:

    $site = asci_cos_label()

or 

    if asci_cos_label() == 'DEV' {
      <resources defined for hosts in a Dev environment> 
    }

## Reference

Only the Facter variable 'ipaddress' is used.

## Limitations

None at this time.

