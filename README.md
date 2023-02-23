# associationist

![Build Status](https://github.com/onyxblade/associationist/actions/workflows/test.yml/badge.svg?branch=master)

A gem to define virtual associations on Rails models.

Getting Started
------
### What are virtual associations, and why?

By default, every association defined by `has_one` or `has_many` must be in correspondence to the underlying table structure. It is by the Rails conventions, it can figure out how to load data based on the associations defined in our model file. Therefore, an association cannot live without the actual tables.

Aside from the convenience Rails provides, we sometimes would want to loosen this restriction. We want associations to work without tables, but preserving the Rails way of loading and using data.

Let's consider two examples. In the first example, we will define a virtual association for an external API service. In the second example, we will implement an [automated collection](https://help.shopify.com/en/manual/products/collections/automated-collections), a very cool feature provided by Shopify.

### City weather example

Suppose we have three models `Province`, `City` and `Weather`. Every province has many cities, and every city has a current weather. It's natural for us to preload data like this:

```ruby
provinces = Province.includes(cities: :weather)
```

However, for this to work we need to actually have a `weathers` table, which might be undesired because weather data is usually temporary. So instead, we might need to assign weather data to an instance variable for each of our cities.

```ruby
provinces = Province.includes(:cities)
weather_data = WeatherAPI.load_for_cities(province.map(&:cities).flatten)
# Supposing the weather data is a hash from city to weather
province.flat_map(&:cities).each do |city|
  city.weather = weather_data[city]
end
# then for every city we can access city.weather
```

This solution would introduce a bunch of boilerplates and does not look elegant. We would want to load weather data using `includes` as in the first snippet. Here `associationist` comes to help.

```ruby
# First define a virtual association on City model
class City < ApplicationRecord
  belongs_to :province
  include Associationist::Mixin.new(
    name: :weather,
    preloader: -> cities {
      WeatherAPI.load_for_cities(cities)
    }
  )
end

# Load and access the data
province = Province.includes(cities: :weather)
province.first.city.first.weather # works
```

### Automated collection example

Shopify has automated collections to manage products, which in a nutshell are collections by rules. For example, we could define a collection of all products cheaper than $5. When a product's price is set to less than $5, it would automatically enter the collection, and when a product's price is raised over $5, it automatically leaves.

It would be very desirable if we can load product data by `includes`:

```ruby
collections = Collection.includes(products: :stock).all
```

For this to work, again, we need an actual `Collection` table, a `Product` table and a `CollectionsProducts` table to store the many-to-many connections. Then, whenever a product is updated, we check and update the through-relations between collections and products. This solution involves too many queries and updating the database, which we usually would avoid.

But with `associationist`, we can define a virtual association to return an arbitrary scope:

```ruby
class Collection < ApplicationRecord
  include Associationist::Mixin.new(
    name: :products,
    scope: -> collection {
      price_range = collection.price_range
      Product.where(price: price_range)
    },
    type: :collection
  )
end
```

The scope returned by the `scope` lambda will be installed to a collection as its `collection.products` association. This association can be totally dynamic, since we can use properties of `collection`, in this case, the `price_range`, to determine which scope to return. And if we want to implement an automated collection similar to Shopify's, we just need to add a column to `Collection` to store the rules needed to fetch products and construct a scope based on these rules.

Virtual associations defined by `scope` can work seamlessly in any place of the preloading chain:

```ruby
# Supposing a Shop has many Collections
Shop.includes(collections: {products: :stock}) # works just fine
Collection.first.products.where(price: 1).order(id: :desc) # scopes works as well
```

For a more featured implementation of automated collections that supports caching, please checkout [https://github.com/onyxblade/smart_collection](https://github.com/onyxblade/smart_collection).

Install
------

Add `gem 'associationist'` to your Gemfile and `bundle`.

Usage
------

Define a virtual association:
```ruby
class Product < ApplicationRecord
  include Associationist::Mixin.new(
    name: :stock,

    # Define how the association should be handled.
    # You can choose to implement one of [preloader, scope].

    # preloader receives a list of association owners, and returns a hash from owner to loaded data.
    # It prevents n+1 query when used with includes.
    preloader: -> products {
      products.map{|product| [product, 100]}.to_h
    },
    # If your preloaded objects are of an ActiveRecord class, you need to specify class_name for through-preloading.
    # This is not needed when using the scope option.
    class_name: 'Stock',

    # scope defines the scope returned by association reading.
    scope: -> product {
      Stock.where(product_id: product)
    },

    # The type of association. Only needed when scope option is used.
    # Available options: [:singular, :collection].
    type: :singular
  )
end
```

Using a virtual association:
```ruby
Product.last.stock # => 100
Product.all.includes(:stock).map(&:stock) # => [100, ...]

# use Associationist.preload to manually load associations.
# this will not cause products to reload.
Associationist.preload(products, :stock)
Associationist.preload(products, [:stock])
Associationist.preload(products, stock: [])
```

Test
------
```shell
bundle exec --gemfile=./gemfiles/rails6-1 rake test
```

License
------

[The MIT License](https://opensource.org/licenses/MIT)
