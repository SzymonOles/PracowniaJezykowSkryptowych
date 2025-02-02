require "sequel"

# Połączenie z bazą danych SQLite
DB = Sequel.sqlite("amazon_products.db")

# Tworzenie tabeli, jeśli nie istnieje
DB.create_table? :products do
  primary_key :id
  String :title
  String :price
  String :url
  String :details
end

# Model ORM dla produktów
class Product < Sequel::Model(:products)
end