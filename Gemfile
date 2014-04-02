source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails', '4.0.4'

gem 'sass-rails', '~> 4.0.2'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'pg'

group :doc do
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'foreman'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'spork-rails'
  gem 'guard-spork'
  gem 'childprocess'
  gem 'pry-rails'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'
end

group :production do
  gem 'rails_12factor'
end

group :docker do
  gem 'rake'
  gem 'rspec'
  gem 'my_docker_rake', github: 'hyone/my_docker_rake'
end
