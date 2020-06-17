# encoding: utf-8
require_relative "../spec_helper"

describe LogStash::Outputs::Mongodb, :integration => true do

  let(:uri)        { 'mongodb://localhost:27017' }
  let(:database)   { 'logstash' }
  let(:collection) { 'logs' }
  let(:uuid)       { SecureRandom.uuid }

  let(:config) do
    { "uri" => uri, "database" => database,
      "collection" => collection, "isodate" => true }
  end

  describe "#send" do

    subject { LogStash::Outputs::Mongodb.new(config) }

    let(:properties) { { "message" => "This is a message!",
                         "uuid" => uuid, "number" => BigDecimal.new("4321.1234"),
                         "utf8" => "żółć", "int" => 42,
                         "arry" => [42, "string", 4321.1234]} }
    let(:event)      { LogStash::Event.new(properties) }

    let(:properties_bson_size_exceeded) { { "message" => "This is a huge message!"*800000,
                         "uuid" => uuid, "number" => BigDecimal.new("4321.1234"),
                         "utf8" => "żółć", "int" => 42,
                         "arry" => [42, "string", 4321.1234]} }
    let(:event_bson_size_exceeded)      { LogStash::Event.new(properties_bson_size_exceeded) }

    before(:each) do
      subject.register
    end

    it "should send the event to the database" do
      subject.receive(event)
      expect(subject).to have_received(event)
    end

    it "should skip insertion of the event to the database when bson limit size is exceeded" do
      subject.receive(event_bson_size_exceeded)
      expect(subject).to not_have_received(event_bson_size_exceeded)
    end
  end

end
