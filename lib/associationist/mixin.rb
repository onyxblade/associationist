module Associationist
  class Mixin < Module
    def initialize raw_config
      @raw_config = raw_config
    end

    def included base
      config = Config.new @raw_config
      config.check

      reflection_options = {associationist: config}

      case config.type
      when :singular
        reflection = Builder::SingularAssociation.build(base, config.name, nil, reflection_options)
      when :collection
        reflection = Builder::CollectionAssociation.build(base, config.name, nil, reflection_options)
      else
        raise "unknown type #{config.type.inspect}"
      end
      ::ActiveRecord::Reflection.add_reflection base, config.name, reflection
    end

    def inspect
      "#<Associationist::Mixin @name=#{@raw_config[:name].inspect}>"
    end
  end
end
