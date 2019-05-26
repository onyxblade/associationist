module Associationist
  module Associations
    module Preloader
      class SingularAssociation
        def initialize klass, owners, reflection, preload_scope
          @owners = owners
          @reflection = reflection
        end

        def run preloader
          @reflection.config.preloader_proc.call(@owners).map do |record, value|
            record.association(@reflection.name).target = value
          end
        end
      end

    end
  end

  module ActiveRecordPreloaderPatch
    case
    when ActiveRecord.version < Gem::Version.new('5.2.0')
      def preloader_for(reflection, owners, rhs_klass)
        config = reflection.options[:associationist]
        if config
          Associationist::Associations::Preloader::SingularAssociation
        else
          super
        end
      end
    when ActiveRecord.version >= Gem::Version.new('5.2.0')
      def preloader_for(reflection, owners)
        config = reflection.options[:associationist]
        if config
          Associationist::Associations::Preloader::SingularAssociation
        else
          super
        end
      end
    end
  end

  ActiveRecord::Associations::Preloader.prepend ActiveRecordPreloaderPatch
end
