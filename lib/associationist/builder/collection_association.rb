module Associationist
  module Builder
    class CollectionAssociation < ::ActiveRecord::Associations::Builder::CollectionAssociation
      def self.macro
        :has_many
      end

      def self.valid_options(options)
        super + [:associationist]
      end

      def self.valid_dependent_options
        [:destroy, :delete_all, :nullify, :restrict_with_error, :restrict_with_exception]
      end

      def self.create_reflection(model, name, scope, options, extension = nil)
        raise ArgumentError, "association names must be a Symbol" unless name.kind_of?(Symbol)

        validate_options(options)

        case
        when ActiveRecord.version >= Gem::Version.new('6.0.0')
          scope = build_scope(scope)
        else
          scope = build_scope(scope, extension)
        end
        Reflection::CollectionReflection.new(name, scope, options, model)
      end
    end
  end
end
