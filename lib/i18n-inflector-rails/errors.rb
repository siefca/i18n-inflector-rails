# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2010 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains error reporting classes for I18n::Backend::Inflector module.

module I18n
  module Inflector
    module Rails
      
      class BadInflectionMethod < I18n::ArgumentError
        attr_reader :assignment
        def initialize(assignment)
          @assignment = assignment
          super "The given assignment is invalid: #{assignment}"
        end
      end
      
    end
  end
end
