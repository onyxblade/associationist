module Associationist
  module Associations
    class CollectionAssociation < ::ActiveRecord::Associations::HasManyAssociation
      def association_scope
        @_association_scope ||= reflection.config.scope_proc.call(owner)
      end

      def find_target?
        !loaded?
      end

      def null_scope?
        false
      end

      def klass
        association_scope.klass
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

      def self.define_writers(mixin, name)
        mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{name}=(value)
            raise "Virtual associations are read-only."
          end
        CODE
      end
    end
  end
end
