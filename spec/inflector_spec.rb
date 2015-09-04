require 'spec_helper'

class ApplicationController < ActionController::Base;       end
class InflectedTranslateController < ApplicationController; end
class InflectedStrictController    < ApplicationController; end

describe I18n.inflector.options.class do

  context "instance I18n.inflector.options" do

    it "should contain verify_methods switch" do
      expect(I18n.inflector.options).to respond_to :verify_methods
    end

    it "should have default value set to false" do
      expect(I18n.inflector.options.verify_methods).to eq(false)
    end

  end

end

describe ApplicationController do

  before do

    I18n.config.available_locales = :xx, :ns
    I18n.locale = :xx
    I18n.backend.store_translations(:xx, :i18n => { :inflections => {
                                                     :gender => {
                                                       :m => 'male',
                                                       :f => 'female',
                                                       :n => 'neuter',
                                                       :s => 'strange',
                                                       :masculine  => '@m',
                                                       :feminine   => '@f',
                                                       :neuter     => '@n',
                                                       :neutral    => '@neuter',
                                                       :default    => 'neutral' },
                                                      :time => {
                                                        :present  => 'present',
                                                        :past     => 'past',
                                                        :future   => 'future'},
                                                      :@gender => {
                                                        :m => 'male',
                                                        :f => 'female',
                                                        :d => 'dude',
                                                        :x => 'tester',
                                                        :n => 'neuter',
                                                        :default => 'n'},
                                                      :person => {
                                                        :i   => 'I',
                                                        :you => 'You',
                                                        :it  => 'It'},
                                                      :@person => {
                                                        :i   => 'I',
                                                        :you => 'You',
                                                        :it  => 'It'},
                                       }   })

   I18n.backend.store_translations(:ns, 'welcome'         => 'Dear @{f:Lady|m:Sir|n:You|All}!')
   I18n.backend.store_translations(:xx, 'welcome'         => 'Dear @{f:Lady|m:Sir|n:You|All}!')
   I18n.backend.store_translations(:xx, 'welcome_strict'  => 'Dear @gender{f:Lady|m:Sir|d:Dude|n:You|All}!')
   I18n.backend.store_translations(:xx, 'to_be'           => 'Oh @{i:I am|you:You are|it:It is}')
   I18n.backend.store_translations(:xx, 'to_be_strict'    => 'Oh @person{i:me|you:You are|it:It is}')
   I18n.backend.store_translations(:xx, 'hitime'          => '@{present,past,future:~}!')

  end

  describe ".inflection_method" do

    before do
      class AnotherController < InflectedTranslateController; end
    end

    it "should be albe to assign a mehtod to the inflection kind" do
      expect{AnotherController.inflection_method(:users_gender => :gender)}.not_to raise_error
    end

    it "should be albe to assign a mehtod to the strict inflection kind" do
      expect{AnotherController.inflection_method(:users_gender => :@gender)}.not_to raise_error
    end

    it "should be albe to accept single Symbol argument" do
      expect{AnotherController.inflection_method(:time)}.not_to raise_error
      expect{AnotherController.inflection_method(:@time)}.not_to raise_error
    end

    it "should be albe to accept single String argument" do
      expect{AnotherController.inflection_method('time')}.not_to raise_error
      expect{AnotherController.inflection_method('@time')}.not_to raise_error
    end

    it "should be albe to accept Array<Symbol> argument" do
      expect{AnotherController.inflection_method([:time])}.not_to raise_error
      expect{AnotherController.inflection_method([:@time])}.not_to raise_error
    end

    it "should raise an error when method name is wrong" do
      expect{AnotherController.inflection_method}.to                  raise_error
      expect{AnotherController.inflection_method(nil => :blabla)}.to  raise_error
      expect{AnotherController.inflection_method(:blabla => nil)}.to  raise_error
      expect{AnotherController.inflection_method(nil => :@blabla)}.to raise_error
      expect{AnotherController.inflection_method(:@blabla => nil)}.to raise_error
      expect{AnotherController.inflection_method(:"@")}.to            raise_error
      expect{AnotherController.inflection_method({''=>''})}.to        raise_error
      expect{AnotherController.inflection_method(nil => nil)}.to      raise_error
      expect{AnotherController.inflection_method(nil)}.to             raise_error
      expect{AnotherController.inflection_method([nil])}.to           raise_error
      expect{AnotherController.inflection_method([''])}.to            raise_error
      expect{AnotherController.inflection_method([])}.to              raise_error
      expect{AnotherController.inflection_method({})}.to              raise_error
    end

  end

  describe ".no_inflection_method" do

    before do
      class AnotherController < InflectedTranslateController; end
    end

    it "should be albe to split a mehtod of the inflection kind" do
      expect{AnotherController.no_inflection_method(:users_gender)}.not_to raise_error
    end

    it "should be albe to accept single Symbol argument" do
      expect{AnotherController.no_inflection_method(:time)}.not_to raise_error
      expect{AnotherController.no_inflection_method(:@time)}.not_to raise_error
    end

    it "should be albe to accept single String argument" do
      expect{AnotherController.no_inflection_method('time')}.not_to raise_error
      expect{AnotherController.no_inflection_method('@time')}.not_to raise_error
    end

    it "should be albe to accept Array<Symbol> argument" do
      expect{AnotherController.no_inflection_method([:time])}.not_to raise_error
      expect{AnotherController.no_inflection_method([:@time])}.not_to raise_error
    end

    it "should raise an error when method name is wrong" do
      expect{AnotherController.no_inflection_method}.to         raise_error
      expect{AnotherController.no_inflection_method(nil)}.to    raise_error
      expect{AnotherController.no_inflection_method([nil])}.to  raise_error
      expect{AnotherController.no_inflection_method(:"@")}.to   raise_error
      expect{AnotherController.no_inflection_method([''])}.to   raise_error
      expect{AnotherController.no_inflection_method([])}.to     raise_error
      expect{AnotherController.no_inflection_method({})}.to     raise_error
    end

  end

  describe ".no_inflection_kind" do

    before do
      class AnotherController < InflectedTranslateController; end
    end

    it "should be albe to spit a mehtod of the inflection kind" do
      expect{AnotherController.no_inflection_kind(:gender)}.not_to raise_error
      expect{AnotherController.no_inflection_kind(:@gender)}.not_to raise_error
    end

    it "should be albe to accept single Symbol argument" do
      expect{AnotherController.no_inflection_kind(:time)}.not_to raise_error
      expect{AnotherController.no_inflection_kind(:@time)}.not_to raise_error
    end

    it "should be albe to accept single String argument" do
      expect{AnotherController.no_inflection_kind('time')}.not_to raise_error
      expect{AnotherController.no_inflection_kind('@time')}.not_to raise_error
    end

    it "should be albe to accept Array<Symbol> argument" do
      expect{AnotherController.no_inflection_kind([:time])}.not_to raise_error
      expect{AnotherController.no_inflection_kind([:@time])}.not_to raise_error
    end

    it "should raise an error when method name is wrong" do
      expect{AnotherController.no_inflection_kind}.to        raise_error
      expect{AnotherController.no_inflection_kind(nil)}.to   raise_error
      expect{AnotherController.no_inflection_kind(:"@")}.to  raise_error
      expect{AnotherController.no_inflection_kind([nil])}.to raise_error
      expect{AnotherController.no_inflection_kind([''])}.to  raise_error
      expect{AnotherController.no_inflection_kind([])}.to    raise_error
      expect{AnotherController.no_inflection_kind({})}.to    raise_error
    end

  end

  describe ".i18n_inflector_kinds" do

    before do
      InflectedTranslateController.inflection_method(:users_gender => :gender)
      InflectedTranslateController.inflection_method(:time) 
      @expected_hash =  { :gender => :users_gender, :time   => :time }
    end

    it "should be callable" do
      expect{InflectedTranslateController.i18n_inflector_kinds}.not_to raise_error
    end

    it "should be able to read methods assigned to inflection kinds" do
      expect(InflectedTranslateController.i18n_inflector_kinds).to eq(@expected_hash)
    end

  end

  describe "controller instance methods" do

    before do

      class InflectedTranslateController
        def trn(*args); t(*args)          end
        def t_male; t('welcome')          end
        def users_gender; :m              end
        def time
          kind, locale = yield
          kind == :time ? :past : nil
        end
      end

      class InflectedStrictController
        inflection_method :@gender

        def gender; :m end
        def trn(*args);  translate(*args) end
      end

      class InflectedStrictOverrideController < InflectedTranslateController
        inflection_method :users_dude     => :@gender
        inflection_method :users_female   => :gender
        inflection_method :person_i       => :person

        no_inflection_method_for :@person

        def users_female; :f end
        def users_dude;   :d end
        def person_i;     :i end
      end

      class NomethodController < InflectedTranslateController
        inflection_method :nonexistent => :gender
      end

      class MethodDisabledController < InflectedTranslateController
        no_inflection_method :users_gender
      end

      @controller             = InflectedTranslateController.new
      @strict_controller      = InflectedStrictController.new
      @strict_over_controller = InflectedStrictOverrideController.new
      @disabled_controller    = MethodDisabledController.new
      @nomethod_controller    = NomethodController.new

    end

    describe "#i18n_inflector_kinds" do

      before do
        @expected_hash = {:gender => :users_gender, :time => :time }
      end

      it "should be able to read methods assigned to inflection kinds" do
        expect(@controller.i18n_inflector_kinds).to eq(@expected_hash)
      end

    end

    describe "#translate" do

      it "should translate using inflection patterns and pick up the right value" do
        expect(@controller.trn('welcome')).to eq('Dear Sir!')
        expect(@controller.trn('welcome_strict')).to eq('Dear Sir!')
        expect(@strict_controller.trn('welcome_strict')).to eq('Dear Sir!')
      end

      it "should make use of a block passed to inflection method" do
        expect(@controller.trn('hitime')).to eq('past!')
      end

      it "should make use of inherited inflection method assignments" do
        expect(@strict_over_controller.trn('hitime')).to eq('past!')
      end

      it "should make use of overriden inflection method assignments" do
        expect(@strict_over_controller.trn('welcome')).to eq('Dear Lady!')
      end

      it "should prioritize strict kinds when both inflection options are passed" do
        expect(@strict_over_controller.trn('welcome_strict')).to eq('Dear Dude!')
        expect(@strict_over_controller.trn('welcome')).to eq('Dear Lady!')
      end

      it "should use regular kind option when strict kind option is missing" do
        expect(@strict_over_controller.trn('to_be')).to eq('Oh I am')
        expect(@strict_over_controller.trn('to_be_strict')).to eq('Oh me')
      end

      it "should make use of disabled inflection method assignments" do
        expect(@disabled_controller.trn('welcome')).to eq('Dear You!')
      end

      it "should raise exception when method does not exists" do
        expect{@nomethod_controller.translated_male}.to raise_error(NameError)
      end

      it "should not raise when method does not exists and verify_methods is enabled" do
        expect{@nomethod_controller.trn('welcome', :inflector_verify_methods => true)}.not_to raise_error
        I18n.inflector.options.verify_methods = true
        expect{@nomethod_controller.trn('welcome')}.not_to raise_error
      end

      it "should translate with the :inflector_lazy_methods switch turned off" do
        expect(@strict_over_controller.trn('welcome', :inflector_lazy_methods => false)).to eq('Dear Lady!')
      end

      it "should omit pattern interpolation when locale is not inflected" do
        expect(@strict_over_controller.trn('welcome', :locale => :ns)).to eq('Dear !')
      end

    end

    describe "#t" do

      it "should call translate" do
        expect(@controller.t_male).to eq('Dear Sir!')
      end

    end

  end

end
