require 'govuk_template/version'
require_relative '../helpers'
require 'tmpdir'
require 'open3'

module Publisher
  class PlayPublisher
    include Helpers
    GIT_URL = "https://#{ENV['GITHUB_TOKEN']}@github.com/alphagov/govuk_template_play.git"

    def initialize(version = GovukTemplate::VERSION)
      @version = version
      @repo_root = Pathname.new(File.expand_path('../../..', __FILE__))
      @source_dir = @repo_root.join('pkg', "play_govuk_template-#{@version}")
    end

    def publish
      Dir.mktmpdir("govuk_template_play") do |dir|
        run "git clone -q #{GIT_URL.shellescape} #{dir.shellescape}"
        Dir.chdir(dir) do
          run "ls -1 | grep -v 'README.md' | xargs -I {} rm -rf {}"
          run "cp -r #{@source_dir.to_s.shellescape}/* ."
          run "git add -A ."
          run "git commit -q -m 'deploying GOV.UK Play templates #{@version}'"
          run "git tag v#{@version}"
          run "git push --tags origin master"
        end
      end
    end
  end
end
