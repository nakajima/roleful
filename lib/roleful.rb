module Roleful
  VERSION = '0.0.3'
end

# Core extensions
require 'roleful/core_ext/object'  unless respond_to?(:instance_exec)
require 'roleful/core_ext/array'   unless [].respond_to?(:extract_options!)

# Project files
require 'roleful/role'
require 'roleful/inclusion'

# Other libraries
require 'metaid'
require 'set'
