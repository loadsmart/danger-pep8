require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerPep8 do
    it 'should be a plugin' do
      expect(Danger::DangerPep8.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.pep8
      end
    end
  end
end
