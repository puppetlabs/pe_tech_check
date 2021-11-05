# pe_tech_check

<!-- markdownlint-disable MD001 -->

#### Table of Contents

1. [Description](#description)
2. [Setup - Installation and preparations](#setup)
3. [Using pe_tech_check](#usage)
4. [Development - Guide for contributing to the module](#development)
5. [Deprecations](#deprecations)

## Description

This module collects Puppet Enterprise data for analysis as part of the PE Tech Check service offering.
The majority of the data is collected by the Puppet Enterprise Support Script.

https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe-support-script

## Setup

### Install the `pe_tech_check` module


The preferred method of installation of `pe_tech_check` is via Code manager however should this not be possible other options are available

#### Manually

To manually install the `pe_tech_check` module, execute the following command on the Primary Server.

```bash
puppet module install puppetlabs-pe_tech_check --modulepath=/opt/puppetlabs/puppet/modules
```

Doing so will install this module into the base module path, making its tasks available without interfering with other modules.

If your Primary Server has environment caching enabled (which is true by default if Code Manager is being used), flush the environment cache to enable the tasks in this module by running the following command on the Primary Server:

```bash
/opt/puppetlabs/puppet/modules/pe_tech_check/scripts/flush_environment_cache.sh
```




#### Using Bolt

Bolt can be used either on the Primary Server  or another machine with connectivity to the Primary Server. Firstly, follow the instruction for [installing Bolt](https://puppet.com/docs/bolt/latest/bolt_installing.html).

The following block of code will create a Bolt Project under the logged in user's home directory and set up the module:

```bash
mkdir -p ~/tech_check
cd ~/tech_check

cat >>Puppetfile <<EOF
mod 'puppetlabs-stdlib'
mod 'puppetlabs-pe_tech_check'
EOF

bolt project init
bolt module install --no-resolve
```


## Usage

Pe_tech_check consumes Metric Provided by Puppet_Metrics_Collector Module, Puppet Enterprise  >= 2019.8.8 and >= 2021.3 Come with Puppet Metrics Collector built in however for PE 2019.8.8 this feature must be enabled before proceeding.

To enable metrics collector in 2019.8.8 set the following parameters to true:

```
puppet_enterprise::enable_metrics_collection
puppet_enterprise::enable_system_metrics_collection

```

If using a supported version of Puppet enterprise prior to 2019.8.8 or 2021.3 ensure you have Puppet Metrics Collector installed and enabled using the documentation from the [Forge](https://forge.puppet.com/modules/puppetlabs/puppet_metrics_collector) 

> **Note:** Allow at least one day after enabling  `puppet_metrics_collector` to allow the  module to collect metrics data before executing the `pe_tech_check::collect` task.


### Run the `pe_tech_check::collect` task

#### Via Bolt

> **Note:** if running Bolt from the Primary Server the --targets parameter will accept `localhost` as a destination which will not require authentication

```bash
bolt task run pe_tech_check::collect --targets <primary_fqdn>
```


#### Via the Console

In the Console, run the `pe_tech_check::collect` task, targeting the Primary Server.

#### Via Puppet Task

From the command line of the Primary Server, run:

```bash
puppet task run pe_tech_check::collect --targets $(puppet config print certname)
```

When finished, the `pe_tech_check::collect` task will output a list of files.
Upload those files from the Primary Server to Puppet for analysis.

## Development

This module is developed and maintained by the Puppet Enterprise Support and Technical Sales teams.


## Deprecations

pe_tech_check::configure should be considered deprecated and should not be used in currently supported versions of Puppet Enterprise
