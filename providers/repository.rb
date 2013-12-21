#
# Cookbook Name:: apt
# Provider:: repository
#
# Copyright 2013, Thomas Boerger
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

action :add do
  if new_resource.keyserver && new_resource.key
    execute "apt_repository_key_#{new_resource.key}" do
      command "apt-key adv --keyserver #{new_resource.keyserver} --recv #{new_resource.key}"
      action :run
    end
  elsif new_resource.key && (new_resource.key =~ /http/)
    key_name = new_resource.key.split(/\//).last

    remote_file "#{Chef::Config[:file_cache_path]}/#{key_name}" do
      source new_resource.key
      mode "0644"
      action :create_if_missing
    end

    execute "apt_repository_key_#{key_name}" do
      command "apt-key add #{Chef::Config[:file_cache_path]}/#{key_name}"
      action :run
    end
  end

  result = [].tap do |repository|
    repository.push [
      "# Generated by Chef for", 
      node["fqdn"]
    ].join(" ")
    
    repository.push [
      "deb", 
      new_resource.uri, 
      new_resource.distribution, 
      new_resource.components
    ].flatten.join(" ")

    repository.push [
      "deb-src", 
      new_resource.uri, 
      new_resource.distribution, 
      new_resource.components
    ].flatten.join(" ") if new_resource.source
  end.flatten.join("\n")

  file "/etc/apt/sources.list.d/#{new_resource.alias}.list" do
    owner "root"
    group "root"
    mode 0644

    content result

    action :create
    notifies :run, "execute[aptget_update]", :immediately
  end

  new_resource.updated_by_last_action(true)
end

action :remove do
  file "/etc/apt/sources.list.d/#{new_resource.alias}.list" do
    action :delete
    notifies :run, "execute[aptget_update]", :immediately
  end

  new_resource.updated_by_last_action(true)
end