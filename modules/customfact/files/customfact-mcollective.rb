#!/usr/bin/env ruby

require 'rubygems'

# Gather the path to the plugins if mcollective is installed
begin
  gem = Gem::Specification.find_by_name('mcollective')
  if gem 
    puts "mcollective_plugin_dir=#{gem.gem_dir}/plugins"
  end
rescue Exception
end