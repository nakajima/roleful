$LOAD_PATH << File.dirname(__FILE__) + '/roleful'
$LOAD_PATH << File.dirname(__FILE__) + '/core_ext'

require 'rubygems'
require 'metaid'
require 'module'
require 'proc'
require 'object'
require 'role'
require 'inclusion'

module Roleful
  VERSION = '0.0.1'
end