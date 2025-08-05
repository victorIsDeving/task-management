# Gemfile
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 8.0.2"
gem "pg", "~> 1.6"
gem "puma", "~> 6.0"
gem "bootsnap", ">= 1.4.4", require: false
gem "image_processing", "~> 1.2"

# Authentication
gem "bcrypt", "~> 3.1.7"
gem "jwt"

# CORS for API
gem "rack-cors"

# Background jobs
gem "sidekiq"

# Pagination
gem "kaminari"

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem "listen", "~> 3.3"
  gem "spring"
end

group :test do
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
end