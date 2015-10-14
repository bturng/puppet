
require 'facter'

module AsciDefs
  
  # Indexes of the columns for the NETWORK_MAP table
  SITE    = 0
  BUBBLE  = 1
  COS     = 2
  NET_DEF = 3
  
  # site, bubble, COS, network def
  NETWORK_MAP = [ 
                ['DC1', 'dc01', 'PROD', '192.168.81.0/24'],
              ]

  # The order to look for an IP to validate against NETWORK_MAP 
  INTERFACE_ORDER = %w(eth2 em3 eth0 em1 bond0)


  def AsciDefs.asci_network_table_lookup(column)
    # find the IP address to use in looking up the 
    local_interfaces = Facter['interfaces'].value.split(',')
    ip = nil
    INTERFACE_ORDER.each { |intf|
      if local_interfaces.include? intf
        ip = Facter["ipaddress_#{intf}"].value
        break
      end
    }
    
    # if an IP address could not be found then we can not continue
    if ip.nil? 
      raise(Puppet::Error, "Unable to locate valid network interface in #{INTERFACE_ORDER}")
    end
    
    # walk through network_map and find the network where gateway resides
    return_val = ''
    NETWORK_MAP.each do |net_def|
      ipaddr = IPAddr.new net_def[NET_DEF]
      if ipaddr.include? ip
        return_val = net_def[column]
      end
    end
  
    # No network found
    if return_val.empty?
      raise(Puppet::Error, 'Unable to find IP in network map')
    else
      return_val
    end
  end
  
end
            
