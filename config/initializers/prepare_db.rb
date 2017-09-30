# If environment is development, seed database.
if Rails.env.development?
  30.times do
    params_array = []
    ph = PublishingHouse.create(name: Faker::Book.publisher.truncate(40))

    30.times do
      params = {
        title: Faker::Book.title.truncate(50),
        description: Faker::Lorem.sentence.truncate(50),
        author: Faker::Book.author.truncate(50),
        publishing_house_id: ph.id
      }

      params_array << params
    end

    Book.create(params_array)
  end
end
