require 'spec_helper'
require_relative '../../../lib/puppet/functions/cd4pe_deployments/partition_nodes'
require 'webmock/rspec'

describe 'cd4pe_deployments::partition_nodes' do
  it 'exists' do
    is_expected.not_to eq(nil)
  end

  it 'requires 2 parameters' do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  context 'happy' do
    include_context 'deployment'

    let(:batch_size) { 3 }
    let(:node_list) do
      {
        nodes: [
          'carlscoolnode1.net',
          'carlscoolnode2.net',
          'carlscoolnode3.net',
          'carlscoolnode4.net',
          'carlscoolnode5.net',
          'carlscoolnode6.net',
          'carlscoolnode7.net',
        ],
      }
    end

    let(:result) do
      {
        result:
          [
            [
              'carlscoolnode1.net',
              'carlscoolnode2.net',
              'carlscoolnode3.net',
            ],
            [
              'carlscoolnode4.net',
              'carlscoolnode5.net',
              'carlscoolnode6.net',
            ],
            [
              'carlscoolnode7.net',
            ],
          ],
        error: nil,
      }
    end

    it 'succeeds with parameters' do
      stub_request(:get, ajax_url)
        .with(query: { op: 'GetNodeGroupInfo', deploymentId: deployment_id, nodeGroupId: node_group_id }, headers: { 'authorization' => "Bearer token #{ENV['DEPLOYMENT_TOKEN']}" })
        .to_return(body: JSON.generate(node_list))
        .times(1)

      is_expected.to run.with_params(node_group_id, batch_size).and_return(result)
    end

    it 'succeeds with an empty node list' do
      stub_request(:get, ajax_url)
        .with(query: { op: 'GetNodeGroupInfo', deploymentId: deployment_id, nodeGroupId: node_group_id }, headers: { 'authorization' => "Bearer token #{ENV['DEPLOYMENT_TOKEN']}" })
        .to_return(body: JSON.generate(nodes: []))
        .times(1)
      is_expected.to run.with_params(node_group_id, batch_size).and_return(result: [], error: nil)
    end

    it 'fails with non-200 response code' do
      stub_request(:get, ajax_url)
        .with(query: { op: 'GetNodeGroupInfo', deploymentId: deployment_id, nodeGroupId: node_group_id }, headers: { 'authorization' => "Bearer token #{ENV['DEPLOYMENT_TOKEN']}" })
        .to_return(body: JSON.generate(error_response), status: 404)
        .times(1)

      is_expected.to run.with_params(node_group_id, batch_size).and_return(error_response)
    end
  end
end
