module Associationist
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
