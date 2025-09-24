require 'faker'
require 'faraday'

# API Client Setup
API_URL = 'http://localhost:3000/api/v1'
connection = Faraday.new(url: API_URL) do |faraday|
  faraday.request :json
  faraday.adapter Faraday.default_adapter
end

puts 'Generating seed data via API...'

# --- Generate Users and IPs ---
USER_COUNT = 100 # [cite: 33]
IP_COUNT = 50 # [cite: 33]
POST_COUNT = 200_000 # [cite: 33]

user_logins = Array.new(USER_COUNT) { Faker::Internet.unique.username(specifier: 5..12) }
ip_addresses = Array.new(IP_COUNT) { Faker::Internet.unique.ip_v4_address }

# --- Create Posts ---
BATCH_SIZE = 5000
post_ids = []

puts "Generating #{POST_COUNT} posts..."
all_posts_payload = []
(1..POST_COUNT).each do |i|
  all_posts_payload << {
    title: Faker::Lorem.sentence(word_count: 3),
    body: Faker::Lorem.paragraph(sentence_count: 4),
    login: user_logins.sample,
    ip: ip_addresses.sample
  }
  print "\rGenerating posts: #{i}/#{POST_COUNT}"
end
puts "\nDone generating posts."

all_posts_payload.each_slice(BATCH_SIZE).with_index do |batch, index|
  response = connection.post('posts/bulk_create', { posts: batch })

  if response.success?
    # The bulk_create action needs to return the IDs of the created posts
    # For now, we'll assume it does, and we'll fetch them later for rating.
    print "\rBatches processed: #{index + 1}/#{all_posts_payload.size / BATCH_SIZE}"
  else
    puts "\nFailed to create post batch: #{response.body}"
  end
end
puts "\nPost creation complete."

# --- Create Ratings ---
# Fetch all post IDs for rating
post_ids = Post.pluck(:id)

# Rate about 75% of posts
user_ids = User.pluck(:id) # Fetch all user IDs from the DB
posts_to_rate_count = (POST_COUNT * 0.75).to_i
ratings_payload = []
rated_pairs = Set.new # Ensure a user rates a post only once

puts "Generating #{posts_to_rate_count} ratings..."
while ratings_payload.size < posts_to_rate_count
  post_id = post_ids.sample
  user_id = user_ids.sample

  # Avoid duplicate ratings
  next if rated_pairs.include?([ user_id, post_id ])

  ratings_payload << {
    post_id: post_id,
    user_id: user_id,
    value: rand(1..5)
  }
  rated_pairs.add([ user_id, post_id ])
  print "\rGenerating ratings: #{ratings_payload.size}/#{posts_to_rate_count}"
end
puts "\nDone generating ratings."

ratings_payload.each_slice(BATCH_SIZE).with_index do |batch, index|
  response = connection.post('ratings/bulk_create', { ratings: batch })

  if response.success?
    print "\rRating batches processed: #{index + 1}/#{ratings_payload.size / BATCH_SIZE}"
  else
    puts "\nFailed to create rating batch: #{response.body}"
  end
end
puts "\nDatabase seeding complete."
