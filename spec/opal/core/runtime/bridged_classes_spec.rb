require 'spec_helper'

%x{
  var bridge_class_demo = function(){};
  bridge_class_demo.prototype.$foo = function() { return "bar" };
}
class TopBridgedClassDemo < `bridge_class_demo`
  def some_bridged_method
    [1, 2, 3]
  end
end

describe "Bridged Classes" do
  describe "Passing native constructor to class keyword" do
    before do
      @bridged = ::TopBridgedClassDemo
      @instance = `new bridge_class_demo()`
    end

    it "should expose the given class at the top level scope" do
      @bridged.should be_kind_of(Class)
    end

    it "gives the class the correct name" do
      @bridged.name.should == "TopBridgedClassDemo"
    end

    it "should have all BasicObject methods defined" do
      @instance.should respond_to(:instance_eval)
      @bridged.new.should respond_to(:==)
    end

    it "should have all Object methods defined" do
      @instance.should respond_to(:class)
      @bridged.new.should respond_to(:singleton_class)
    end

    it "instances of class should be able to call native ruby methods" do
      @instance.foo.should == "bar"
      @bridged.new.foo.should == "bar"
    end

    it "allows new methods to be defined on the bridged prototype" do
      @instance.some_bridged_method.should == [1, 2, 3]
      @bridged.new.some_bridged_method.should == [1, 2, 3]
    end
  end

  describe ".instance_methdods" do
    it "should report methods for class" do
      Array.instance_methods(false).should include(:shift)
    end

    it "should not include methods donated from Object/Kernel" do
      Array.instance_methods(false).should_not include(:class)
    end

    it "should not include methods donated from BasicObject" do
      Array.instance_methods(false).should_not include(:__send__)
      Array.instance_methods(false).should_not include(:send)
    end
  end
end

class ModularizedBridgeClass
  def something
    'different module'
  end
end

%x{
  var bridge_class_demo_module = function(){};
  bridge_class_demo_module.prototype.$foo = function() { return "foobar" };
}

module BridgeModule
  class ModularizedBridgeClass < `bridge_class_demo_module`
    def some_bridged_method
      [4, 5, 6]
    end
  end
end

describe 'Bridged classes in different modules' do
  before do
    @bridged = BridgeModule::ModularizedBridgeClass
    @instance = `new bridge_class_demo_module()`
  end
  
  it "should expose the given class not at the top level scope" do
    @bridged.should be_kind_of(Class)
  end
  
  it 'should not disturb an existing class at the top level scope' do
    ModularizedBridgeClass.new.something.should == 'different module'
  end

  it "gives the class the correct name" do
    @bridged.name.should == "BridgeModule::ModularizedBridgeClass"
  end

  it "instances of class should be able to call native ruby methods" do
    @instance.foo.should == "foobar"
    @bridged.new.foo.should == "foobar"
  end

  it "allows new methods to be defined on the bridged prototype" do
    @instance.some_bridged_method.should == [4, 5, 6]
    @bridged.new.some_bridged_method.should == [4, 5, 6]
  end
end
