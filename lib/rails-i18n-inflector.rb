# encoding: utf-8

require 'i18n-inflector'
require 'rails-i18n-inflector/version'
require 'rails-i18n-inflector/errors'
require 'rails-i18n-inflector/inflector'

if defined? Rails::Engine

  require 'rails-i18n-inflector/railtie'

else

  require 'action_controller' if not defined? ActionController::Base
  ActionController::Base.send(:extend,  I18n::Inflector::Rails::ClassMethods)
  ActionController::Base.send(:include, I18n::Inflector::Rails::InstanceMethods)
  ActionController::Base.send(:include, I18n::Inflector::Rails::InflectedTranslate)

end
