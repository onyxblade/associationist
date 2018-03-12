module AssociationBuilder
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
  end
end
