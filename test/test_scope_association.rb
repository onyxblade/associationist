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
      type: :singular,
      name: :product,
      scope: -> (owner) {
        Product.where(catalog_id: owner.id)
      },
      preloader: -> (owners) {
        id_to_products_hash = Product.where(catalog_id: owners.map(&:id)).group_by(&:catalog_id)
        owners.map{|owner| [owner, id_to_products_hash[owner.id]&.first]}.to_h
      }
    )
  end

  class CatalogWithCollectionScopeAndPreloader < ActiveRecord::Base
    cattr_accessor :value
    self.table_name = 'catalogs'

    include Associationist::Mixin.new(
      type: :collection,
      name: :products,
      scope: -> (owner) {
        Product.where(catalog_id: owner.id)
      },
      preloader: -> (owners) {
        id_to_products_hash = Product.where(catalog_id: owners.map(&:id)).group_by(&:catalog_id)
        owners.map{|owner| [owner, id_to_products_hash[owner.id]]}.to_h
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

    assert_queries 1 do
      assert_equal products.first, catalog.product
    end

    catalog = CatalogWithCollectionScope.create
    products = create_products_for_catalog catalog

    assert_queries 1 do
      assert_equal products, catalog.products.to_a
    end
  end

  def test_preload
    catalogs = 3.times.map{CatalogWithSingularScopeAndPreloader.create}
    products = catalogs.map{|catalog| (create_products_for_catalog catalog).first}

    assert_queries 2 do
      assert_equal products, CatalogWithSingularScopeAndPreloader.where(id: catalogs).includes(:product).map(&:product)
    end

    catalogs = 3.times.map{CatalogWithCollectionScopeAndPreloader.create}
    products = catalogs.map{|catalog| create_products_for_catalog catalog}

    assert_queries 2 do
      assert_equal products, CatalogWithCollectionScopeAndPreloader.where(id: catalogs).includes(:products).map(&:products)
    end

    catalogs = 3.times.map{CatalogWithCollectionScopeAndPreloader.create}
    products = catalogs.map{|catalog| create_products_for_catalog catalog}
    properties = products.first.map do |product|
      product.properties.create
    end
    assert_queries 3 do
      assert_equal products, CatalogWithCollectionScopeAndPreloader.where(id: catalogs).includes(products: :properties).map(&:products)
    end

    assert_queries 3 do
      assert_equal properties, CatalogWithCollectionScopeAndPreloader.where(id: catalogs).includes(products: :properties).map(&:products).first.map(&:properties).inject(:+)
    end
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

  #def test_preloader_take_precedence_over_scope
  #  catalogs = 3.times.map{CatalogWithSingularScope.create}
  #  products = catalogs.map{|catalog| (create_products_for_catalog catalog).first}

  #  assert [1, 1, 1], CatalogWithSingularScope.all.includes(:product).map(&:product)
  #end

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


  class CatalogWithScopeThatTouchDB < ActiveRecord::Base
    self.table_name = 'catalogs'
    include Associationist::Mixin.new(
      name: :products,
      type: :singular,
      scope: -> record {
        Product.last
        Product.all
      }
    )
  end

  def test_scope_should_be_executed_once
    catalog = CatalogWithScopeThatTouchDB.create
    assert_queries 2 do
      catalog.products
    end
  end
end
