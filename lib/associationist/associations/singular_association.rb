module Associationist
  module Associations
    class SingularAssociation < ::ActiveRecord::Associations::SingularAssociation
      def scope
        raise NotImplementedError
      end

      def find_target
        reflection.config.loader_proc.call(self)
      end

      def find_target?
        !loaded? && !owner.new_record?
      end

    end
  end
end
