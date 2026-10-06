platform :osx, '13.5.2'

use_frameworks!

target 'typio' do
end

target 'Tests' do
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = 'RECOMMENDED_MACOSX_DEPLOYMENT_TARGET'
         end
    end
  end
end