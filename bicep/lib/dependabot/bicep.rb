# frozen_string_literal: true

# These all need to be required so the various classes can be registered in a
# lookup table of package manager names to concrete classes.
require "dependabot/bicep/file_fetcher"
require "dependabot/bicep/file_parser"
require "dependabot/bicep/update_checker"
require "dependabot/bicep/file_updater"
require "dependabot/bicep/metadata_finder"
require "dependabot/bicep/requirement"
require "dependabot/bicep/version"
require "dependabot/bicep/name_normaliser"

require "dependabot/pull_request_creator/labeler"
Dependabot::PullRequestCreator::Labeler.
  register_label_details("bicep", name: "bicep", colour: "2b67c6")

require "dependabot/dependency"
Dependabot::Dependency.
register_production_check("bicep", ->(_) { true })

require "dependabot/utils"
Dependabot::Utils.register_always_clone("bicep")

Dependabot::Dependency.
  register_display_name_builder(
    "bicep",
    lambda { |name|
      # Only modify the name if it a git source dependency
      return name unless name.include? "::"

      name.split("::").first + "::" + name.split("::")[2].split("/").last.split("(").first
    }
  )
