require_relative './test_helper'

class TestScopeAssociation < Associationist::Test

  class CatalogWithSingularScope < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'catalogs'

    include Associationist::Mixin.new(
      type: :singular,
      name: :product,
      scope: -> (owner) {
        Product.where(catalog_id: owner.id)
      },
      preloader: -> (owners) {
        owners.map{|x| [x, [1, 2, 3]]}.to_h
      }
    )
  end

  class CatalogWithCollectionScope < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'catalogs'

    include Associationist::Mixin.new(
      type: :collection,
      name: :products,
      scope: -> (owner) {
        Product.where(catalog_id: owner.id)
      },
      preloader: -> (owners) {
        owners.map{|x| [x, [1, 2, 3]]}.to_h
      }
    )
  end

  def create_products_for_catalog catalog
    3.times.map{ Product.create(catalog_id: catalog.id) }
  end

  def test_load
    catalog = CatalogWithSingularScope.create
    products = create_products_for_catalog catalog

    assert_equal products.first, catalog.product

    catalog = CatalogWithCollectionScope.create
    products = create_products_for_catalog catalog

    assert_equal products, catalog.products.to_a
  end

  def test_singular_preload
    catalog_a = CatalogWithCollectionScope.create
    catalog_b = CatalogWithCollectionScope.create

    p CatalogWithCollectionScope.preload(:products).map{|x| x.products}
  end

  def test_collection_preload
    catalog_a = CatalogWithSingularScope.create
    catalog_b = CatalogWithSingularScope.create

    p CatalogWithSingularScope.preload(:product).map{|x| x.product}
  end
end
