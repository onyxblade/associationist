require_relative './test_helper'

class TestSingularAssociation < Associationist::Test

  class ProductWithLoader < ActiveRecord::Base
    self.table_name = 'products'
    include Associationist::Mixin.new(
      type: :singular,
      name: :stock,
      loader: -> record {
        1
      }
    )
  end

  class ProductWithPreloader < ActiveRecord::Base
    self.table_name = 'products'
    include Associationist::Mixin.new(
      type: :singular,
      name: :stock,
      preloader: -> records {
        records.map{|x| [x, 2]}.to_h
      }
    )
  end

  def test_load
    product = ProductWithLoader.create
    refute product.association(:stock).loaded?
    assert_equal 1, product.stock
    assert product.association(:stock).loaded?

    product = ProductWithPreloader.create
    refute product.association(:stock).loaded?
    assert_equal 2, product.stock
    assert product.association(:stock).loaded?
  end

  def test_preloader
    ProductWithPreloader.create
    ProductWithPreloader.create

    ProductWithPreloader.includes(:stock).all.each do |product|
      assert_equal 2, product.stock
    end
  end
end
