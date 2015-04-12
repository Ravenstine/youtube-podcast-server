require_relative "../environment"
Bundler.require :test
require 'webmock/rspec'

describe "#to_podcast" do
  before :each do 
    WebMock.reset!
  end
  context "a valid playlist id is provided" do
    it "returns an xml feed" do
      playlist = Playlist.new "123456789"

      channel_info = {"kind"=>"youtube#playlistListResponse",
         "etag"=>"\"someetag\"",
         "pageInfo"=>{"totalResults"=>1, "resultsPerPage"=>1},
         "items"=>
          [{"kind"=>"youtube#playlist",
            "etag"=>"\"someetag\"",
            "id"=>"123456789",
            "snippet"=>
             {"publishedAt"=>"2015-01-15T21:43:20.000Z",
              "channelId"=>"87654321",
              "title"=>"TestPlaylist",
              "description"=>"",
              "thumbnails"=>
               {"default"=>{"url"=>"https://i.ytimg.com/vi/somethumbnail/default.jpg", "width"=>120, "height"=>90},
              "channelTitle"=>"TestChannel",
              "localized"=>{"title"=>"TestPlaylist", "description"=>""}
              }}}]}.to_json

      page_1_info = {"kind"=>"youtube#playlistItemListResponse",
       "etag"=>"\"someetag\"",
       "pageInfo"=>{"totalResults"=>6, "resultsPerPage"=>3},
       "items"=>
        [{"kind"=>"youtube#playlistItem",
          "etag"=>"\"someetag\"",
          "id"=>"123456789",
          "contentDetails"=>{"videoId"=>"232626423"}},
         {"kind"=>"youtube#playlistItem",
          "etag"=>"\"someetag\"",
          "id"=>"123456789",
          "contentDetails"=>{"videoId"=>"58568569"}},
         {"kind"=>"youtube#playlistItem",
          "etag"=>"\"someetag\"",
          "id"=>"123456789",
          "contentDetails"=>{"videoId"=>"0789676754"}}
        ]}.to_json

      page_2_info = {"kind"=>"youtube#playlistItemListResponse",
       "etag"=>"\"someetag\"",
       "pageInfo"=>{"totalResults"=>6, "resultsPerPage"=>3},
       "items"=>
        [{"kind"=>"youtube#playlistItem",
          "etag"=>"\"someetag\"",
          "id"=>"123456789",
          "contentDetails"=>{"videoId"=>"23262446423"}},
         {"kind"=>"youtube#playlistItem",
          "etag"=>"\"someetag\"",
          "id"=>"123456789",
          "contentDetails"=>{"videoId"=>"58562228569"}},
         {"kind"=>"youtube#playlistItem",
          "etag"=>"\"someetag\"",
          "id"=>"123456789",
          "contentDetails"=>{"videoId"=>"0782229676754"}}
        ]}.to_json

      item_details = {"kind"=>"youtube#videoListResponse",
         "etag"=>"\"someetag\"",
         "items"=>
          [{"kind"=>"youtube#video",
            "etag"=>"\"someetag\"",
            "id"=>"someid",
            "snippet"=>
             {"publishedAt"=>"2015-01-15T22:00:55.000Z",
              "channelId"=>"somechannelid",
              "title"=>"Test video",
              "description"=>
               "This is a test description!",
              "thumbnails"=>
               {"default"=>{"url"=>"default.jpg", "width"=>120, "height"=>90},
                "medium"=>{"url"=>"mqdefault.jpg", "width"=>320, "height"=>180},
                "high"=>{"url"=>"hqdefault.jpg", "width"=>480, "height"=>360},
                "standard"=>{"url"=>"sddefault.jpg", "width"=>640, "height"=>480},
                "maxres"=>{"url"=>"maxresdefault.jpg", "width"=>1280, "height"=>720}},
              "channelTitle"=>"testchannel",
              "categoryId"=>"27",
              "liveBroadcastContent"=>"none"
                }}]}.to_json

      stub_request(:any, /https:\/\/www.googleapis.com\/youtube\/v3\/playlistItems\?.*part=snippet/)
        .to_return(body: channel_info)

      stub_request(:any, /https:\/\/www.googleapis.com\/youtube\/v3\/playlists\?.*part=snippet/)
        .to_return(body: channel_info)

      stub_request(:any, /https:\/\/www.googleapis.com\/youtube\/v3\/playlists\?.*part=contentDetails/)
        .to_return(body: page_1_info)

      stub_request(:any, /https:\/\/www.googleapis.com\/youtube\/v3\/playlistItems\?.*part=contentDetails/)
        .to_return(body: page_1_info)

      stub_request(:any, /https:\/\/www.googleapis.com\/youtube\/v3\/videos\?.*part=snippet/)
        .to_return(body: item_details)

      document = Nokogiri::XML(playlist.to_podcast)
      first_item = document.xpath("//rss//channel//item").first.to_s
      expect(first_item.include?("Test video")).to eq(true)
    end
  end



  context "a valid playlist id is provided" do
    it "returns nothing" do

      stub_request(:any, /.*/).to_return(body: {}.to_json)

      playlist = Playlist.new "123456789"

      expect(playlist.to_podcast).to eq(nil)

    end
  end



end