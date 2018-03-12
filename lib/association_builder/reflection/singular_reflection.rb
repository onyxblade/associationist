module AssociationBuilder
  module Reflection
    class SingularReflection < ::ActiveRecord::Reflection::HasOneReflection
      def association_class
        Associations::SingularAssociation
      end

      def check_eager_loadable!

      end

      def config
        options[:association_builder]
      end
    end
  end
end
