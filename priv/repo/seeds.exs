# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MRP.Repo.insert!(%MRP.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

for _i <- 1..25 do
  MRP.Repo.insert!(%Core.Inventory.Item{
    name: Faker.Commerce.product_name_product(),
    description: Faker.Food.description(),
    category: Faker.Industry.industry(),
    supplier_information: Faker.Company.name(),
    unit_price: Decimal.new(:erlang.float_to_binary(Faker.Commerce.price(), decimals: 2)),
    unit_of_measurement: Enum.random(~w(lb oz ft in yd mi m cm mm km g kg mL L gal pt qt)),
    quantity_in_stock: Decimal.new(:erlang.float_to_binary(Faker.Commerce.price(), decimals: 1)),
    reorder_point: Enum.random(1..20)
  })
end
