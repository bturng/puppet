#
#  crond_to_crontab.rb
#
require 'puppet/parser/functions'

module Puppet::Parser::Functions
  newfunction(:crond_to_crontab, :type => :rvalue, :doc => <<-'EOS'
    Take an entry that is used in the /etc/cron.d directory and convert
    it to be used in a crontab. Effectively this function will remove the
    user to run as from the cron entry lines.
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "crond_to_crontab(): Wrong number of arguments " +
      "given (#{arguments.size} for 1): #{arguments.inspect}") unless arguments.size == 1

    return_text = []
    vars = {}
    arguments[0].split("\n").each do |line|
      # ignore comments
      unless line.match %r{^\s*#}
        # Regex for generic crontab entry with username (cron.d format)
        match = line.match %r{^\s*
                              ([\d,\*]+)\s+
                              ([\d,\*]+)\s+
                              ([\d,\*]+)\s+
                              ([\d,\*]+)\s+
                              ([\d,\*]+)\s+
                              \w+\s+
                              (.*)$}x
        if match
          (min,hr,day,mon,dow,cmd) = match.captures
          
          # Add the PATH to the beginning of the cmd only if defined
          if vars.member? 'PATH'
            cmd = 'PATH=$PATH; export PATH; %s' % cmd
          end 
          
          # check for any variable stubstitutions that need to be made
          vars.keys.each { |v|  cmd.gsub! "\$#{v}", vars[v] }
          
          # recombine the line to produce the crontab entry. 
          line = [min, hr, day, mon, dow, cmd].join(' ')
        end
        
        
      end
      
      # match an environment var setting
      match =  line.match %r{^\s*([\w_]+)=['"]?([^'"]+)['"]?\s*$}
      if match 
        vars[match[1]] = match[2]
      else
        # Add to return_text
        return_text << line
      end
    end

    return_text.join("\n")
  end
end