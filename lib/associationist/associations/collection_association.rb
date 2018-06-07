module Associationist
  module Associations
    class CollectionAssociation < ::ActiveRecord::Associations::CollectionAssociation
      def association_scope
        reflection.config.scope_proc.call(owner)
      end

      def skip_statement_cache?
        true
      end
    end
  end
end
