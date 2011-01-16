# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains I18n::Inflector::Rails::AdditionalOptions module,
# which extends I18n::Inflector::InflectionOptions so new switches controlling
# inflector's behavior are available.

module I18n
  module Inflector
    module Rails
      
      # This module adds options to {I18n::Inflector::InflectionOptions}
      module AdditionalOptions

        # When this is set tu +true+ then
        # inflection works a bit slower but
        # checks whether any method exists before
        # calling it. This switch is by default set
        # to +false+.
        # 
        # By turning this switch on you're sure that
        # there will be no +NameError+ (no method) exception
        # raised during translation.
        # 
        # Alternatively you can turn this locally,
        # for the specified translate call, by setting
        # one of the passed options:
        #   :inflector_verify_methods => true
        # 
        # @example Enabling methods verification
        #   I18n.inflector.options.verify_methods = true
        attr_writer :verify_methods

        # @private
        def verify_methods
          @verify_methods || false
        end 

        # @private
        def reset
          @verify_methods = false
          super
        end

      end
    end
  end
end
