module Associationist
  module Reflection
    class CollectionReflection < ::ActiveRecord::Reflection::HasManyReflection
      def association_class
        Associations::CollectionAssociation
      end

      def check_eager_loadable!
        raise "Virtual associations cannot be eager-loaded."
      end

      def has_cached_counter?
        false
      end

      def config
        options[:associationist]
      end
    end
  end
end
