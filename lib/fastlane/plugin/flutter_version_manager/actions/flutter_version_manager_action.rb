require 'fastlane/action'
require_relative '../helper/flutter_version_manager_helper'
require 'git'
require 'yaml'

GIT_OFFSET = 1598622000 # IMPORTANT: Do not change!

module Fastlane
  module Actions

    class ArgumentManager
      def evaluateArgument(argument)
        case argument
        when '-h'
          true
        when "-version"
          true
        when "-code"
          true
        when "-major"
          true
        when "-minor"
          true
        when "-patch"
          true
        when "-apply"
          true
        else
          false
        end
      end
  
      def invalid_argument
        UI.message("You have to pass at least one argument: Use -h view all commands")
      end
  
      def missing_required_arguments
        UI.message("You have to pass paths to version.yml and pubspec.yml: Use -h for more info")
      end
  
      def commands
        "
        -h: Access this menu
        -version: Reads current version name
        -code: Reads current version code
        -major: Bumps major version
        -minor: Bumps minor version
        -patch: Bumps patch version
        -apply: Applies version specified from version.yml to pubspec
        "
      end
    end
  
    class GitReader
      def initialize(git_path)
        @git = Git.open(git_path)
      end
  
      def get_timestamp
        head = @git.object('HEAD')
        commit = @git.gcommit(head.sha)
        commit.date.to_i
      end
    end
  
    class YamlReader
      def initialize(yaml_path)
        @yamlFile = YAML.load_file(yaml_path)
      end
  
      def field(fieldName)
        @yamlFile[fieldName]
      end
  
      def all
        @yamlFile
      end
    end
  
    class YamlWritter
      def initialize(yaml_path)
        @yaml_path = yaml_path
      end
  
      def write(yaml)
        File.open(@yaml_path, "w") { |file| file.write(yaml.to_yaml) }
      end
    end
  
    class FileReader
      def initialize(yaml_path)
        @yaml_path = yaml_path
      end
  
      def read
        IO.readlines(@yaml_path)
      end
    end
  
    class FileWritter
      def initialize(yaml_path)
        @yaml_path = yaml_path
      end
  
      def write(content)
        File.open(@yaml_path, "w") { |file|
          file.puts(content)
          file.close
        }
      end
    end
  
    class VersionManager
      def initialize(yaml_path, pubspec_path, git_path)
        @version_reader = YamlReader.new(yaml_path)
        @version_writter = YamlWritter.new(yaml_path)
        @pubspec_yaml_reader = YamlReader.new(pubspec_path)
        @pubspec_file_reader = FileReader.new(pubspec_path)
        @pubspec_file_writter = FileWritter.new(pubspec_path)
        @git_reader = GitReader.new(git_path)
      end
  
      def get_current_version_name
        "#{@version_reader.field('major')}.#{@version_reader.field('minor')}.#{@version_reader.field('patch')}"
      end
  
      def get_current_version_code
        @git_reader.get_timestamp - GIT_OFFSET
      end
  
      def bump_major(suffix = nil)
        context = @version_reader.all
        context['major'] = context['major'] + 1
        context['minor'] = 0
        context['patch'] = 0
        @version_writter.write(context)
        update_pubspec(suffix)
      end
  
      def bump_minor(suffix = nil)
        context = @version_reader.all
        context['minor'] = context['minor'] + 1
        context['patch'] = 0
        @version_writter.write(context)
        update_pubspec(suffix)
      end
  
      def bump_patch(suffix = nil)
        context = @version_reader.all
        context['patch'] = context['patch'] + 1
        @version_writter.write(context)
        update_pubspec(suffix)
      end
      
      def update_pubspec(suffix = nil)
        previousVersion = @pubspec_yaml_reader.field('version')
        newVersion = "#{get_current_version_name}+#{get_current_version_code}#{suffix}"
        newContent = @pubspec_file_reader.read.map { |s| s.gsub(previousVersion, newVersion) }
        @pubspec_file_writter.write(newContent)
        UI.message("Previous app version: #{previousVersion}")
        UI.message("New app version: #{newVersion}")
      end
    end
  
    ARGUMENT_MANAGER = ArgumentManager.new()

    class FlutterVersionManagerAction < Action
      def self.run(params)
        version_path = params[:yml]
        pubspec_path = params[:pubspec]
        git_path = params[:git_repo] || './'
        args = (params[:arguments] || "").split(" ")
        suffix = (params[:version_suffix])

        # Paths valid, continue
        versionManager = VersionManager.new(version_path, pubspec_path, git_path)

        # Check if the user has passed additional arguments
        if(args.include?("-h") || args.include?("-version") || args.include?("-code") || args.include?("-major") || args.include?("-minor") || args.include?("-patch") || args.include?("-apply"))
          args.each { |a|
            case a
            when '-h'
              UI.message(ARGUMENT_MANAGER.commands)
            when "-version"
              UI.message(versionManager.get_current_version_name)
            when "-code"
              UI.message(versionManager.get_current_version_code)
            when "-major"
              versionManager.bump_major(suffix)
            when "-minor"
              versionManager.bump_minor(suffix)
            when "-patch"
              versionManager.bump_patch(suffix)
            when "-apply"
              versionManager.update_pubspec(suffix)
            end
          }
        else
          ARGUMENT_MANAGER.invalid_argument
        end
      end

      def self.description
        "Manages app versioning of a Flutter project."
      end

      def self.authors
        ["Davor Maric", "rubicon-world.com"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "App versioning tool for Flutter projects that can be plugged into pipeline via CI/CD"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :arguments,
            description: "Additional arguments",
            optional: true,
            type: String),
          FastlaneCore::ConfigItem.new(
            key: :yml,
            description: "Path to version.yml",
            optional: false,
            type: String),
          FastlaneCore::ConfigItem.new(
            key: :pubspec,
            description: "Path to pubspec.yaml",
            optional: false,
            type: String),
          FastlaneCore::ConfigItem.new(
            key: :git_repo,
            description: "Path to root folder of git repository",
            optional: true,
            type: String),
          FastlaneCore::ConfigItem.new(
            key: :version_suffix,
            description: "Number to add to the end of the Git generated version number",
            optional: true,
            type: String)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
