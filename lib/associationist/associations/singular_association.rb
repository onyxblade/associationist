module Associationist
  module Associations
    class SingularAssociation < ::ActiveRecord::Associations::SingularAssociation
      def association_scope
        if reflection.config.scope_proc
          reflection.config.scope_proc.call(owner)
        else
          raise NotImplementedError
        end
      end

      def find_target
        if reflection.config.scope_proc
          super
        else
          reflection.config.loader_proc.call(owner)
        end
      end

      def find_target?
        !loaded?
      end

      def klass
        if reflection.config.scope_proc
          super
        else
          Object
        end
      end

      def force_reload_reader
        reload
        target
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
