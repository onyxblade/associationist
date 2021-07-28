module Associationist
  module Reflection
    class SingularReflection < ::ActiveRecord::Reflection::HasOneReflection
      def association_class
        Associations::SingularAssociation
      end

      def check_eager_loadable!
        raise "Virtual associations cannot be eager-loaded."
      end

      def constructable?
        false
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
