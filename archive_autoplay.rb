#!/usr/bin/env ruby
require 'rubygems'
require 'trollop'
require_relative './main'

params = Trollop::options do
  opt :query, "The search query", :type  => :string
  opt :rows, "", :type  => :int, :default => 200
  opt :file_dir, "", :type  => :string, :default => '/tmp/'
  opt :autoplay, "", :type  => :boolean, :default => true
end

main params
