require_relative './test_helper'

class TestCollectionAssociation < Associationist::Test
  class Catalog__WithPreloader < ActiveRecord::Base
    self.table_name = 'catalogs'
    include Associationist::Mixin.new(
      name: :products,
      preloader: -> records {
        products = Product.all.to_a
        records.map{|x| [x, products.to_a] }.to_h
      }
    )
  end

  def test_preload_multilevel
    products = 3.times.map{ Product.create }
    properties = products.map{|x| x.properties.create }

    catalogs = 3.times.map{ Catalog__WithPreloader.create }
    loaded_catalogs = assert_queries 3 do
      Catalog__WithPreloader.where(id: catalogs.map(&:id)).includes(products: :properties).all.to_a
    end

    assert_no_queries do
      assert_equal products, loaded_catalogs.first.products
      assert_equal properties, loaded_catalogs.first.products.map(&:properties).inject(:+)
    end
  end

  def test_write_association
    catalog = Catalog__WithPreloader.create
    assert_raises do
      catalog.products = [1]
    end
  end

  def test_eager_load
    assert_raises do
      Catalog__WithPreloader.eager_load(:products).all.to_a
    end
  end
end
