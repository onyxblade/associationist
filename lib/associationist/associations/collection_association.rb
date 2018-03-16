module Associationist
  module Associations
    class CollectionAssociation < ::ActiveRecord::Associations::CollectionAssociation
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

      def reader
        if stale_target?
          reload
        end

        @proxy ||= CollectionProxy.new(klass, self)
        @proxy.reset_scope
      end

    end
  end
end
