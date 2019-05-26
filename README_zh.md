# associationist

[![Build Status](https://travis-ci.org/CicholGricenchos/associationist.svg?branch=master)](https://travis-ci.org/CicholGricenchos/associationist)

让ActiveRecord支持自定义关联。

安装
------

添加 `gem 'associationist'` 到 Gemfile 然后  `bundle`.

使用
------

定义一个自定义关联:
```ruby
class Product < ApplicationRecord
  include Associationist::Mixin.new(
    name: :stock,
    # 你可以选择实现 [loader, preloader, scope] 中的一个或多个。
    # loader 定义了当读取关联时将返回的对象，不要求一定是Model对象，loader即使配合preload使用也不能避免n+1问题。
    loader: -> product {
      100
    },
    # preloader 是批量加载时使用的，结合includes和preload可以避免n+1问题。
    # 如果定义了preloader，loader可以不定义，会自动使用preloader的定义。
    preloader: -> products {
      products.map{|product| [product, 100]}.to_h
    },
    # scope 定义了当读取关联时将返回的scope。
    # scope和loader不能同时定义。
    scope: -> product {
      Stock.where(product_id: product)
    },
    # 可选的值：[:singular, :collection]。定义了使用scope时关联是单数关联还是复数关联。
    type: :singular
  )
end

Product.all.includes(:stock).map(&:stock) # => [100, ...]

# Associationist.preload可以在已经被加载的model集合上重新触发一次preload。
Associationist.preload(products, :stock)
```

测试
------
```shell
bundle rake
```

协议
------

[The MIT License](https://opensource.org/licenses/MIT)
