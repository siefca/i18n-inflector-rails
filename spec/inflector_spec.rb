require 'spec_helper'

class ApplicationController < ActionController::Base;       end
class InflectedTranslateController < ApplicationController; end

describe ApplicationController do

  before do

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
                                                      :person => {
                                                        :i   => 'I',
                                                        :you => 'You',
                                                        :it  => 'It'}
                                       }   })
   I18n.backend.store_translations(:xx, 'welcome' => 'Dear @{f:Lady|m:Sir|n:You|All}!')
   I18n.backend.store_translations(:xx, 'to_be'   => 'Oh @{i:I am|you:You are|it:It is}')

  end
  
  describe ".inflection_method" do
    
    before do
      class AnotherController < InflectedTranslateController; end
    end

    it "should be albe to assign a mehtod to the inflection kind" do
      lambda{AnotherController.inflection_method(:users_gender => :gender)}.should_not raise_error
    end
    
    it "should be albe to accept single Symbol argument" do
      lambda{AnotherController.inflection_method(:time)}.should_not raise_error
    end

    it "should be albe to accept single String argument" do
      lambda{AnotherController.inflection_method('time')}.should_not raise_error
    end

    it "should be albe to accept Array<Symbol> argument" do
      lambda{AnotherController.inflection_method([:time])}.should_not raise_error
    end

    it "should be albe to assign a mehtod to the inflection kind with proc" do
      lambda{AnotherController.inflection_method(:users_gender => :gender){|a,b,c,d,e| :m} }.should_not raise_error
      lambda{AnotherController.inflection_method(:time){|a,b,c,d,e| :m} }.should_not raise_error
    end

    it "should raise an error when method name is wrong" do
      lambda{AnotherController.inflection_method}.should                  raise_error
      lambda{AnotherController.inflection_method(nil => :blabla)}.should  raise_error
      lambda{AnotherController.inflection_method(:blabla => nil)}.should  raise_error
      lambda{AnotherController.inflection_method({''=>''})}.should        raise_error
      lambda{AnotherController.inflection_method(nil => nil)}.should      raise_error
      lambda{AnotherController.inflection_method(nil)}.should             raise_error
      lambda{AnotherController.inflection_method([nil])}.should           raise_error
      lambda{AnotherController.inflection_method([''])}.should            raise_error
      lambda{AnotherController.inflection_method([])}.should              raise_error
      lambda{AnotherController.inflection_method({})}.should              raise_error
    end

  end

  describe ".no_inflection_method" do
    
    before do
      class AnotherController < InflectedTranslateController; end
    end

    it "should be albe to spit a mehtod of the inflection kind" do
      lambda{AnotherController.no_inflection_method(:users_gender)}.should_not raise_error
    end
    
    it "should be albe to accept single Symbol argument" do
      lambda{AnotherController.no_inflection_method(:time)}.should_not raise_error
    end

    it "should be albe to accept single String argument" do
      lambda{AnotherController.no_inflection_method('time')}.should_not raise_error
    end

    it "should be albe to accept Array<Symbol> argument" do
      lambda{AnotherController.no_inflection_method([:time])}.should_not raise_error
    end

    it "should raise an error when method name is wrong" do
      lambda{AnotherController.no_inflection_method}.should                  raise_error
      lambda{AnotherController.no_inflection_method(nil)}.should             raise_error
      lambda{AnotherController.no_inflection_method([nil])}.should           raise_error
      lambda{AnotherController.no_inflection_method([''])}.should            raise_error
      lambda{AnotherController.no_inflection_method([])}.should              raise_error
      lambda{AnotherController.no_inflection_method({})}.should              raise_error
    end

  end

  describe ".i18n_inflector_methods" do

    before do
      InflectedTranslateController.inflection_method(:users_gender => :gender)
      InflectedTranslateController.inflection_method(:time) 
      @expected_hash = {:users_gender=>{:kind=>:gender, :proc=>nil},
                        :time=>{:kind=>:time, :proc=>nil}}   
    end

    it "should be callable" do
      lambda{InflectedTranslateController.i18n_inflector_methods}.should_not raise_error
    end

    it "should be able to read methods assigned to inflection kinds" do
      InflectedTranslateController.i18n_inflector_methods.should ==  @expected_hash
    end

  end
  
  describe "controller instance methods" do
  
    before do

      class InflectedTranslateController
        inflection_method :users_gender => :gender
        def users_gender;     :m                    end
        def time;             :present              end
        def translated_male;  translate('welcome')  end
        def t_male;           t('welcome')          end
      end

      class InflectedLambdedController < InflectedTranslateController
        inflection_method(:person) {:it}
        def person; :you                            end
        def translated_person;  translate('to_be')  end
      end

      class InflectedLambdedPrimController < InflectedLambdedController
        inflection_method :person
      end

      @controller             = InflectedTranslateController.new
      @person_controller      = InflectedLambdedController.new
      @personprim_controller  = InflectedLambdedPrimController.new
      
      @expected_hash = {:users_gender=>{:kind=>:gender, :proc=>nil},
                        :time=>{:kind=>:time, :proc=>nil}}

    end

    describe "#i18n_inflector_methods" do

      it "should be able to read methods assigned to inflection kinds" do
        @controller.i18n_inflector_methods.should == @expected_hash
      end

    end

    describe "#translate" do

      it "should translate using inflection patterns and pick up the right value" do
        @controller.translated_male.should == 'Dear Sir!'
      end

      it "should make use of blocks if assigned to inflection methods" do
        @person_controller.translated_person.should == 'Oh It is'
      end

      it "should make use of inherited inflection method assignments" do
        @person_controller.translated_male.should == 'Dear Sir!'
      end

      it "should make use of overriden inflection method assignments" do
        @personprim_controller.translated_person.should == 'Oh You are'
      end
      
      it "should make use of disabled inflection method assignments" do
        InflectedLambdedPrimController.no_inflection_method :person
        @personprim_controller.translated_person.should == 'Oh '
        @person_controller.translated_person.should == 'Oh It is'
      end

    end
    
    describe "#t" do
      
      it "should call translate" do
        @controller.t_male.should == 'Dear Sir!'
      end
      
    end

  end

end
