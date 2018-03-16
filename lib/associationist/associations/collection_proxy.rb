module Associationist
  module Associations
    class CollectionProxy < ::ActiveRecord::Associations::CollectionProxy
      def initialize(klass, association) #:nodoc:
        @association = association
        #super klass, klass.arel_table, klass.predicate_builder

        #extensions = association.extensions
        #extend(*extensions) if extensions.any?
      end

      def inspect
        subject = loaded? ? records : load_target
        entries = subject.first(11)
        entries[10] = "..." if entries.size == 11

        "#<#{self.class.name} [#{entries.join(', ')}]>"
      end
    end
  end
end
