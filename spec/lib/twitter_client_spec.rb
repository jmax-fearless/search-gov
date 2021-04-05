# frozen_string_literal: true

require 'spec_helper'

describe TwitterClient do
  describe '.instance' do
    before { skip 'until SRCH-2042 is fixed' }

    subject(:instance) { described_class.instance }

    it { is_expected.to be_an_instance_of(Twitter::REST::Client) }
  end
end
