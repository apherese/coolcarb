# require "pry"

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# avec Rest-Client (marche aussi)
# require "json"
# require "rest-client"
# url = "https://data.ademe.fr/data-fair/api/v1/datasets/bilans-ges/values_agg?field=APE(NAF)&metric=avg&metric_field=Emissions_publication_P1_-_tCO2e&qs=5510Z"
# benchmark_serialized = RestClient.get(url)
# benchmark = JSON.parse(benchmark_serialized)

Task.destroy_all
Footprint.destroy_all
User.destroy_all
Company.destroy_all

# liste des hôtels de l'ademe avec les paramètres nécessaires spour calcul des scopes
# require "json"
require "open-uri"
# url = "https://data.ademe.fr/data-fair/api/v1/datasets/bilans-ges/lines?select=Raison_sociale_%2F_Nom_de_l'entit%C3%A9%2CAnn%C3%A9e_de_reporting%2CNombre_de_salari%C3%A9s_%2F_d'agents%2CAPE(NAF)%2CEmissions_publication_P1_-_tCO2e%2CEmissions_publication_P2_-_tCO2e%2CEmissions_publication_P3_-_tCO2e%2CEmissions_publication_P4_-_tCO2e%2CEmissions_publication_P5_-_tCO2e%2CEmissions_publication_P6_-_tCO2e%2CEmissions_publication_P7_-_tCO2e%2CEmissions_publication_P8_-_tCO2e%2CEmissions_publication_P9_-_tCO2e%2CEmissions_publication_P10_-_tCO2e%2CEmissions_publication_P11_-_tCO2e%2CEmissions_publication_P12_-_tCO2e%2CEmissions_publication_P13_-_tCO2e%2CEmissions_publication_P14_-_tCO2e%2CEmissions_publication_P15_-_tCO2e%2CEmissions_publication_P16_-_tCO2e%2CEmissions_publication_P17_-_tCO2e%2CEmissions_publication_P18_-_tCO2e%2CEmissions_publication_P19_-_tCO2e%2CEmissions_publication_P20_-_tCO2e%2CEmissions_publication_P21_-_tCO2e%2CEmissions_publication_P22_-_tCO2e%2CEmissions_publication_P23_-_tCO2e%2CVolume_de_r%C3%A9duction_attendu_-_Scope_1_-_en_tCO2e%2CVolume_de_r%C3%A9duction_attendu_-_Scope_2_-_en_tCO2e%2CVolume_de_r%C3%A9duction_attendu_-_Scope_3_-_en_tCO2e%2CPlan_d'actions_-_Scope_1%2CPlan_d'actions_-_Scope_2%2CPlan_d'actions_-_Scope_3&qs=5510Z"
# list_hotel_serialized = URI.open(url).read
# @list_hotel = JSON.parse(list_hotel_serialized)

# moyenne du secteur des hôtels du Poste P1
# url = "https://data.ademe.fr/data-fair/api/v1/datasets/bilans-ges/values_agg?field=APE(NAF)&metric=avg&metric_field=Emissions_publication_P1_-_tCO2e&qs=5510Z"
# benchmark_serialized = URI.open(url).read
# benchmark_mean = JSON.parse(benchmark_serialized)

require "json"
filepath = "data/ademe_data.json"
data = File.read(filepath)
list_data = JSON.parse(data)["results"]

list_data.each do |el|
  hotel_parameter = {
    name: el["Raison_sociale_/_Nom_de_l'entité"],
    industry: el["Secteur"],
    employee_nb: el["Nombre_de_salariés_/_d'agents"]
  }

  company = Company.create!(hotel_parameter)

  scope_1 = [el["Emissions_publication_P1_-_tCO2e"], el["Emissions_publication_P2_-_tCO2e"], el["Emissions_publication_P3_-_tCO2e"], el["Emissions_publication_P4_-_tCO2e"], el["Emissions_publication_P5_-_tCO2e"]].compact.sum
  scope_2 = [el["Emissions_publication_P6_-_tCO2e"], el["Emissions_publication_P7_-_tCO2e"]].compact.sum
  scope_3 = [el["Emissions_publication_P8_-_tCO2e"], el["Emissions_publication_P9_-_tCO2e"], el["Emissions_publication_P10_-_tCO2e"], el["Emissions_publication_P11_-_tCO2e"], el["Emissions_publication_P12_-_tCO2e"], el["Emissions_publication_P13_-_tCO2e"], el["Emissions_publication_P14_-_tCO2e"], el["Emissions_publication_P15_-_tCO2e"], el["Emissions_publication_P16_-_tCO2e"], el["Emissions_publication_P17_-_tCO2e"], el["Emissions_publication_P18_-_tCO2e"], el["Emissions_publication_P19_-_tCO2e"], el["Emissions_publication_P20_-_tCO2e"], el["Emissions_publication_P21_-_tCO2e"], el["Emissions_publication_P22_-_tCO2e"], el["Emissions_publication_P23_-_tCO2e"]].compact.sum
  ghg_result = scope_1 + scope_2 + scope_3

  footprint_parameter = {
    scope_1: scope_1,
    scope_2: scope_2,
    scope_3: scope_3,
    ghg_result: ghg_result,
    date: el["Année_de_reporting"],
    certified: true,
    company_id: company.id
  }
  Footprint.create!(footprint_parameter)
end

aigle_noir = Company.create!({ name: "Aigle Noir", industry: "Hôtel", employee_nb: 15, room_nb: 80, length_of_stay: 4.2, load_factor: 0.8 })
hotel_plage = Company.create!({ name: "La Plage", industry: "Hôtel", employee_nb: 5, room_nb: 20, length_of_stay: 5.3, load_factor: 0.9 })
metropol = Company.create!({ name: "Metropol", industry: "Hôtel", employee_nb: 100, room_nb: 250, length_of_stay: 2.1, load_factor: 0.70 })
radisson = Company.create!({ name: "Radisson", industry: "Hôtel", employee_nb: 50, room_nb: 160, length_of_stay: 3.3, load_factor: 0.75 })

jeanpierre = User.create!({ name: "Jean-Pierre", position: "Directeur financier", email: "jeanpierre@gmail.com", company: aigle_noir, password: "azerty", admin: true })
file = URI.open("https://res.cloudinary.com/dton44gcy/image/upload/v1674321181/jpd_profile_q0gj5a.png")
jeanpierre.photo.attach(io: file, filename: "jpd_profile.jpg", content_type: "image/jpg")

greta = User.create!({ name: "Greta", position: "Présidente", email: "greta@gmail.com", password: "azerty", admin: false })
file = URI.open("https://res.cloudinary.com/dton44gcy/image/upload/v1676715950/greta_avatar_rwex34.webp")
greta.photo.attach(io: file, filename: "greta_avatar.jpg", content_type: "image/jpg")

mohamed = User.create!({ name: "Mohamed", position: "Directeur général", email: "mohamed@gmail.com", company: hotel_plage, password: "azerty", admin: true })
file = URI.open("https://res.cloudinary.com/dton44gcy/image/upload/v1674839485/einstein_profile_pxl1ji.jpg")
mohamed.photo.attach(io: file, filename: "einstein_profile.jpg", content_type: "image/jpg")

amine = User.create!({ name: "Amine", position: "Directeur RSE", email: "amine@gmail.com", company: metropol, password: "azerty", admin: true })
file = URI.open("https://res.cloudinary.com/dton44gcy/image/upload/v1674248768/ybxnuoodebwxmnzewjyy.jpg")
amine.photo.attach(io: file, filename: "amine_profile.jpg", content_type: "image/jpg")

nathanael = User.create!({ name: "Nathanaël", position: "Directeur juridique", email: "nathanael@gmail.com", company: radisson, password: "azerty", admin: true })
file = URI.open("https://res.cloudinary.com/dton44gcy/image/upload/v1674371244/yoda_profile_iis5yg.jpg")
nathanael.photo.attach(io: file, filename: "yoda_profile.jpg", content_type: "image/jpg")

# footprint_1 = Footprint.create!({ company: aigle_noir, scope_1: 10_000, scope_2: 22_000, scope_3: 345_000, ghg_result: (10_000 + 22_000 + 345_000), certified: true, date: "2023-02-01" })
# footprint_2 = Footprint.create!({ company: hotel_plage, scope_1: 4_000, scope_2: 12_000, scope_3: 145_000, ghg_result: (4_000 + 12_000 + 145_000), certified: false, date: "2020-05-01" })
# footprint_3 = Footprint.create!({ company: metropol, scope_1: 17_000, scope_2: 36_000, scope_3: 645_000, ghg_result: (17_000 + 36_000 + 645_000), certified: false, date: "2021-12-01" })
# footprint_4 = Footprint.create!({ company: radisson, scope_1: 35_000, scope_2: 62_000, scope_3: 1_345_000, ghg_result: (35_000 + 62_000 + 1_345_000), certified: false, date: "2019-07-01" })

employee_1_1 = User.create!({ name: "Claire", position: "CEO", email: "claire1@gmail.com", company: aigle_noir, password: "azerty", admin: false })
employee_1_2 = User.create!({ name: "Margot", position: "DRSE", email: "margot1@gmail.com", company: aigle_noir, password: "azerty", admin: false })
employee_1_3 = User.create!({ name: "Fred", position: "DSI", email: "fred1@gmail.com", company: aigle_noir, password: "azerty", admin: false })
employee_1_4 = User.create!({ name: "Iris", position: "Chef", email: "iris1@gmail.com", company: aigle_noir, password: "azerty", admin: false })
employee_1_5 = User.create!({ name: "Luc", position: "Commis", email: "luc1@gmail.com", company: aigle_noir, password: "azerty", admin: false })
employee_1_6 = User.create!({ name: "Flora", position: "CPO", email: "flora1@gmail.com", company: aigle_noir, password: "azerty", admin: false })

employee_2_1 = User.create!({ name: "Claire", position: "CEO", email: "claire2@gmail.com", company: hotel_plage, password: "azerty", admin: false })
employee_2_2 = User.create!({ name: "Margot", position: "DRSE", email: "margot2@gmail.com", company: hotel_plage, password: "azerty", admin: false })
employee_2_3 = User.create!({ name: "Fred", position: "DSI", email: "fred2@gmail.com", company: hotel_plage, password: "azerty", admin: false })
employee_2_4 = User.create!({ name: "Iris", position: "Chef", email: "iris2@gmail.com", company: hotel_plage, password: "azerty", admin: false })
employee_2_5 = User.create!({ name: "Luc", position: "Commis", email: "luc2@gmail.com", company: hotel_plage, password: "azerty", admin: false })
employee_2_6 = User.create!({ name: "Flora", position: "CPO", email: "flora2@gmail.com", company: hotel_plage, password: "azerty", admin: false })

employee_3_1 = User.create!({ name: "Claire", position: "CEO", email: "claire3@gmail.com", company: metropol, password: "azerty", admin: false })
employee_3_2 = User.create!({ name: "Margot", position: "DRSE", email: "margot3@gmail.com", company: metropol, password: "azerty", admin: false })
employee_3_3 = User.create!({ name: "Fred", position: "DSI", email: "fred3@gmail.com", company: metropol, password: "azerty", admin: false })
employee_3_4 = User.create!({ name: "Iris", position: "Chef", email: "iris3@gmail.com", company: metropol, password: "azerty", admin: false })
employee_3_5 = User.create!({ name: "Luc", position: "Commis", email: "luc3@gmail.com", company: metropol, password: "azerty", admin: false })
employee_3_6 = User.create!({ name: "Flora", position: "CPO", email: "flora3@gmail.com", company: metropol, password: "azerty", admin: false })

employee_4_1 = User.create!({ name: "Claire", position: "CEO", email: "claire4@gmail.com", company: radisson, password: "azerty", admin: false })
employee_4_2 = User.create!({ name: "Margot", position: "DRSE", email: "margot4@gmail.com", company: radisson, password: "azerty", admin: false })
employee_4_3 = User.create!({ name: "Fred", position: "DSI", email: "fred4@gmail.com", company: radisson, password: "azerty", admin: false })
employee_4_4 = User.create!({ name: "Iris", position: "Chef", email: "iris4@gmail.com", company: radisson, password: "azerty", admin: false })
employee_4_5 = User.create!({ name: "Luc", position: "Commis", email: "luc4@gmail.com", company: radisson, password: "azerty", admin: false })
employee_4_6 = User.create!({ name: "Flora", position: "CPO", email: "flora4@gmail.com", company: radisson, password: "azerty", admin: false })

# task1_1 = Task.create!({ name: "chauffage", footprint: footprint_1, ghg_contribution: 20, owner: jeanpierre })
# task1_2 = Task.create!({ name: "isolation", footprint: footprint_1, ghg_contribution: 15, owner: jeanpierre })
# task1_3 = Task.create!({ name: "cycle court", footprint: footprint_1, ghg_contribution: 25, owner: jeanpierre })

# task2_1 = Task.create!({ name: "chauffage", footprint: footprint_2, ghg_contribution: 20, owner: mohamed })
# task2_2 = Task.create!({ name: "isolation", footprint: footprint_2, ghg_contribution: 15, owner: mohamed })
# task2_3 = Task.create!({ name: "cycle court", footprint: footprint_2, ghg_contribution: 25, owner: mohamed })

# task3_1 = Task.create!({ name: "chauffage", footprint: footprint_3, ghg_contribution: 20, owner: amine })
# task3_2 = Task.create!({ name: "isolation", footprint: footprint_3, ghg_contribution: 15, owner: amine })
# task3_3 = Task.create!({ name: "cycle court", footprint: footprint_3, ghg_contribution: 25, owner: amine })

# task4_1 = Task.create!({ name: "chauffage", footprint: footprint_4, ghg_contribution: 20, owner: nathanael })
# task4_2 = Task.create!({ name: "isolation", footprint: footprint_4, ghg_contribution: 15, owner: nathanael })
# task4_3 = Task.create!({ name: "cycle court", footprint: footprint_4, ghg_contribution: 25, owner: nathanael })
