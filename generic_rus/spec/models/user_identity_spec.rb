require File.dirname(__FILE__) + '/../spec_helper'

describe UserIdentity do
    
  def valid_user_identity_attributes
    {
      :local_user_identity => 'test local user identity',
      :global_user_name => 'test global user name',
      :usage_record => Factory.usage_record
    }
  end
  
  before(:each) do
    @user_identity = UserIdentity.new
  end

  it "should be valid" do
    @user_identity.attributes = valid_user_identity_attributes
    @user_identity.should be_valid
  end
  
  it "should be valid without local user identity" do
    @user_identity.attributes = valid_user_identity_attributes.except(:local_user_identity)
    @user_identity.should be_valid
  end
  
  it "should be valid without global user name" do
    @user_identity.attributes = valid_user_identity_attributes.except(:global_user_name)
    @user_identity.should be_valid
  end
  
  it "should be valid without both local user identity and global user name" do
    @user_identity.attributes = valid_user_identity_attributes.except(:local_user_identity).except(:global_user_name)
    @user_identity.should be_valid
  end
  
  it "should not be valid without usage record" do
    @user_identity.attributes = valid_user_identity_attributes.except(:usage_record)
    @user_identity.should_not be_valid
  end
  
end

describe UserIdentity, ".get_all" do
    
  def key_info # a hash
    {
      :key_issuer_serial => 'test key issuer serial',
      :key_name => 'test_key_name',
      :key_ski => 'test_ski',
      :key_certificate => 'test_key_certificate'
    }
  end
  
  def user_identities # an array of hashes
    [
      { :local_user_identity => 'test local user identity', 
        :global_user_name => 'test global user name', 
        :key_info => key_info
      },
      { :local_user_identity => 'test local user identity', 
        :global_user_name => 'test global user name', 
        :key_info => key_info
      }
    ]
  end
  
  before(:each) do
    @usage_record = Factory.usage_record
  end
  
  it "should not create objects if user identities are empty" do
    UserIdentity.get_all( @usage_record, [] ).should be_nil
  end
  
  it "should not create objects if user identities are nil" do
    UserIdentity.get_all( @usage_record, nil ).should be_nil
  end
  
  it "should not touch database if array is empty" do
    user_idents = UserIdentity.get_all( @usage_record, [] )

    lambda { 
      @usage_record.user_identities = user_idents unless user_idents.nil?
    }.should_not change( UserIdentity, :count )
    
    lambda { 
      @usage_record.user_identities = user_idents unless user_idents.nil?
    }.should_not change( @usage_record.user_identities, :count )
  end
  
  it "should not touch database if array is nil" do
    user_idents = UserIdentity.get_all( @usage_record, nil )
    
    lambda { 
      @usage_record.user_identities = user_idents unless user_idents.nil?
    }.should_not change( UserIdentity, :count )
    
    lambda { 
      @usage_record.user_identities = user_idents unless user_idents.nil?
    }.should_not change( @usage_record.user_identities, :count )
  end
  
  it "should not touch database without assigning to usage record" do
    lambda { 
      UserIdentity.get_all( @usage_record, user_identities )
    }.should_not change( UserIdentity, :count )
    
    lambda { 
      UserIdentity.get_all( @usage_record, user_identities )
    }.should_not change( @usage_record.user_identities, :count )
  end
    
  it "should increase number of user identities in database" do
    lambda { 
      @usage_record.user_identities = UserIdentity.get_all( @usage_record, user_identities )    
    }.should change( UserIdentity, :count ).by( 2 )    
  end
  
  it "should assign key info to user identity " do    
    user_idents = UserIdentity.get_all( @usage_record, user_identities )
    user_idents.should_not be_nil # just a check
    user_idents.each { |user_identity| user_identity.key_info.should_not be_nil }
  end
  
  it "should increase number of key infos in database" do
    lambda { 
      @usage_record.user_identities = UserIdentity.get_all( @usage_record, user_identities )
    }.should change( KeyInfo, :count ).by( 2 )
  end
  
  it "should not increase number of key infos in database if they aren't present" do
    changed_user_identities = user_identities.each { |entry| entry.delete :key_info }
    lambda { 
      @usage_record.user_identities = UserIdentity.get_all( @usage_record, changed_user_identities )
    }.should_not change( KeyInfo, :count )
  end
  
  it "should not assign key infos to user identities if they aren't present" do
    changed_user_identities = user_identities.each { |entry| entry.delete :key_info }
    user_identities = UserIdentity.get_all( @usage_record, changed_user_identities )
    user_identities.should_not be_nil # just a check
    user_identities.each { |user_identity| user_identity.key_info.should be_nil }
  end
  
end

