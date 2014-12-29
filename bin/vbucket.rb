require File.expand_path(File.dirname(__FILE__) + '/../lib/vbucket')

# TODO: SSL
# TODO: Service setup/init script
# TODO: Allow key file to have comments

VBucket::Service.run!
