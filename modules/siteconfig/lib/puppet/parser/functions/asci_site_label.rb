#
#  asci_site_label.rb
#

require 'ipaddr'
require File.join(File.dirname(__FILE__), 'asci_defs')
#require_relative 'asci_defs'

module Puppet::Parser::Functions
  
  include AsciDefs
  
  newfunction(:asci_site_label, :type => :rvalue, :doc => <<-'EOS'
    Inspects local machine to determine what site it is at.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "asci_site_label(): Wrong number of arguments " +
      "given (#{arguments.size} for 0 or 1)") if arguments.size > 1
      
    begin
      return_val = AsciDefs::asci_network_table_lookup(SITE)
    rescue Puppet::Error => e
      # Check to see if we received a arg to determine if we throw
      # an exception or not.
      if arguments.size == 0 or arguments[0] == false
        raise Puppet::Error, "asci_site_label(): #{e}"
      end
    end

    return_val.to_s
  end
    
end

