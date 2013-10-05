require 'spec_helper'

describe "Room Service" do

  before :all do
    @room_service = OpenfireApi::RoomService.new(:url => "http://fakehost.int:2323/", :secret => "bigsecret")
  end

  it "should build query urls" do
    url = @room_service.send(:build_query_uri)
    url.to_s.should == "http://fakehost.int:2323/plugins/roomService/roomservice"
  end

  it "should build query params" do
    params = @room_service.send(:build_query_params, :type => :add, :roomname => "room", :subdomain => "groupchat")
    params.should include("type=add")
    params.should include("roomname=room")
    params.should include("subdomain=groupchat")
    params.should include("secret=bigsecret")
  end

  it "should build queries" do
    url = @room_service.send(:build_query, :type => :add, :roomname => "room", :subdomain => "groupchat")
    url.should include("http://fakehost.int:2323/plugins/roomService/roomservice?")
    url.should include("type=add")
    url.should include("roomname=room")
    url.should include("subdomain=groupchat")
    url.should include("secret=bigsecret")
  end

  it "should submit requests" do
    FakeWeb.register_uri(:get, "http://fakehost.int:2323/plugins/roomService/roomservice?type=add&roomname=room&subdomain=groupchat&secret=bigsecret", :body => "<result>ok</result>")
    @room_service.send(:submit_request, :type => :add, :roomname => "room", :subdomain => "groupchat").should == true
  end

  it "should add rooms" do
    FakeWeb.register_uri(:get, "http://fakehost.int:2323/plugins/roomService/roomservice?type=add&roomname=room&subdomain=groupchat&secret=bigsecret", :body => "<result>ok</result>")
    @room_service.add_room!(:roomname => "room", :subdomain => "groupchat").should == true
  end

  it "should delete rooms" do
    FakeWeb.register_uri(:get, "http://fakehost.int:2323/plugins/roomService/roomservice?type=delete&roomname=room&subdomain=groupchat&secret=bigsecret", :body => "<result>ok</result>")
    @room_service.delete_room!(:roomname => "room", :subdomain => "groupchat").should == true
  end

  it "should handle the error: room service disabled" do
    FakeWeb.register_uri(:get, "http://fakehost.int:2323/plugins/roomService/roomservice?roomname=room1&type=add&secret=bigsecret", :body => "<error>RoomServiceDisabled</error>")
    lambda{ @room_service.add_room!(:roomname => "room1") }.should raise_error(OpenfireApi::RoomService::RoomServiceDisabledException)
  end

  it "should handle the error: request not authorized" do
    FakeWeb.register_uri(:get, "http://fakehost.int:2323/plugins/roomService/roomservice?roomname=room1&type=add&secret=bigsecret", :body => "<error>RequestNotAuthorised</error>")
    lambda{ @room_service.add_room!(:roomname => "room1") }.should raise_error(OpenfireApi::RoomService::RequestNotAuthorisedException)
  end

  it "should handle the error: not allowed" do
    FakeWeb.register_uri(:get, "http://fakehost.int:2323/plugins/roomService/roomservice?roomname=room1&type=add&secret=bigsecret", :body => "<error>NotAllowedException</error>")
    lambda{ @room_service.add_room!(:roomname => "room1") }.should raise_error(OpenfireApi::RoomService::NotAllowedException)
  end

  it "should handle the error: illegal argument" do
    FakeWeb.register_uri(:get, "http://fakehost.int:2323/plugins/roomService/roomservice?roomname=room1&type=add&secret=bigsecret", :body => "<error>IllegalArgumentException</error>")
    lambda{ @room_service.add_room!(:roomname => "room1") }.should raise_error(OpenfireApi::RoomService::IllegalArgumentException)
  end

end

