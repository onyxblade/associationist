module Associationist
  module Builder
    class SingularAssociation < ::ActiveRecord::Associations::Builder::SingularAssociation
      def self.valid_options(options)
        super + [:associationist]
      end

      def self.define_accessors(model, reflection)
        super
        mixin = model.generated_association_methods
        name = reflection.name

        mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def reload_#{name}
            association(:#{name}).force_reload_reader
          end
        CODE
      end

      def self.define_callbacks(model, reflection)
        # bypass dependent callback and autosave callback
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
        Reflection::SingularReflection.new(name, scope, options, model)
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
