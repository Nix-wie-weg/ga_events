require 'spec_helper'

describe TestsController do
  describe '#test' do
    specify do
      get :test
    end
  end
end