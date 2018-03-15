module Associationist
  module Associations
    class SingularAssociation < ::ActiveRecord::Associations::SingularAssociation
      def scope
        raise NotImplementedError
      end

      def find_target
        reflection.config.loader_proc.call(owner)
      end

      def find_target?
        !loaded? && !owner.new_record?
      end

      def klass
        Object
      end

      def force_reload_reader
        reload
        target
      end

    end
  end
end
