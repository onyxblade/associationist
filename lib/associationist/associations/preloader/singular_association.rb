module Associationist
  module Associations
    module Preloader
      class SingularAssociation
        attr_reader :klass
        def initialize klass, owners, reflection, preload_scope, reflection_scope = nil, associate_by_default = true
          @klass = klass
          @owners = owners
          @reflection = reflection
          @run = false
        end

        # handle >= 6.0
        def run preloader = nil
          return self if @run
          @run = true
          case
          when @reflection.config.preloader_proc
            @reflection.config.preloader_proc.call(@owners).each do |record, value|
              record.association(@reflection.name).target = value
            end
          when @reflection.config.loader_proc
            @owners.each do |record|
              record.association(@reflection.name).target = @reflection.config.loader_proc.call(record)
            end
          when @reflection.config.scope_proc
            case @reflection.config.type
            when :singular
              @owners.each do |record|
                record.association(@reflection.name).target = @reflection.config.scope_proc.call(record).first
              end
            when :collection
              @owners.each do |record|
                record.association(@reflection.name).target = @reflection.config.scope_proc.call(record)
              end
            end
          end
          self
        end

        def preloaded_records
          @owners.flat_map { |owner| owner.association(@reflection.name).target }
        end

        # handle >=7.0
        def runnable_loaders
          [self]
        end

        def run?
          @run
        end

        def future_classes
          if run?
            []
          else
            if @klass <= ActiveRecord::Base
              [@klass]
            else
              []
            end
          end
        end

        def table_name
          if @klass <= ActiveRecord::Base
            @klass.table_name
          else
            nil
          end
        end
      end

    end
  end

  if ActiveRecord.version >= Gem::Version.new('7.0.0')
    module ActiveRecordPreloaderBranchPatch
      def preloader_for(reflection)
        config = reflection.options[:associationist]
        if config
          Associationist::Associations::Preloader::SingularAssociation
        else
          super
        end
      end
    end

    ActiveRecord::Associations::Preloader::Branch.prepend ActiveRecordPreloaderBranchPatch

    module ActiveRecordPreloaderPatch
    end

    ActiveRecord::Associations::Preloader.prepend ActiveRecordPreloaderPatch

    module ActiveRecordPreloaderBatchPatch
      def call
        branches = @preloaders.flat_map(&:branches)
        until branches.empty?
          loaders = branches.flat_map(&:runnable_loaders)
          loaders.each do |loader|
            if loader.is_a? Associationist::Associations::Preloader::SingularAssociation
            else
              loader.associate_records_from_unscoped(@available_records[loader.klass.base_class])
            end
          end

          if loaders.any?
            future_tables = branches.flat_map do |branch|
              branch.future_classes - branch.runnable_loaders.map(&:klass)
            end.map(&:table_name).uniq

            target_loaders = loaders.reject { |l| future_tables.include?(l.table_name)  }
            target_loaders = loaders if target_loaders.empty?

            non_associationist_loaders = target_loaders.reject{|x| x.is_a? Associationist::Associations::Preloader::SingularAssociation}
            group_and_load_similar(non_associationist_loaders)
            target_loaders.each(&:run)
          end

          finished, in_progress = branches.partition(&:done?)

          branches = in_progress + finished.flat_map(&:children)
        end
      end
    end

    ActiveRecord::Associations::Preloader::Batch.prepend ActiveRecordPreloaderBatchPatch
  else
    module ActiveRecordPreloaderPatch
      case
      when ActiveRecord.version < Gem::Version.new('5.2.0')
        def preloader_for(reflection, owners, rhs_klass)
          config = reflection.options[:associationist]
          if config
            Associationist::Associations::Preloader::SingularAssociation
          else
            super
          end
        end
      when ActiveRecord.version >= Gem::Version.new('5.2.0')
        def preloader_for(reflection, owners)
          config = reflection.options[:associationist]
          if config
            Associationist::Associations::Preloader::SingularAssociation
          else
            super
          end
        end
      end
    end

    ActiveRecord::Associations::Preloader.prepend ActiveRecordPreloaderPatch
  end
end
