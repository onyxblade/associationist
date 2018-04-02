module Associationist
  class Mixin < Module
    def initialize raw_config
      @raw_config = raw_config
    end

    def included base
      config = Config.new @raw_config
      reflection_options = {associationist: config}

      reflection = Builder::SingularAssociation.build(base, config.name, nil, reflection_options)
      ::ActiveRecord::Reflection.add_reflection base, config.name, reflection
    end

    def inspect
      "#<Associationist::Mixin @name=#{@raw_config[:name].inspect}>"
    end
  end
end
