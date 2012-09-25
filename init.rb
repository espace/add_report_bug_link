# Include hook code here
#require 'redmine'
require 'dispatcher'  unless Rails::VERSION::MAJOR >= 3
#require 'add_report_bug_link'

# Hooks
require_dependency 'my_hooks'

# ActiveSupport::Dependencies.autoload_paths += [File.join(Rails.root, 'plugins/add_report_bug_link/app/controllers')]
# require "#{File.join(Rails.root, 'plugins/add_report_bug_link/app/controllers')}/issues_controller.rb"

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'issue'
    require 'issue_patch'
    Issue.send( :include, IssuePatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'issue'
    require 'issue_patch'
    Issue.send( :include, IssuePatch)
  end
end

Redmine::Plugin.register :add_report_bug_link do
  name 'Add Report Bug Link'
  author 'Basayel Said'
  description 'As a team member, can click on a "Open an Issue on this Story" link in the side bar of any story.'
  version '0.0.1'
end

#fix required to make the plugin work in devel mode with rails 2.2
Rails.configuration.autoload_paths.each do |path|
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

