#!/usr/bin/env  ruby

require 'rubygems'
require 'facter'

# if there is no ethtool then stop
if not File.executable? '/sbin/ethtool'
  exit
end

Facter.value('interfaces').split(',').each do |intf|
  if intf != 'lo'
    output = `/sbin/ethtool #{intf} 2>/dev/null`
    if match = output.match(/Speed:\s*(\d+).*Duplex:\s*\b(\w+)\b/mi)
      puts "interface_speed_#{intf}=#{match[1]}"
      puts "#{intf}=#{match[1]}"
      puts "interface_duplex_#{intf}=#{match[2].downcase}"
    end
  end
end

