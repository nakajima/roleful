$LOAD_PATH << File.dirname(__FILE__) + '/roleful'
$LOAD_PATH << File.dirname(__FILE__) + '/core_ext'

# Core extensions
require 'object'  unless respond_to?(:instance_exec)
require 'array'   unless [].respond_to?(:extract_options!)

# Project files
require 'role'
require 'inclusion'

# Other libraries
require 'rubygems'
require 'metaid'
require 'set'

module Roleful
  VERSION = '0.0.3'
end