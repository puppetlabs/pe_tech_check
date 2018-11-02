# healthcheck_lite

#### Table of Contents

1. [Description](#description)
2. [Setup - Installation and preparations](#setup)
3. [Using healthcheck_lite](#usage)
4. [Development - Guide for contributing to the module](#development)

## Description

This module gathers data from the PE Infrastructure nodes for analysis as part of the HealthCheck Lite Service offering. It primarily does this by gathering data in the form of the Support Script, as well as an additional data capture script. It will also gather up the metrics from the puppetlabs/puppet_metrics_collector module if installed and enabled.

## Setup

### Installing the healthcheck_lite module

To install the `healthcheck_lite` module execute this command on the Primary Master:

```bash
puppet module install puppetlabs-healthcheck_lite
 --modulepath=/opt/puppetlabs/puppet/modules
```

This will install the modules into the system module path, making the tasks and classes available without interfering with the normal code directory. Installing here is unlikely to survive a PE upgrade, but the same installation method can be used after an upgrade if required.

The `healthcheck_lite` module has a dependency for the `puppetlabs/puppet_metrics_collector` module. If the `puppetlabs/puppet_metrics_collector` module was already installed and classified in the standard code directory, it will be re-installed in this alternate location, but this will not cause any issues.

If code manager is being used, you need to deploy the production environment to make sure the newly installed modules are available to Puppet Enterprise.

```bash
puppet code deploy production --wait
```

### Preparation before using healthcheck_lite

If puppet_metrics_collector is not already being used, enable the Puppet Metrics Collector by adding the class puppet_metrics_collector to the PE Infrastructure classification group. For more information on puppetlabs/puppet_metrics_collector please see the documentation for that module. <https://forge.puppet.com/puppetlabs/puppet_metrics_collector/readme.>
Trigger a Puppet Run on the PE Infrastructure group or let the scheduled Puppet runs happen.
Allow at least 24 hours to ensure as much pertinent information is captured as possible.

## Usage

### Run the healthcheck_lite::hcl1 task

This task takes 2 input parameters, which are the username and password for a user account which has RBAC permissions to run Tasks on the infrastructure nodes. These are used to create a short lived Authentication Token which will be used to run the healthcheck-related tasks. After creating the token and writing it to a file, `healthcheck_lite::hcl1` task executes PE Support Script (the healthcheck_lite::supportcapture task) on all infrastructure nodes (Primary Master/Compile Masters, PuppetDB and Console nodes if present).

### Copy the Support Script output

Copy the resultant Support Script tarballs from all infrastructure nodes to the `/var/tmp/hcl_data` directory on the Primary Master. The location of the tarball can be found in the output of the `healthcheck_lite::supportcapture` task on each Infrastructure node.

### Run the healthcheck_lite::hcl2 task

This task will capture some additional data on the Primary Master, and then package all this data, including the Support Script tarballs copied to the Primary Master, up for forwarding to Puppet. It takes a single parameter which is an identifier (allowed characters are all alphanumeric characters plus underscore) which is to be agreed with Puppet during the Healthcheck Lite intake conversation. This task also cleans up after itself by deleting the working directory and the temporary Authentication Token.

## Development

This module is developed and maintained by the Puppet Support and Technical Sales teams.
