# frozen_string_literal: true

namespace :users do
  desc 'Import users from CSV'
  task :import, [:file_path] => :environment do |_, args|
    file_path = args[:file_path]

    begin
      ImportUserService.new(file_path).call
    rescue StandardError => e
      abort("An error occurred during import: #{e.message}")
    end
  end
end
