# TODO What to do with this?
#
Dir.chdir File.join(File.dirname(__FILE__), '../ext/ruby19') do
  %x{ ruby extconf.rb && make }
end
require File.expand_path(File.join(File.dirname(__FILE__), '../ext/ruby19/performant'))