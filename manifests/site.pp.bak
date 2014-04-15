## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'puppet.myowntechpros.com',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {

}
node "dns.myowntechpros.com" {
	include bind
	bind::server::conf { '/etc/named.conf':
  	listen_on_addr    => [ 'any' ],
  	listen_on_v6_addr => [ 'any' ],
  	forwarders        => [ '192.168.2.1', '75.75.75.75' ],
  	allow_query       => [ 'localnets' ],
  		zones             => {
    			'myowntechpros.com' => [
      			'type master',
      			'file "myowntechpros.com.zone"',
    			],
    			'2.168.192.in-addr.arpa' => [
      			'type master',
      			'file "2.168.192.in-addr.arpa"',
    			],
  		},
	}
	bind::server::file { [ 'myowntechpros.com.zone', '2.168.192.in-addr.arpa' ]:
	  source_base => 'puppet:///modules/bind/',
	}
}
