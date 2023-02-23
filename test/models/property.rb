ActiveRecord::Base.connection.create_table(:properties, force: true) do |t|
  t.string :name
  t.integer :product_id
  t.timestamps
end

class Property < ActiveRecord::Base
  belongs_to :product

  include Associationist::Mixin.new(
    name: :associationist_product,
    type: :singular,
    scope: -> property { Product.where(id: property.product_id) }
  )
end
