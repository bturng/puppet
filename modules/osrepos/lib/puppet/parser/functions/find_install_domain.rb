#
#  find_install_domain.rb
#

module Puppet::Parser::Functions
  newfunction(:find_install_domain, :type => :rvalue, :doc => <<-'EOS'
    Processes domain name to find the local installsvc.vip server.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "find_install_domain(): Wrong number of arguments " +
      "given (#{arguments.size} for 0)") if arguments.size != 0

    # Domains that don't have an installsvc.vip machine
    noinstallsvc = ['corp.ebay.com', 'dev.ebay.com', 'sjc.ebay.com', 
                    'smf.ebay.com', 'vip.ebay.com', 'engrs.ebay.com']

    local_domain = lookupvar('fqdn').split('.')[-3..-1].join('.')
    debug "find_install_domain::local domain found to be #{local_domain}"
    
    if noinstallsvc.member? local_domain
      # direct domains without installsvc.vip to SLC
      result = 'slc.ebay.com'
    else
      result = local_domain
    end

    return result
  end
end