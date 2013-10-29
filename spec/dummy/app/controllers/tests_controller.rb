class TestsController < ApplicationController
  def test
    GaEvents::Event.new('tests', 'test')
  end
end