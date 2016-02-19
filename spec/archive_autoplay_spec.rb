require 'spec_helper'

describe "#main" do
  params = { query: "",
                  rows: 10,
                  file_dir: "/tmp/tmpy",
                  autoplay: true}
  
  it "recieves and empty query" do
    expect{ main params }.to output("Please add a search term:\n").to_stdout
  end
  context "No search query was given" do

  end
end
