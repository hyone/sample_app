source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails', '4.0.4'
gem 'bcrypt-ruby'
gem 'sass-rails', '~> 4.0.2'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'bootstrap-sass', '2.3.2.0'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'pg'

group :doc do
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'foreman'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'spork-rails'
  gem 'childprocess'
  gem 'terminal-notifier-guard'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'better_errors'
  # dispaly irb/pry(PERL) on better_errors
  gem 'binding_of_caller'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'factory_girl_rails'
end

group :production do
  gem 'rails_12factor'
end

group :docker do
  gem 'rake'
  gem 'rspec'
  gem 'my_docker_rake', github: 'hyone/my_docker_rake'
end
