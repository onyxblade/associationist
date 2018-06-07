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
end
