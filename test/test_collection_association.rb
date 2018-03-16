require_relative './test_helper'

class TestSingularAssociation < Associationist::Test

  class ProductWithLoader < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'products'

    include Associationist::Mixin.new(
      type: :collection,
      name: :stocks,
      loader: -> record {
        #assert_instance_of ProductWithLoader, record
        value
      }
    )
  end

  class ProductWithPreloader < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'products'

    include Associationist::Mixin.new(
      type: :collection,
      name: :stocks,
      preloader: -> records {
        #records.map{|x| assert_instance_of ProductWithPreloader, record}
        records.map{|x| [x, value]}.to_h
      }
    )
  end

  def test_load
    ProductWithLoader.value = [1, 2, 3]
    ProductWithPreloader.value = [4, 5, 6]

    product = ProductWithLoader.create
    refute product.association(:stocks).loaded?
    assert_equal [1, 2, 3], product.stocks.to_a
    assert product.association(:stocks).loaded?
    assert_instance_of Associationist::Associations::CollectionProxy, product.stocks


    product = ProductWithPreloader.create
    refute product.association(:stocks).loaded?
    assert_equal [4, 5, 6], product.stocks.to_a
    assert product.association(:stocks).loaded?
    assert_instance_of Associationist::Associations::CollectionProxy, product.stocks
  end

  def test_preloader
    ProductWithPreloader.value = [1, 2, 3]

    ProductWithPreloader.create
    ProductWithPreloader.create

    ProductWithPreloader.includes(:stocks).all.each do |product|
      assert_equal [1, 2, 3], product.stocks.to_a
      assert_instance_of Associationist::Associations::CollectionProxy, product.stocks
    end
  end
end
