ActiveRecord::Base.connection.create_table(:products, force: true) do |t|
  t.string :name
  t.integer :catalog_id
  t.timestamps
end

class Product < ActiveRecord::Base
  has_many :properties
end
