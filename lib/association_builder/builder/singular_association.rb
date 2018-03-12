module AssociationBuilder
  module Builder
    class SingularAssociation < ::ActiveRecord::Associations::Builder::SingularAssociation
      def self.valid_options(options)
        super + [:foreign_type, :dependent, :primary_key, :inverse_of, :required, :association_builder]
      end

      def self.define_accessors(model, reflection)
        super
        mixin = model.generated_association_methods
        name = reflection.name

        define_constructors(mixin, name) if reflection.constructable?

        mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def reload_#{name}
            association(:#{name}).force_reload_reader
          end
        CODE
      end

      def self.create_reflection(model, name, scope, options, extension = nil)
        raise ArgumentError, "association names must be a Symbol" unless name.kind_of?(Symbol)

        validate_options(options)

        scope = build_scope(scope, extension)
        Reflection::SingularReflection.new(name, scope, options, model)
      end

    end
  end
end
