# encoding: utf-8

lib = File.expand_path('../../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'rails-i18n-inflector/version'

Gem::Specification.new do |s|
  s.name         = "rails-i18n-inflector"
  s.version      = I18n::Inflector::Rails::VERSION
  s.authors      = [I18n::Inflector::Rails::DEVELOPER]
  s.email        = I18n::Inflector::Rails::EMAIL
  s.homepage     = I18n::Inflector::Rails::URL
  s.summary      = I18n::Inflector::Rails::SUMMARY
  s.description  = I18n::Inflector::Rails::DESCRIPTION

  s.files        = Dir.glob("{ci,lib,spec,docs}/**/**") + %w(install.rb uninstall.rb init.rb Gemfile .rspec .yardopts README.rdoc LGPL-LICENSE ChangeLog Manifest.txt)
  s.extra_rdoc_files = ["README.rdoc", "docs/HISTORY", "docs/LGPL-LICENSE", "docs/COPYING"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_rubygems_version = '>= 1.3.5'
  s.specification_version = 3

  s.add_dependency 'i18n-inflector',          '~> 1.0.8'
  #s.add_dependency 'rails',                   '~> 3.0.0'
  s.add_development_dependency 'rspec',       '>= 2.3.0'
  s.add_development_dependency 'yard',        '>= 1.0.7'
  s.add_development_dependency 'hoe-bundler', '>= 1.0.0'
end
