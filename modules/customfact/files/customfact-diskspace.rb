#!/usr/bin/env ruby

# 
#  This file is maintained by puppet. 
#  Any changes will be overwritten at the next puppet run. 
#

require 'rubygems' unless defined? Gem
require 'facter'

def gather_disk_stats(filesystem)
  if File.directory? filesystem
    begin
      case Facter.operatingsystem
      when /Redhat|CentOS|Ubuntu|Darwin/
        `/bin/df -Pk #{filesystem}`.split("\n").each do |line|
          line.chomp!
          if line.end_with?(filesystem)
            dev,total,used,avail,percent,fs = line.split
            yield total,used,avail,percent.delete('%')
          end
        end

      when /Solaris/
        `/bin/df -k #{filesystem}`.split("\n").each do |line|
          line.chomp!
          if line.end_with?(filesystem)
            dev,total,used,avail,percent,fs = line.split
            yield total,used,avail,percent.delete('%')
          end
        end
      end
    rescue NoMethodError
      return
    end
  end
end


# Monkey patch String class to add pretty_print()
class String
  def pretty_print
    gb_blocks = 1024 * 1024
    mb_blocks = 1024 
    
    blocks = self.to_f
    if blocks >= gb_blocks
      return "%5.2f GB" % (blocks / gb_blocks)
    elsif blocks >= mb_blocks
      return "%5.2f MB" % (blocks / mb_blocks)
    else 
      return "%5f KB" % blocks
    end
  end
end



if __FILE__ == $0

  gather_disk_stats('/') { |total,used,avail,percent|
    puts "bootvolsize=#{total.pretty_print}"
    puts "bootvolsize_mb=#{total.to_f / 1024}"
    puts "bootvolused=#{used.pretty_print}"
    puts "bootvolused_mb=#{used.to_f / 1024}"
    puts "bootvolfree=#{avail.pretty_print}"
    puts "bootvolfree_mb=#{avail.to_f / 1024}"
    puts "bootvolpercent=#{percent}"
  }
  
end
