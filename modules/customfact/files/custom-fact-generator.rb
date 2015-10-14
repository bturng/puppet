#!/usr/bin/env ruby

# 
#  This file is maintained by puppet. 
#  Any changes will be overwritten at the next puppet run. 
#

require 'rubygems'
require 'yaml'
require 'json'
require 'net/http'
require 'optparse'
require 'facter'

$facts = {}
$ip = Facter[:ipaddress].value
$odb_endpoint = 'cloud-odb-api.vip.ebay.com'


def debug(msg) 
  # function gets created when --debug is used
end


def odb_attributes(object, attrs, &block)
  # Process if attrs is sent in as a string
  if attrs.class == String
    # split the attrs allowing delimitors of comma, space or [semi]colon
    attrs = attrs.split(/[,\s:;]/).select {|v| not v.empty? }
  end
    
  # Retrieve values from ODB
  begin
    resp = Net::HTTP.start($odb_endpoint) { |http|
      http.get("/jodbweb/odb.do?type=object&print=#{attrs.join(',')}&name=#{object}&format=json")
    }

    odb_attrs = JSON.parse(resp.body)
    attr_vals={}
    # Sort through the data and print the results
    if not odb_attrs.empty?
      odb_attrs['objects'][0]['attributes'].each {|entry|
        if entry.has_key? 'value'
          attr_vals[entry['name'][0]] = entry['value'][0]
        end
      }
    end
  rescue JSON::ParserError
    return nil
  rescue Errno::ECONNRESET
    return nil
  end
  
  yield attr_vals if block_given?
  attr_vals
end

def odb_from_relationship(object, relationship_type, object_type, &block)
  result = odb_relationship('from', object, relationship_type, object_type)
  yield result if block_given?
  result
end

def odb_to_relationship(object, relationship_type, object_type, &block)
  result = odb_relationship('to', object, relationship_type, object_type)
  yield result if block_given?
  result
end

def odb_relationship(dir, object, relationship_type, object_type)
  # Retrieve values from ODB
  begin
    resp = Net::HTTP.start($odb_endpoint) { |http|
      http.get("/jodbweb/odb.do?type=relationship&direction=#{dir}&view=object&name=#{object}&relationtype=#{relationship_type}&targettype=#{object_type}&format=json")
    }
  
    odb_rel = JSON.parse(resp.body)
    # Sort through the data and print the results
    if not odb_rel.empty?
      if odb_rel['objects'][0].member? 'name'
        yield odb_rel['objects'][0]['name'][0] if block_given?
        return odb_rel['objects'][0]['name'][0]
      end
    end
  rescue JSON::ParserError
    return nil
  rescue Errno::ECONNRESET
    return nil
  end
  
  return nil
end


def dig_through_odb
  debug("dig_through_odb")
  debug("    May define: assetid, datacenter")
  
  # Find the assetid
  assetid = odb_from_relationship($ip, 'ODB::Link::LogicalOn', 'ODB::Asset')
  if assetid
    $facts['assetid'] = assetid
    debug("\tassetid = #{assetid}")
    dc = odb_attributes($ip, ['location'])
    if dc.has_key? 'location'
      $facts['datacenter'] = dc['location']
      debug("\tdatacenter = #{dc['location']}")
    end
  end
end


def process_os_vars(inf)
  debug("process_os_vars(#{inf})")
  debug("    May define: assetid, datacenter, macaddress_ilom, os_profile_name,")
  debug("      os_profile_version, interface_count, iaas_job_id, gateway_eth0,")
  debug("      gateway_eth1, install_server_url, serial_console_options,")
  debug("      extra_packages_url")
  myvars = {}
  
  begin
    # stream in the my-var.txt file
    File.open(inf, 'r') do |fh|
      while line = fh.gets
        key,val = line.split('=')
        myvars[key] = val.chomp
      end
    end
  rescue Errno::ENOENT
    debug("    #{inf} not present")
    return
  end
  
  # marshall out the desired variables to make custom facts
  { 'asset-id'             => 'assetid',
    'region'               => 'datacenter',
    'ilom-mac'             => 'macaddress_ilom',
    'os-profile-name'      => 'os_profile_name', 
    'os-profile-version'   => 'os_profile_version',
    'if-count'             => 'interface_count',
    'job-id'               => 'iaas_job_id', 
    'gateway-0'            => 'gateway_eth0',
    'gateway-1'            => 'gateway_eth1',
    'install-service-url'  => 'install_server_url',
    'console-options'      => 'serial_console_options',
    'extra-packages-url'   => 'extra_packages_url'
  }.each { |myvar_name, facter_name|
    if myvars.member? myvar_name
      $facts[facter_name] = myvars[myvar_name] == '' ? nil : myvars[myvar_name]
      debug("\t#{facter_name} = #{myvars[myvar_name]}")
    end
  }
end


def process_sudo_facter
  debug("process_sudo_facter")
  debug("    May define: boardmanufactuer, boardserialnumber, boardproductname,")
  debug("      manufacturer, productname, serialnumber, type, uniqueid.")
  
  [ 'boardmanufacturer', 'boardserialnumber', 'boardproductname',
    'bios_release_date', 'bios_vendor', 'bios_version',
    'manufacturer', 'productname', 'serialnumber', 'type', 
    'uniqueid' ].each do |var_name|
    unless Facter[var_name].nil?
      $facts[var_name] = Facter[var_name].value
      debug("\t#{var_name} = #{$facts[var_name]}")
    end
  end
end


def process_odb_asset_record
  debug("process_odb_asset_record")
  debug("    May define: tag, faultdomain, locationcode, ipaddress_ilom,")
  debug("      ebay_hw_sku, hypervisor_fqdn, hypervisor_hostname")
  
  assetid = nil
  attrs = {}
  
  unless $facts['assetid'].nil?
    # Physical (bare metal) asset
    attrs = odb_attributes($facts['assetid'], ['tag', 'faultdomain', 'locationcode'])
    
    # Find the hardware SKU
    odb_from_relationship($facts['assetid'], 'ODB::Link::ConfiguredTo', 
                                'ODB::Configuration::SKU') do |sku_label|
      if not sku_label.nil?
        sku,maker,model,dummy = sku_label.split('-')
        $facts['ebay_hw_sku'] = sku
        debug("\tebay_hw_sku = #{$facts['ebay_hw_sku']}")
      end
    end
    
    # if this is a physical asset, retrieve the ilom ipaddress
    if $facts['assetid']
      odb_to_relationship($facts['assetid'], 
                  'ODB::Link::ManagedVia', 'ODB::Node::LOM') do |ilom_addr|
        if not ilom_addr.nil?
          $facts['ipaddress_ilom'] = ilom_addr
          debug("\tipaddress_ilom = #{$facts['ipaddress_ilom']}")
        end
      end
    end
  else
    # Test for VM or Solaris zone
    ['ODB::Asset::VM', 'ODB::Asset::Zone'].each do |vm_type|
      odb_from_relationship($ip, 'ODB::Link::LogicalOn', vm_type) do |vm_info|
        unless vm_info.nil?
          # Gather info about the asset that the VM is on
          assetid = odb_from_relationship(vm_info, 'ODB::Link::LocatedIn', 'ODB::Asset')
          attrs = odb_attributes(assetid, ['faultdomain', 'locationcode'])
          odb_attributes($ip, 'manager') do |vm_attr|
            attrs['hypervisor_fqdn'] = vm_attr['manager']
            attrs['hypervisor_hostname'] = vm_attr['manager'].gsub(/\..+/, '')
          end
        end
      end
    end
    
    if assetid.nil?
      # unable to find more info about the asset the VM is on
      debug("    *** Unable to find asset that this VM is on")
    end
  end
  
  # Process all attributes that could be found
  attrs.keys.each do |item|
    $facts[item] = attrs[item]
    debug("\t#{item} = #{attrs[item]}")
  end
end



def write_custom_facts(filename)
  debug("write_custom_facts(#{filename})")
  File.open(filename, 'w') do |fh|
    fh.write($facts.to_yaml)
  end
end

  


if __FILE__ == $0
  
  options = { :file     => '/etc/facts.d/asset.yaml', 
              :format   => :yaml,
              :input    => '/var/tmp/install/my-vars.txt',
              :debug    => false }
  parser = OptionParser.new() do |opts|
    opts.on('--file FILE', '-f', 'Output file') { |val|
      options[:file] = val
    }
    opts.on('--format TYPE', '-t', 'Output type (supported yaml, json, text)') { |val|
      options[:format] = val.to_sym
    }
    opts.on('--input FILE', '-i', 'OS install vars (default: /var/tmp/install/my-vars.txt)') { |val|
      options[:input] = val
    }
    opts.on('-j', '--jrds', 'Use the JRDS ODB gateway') {
      $odb_endpoint = 'jrds.vip.ebay.com'
    }
    opts.on('--debug', '-d') { 
      def debug(msg)
        puts msg
      end
    }
    
    opts.on_tail('--help', '-h', 'Display command line help') {
      puts parser.help()
      exit
    }
  end
  parser.parse!
  
  
  process_os_vars(options[:input])
  unless $facts.has_key? 'assetid'
    dig_through_odb
  end
  process_sudo_facter
  process_odb_asset_record  
  
  write_custom_facts(options[:file])
  
end