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
end
