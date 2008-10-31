require File.dirname(__FILE__) + '/spec_helper'

describe Roleful do
  attr_reader :klass, :object
  
  before(:each) do
    @klass = Class.new do
      attr_reader :role
      
      def initialize(role=:null)
        @role = role
      end
      
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
      klass.new(:admin).should be_admin
    end
    
    it "returns if not proper role" do
      klass.new.should_not be_admin
    end
  end
  
  describe "declaring role permissions" do
    before(:each) do
      klass.role(:admin) { can :view_foos }
    end
    
    it "works for declared roles" do
      object = klass.new(:admin)
      object.can_view_foos?.should be_true
    end
    
    it "works with built-in null object" do
      object = klass.new
      object.can_view_foos?.should be_false
    end
    
    it "does not add the same role more than once" do
      proc {
        klass.role(:admin) { can :view_bars }
      }.should_not change(klass::ROLES, :length)
    end
    
    it "does not add the same permission more than once to the same role" do
      proc {
        klass.role(:admin) { can :view_foos }
      }.should_not change(klass::ROLES[:admin].permissions, :length)
    end
    
    describe "#can?" do
      context "as object with role" do
        it "returns true or false depending on the permission" do
          object = klass.new(:admin)
          object.can?(:view_foos).should be_true
        end
      end
      
      context "for superuser role" do
        before(:each) do
          klass.role(:super_admin, :superuser => true)
        end
        
        it "returns true for existing permission" do
          klass.new(:super_admin).can?(:view_foos).should be_true
        end
        
        it "returns false when permission doesn't exist" do
          klass.new(:super_admin).can?(:eat_cheese).should be_false
        end
      end
      
      context "as object without role" do
        it "returns true or false depending on the permission" do
          object = klass.new
          object.can?(:view_foos).should be_false
        end
      end
    end
    
    context "for :null role" do
      it "returns false when permission exists elsewhere" do
        klass.new.can_view_foos?.should_not be
      end

      it "blows up when permission hasn't been declared" do
        proc {
          klass.new.can_eat_cheese?
        }.should raise_error(NoMethodError)
      end
      
      it "allows permissions to be declared" do
        klass.role(:null) { can :be_null }
        klass.new.can_be_null?.should be_true
      end
    end
    
    context "for :superuser role" do
      it "has all permissions" do
        klass.role(:super_admin, :superuser => true)
        object = klass.new(:super_admin)
        object.can_view_foos?.should be_true
      end
    end
  end
  
  describe "with instance-specific permissions" do
    before(:each) do
      klass.role :admin do
        can(:be_self) { |that| self == that }
        can(:be_two)  { |that| :two == that }
      end
    end
    
    it "takes a block" do
      object = klass.new(:admin)
      object.can_be_two?(:one).should be_false
      object.can_be_two?(:two).should be_true
    end
    
    context "as object with role" do
      it "binds self to instance" do
        object = klass.new(:admin)
        object.can_be_self?(object).should be_true
      end
      
      it "work with #can? calls" do
        object = klass.new(:admin)
        object.can?(:be_self, object).should be_true
        object.can?(:be_self, :other).should be_false
      end
    end
    
    context "as object without role" do
      it "binding self to instance" do
        object = klass.new
        object.can_be_self?(object).should be_false
      end
      
      it "work with #can? calls" do
        object = klass.new
        object.can?(:be_self, object).should be_false
        object.can?(:be_self, :other).should be_false
      end
    end
  end
  
  describe "declaring multiple roles at once" do
    before(:each) do
      klass.role :admin, :paid do
        can :have_access
      end
    end
    
    describe "passing multiple role names" do
      it "adds permissions to each role" do
        klass.new(:admin).can_have_access?.should be_true
        klass.new(:paid).can_have_access?.should be_true
      end
      
      it "doesn't give permissions to null user" do
        klass.new.can_have_access?.should be_false        
      end
    end
    
    describe "with :all option" do
      before(:each) do
        klass.role(:all) { can :do_anything }
      end
      
      it "adds permissions to all non-null roles" do
        klass.new(:admin).can_do_anything?.should be_true
        klass.new(:paid).can_do_anything?.should be_true
      end
      
      it "doesn't add permissions to null role" do
        klass.new.can_do_anything?.should be_false
      end
    end
  end
  
  describe "having multiple roles" do
    before(:each) do
      klass.role(:foo) { can :be_foo }
      klass.role(:bar) { can :be_bar }
    end
    
    it "returns true for all role predicate helpers" do
      klass.new([:foo, :bar]).should be_foo
      klass.new([:foo, :bar]).should be_bar
    end
    
    it "grants permissions of all roles" do
      klass.new([:foo, :bar]).can_be_foo?.should be_true
      klass.new([:foo, :bar]).can_be_bar?.should be_true
    end
    
    it "handles invalid roles in collection" do
      klass.new([:fizz, :foo, :bar]).can_be_foo?.should be_true
    end
  end
  
  describe "temporary role contexts" do
    before(:each) do
      klass.role(:awesome) do
        can :be_awesome
      end
    end
    
    it "allows an object to have a role within a block" do
      object = klass.new
      object.can?(:be_awesome).should be_false
      object.with_role(:awesome) { object.can?(:be_awesome).should be_true }
      object.can?(:be_awesome).should be_false
    end
  end
end