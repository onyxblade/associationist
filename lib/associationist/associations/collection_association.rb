module Associationist
  module Associations
    class CollectionAssociation < ::ActiveRecord::Associations::CollectionAssociation
      def association_scope
        reflection.config.scope_proc.call(owner)
      end

      case
      when ActiveRecord.version < Gem::Version.new('5.2.0')
        def skip_statement_cache?
          true
        end
      when ActiveRecord.version >= Gem::Version.new('5.2.0')
        def skip_statement_cache? scope
          true
        end
      end
    end
  end
end
