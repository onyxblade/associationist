# associationist

[![Build Status](https://travis-ci.org/CicholGricenchos/associationist.svg?branch=master)](https://travis-ci.org/CicholGricenchos/associationist)

An ActiveRecord plugin that allows you to create customized association.

Install
------

Add `gem 'associationist'` to your Gemfile and `bundle`.

Usage
------

Define a customized association:
```ruby
class Product < ApplicationRecord
  include Associationist::Mixin.new(
    name: :stock,
    # You can choose to implement one or many of [loader, preloader, scope].
    # loader is for singly association loading. The return value can be of any type. n+1 query cannot be avoided by this strategy.
    loader: -> product {
      100
    },
    # preloader is for batch loading. It prevents n+1 query when using with includes and preload.
    # When preloader is defined, definition of loader is optional.
    preloader: -> products {
      products.map{|product| [product, 100]}.to_h
    },
    # scope defines the scope that will be returned when reading association.
    # Only one of [scope, loader] should be defined.
    scope: -> product {
      Stock.where(product_id: product)
    },
    # Available options: [:singular, :collection]. Use when scope option is defined, to determine the association is singluar or collection.
    type: :singular
  )
end

Product.all.includes(:stock).map(&:stock) # => [100, ...]

# use Associationist.preload to trigger a preloading for collections that are already load
Associationist.preload(products, :stock)
```

Test
------
```shell
bundle rake
```

License
------

[The MIT License](https://opensource.org/licenses/MIT)
