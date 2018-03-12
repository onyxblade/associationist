module Fixtures
  def load_fixtures
    @pen_catalog = Catalog.create

    @black_pen = Product.create(catalog: @pen_catalog, price: 2)
    @black_pen.properties.create(value: 'Black')

    @red_pen = Product.create(catalog: @pen_catalog, price: 4)
    @red_pen.properties.create(value: 'Red')

    @blue_pen = Product.create(catalog: @pen_catalog, price: 4)
    @blue_pen.properties.create(value: 'Blue')

    @pencil_catalog = Catalog.create

    @black_pencil = Product.create(catalog: @pencil_catalog, price: 1)
    @black_pencil.properties.create(value: 'Black')

    @red_pencil = Product.create(catalog: @pencil_catalog, price: 2)
    @red_pencil.properties.create(value: 'Red')

    @blue_pencil = Product.create(catalog: @pencil_catalog, price: 2)
    @blue_pencil.properties.create(value: 'Blue')

    @marker_catalog = Catalog.create

    @black_marker = Product.create(catalog: @marker_catalog, price: 4)
    @black_marker.properties.create(value: 'Black')

    @red_marker = Product.create(catalog: @marker_catalog, price: 8)
    @red_marker.properties.create(value: 'Red')

    @blue_marker = Product.create(catalog: @marker_catalog, price: 8)
    @blue_marker.properties.create(value: 'Blue')

    @pen_and_pencil_collection = ProductCollection.create(
      rule: {
        or: [
          {
            association: {
              class_name: 'Catalog',
              id: @pen_catalog.id,
              source: 'products'
            }
          },
          {
            association: {
              class_name: 'Catalog',
              id: @pencil_catalog.id,
              source: 'products'
            }
          }
        ]
      }
    )

    @pen_and_marker_collection = ProductCollection.create(
      rule: {
        or: [
          {
            association: {
              class_name: 'Catalog',
              id: @pen_catalog.id,
              source: 'products'
            }
          },
          {
            association: {
              class_name: 'Catalog',
              id: @marker_catalog.id,
              source: 'products'
            }
          }
        ]
      }
    )
  end
end
