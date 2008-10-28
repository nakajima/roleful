require File.dirname(__FILE__) + '/spec_helper'

describe Roleful do
  attr_reader :klass, :object
  
  before(:each) do
    @klass = Class.new do
      include Roleful
    end
  end
  
  it "adds ROLES to class" do
    proc {
      klass::ROLES
    }.should_not raise_error
  end
  
  it "has :null role by default" do
    klass::ROLES[:null].should_not be_nil
  end
  
  it "allows roles to be added" do
    klass.role :admin
    klass::ROLES[:admin].should_not be_nil
  end
  
  describe "role predicate helpers" do
    before(:each) do
      klass.role :admin
    end
    
    it "return true if proper role" do
      admin = klass.new
      stub(admin).role { :admin }
      admin.should be_admin
    end
    
    it "returns if not proper role" do
      non_admin = klass.new
      non_admin.should_not be_admin
    end
  end
  
  describe "delegating permissions to role" do
    before(:each) do
      klass.role(:admin) { can :view_foos }
    end
    
    it "works for declared roles" do
      stub(object = klass.new).role { :admin }
      object.can_view_foos?.should be_true
    end
    
    describe ":null role" do
      it "returns false when permission exists elsewhere" do
        klass.new.can_view_foos?.should be_false
      end

      it "blows up when permission hasn't been declared" do
        proc {
          klass.new.can_eat_cheese?.should be_false
        }.should raise_error(NoMethodError)
      end
    end
  end
end