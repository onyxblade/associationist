require_relative './test_helper'

class TestSingularAssociation < Associationist::Test

  class ProductWithLoader < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'products'

    include Associationist::Mixin.new(
      #type: :singular,
      name: :stock,
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
      #type: :singular,
      name: :stock,
      preloader: -> records {
        #records.map{|x| assert_instance_of ProductWithPreloader, record}
        records.map{|x| [x, value]}.to_h
      }
    )
  end

  def test_load
    ProductWithLoader.value = 1
    ProductWithPreloader.value = 2

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
    ProductWithPreloader.value = 2

    ProductWithPreloader.create
    ProductWithPreloader.create

    ProductWithPreloader.includes(:stock).all.each do |product|
      assert product.association(:stock).loaded?
      assert_equal 2, product.stock
    end
  end

  def test_associationist_preload
    ProductWithPreloader.value = 2

    ProductWithPreloader.create
    ProductWithPreloader.create

    products = ProductWithPreloader.all
    Associationist.preload(products, :stock)
    products.each do |product|
      assert product.association(:stock).loaded?
      assert_equal 2, product.stock
    end
  end

  def test_reload
    ProductWithLoader.value = 1
    product = ProductWithLoader.create
    assert_equal 1, product.stock
    ProductWithLoader.value = 2
    assert_equal 2, product.reload_stock

    ProductWithPreloader.value = 2
    product = ProductWithPreloader.create
    assert_equal 2, product.stock
    ProductWithPreloader.value = 3
    assert_equal 3, product.reload_stock

    product = ProductWithPreloader.includes(:stock).all.last
    assert_equal 3, product.stock
    ProductWithPreloader.value = 4
    assert_equal 4, product.reload_stock
  end

  def test_construct_methods
    product = ProductWithLoader.create
    refute product.respond_to? :build_stock
    refute product.respond_to? :create_stock
    refute product.respond_to? :create_stock!
  end

  def test_disable_autosave
    product = ProductWithLoader.create
    # trigger association_cache and then save
    product.stock
    assert product.save
  end
end
