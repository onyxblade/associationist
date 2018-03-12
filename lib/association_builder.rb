require 'active_record'

Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each do |file|
  require file
end
