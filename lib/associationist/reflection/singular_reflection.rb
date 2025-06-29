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

      def klass
        if config.class_name
          config.class_name.constantize
        else
          ActiveRecord::Base
        end
      end

      alias :check_validity! :check_validity_of_inverse!
    end
  end
end
