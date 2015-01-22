include_recipe "git"
include_recipe "ruby_build"
include_recipe "logrotate"

ruby_bin_path = "#{node["ruby_build"]["default_ruby_base_path"]}/#{node["umpire"]["ruby_version"]}/bin"

if Chef::Config[:solo]
  if node["umpire"]["graphite_fqdn"].empty?
    Chef::Application.fatal!("No Graphite server found.")
  else
    graphite_fqdn = node["umpire"]["graphite_fqdn"]
  end
else
  if node["umpire"]["graphite_fqdn"].empty?
    graphite_server_results = search(:node, "roles:#{node["umpire"]["graphite_role"]} AND chef_environment:#{node.chef_environment}")

    if graphite_server_results.empty?
      Chef::Application.fatal!("No Graphite server found.")
    else
      graphite_fqdn = graphite_server_results[0]["fqdn"]
    end
  else
    graphite_fqdn = node["umpire"]["graphite_fqdn"]
  end
end

file "/etc/profile.d/ruby.sh" do
  mode "0644"
  content "PATH=#{ruby_bin_path}:\$PATH"
  action :nothing
end

ruby_build_ruby node["umpire"]["ruby_version"] do
  action :install
  notifies :create_if_missing, "file[/etc/profile.d/ruby.sh]"
end

group node["umpire"]["user"] do
  system true
end

user node["umpire"]["user"] do
  group node["umpire"]["user"]
  system true
  shell "/bin/false"
end

git node["umpire"]["dir"] do
  repository node["umpire"]["repository"]
  reference "master"
  action :sync
  notifies :restart, "service[umpire]"
end

directory node["umpire"]["log_dir"] do
  mode "0755"
  owner node["umpire"]["user"]
  group node["umpire"]["user"]
end

template "/etc/init/umpire.conf" do
  mode "0644"
  source "umpire.conf.erb"
  variables(
    :path               => ruby_bin_path,
    :dir                => node["umpire"]["dir"],
    :user               => node["umpire"]["user"],
    :force_https        => node["umpire"]["force_https"],
    :api_key            => node["umpire"]["api_key"],
    :graphite_fqdn      => graphite_fqdn,
    :port               => node["umpire"]["port"],
    :log_dir            => node["umpire"]["log_dir"]
  )
  notifies :restart, "service[umpire]"
end

logrotate_app "umpire" do
  cookbook "logrotate"
  path "#{node["umpire"]["log_dir"]}/*.log"
  frequency "daily"
  rotate 7
  create "644 root root"
end

execute "install-bundler" do
  command "#{ruby_bin_path}/gem install bundler"
  not_if "#{ruby_bin_path}/gem list | grep 'bundler'"
end

execute "bundle-install" do
  cwd node["umpire"]["dir"]
  command "#{ruby_bin_path}/bundle install --deployment --path vendor"
end

service "umpire" do
  provider Chef::Provider::Service::Upstart
  action [ :enable, :start ]
end
