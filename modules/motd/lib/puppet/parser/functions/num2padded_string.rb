#
#  num2padded_string.rb
#
require 'puppet/parser/functions'

module Puppet::Parser::Functions
  newfunction(:num2padded_string, :type => :rvalue, :doc => <<-'EOS'
    Take an integer and convert to a string that is padded with 0s. The
    first argument needs to be the integer that needs to be converted and
    the second argument, which is optional, specifies how many 0s to pad
    the string. If the second argument is not specified, then it defaults
    to 2. 
    EOS
  ) do |args|
    raise(Puppet::ParseError, "num2padded_string(): Wrong number of arguments " +
      "given (#{args.size} for 1 or 2): #{args.inspect}") if args.size<1 or args.size>2

    padding = 2
    if args.size == 2
      padding = args[1]
    end
       
    return "%0#{padding}d" % args[0]
  end
end