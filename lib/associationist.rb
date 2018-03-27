require 'active_record'

Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each do |file|
  require file
end

module Associationist
  def self.preload records, associations
    ActiveRecord::Associations::Preloader.new.preload records, associations
  end
end
