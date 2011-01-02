# encoding: utf-8

require 'i18n-inflector'
require 'rails-i18n-inflector/errors.rb'
require 'rails-i18n-inflector/inflector.rb'

require 'action_controller' if not defined?(ActionController::Base)
require 'action_view'       if not defined?(ActionView::Base)

# Add methods to assign attribute readers to inflection kinds
ActionController::Base.send(:extend,  I18n::Inflector::Rails::ClassMethods)
ActionController::Base.send(:include, I18n::Inflector::Rails::InstanceMethods)

# Alternate translate() and t() in common contexts.
ActionView::Helpers::TranslationHelper.send(:include, I18n::Inflector::Rails::Translate)

module I18n
  module Backend
    module Inflector
      module Rails

        # @private
        DEVELOPER   = 'Paweł Wilk'
        # @private
        EMAIL       = 'pw@gnu.org'
        # @private
        VERSION     = '1.0.0'
        # @private
        NAME        = 'rails-i18n-inflector'
        # @private
        SUMMARY     = 'I18n Inflector bindings for Rails (Action Pack)'
        # @private
        URL         = 'https://rubygems.org/gems/rails-i18n-inflector/'
        # @private
        DESCRIPTION = 'This library provides I18n Inflector module bindings for Rails.'

      end
    end
  end
end

