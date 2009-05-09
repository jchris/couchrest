require File.dirname(__FILE__) + '/../../spec_helper'
require 'couchrest/helper/streamer'

describe CouchRest::Streamer do
  before(:all) do
    @db = reset_test_db!
    @streamer = CouchRest::Streamer.new(@db)
    @docs = (1..1000).collect{|i| {:integer => i, :string => i.to_s}}
    @db.bulk_save(@docs)
  end
  
  it "should yield each row in a view" do
    count = 0
    sum = 0
    @streamer.view("_all_docs") do |row|
      count += 1
    end
    count.should == 1001
  end
  
end