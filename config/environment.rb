# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Rafael::Application.initialize!

ENV['JAVA_HOME'] = JAVA_CONFIG['java_home']
ENV['LD_LIBRARY_PATH'] = JAVA_CONFIG['ld_library_path']
