# AUTOGENERATED FILE -- Don't change this file unless you know what you are doing! 
PADRINO_ROOT = File.dirname(__FILE__) + '/..' unless defined? PADRINO_ROOT
if ENV["RACK_ENV"] == 'production'
  require File.expand_path(File.join(PADRINO_ROOT, 'vendor', 'gems', 'environment'))
  Bundler.require_env
end
require 'padrino'
Padrino.load!