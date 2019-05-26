require_relative './test_helper'

class TestAssociationist < Associationist::Test

  class ProductWithPreloader < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'products'

    include Associationist::Mixin.new(
      name: :stock,
      preloader: -> records {
        records.map{|x| [x, 1]}.to_h
      }
    )
  end

  def test_preload
    products = 3.times.map{ ProductWithPreloader.create }
    products_using_includes = ProductWithPreloader.all.includes(:stock).load
    products_using_preload = ProductWithPreloader.all
    Associationist.preload(products_using_preload, :stock)

    assert_no_queries do
      assert_equal products_using_includes.map(&:stock), products_using_preload.map(&:stock)
    end
  end
end
