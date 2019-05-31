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

  class CatalogWithSingularScopeAndPreloader < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'catalogs'

    include Associationist::Mixin.new(
      type: :collection,
      name: :product,
      scope: -> (owner) {
        Product.where(catalog_id: owner.id)
      },
      preloader: -> (owners) {
        owners.map{|owner| [owner, 1]}.to_h
      }
    )
  end

  class CatalogWithArbitraryScope < ActiveRecord::Base
    self.table_name = 'catalogs'

    include Associationist::Mixin.new(
      type: :collection,
      name: :products,
      scope: -> (owner) {
        Product.all
      }
    )

    include Associationist::Mixin.new(
      type: :singular,
      name: :product,
      scope: -> (owner) {
        Product.all
      }
    )

    include Associationist::Mixin.new(
      type: :collection,
      name: :some_products,
      class_name: 'Product',
      scope: -> (owner) {
        Product.all
      }
    )

    include Associationist::Mixin.new(
      type: :singular,
      name: :some_product,
      class_name: 'Product',
      scope: -> (owner) {
        Product.all
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

  def test_preload
    catalogs = 3.times.map{CatalogWithSingularScope.create}
    products = catalogs.map{|catalog| (create_products_for_catalog catalog).first}

    assert products, CatalogWithSingularScope.all.includes(:product).map(&:product)

    catalogs = 3.times.map{CatalogWithCollectionScope.create}
    products = catalogs.map{|catalog| create_products_for_catalog catalog}

    assert products, CatalogWithCollectionScope.all.includes(:products).map(&:products)
  end

  def test_limit
    catalog = CatalogWithCollectionScope.create
    products = create_products_for_catalog catalog

    assert_equal 2, catalog.products.limit(2).size
    assert_equal products.first(2), catalog.products.limit(2).to_a
  end

  def test_count
    catalog = CatalogWithCollectionScope.create
    products = create_products_for_catalog catalog

    assert_equal 3, catalog.products.size
    assert_equal 3, catalog.products.count
  end

  def test_preloader_take_precedence_over_scope
    catalogs = 3.times.map{CatalogWithSingularScope.create}
    products = catalogs.map{|catalog| (create_products_for_catalog catalog).first}

    assert [1, 1, 1], CatalogWithSingularScope.all.includes(:product).map(&:product)
  end

  def test_loading_scope_before_save
    products = 3.times.map{ Product.create }
    catalog = CatalogWithArbitraryScope.new

    assert_equal 3, catalog.products.size
    assert_equal products, catalog.products.to_a

    assert_equal products.first, catalog.product
  end

  def test_determine_classname
    products = 3.times.map{ Product.create }
    catalog = CatalogWithArbitraryScope.new

    assert_equal 3, catalog.some_products.size
    assert_equal products, catalog.some_products.to_a

    assert_equal products.first, catalog.some_product
  end
end
