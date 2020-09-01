require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class FlutterVersionManagerHelper
      # class methods that you define here become available in your action
      # as `Helper::FlutterVersionManagerHelper.your_method`
      #
      def self.show_message
        # Hi! :)
      end
    end
  end
end
