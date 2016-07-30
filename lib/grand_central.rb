require "grand_central/version"
require "grand_central/store"
require "grand_central/action"
require "grand_central/model"
require "grand_central/store_mixin"

module GrandCentral
end

if RUBY_ENGINE != 'opal'
  # Autodetect Opal
  begin
    require "opal"
    Opal.append_path File.expand_path('..', __FILE__)
  rescue LoadError => e
  end
end
