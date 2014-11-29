#
# Cookbook Name:: apt
# Recipe:: default
#
# Copyright 2013-2014, Thomas Boerger <thomas@webhippie.de>
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

template "/etc/apt/sources.list" do
  source "sources.list.erb"

  owner "root"
  group "root"
  mode 0644

  notifies :run, "execute[aptget_update]", :immediately
end

node["apt"]["repos"].each do |repo|
  apt_repository repo["alias"] do
    uri repo["uri"]
    distribution repo["distribution"]
    components repo["components"]

    if repo["source"]
      source true
    else
      source false
    end

    if repo["key"]
      key repo["key"]
    end

    if repo["keyserver"]
      keyserver repo["keyserver"]
    end

    notifies :run, "execute[aptget_update]", :immediately
  end
end

execute "aptget_update" do
  command "apt-get update"
  ignore_failure true

  action :nothing
end.run_action(:run)

node["apt"]["packages"].each do |name|
  package name do
    action :install
  end.run_action(:install)
end
