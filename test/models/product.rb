ActiveRecord::Base.connection.create_table(:products, force: true) do |t|
  t.string :name
  t.timestamps
end

class Product < ActiveRecord::Base
  include Associationist::Mixin.new(
    type: :singular,
    name: :stock
  )
end
