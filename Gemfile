source('https://rubygems.org')

gemspec

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')

eval_gemfile(plugins_path) if File.exist?(plugins_path)

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "git"
