# associationist

[![Build Status](https://travis-ci.org/onyxblade/associationist.svg?branch=master)](https://travis-ci.org/onyxblade/associationist)

An ActiveRecord plugin to define virtual associations for models.

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
    # You can choose to implement one or many of [loader, preloader, scope].

    # loader is for singly association loading.
    # The return value can be of any type.
    #  n+1 query cannot be avoided by this strategy.
    loader: -> product {
      100
    },

    # preloader is for batch loading.
    # It prevents n+1 query when using with includes and preload.
    # When preloader is defined, definition of loader is optional.
    preloader: -> products {
      products.map{|product| [product, 100]}.to_h
    },

    # scope defines the scope returned by association reading.
    # Only one of [scope, loader] should be defined.
    scope: -> product {
      Stock.where(product_id: product)
    },

    # Defines the type of association. Only needed when scope option is used.
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
bundle exec rake
```

License
------

[The MIT License](https://opensource.org/licenses/MIT)
