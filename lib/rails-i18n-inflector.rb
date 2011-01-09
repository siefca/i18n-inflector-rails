# encoding: utf-8

require 'i18n-inflector'
require 'rails-i18n-inflector/errors'
require 'rails-i18n-inflector/inflector'

require 'action_controller' if not defined?(ActionController::Base)

if defined?(Rails) && Rails::VERSION::MAJOR == 3

  require 'rails-i18n-inflector/railtie'

else

  #require 'action_view' if not defined?(ActionView::Base)

  ActionController::Base.send(:extend,  I18n::Inflector::Rails::ClassMethods)
  ActionController::Base.send(:include, I18n::Inflector::Rails::InstanceMethods)
  ActionController::Base.send(:include, I18n::Inflector::Rails::InflectedTranslate)

end

module I18n
  module Inflector
    module Rails

      # @private
      DEVELOPER   = 'Paweł Wilk'
      # @private
      EMAIL       = 'pw@gnu.org'
      # @private
      VERSION     = '0.0.1'
      # @private
      NAME        = 'rails-i18n-inflector'
      # @private
      SUMMARY     = 'I18n Inflector bindings for Rails'
      # @private
      URL         = 'https://rubygems.org/gems/rails-i18n-inflector/'
      # @private
      DESCRIPTION = 'This library provides I18n Inflector module bindings for Rails.'

    end
  end
end
