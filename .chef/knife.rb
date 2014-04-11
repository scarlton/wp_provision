# See http://docs.opscode.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "scarlton"
client_key               "#{current_dir}/scarlton.pem"
validation_client_name   "rockstar_digital-validator"
validation_key           "#{current_dir}/rockstar_digital-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/rockstar_digital"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
