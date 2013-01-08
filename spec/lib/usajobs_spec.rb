require 'spec_helper'

describe Usajobs do
  describe '.search(options)' do
    context "when there is some problem" do
      before do
        YAML.stub!(:load_file).and_return({'host' => 'http://nonexistent.server.gov',
                                           'endpoint' => '/test/search',
                                           'adapter' => Faraday.default_adapter})
        Usajobs.establish_connection!
      end

      it "should log any errors that occur and return nil" do
        Rails.logger.should_receive(:error).with(/Trouble fetching USAJobs information/)
        Usajobs.search(:query => 'jobs').should be_nil
      end
    end
  end
end