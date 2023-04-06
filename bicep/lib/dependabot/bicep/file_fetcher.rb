# frozen_string_literal: true

require "dependabot/file_fetchers"
require "dependabot/file_fetchers/base"
require "dependabot/bicep/file_selector"

module Dependabot
  module Bicep
    class FileFetcher < Dependabot::FileFetchers::Base
      include FileSelector

      def self.required_files_in?(filenames)
        filenames.any? { |f| f.end_with?(".bicep") }
      end

      private

      def fetch_files
        fetched_files = []
        fetched_files += bicep_files
        fetched_files += local_path_module_files(terraform_files)

        return fetched_files if fetched_files.any?

        raise(
          Dependabot::DependencyFileNotFound,
          File.join(directory, "<anything>.bicep")
        )
      end

      def bicep_files
        @bicep_files ||=
          repo_contents(raise_errors: false).
          select { |f| f.type == "file" && f.name.end_with?(".bicep") }.
          map { |f| fetch_file_from_host(f.name) }
      end

      def terragrunt_files
        @terragrunt_files ||=
          repo_contents(raise_errors: false).
          select { |f| f.type == "file" && terragrunt_file?(f.name) }.
          map { |f| fetch_file_from_host(f.name) }
      end

      def local_path_module_files(files, dir: ".")
        bicep_files = []

        files.each do |file|
          bicep_file_local_module_details(file).each do |path|
            base_path = Pathname.new(File.join(dir, path)).cleanpath.to_path
            nested_bicep_files =
              repo_contents(dir: base_path).
              select { |f| f.type == "file" && f.name.end_with?(".bicep") }.
              map { |f| fetch_file_from_host(File.join(base_path, f.name)) }
            bicep_files += nested_bicep_files
            bicep_files += local_path_module_files(nested_bicep_files, dir: path)
          end
        end

        # NOTE: The `support_file` attribute is not used but we set this to
        # match what we do in other ecosystems
        bicep_files.tap { |fs| fs.each { |f| f.support_file = true } }
      end

      def bicep_file_local_module_details(file)
        return [] unless file.name.end_with?(".bicep")
        return [] unless file.content.match?(LOCAL_PATH_SOURCE)

        file.content.scan(LOCAL_PATH_SOURCE).flatten.map do |path|
          Pathname.new(path).cleanpath.to_path
        end
      end

    end
  end
end

Dependabot::FileFetchers.
  register("bicep", Dependabot::Bicep::FileFetcher)
