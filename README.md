# umpire [![Build Status](https://secure.travis-ci.org/hectcastro/chef-umpire.png?branch=master)](http://travis-ci.org/hectcastro/chef-umpire)

## Description

Installs and configures [Umpire](https://github.com/heroku/umpire).

## Requirements

### Platforms

* Ubuntu 12.04 (Precise)

### Cookbooks

* git
* logrotate
* ruby_build

## Attributes

* `node["umpire"]["dir"]` - Directory to install into.
* `node["umpire"]["log_dir"]` - Log directory.
* `node["umpire"]["user"]` -  User for Umpire.
* `node["umpire"]["port"]` - Port for Umpire API endpoint.
* `node["umpire"]["ruby_version"]` - Version of Ruby to install.
* `node["umpire"]["repository"]` - Reference to an Umpire repository.
* `node["umpire"]["force_https"]` – Force HTTPS API connections.
* `node["umpire"]["api_key"]` – API key to use for authorization.
* `node["umpire"]["graphite_role"]` – Role assigned to Graphite server for
  search.
* `node["umpire"]["graphite_fqdn"]` – FQDN to Graphite server if you're trying
  to target one that isn't searchable.

## Recipes

* `recipe[umpire]` will install Uptime.

## Usage
