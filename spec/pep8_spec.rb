require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerPep8 do
    it 'should be a plugin' do
      expect(Danger::DangerPep8.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @pep8 = @dangerfile.pep8
      end

      context 'flake8 not installed' do
        before do
          allow(@pep8).to receive(:`).with("which flake8").and_return("")
        end
      end

      context 'flake8 installed' do
        before do
          allow(@pep8).to receive(:`).with("which flake8").and_return("/usr/bin/flake8")
        end

        it 'runs lint from current directory by default' do
          expect(@pep8).to receive(:`).with("flake8 .").and_return("")
          @pep8.lint
        end

        it 'runs lint from a custom directory' do
          expect(@pep8).to receive(:`).with("flake8 my/custom/directory").and_return("")
          @pep8.lint "my/custom/directory"
        end

        it 'handles a custom config file' do
          expect(@pep8).to receive(:`).with("flake8 . --config my-pep8-config").and_return("")
          @pep8.config_file = "my-pep8-config"
          @pep8.lint
        end

        it 'handles a lint with no errors' do
          allow(@pep8).to receive(:`).with("flake8 .").and_return("")
          @pep8.lint
          expect(@pep8.status_report[:markdowns].first).to be_nil
        end

        context 'when running on github' do
          it 'handles a lint with errors' do
            lint_report = "./tests/test_matcher.py:90:9: E128 continuation line under-indented for visual indent\n"

            allow(@pep8).to receive(:`).with("flake8 .").and_return(lint_report)
            allow(@dangerfile.danger).to receive(:scm_provider).and_return("github")
            allow(@dangerfile.github).to receive(:html_link)
              .with("./tests/test_matcher.py#L90", full_path: false)
              .and_return("fake_link_to:test_matcher.py#90")

            @pep8.lint

            markdown = @pep8.status_report[:markdowns].first
            expect(markdown.message).to include("## DangerPep8 found issues")
            expect(markdown.message).to include("| fake_link_to:test_matcher.py#90 | 90 | 9 | E128 continuation line under-indented for visual indent |")
          end
        end

        context 'when running outside github' do
          it 'handles a lint with errors' do
            lint_report = "./tests/test_matcher.py:90:9: E128 continuation line under-indented for visual indent\n"

            allow(@pep8).to receive(:`).with("flake8 .").and_return(lint_report)
            allow(@dangerfile.danger).to receive(:scm_provider).and_return("fake_provider")

            @pep8.lint

            markdown = @pep8.status_report[:markdowns].first
            expect(markdown.message).to include("## DangerPep8 found issues")
            expect(markdown.message).to include("| ./tests/test_matcher.py | 90 | 9 | E128 continuation line under-indented for visual indent |")
          end
        end

      end

    end
  end
end
