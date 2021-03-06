require File.join(File.dirname(__FILE__), '../../test_helper')
require File.join(File.dirname(__FILE__), '../../organization/organization_helpers')
require File.join(File.dirname(__FILE__),
                  '../../lifecycle_environment/lifecycle_environment_helpers')

describe 'content-view version incremental-update' do
  include OrganizationHelpers
  include LifecycleEnvironmentHelpers

  before do
    @cmd = %w(content-view version incremental-update)
  end

  it "performs incremental update with no updates" do
    params = ['--errata-ids=FOO2012', '--lifecycle-environment-ids=1,2,3',
              '--content-view-version-id=5']

    ex = api_expects(:content_view_versions, :incremental_update, 'Incremental Update') do |par|
      par['update_hosts'].nil? &&
        par[:content_view_version_environments][0][:environment_ids] == %w(1 2 3) &&
        par[:content_view_version_environments][0][:content_view_version_id] == 5 &&
        par['add_content']['errata_ids'] == ['FOO2012']
    end
    ex.returns('id' => '3', 'state' => 'stopped')

    ex2 = api_expects(:foreman_tasks, :show, 'Show task')
    ex2.returns('id' => '3', 'state' => 'stopped')

    run_cmd(@cmd + params)
  end

  it "performs incremental update with update all hosts" do
    params = ['--update-all-hosts=true', '--errata-ids=FOO2012',
              '--lifecycle-environment-ids=1,2,3', '--content-view-version-id=5']

    ex = api_expects(:content_view_versions, :incremental_update, 'Incremental Update') do |par|
      par['update_hosts']['included'][:search] == '' &&
        par[:content_view_version_environments][0][:environment_ids] == %w(1 2 3) &&
        par[:content_view_version_environments][0][:content_view_version_id] == 5 &&
        par['add_content']['errata_ids'] == ['FOO2012']
    end
    ex.returns('id' => '3', 'state' => 'stopped')

    ex2 = api_expects(:foreman_tasks, :show, 'Show task')
    ex2.returns('id' => '3', 'state' => 'stopped')

    run_cmd(@cmd + params)
  end

  it "performs incremental update with names" do
    params = ['--update-all-hosts=true', '--errata-ids=FOO2012',
              '--lifecycle-environments=trump,cruz,bernie',
              '--content-view-version-id=5', '--organization=USA']

    expect_organization_search('USA', 5)
    expect_lifecycle_environments_request(5, [{'name' => 'trump', 'id' => 1},
                                              {'name' => 'cruz', 'id' => 2},
                                              {'name' => 'bernie', 'id' => 3}])

    ex = api_expects(:content_view_versions, :incremental_update, 'Incremental Update') do |par|
      par['update_hosts']['included'][:search] == '' &&
        par[:content_view_version_environments][0][:environment_ids] == [1, 2, 3] &&
        par[:content_view_version_environments][0][:content_view_version_id] == 5 &&
        par['add_content']['errata_ids'] == ['FOO2012']
    end
    ex.returns('id' => '3', 'state' => 'stopped')

    ex2 = api_expects(:foreman_tasks, :show, 'Show task')
    ex2.returns('id' => '3', 'state' => 'stopped')

    run_cmd(@cmd + params)
  end
end
