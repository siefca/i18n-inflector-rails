# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains I18n::Backend::Inflector::Rails module,
# which extends ActionView::Helpers::TranslationHelper
# by adding the ability to interpolate patterns containing
# inflection tokens defined in translation data.

module I18n
  module Inflector
    module Rails
  
      # This module contains instance methods for ActionController.
      module InstanceMethods
  
        # This method calls the class method {I18n::Inflector::Rails::ClassMethods#i18n_inflector_methods}
        def i18n_inflector_methods
          self.class.i18n_inflector_methods
        end

        # @private
        def self.included(base)
          base.helper_method(:i18n_inflector_methods)
        end
  
      end # instance methods
  
      # This module contains class methods for ActionController.
      module ClassMethods
  
        # This method reads the internal Hash +i18n_inflector_methods+ containing registered
        # inflection methods and the assigned kinds. It also reads any methods
        # assignments that were defined earlier in the inheritance path and
        # merges them with current results; the most current entries will
        # override the entries defined before.
        # 
        # @api public
        # @return [Hash] the Hash containing assignments made by using {inflection_method}
        def i18n_inflector_methods
          prev = superclass.respond_to?(:i18n_inflector_methods) ? superclass.i18n_inflector_methods : {}
          return @i18n_inflector_methods.nil? ? prev : prev.merge(@i18n_inflector_methods)
        end

        # This method allows to assign methods (typically attribute readers)
        # to inflection kinds that are defined in translation files and
        # supported by {I18n::Inflector} module. Methods registered like that
        # will be tracked when {translate} is used and their returning values will be
        # passed as inflection options along with assigned kinds. If the kind is not
        # given then method assumes that the name of a kind is the same as the given
        # name of a method.
        # 
        # @api public
        # @note Any added method will become helper!
        # @raise [I18n::Inflector::Rails::BadInflectionMethod] when name or value is malformed
        # @param [Hash,Array,Symbol,String] assignment the methods and inflection kinds assigned to them
        # @return [void]
        # @yield [method, kind, value, caller] optional block that will be executed
        #   each time the registered method is called. Its result will replace
        #   the original returning value of the method that is assigned to a kind
        # @yieldparam [Symbol] method the name of an assigned method
        # @yieldparam [Symbol] kind the name of an inflection kind assigned to that +method+
        # @yieldparam [Object] value the original result of calling the +method+ that will be assigned to a +kind+ as a token
        # @yieldparam [Object] caller the object that made a call to {translate} method
        # @yieldreturn [String] the new +value+ (token name) that will be assigned to a +kind+
        def inflection_method(assignment, &block)
          if assignment.is_a?(Array)
            new_assignment = {}
            assignment.flatten.each{|e| new_assignment[e]=new_assignment}
            assignment = new_assignment
          elsif (assignment.is_a?(String) || assignment.is_a?(Symbol))
            assignment = { assignment => assignment }
          end

          if (assignment.nil? || !assignment.is_a?(Hash) || assignment.empty?)
            raise I18n::Inflector::Rails::BadInflectionMethod.new(assignment)
          end

          @i18n_inflector_methods ||= {}
          assignment.each_pair do |k,v|
            k = k.to_s
            v = v.to_s
            if (k.empty? || v.empty?)
              raise I18n::Inflector::Rails::BadInflectionMethod.new("#{k.inspect} => #{v.inspect}")
            end
            k = k.to_sym
            helper_method(k)
            @i18n_inflector_methods[k]      ||= {}
            @i18n_inflector_methods[k][:kind] = v.to_sym
            @i18n_inflector_methods[k][:proc] = block
          end
        end
        alias_method :inflection_methods, :inflection_method

        # This method allows to remove methods from sets
        # created using {inflection_method}. It is useful
        # when there is a need to break inheritance in some controller,
        # but a method has been marked as inflection method by
        # a parrent class.
        # 
        # @api public
        # @raise [I18n::Inflector::Rails::BadInflectionMethod] when name or value is malformed
        # @param [Array] names the method names that should be marked as removed in this controller
        # @return [void]
        def no_inflection_method(*names)
          names = names.flatten
          if (names.nil? || names.empty?)
            raise I18n::Inflector::Rails::BadInflectionMethod.new(names)
          end
          @i18n_inflector_methods ||= {}
          names.each do |meth|
            unless (meth.is_a?(Symbol) || meth.is_a?(String))
              raise I18n::Inflector::Rails::BadInflectionMethod.new(meth)
            end
            meth = meth.to_s
            raise I18n::Inflector::Rails::BadInflectionMethod.new(meth) if meth.empty?
            @i18n_inflector_methods[meth.to_sym] = nil
           end
        end
        alias_method :no_inflection_methods, :no_inflection_method

      end # class methods
  
      # This module contains a version of {translate} method that
      # tries to use +i18n_inflector_methods+ available in the current context.
      # The method from this module will wrap the
      # {ActionView::Helpers::TranslationHelper#translate} method.
      module InflectedTranslate
  
        # This method tries to feed itself with the data coming
        # from +i18n_inflector_methods+ available in the current context.
        # The data from the last method should contain options
        # of inflection pairs (<tt>kind => value</tt>) that will
        # be passed to {I18n::Backend::Inflector#translate} through
        # {ActionView::Helpers::TranslationHelper#translate}.
        # 
        # @api public
        # @param [String] key translation key
        # @param [Hash] options a set of options to pass to the
        #   translation routines
        # @return [String] the translated string with inflection patterns
        #   interpolated
        def translate(*args)
          opts_present  = args.last.is_a?(Hash)
          if opts_present
            options = args.last
            test_locale = options[:locale]
          else
            options = {}
          end
          test_locale ||= I18n.locale
          inflector = I18n.backend.inflector

          # use standard translate if the locale is not supported
          return super unless inflector.inflected_locale?(test_locale)

          # read switch
          verifies = options.delete(:inflector_verify_methods)
          verifies = verifies.nil? ? inflector.options.verify_methods : verifies

          # collect inflection variables that are present in this context
          subopts  = t_prepare_inflection_options(inflector, verifies)
  
          # jump to original translate if no variables are present
          return super if subopts.empty?

          # pass options
          args.pop if opts_present
          args.push subopts.merge(options)
          super
        end

        alias_method :t, :translate
  
        protected
  
        # This method tries to read +i18n_inflector_methods+ available in the current context.
        # 
        # @return [Hash] the inflection options (<tt>kind => value</tt>)
        def t_prepare_inflection_options(inflector, verifies)
          subopts = {}
          return subopts if (verifies && !respond_to?(:i18n_inflector_methods))
          i18n_inflector_methods.each_pair do |m, obj|
            next if obj.nil?                        # method registered but disabled from usage
            next if (verifies && !respond_to?(m))   # verify_methods enabled
            value = method(m).call
            proca = obj[:proc]
            kind  = obj[:kind]
            value = proca.call(m, kind, value, self) unless proca.nil?
            subopts[kind] = value.to_s
          end
          return subopts
        end
        
      end # Translate
  
    end
  end
end
