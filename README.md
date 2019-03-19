# healthcheck_lite

<!-- markdownlint-disable MD001 -->

#### Table of Contents

1. [Description](#description)
2. [Setup - Installation and preparations](#setup)
3. [Using healthcheck_lite](#usage)
4. [Development - Guide for contributing to the module](#development)

## Description

This module collects Puppet Enterprise data for analysis as part of the HealthCheck Lite service offering.
The majority of the data is collected by the Puppet Enterprise Support Script.

https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe-support-script

## Setup

### Install the `healthcheck_lite` module

To install the `healthcheck_lite` module, execute the following command on the Primary Master.

```bash
puppet module install puppetlabs-healthcheck_lite --modulepath=/opt/puppetlabs/puppet/modules
```

Doing so will install this module into the base module path, making its tasks available without interfering with other modules.

### Enable the `healthcheck_lite` module tasks

If your Primary Master has environment caching enabled (which is true by default if Code Manager is being used), flush the environment cache to enable the tasks in this module.

Run the following command on the Primary Master:

```bash
/opt/puppetlabs/puppet/modules/healthcheck_lite/scripts/flush_environment_cache.sh
```

## Usage

### Run the `healthcheck_lite::configure` task

In the Console, run the `healthcheck_lite::configure` task, targeting the Primary Master.

Or, from the command line of the Primary Master, run:

```bash
puppet task run healthcheck_lite::configure --nodes $(facter -p certname)
```

#### Task parameters

##### `install_pe_metrics` (Boolean, default: true)

Temporarily install and configure the `puppet_metrics_collector` module, if it is not already installed.

https://forge.puppet.com/puppetlabs/puppet_metrics_collector

##### `install_pe_tune` (Boolean, default: true)

Temporarily install the `puppet pe tune` subcommand via the `pe_tune` module.
The `pe_tune` module is the upstream version of the `puppet infrastructure tune` subcommand.

https://github.com/tkishel/pe_tune

> Note Allow at least one day after executing the `healthcheck_lite::configure` task for the `puppet_metrics_collector` module to collect metrics data before executing the `healthcheck_lite::collect` task.

### Run the `healthcheck_lite::collect` task

In the Console, run the `healthcheck_lite::collect` task, targeting the Primary Master.

Or, from the command line of the Primary Master, run:

```bash
puppet task run healthcheck_lite::collect --nodes $(facter -p certname)
```

When finished, the `healthcheck_lite::collect` task will output a list of files.
Upload those files from the Primary Master to Puppet for analysis.

## Development

This module is developed and maintained by the Puppet Enterprise Support and Technical Sales teams.
