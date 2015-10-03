require "grand_central/version"
require "grand_central/store"
require "grand_central/action"
require "opal"

module GrandCentral
end

if RUBY_ENGINE != 'opal'
  Opal.append_path File.expand_path('..', __FILE__)
end
