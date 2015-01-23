# rspec spec/tests/request_spec.rb

describe "Test request" do
  it "should be successful" do
    expect(CPS.unirest).to eq "OK"
  end
end