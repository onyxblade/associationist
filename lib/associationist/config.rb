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
      @config[:type]
    end

    def scope_proc
      @config[:scope]
    end

    def eager_loader_proc
      @config[:eager_loader]
    end
  end
end
