name "apt"
maintainer "Thomas Boerger"
maintainer_email "info@tbpro.de"
license "Apache 2.0"
description "Installs/Configures apt"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version "0.0.1"
recipe "apt", "Installs/Configures apt"

supports "debian", ">= 7.0"
supports "ubuntu", ">= 12.04"
