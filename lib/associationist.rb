require 'active_record'

p Dir.glob("#{File.dirname(__FILE__)}/**/*.rb")

Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each do |file|
  require file
end

module Associationist
  if ActiveRecord.version >= Gem::Version.new('7.0.0')
    def self.preload records, associations
      ActiveRecord::Associations::Preloader.new(records: records, associations: associations).call
    end
  else
    def self.preload records, associations
      ActiveRecord::Associations::Preloader.new.preload records, associations
    end
  end
end
