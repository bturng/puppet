#!/usr/bin/ruby

require 'open3'

version = 'Not Installed'
begin
  Open3.popen3('java -version') do |inp, out, err, thread|
    for line in err.readlines
      if line =~ /^java version\s+\"([\d\._]+)\"?/
        line =~ /[\d\._]+/
        version = $~
        break
      end
    end
  end
rescue 
  # No java installed!
end

puts "javaversion=#{version}"
