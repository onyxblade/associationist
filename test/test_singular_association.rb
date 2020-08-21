require_relative './test_helper'

class TestSingularAssociation < Associationist::Test

  class ProductWithLoader < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'products'

    include Associationist::Mixin.new(
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
      name: :stock,
      preloader: -> records {
        #records.map{|x| assert_instance_of ProductWithPreloader, record}
        records.map{|x| [x, value]}.to_h
      }
    )
  end

  class CatalogWithPreloader < ActiveRecord::Base
    self.table_name = 'catalogs'
    include Associationist::Mixin.new(
      name: :product,
      preloader: -> records {
        product = Product.last
        records.map{|x| [x, product] }.to_h
      }
    )
  end

  def test_preload_multilevel_for_singular_association
    product = Product.create
    properties = 3.times.map{ product.properties.create }

    catalogs = 3.times.map{ CatalogWithPreloader.create }
    loaded_catalogs = assert_queries 3 do
      CatalogWithPreloader.where(id: catalogs.map(&:id)).includes(product: :properties).all.to_a
    end

    assert_no_queries do
      assert_equal product, loaded_catalogs.first.product
      assert_equal properties, loaded_catalogs.first.product.properties
    end
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

  def test_preload_when_only_loader_provided
    ProductWithLoader.value = 1

    ProductWithLoader.create
    ProductWithLoader.create

    ProductWithLoader.includes(:stock).all.each do |product|
      assert product.association(:stock).loaded?
      assert_equal 1, product.stock
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

  def test_write_association
    product = ProductWithLoader.create
    product.stock = 1
    assert_equal 1, product.stock
  end
end
