# frozen_string_literal: true

require "spec_helper"
require "dependabot/dependency"
require "dependabot/bicep/metadata_finder"
require_common_spec "metadata_finders/shared_examples_for_metadata_finders"

RSpec.describe Dependabot::Bicep::MetadataFinder do
  it_behaves_like "a dependency metadata finder"

  let(:dependency) do
    Dependabot::Dependency.new(
      name: "origin_label",
      version: "tags/0.4.1",
      previous_version: nil,
      requirements: [{
        requirement: nil,
        groups: [],
        file: "main.bicep",
        source: {
          type: "git",
          url: "https://github.com/cloudposse/bicep-null.git",
          branch: nil,
          ref: "tags/0.4.1"
        }
      }],
      previous_requirements: [{
        requirement: nil,
        groups: [],
        file: "main.bicep",
        source: {
          type: "git",
          url: "https://github.com/cloudposse/bicep-null.git",
          branch: nil,
          ref: "tags/0.3.7"
        }
      }],
      package_manager: "bicep"
    )
  end
  subject(:finder) do
    described_class.new(dependency: dependency, credentials: credentials)
  end
  let(:credentials) do
    [{
      "type" => "git_source",
      "host" => "github.com",
      "username" => "x-access-token",
      "password" => "token"
    }]
  end
  let(:dependency_name) { "rtfeldman/elm-css" }

  describe "#source_url" do
    subject(:source_url) { finder.source_url }

    it { is_expected.to eq("https://github.com/cloudposse/bicep-null") }

    context "with a registry-based dependency" do
      let(:dependency) do
        Dependabot::Dependency.new(
          name: "hashicorp/consul/aws",
          version: "0.3.8",
          previous_version: "0.1.0",
          requirements: [{
            requirement: "0.3.8",
            groups: [],
            file: "main.bicep",
            source: {
              type: "registry",
              registry_hostname: "registry.bicep.io",
              module_identifier: "hashicorp/consul/aws"
            }
          }],
          previous_requirements: [{
            requirement: "0.1.0",
            groups: [],
            file: "main.bicep",
            source: {
              type: "registry",
              registry_hostname: "registry.bicep.io",
              module_identifier: "hashicorp/consul/aws"
            }
          }],
          package_manager: "bicep"
        )
      end

      let(:registry_url) do
        "https://registry.bicep.io/v1/modules/hashicorp/consul/aws/0.3.8/download"
      end
      before do
        stub_request(:get, "https://registry.bicep.io/.well-known/bicep.json").
          to_return(status: 200, body: { "modules.v1": "/v1/modules/" }.to_json)
        stub_request(:get, registry_url).
          to_return(status: 204, body: "",
                    headers: { "X-Bicep-Get": "git::https://github.com/hashicorp/bicep-aws-consul" })
      end

      it do
        is_expected.to eq("https://github.com/hashicorp/bicep-aws-consul")
      end
    end

    context "with a provider", :vcr do
      let(:dependency) do
        Dependabot::Dependency.new(
          name: "hashicorp/aws",
          version: "3.40.0",
          previous_version: "0.1.0",
          requirements: [{
            requirement: "3.40.0",
            groups: [],
            file: "main.bicep",
            source: {
              type: "provider",
              registry_hostname: "registry.bicep.io",
              module_identifier: "hashicorp/aws"
            }
          }],
          previous_requirements: [{
            requirement: "0.1.0",
            groups: [],
            file: "main.bicep",
            source: {
              type: "provider",
              registry_hostname: "registry.bicep.io",
              module_identifier: "hashicorp/aws"
            }
          }],
          package_manager: "bicep"
        )
      end

      before do
        stub_request(:get, "https://registry.bicep.io/.well-known/bicep.json").
          to_return(status: 200, body: { "providers.v1": "/v1/providers/" }.to_json)
      end

      it do
        is_expected.to eq("https://github.com/hashicorp/bicep-provider-aws")
      end
    end
  end
end
