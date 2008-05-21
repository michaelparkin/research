require File.dirname(__FILE__) + '/../spec_helper'

describe UsageRecordsController do
  describe "route generation" do

    it "should map { :controller => 'usage_records', :action => 'index' } to /usage_records" do
      route_for(:controller => "usage_records", :action => "index").should == "/usage_records"
    end
  
    it "should map { :controller => 'usage_records', :action => 'new' } to /usage_records/new" do
      route_for(:controller => "usage_records", :action => "new").should == "/usage_records/new"
    end
  
    it "should map { :controller => 'usage_records', :action => 'show', :id => 1 } to /usage_records/1" do
      route_for(:controller => "usage_records", :action => "show", :id => 1).should == "/usage_records/1"
    end
  
    it "should map { :controller => 'usage_records', :action => 'edit', :id => 1 } to /usage_records/1/edit" do
      route_for(:controller => "usage_records", :action => "edit", :id => 1).should == "/usage_records/1/edit"
    end
  
    it "should map { :controller => 'usage_records', :action => 'update', :id => 1} to /usage_records/1" do
      route_for(:controller => "usage_records", :action => "update", :id => 1).should == "/usage_records/1"
    end
  
    it "should map { :controller => 'usage_records', :action => 'destroy', :id => 1} to /usage_records/1" do
      route_for(:controller => "usage_records", :action => "destroy", :id => 1).should == "/usage_records/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'usage_records', action => 'index' } from GET /usage_records" do
      params_from(:get, "/usage_records").should == {:controller => "usage_records", :action => "index"}
    end
  
    it "should generate params { :controller => 'usage_records', action => 'new' } from GET /usage_records/new" do
      params_from(:get, "/usage_records/new").should == {:controller => "usage_records", :action => "new"}
    end
  
    it "should generate params { :controller => 'usage_records', action => 'create' } from POST /usage_records" do
      params_from(:post, "/usage_records").should == {:controller => "usage_records", :action => "create"}
    end
  
    it "should generate params { :controller => 'usage_records', action => 'show', id => '1' } from GET /usage_records/1" do
      params_from(:get, "/usage_records/1").should == {:controller => "usage_records", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'usage_records', action => 'edit', id => '1' } from GET /usage_records/1;edit" do
      params_from(:get, "/usage_records/1/edit").should == {:controller => "usage_records", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'usage_records', action => 'update', id => '1' } from PUT /usage_records/1" do
      params_from(:put, "/usage_records/1").should == {:controller => "usage_records", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'usage_records', action => 'destroy', id => '1' } from DELETE /usage_records/1" do
      params_from(:delete, "/usage_records/1").should == {:controller => "usage_records", :action => "destroy", :id => "1"}
    end
  end
end