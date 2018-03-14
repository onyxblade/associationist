module Associationist
  module Associations
    module Preloader
      class SingularAssociation < ActiveRecord::Associations::Preloader::SingularAssociation
        def associated_records_by_owner preloader
          reflection.config.preloader_proc.call(owners).map{|k, v| [k, [v]]}
        end

      end

    end
  end

  module ActiveRecordPreloaderPatch
    def preloader_for(reflection, owners, rhs_klass)
      config = reflection.options[:associationist]
      if config
        Associationist::Associations::Preloader::SingularAssociation
      else
        super
      end
    end
  end

  ActiveRecord::Associations::Preloader.prepend ActiveRecordPreloaderPatch
end
