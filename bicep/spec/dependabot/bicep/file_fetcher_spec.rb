# frozen_string_literal: true

require "spec_helper"
require "dependabot/bicep/file_fetcher"
require_common_spec "file_fetchers/shared_examples_for_file_fetchers"

RSpec.describe Dependabot::Bicep::FileFetcher do
  it_behaves_like "a dependency file fetcher"

  let(:source) do
    Dependabot::Source.new(
      provider: "github",
      repo: "gocardless/bump",
      directory: directory
    )
  end

  let(:file_fetcher_instance) do
    described_class.new(source: source, credentials: [], repo_contents_path: repo_contents_path)
  end

  let(:project_name) { "provider" }
  let(:directory) { "/" }
  let(:repo_contents_path) { build_tmp_repo(project_name) }

  after do
    FileUtils.rm_rf(repo_contents_path)
  end

  context "with Bicep files" do
    let(:project_name) { "versions_file" }

    it "fetches the Bicep files" do
      expect(file_fetcher_instance.files.map(&:name)).
        to match_array(%w(main.bicep))
    end
  end

  context "with a directory that doesn't exist" do
    let(:directory) { "/nonexistent" }

    it "raises a helpful error" do
      expect { file_fetcher_instance.files }.
        to raise_error(Dependabot::DependencyFileNotFound)
    end
  end

  context "when fetching nested local path modules" do
    let(:project_name) { "provider_with_multiple_local_path_modules" }

    it "fetches nested bicep files excluding symlinks" do
      expect(file_fetcher_instance.files.map(&:name)).
        to match_array(
          %w(.bicep.lock.hcl loader.bicep providers.bicep
             loader/providers.bicep loader/projects.bicep)
        )
    end
  end
end
