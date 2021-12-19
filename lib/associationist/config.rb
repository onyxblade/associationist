module Associationist
  class Config
    def initialize config
      @config = config
    end

    def name
      @config[:name]
    end

    def loader_proc
      if @config[:loader]
        @config[:loader]
      elsif preloader_proc
        -> record {
          (preloader_proc.call [record])[record]
        }
      end
    end

    def preloader_proc
      @config[:preloader]
    end

    def type
      @config[:type] || :singular
    end

    def scope_proc
      @config[:scope]
    end

    def class_name
      @config[:class_name]
    end

    def check
      if @config[:loader] && @config[:scope]
        raise "cannot define both loader and scope"
      end

      if @config[:type] && !@config[:scope]
        raise "type option only effects when scope defined"
      end
    end
  end
end
