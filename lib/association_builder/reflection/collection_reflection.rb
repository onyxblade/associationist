module AssociationBuilder
  module Reflection
    class CollectionReflection < ::ActiveRecord::Reflection::HasManyReflection
      def association_class
        Associations::CollectionAssociation
      end

      def check_eager_loadable!

      end

      def config
        options[:association_builder]
      end
    end
  end
end
