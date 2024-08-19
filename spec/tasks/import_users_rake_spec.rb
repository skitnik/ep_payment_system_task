# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'users:import rake task', type: :task do
  before(:all) do
    Rake.application.rake_require('tasks/import_users')
    Rake::Task.define_task(:environment)
  end

  let(:rake_task) { Rake::Task['users:import'] }
  let(:valid_csv_path) { Rails.root.join('spec/fixtures/files/valid_users.csv') }

  after(:each) do
    rake_task.reenable
  end

  it 'calls ImportUserService with the correct file path' do
    import_user_service = instance_double('ImportUserService')
    allow(ImportUserService).to receive(:new).with(valid_csv_path).and_return(import_user_service)
    expect(import_user_service).to receive(:call)

    rake_task.invoke(valid_csv_path)
  end
end
