# openfire_room_api

a ruby client for openfire's room_service api

## Installation

In your Gemfile

  gem "openfire_room_api"

## Usage

create a new roomservice object

  api = OpenfireApi::RoomService.new(:url => "http://localhost:9090/", :secret => "BIGSECRET")

create a new room

  api.add_room!(:roomname => "room", :jid => "jid", :subdomain => "groupchat")

delete a room

  api.delete_room!(:roomname => "room", :subdomain => "groupchat")
