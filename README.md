
# healthcheck_lite

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with healthcheck_lite](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with healthcheck_lite](#beginning-with-healthcheck_lite)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Development - Guide for contributing to the module](#development)

## Description

This module gathers data from the PE Infrastructure nodes for analysis as part of the HealthCheck Lite Service offering.
It primarily does this by gathering data in the form of the Support Script, as well as an additional data capture script.
It will also gather up the metrics from the Metrics Capture module if installed and enabled.


## Setup


### Setup and Installation Requirements

The HealthCheck Lite module has a dependency for the puppetlabs/puppet_metrics_collector module, which will be installed if it is not already present. It is recommended that metrics collection is enabled at least 24 hours before the Tasks in this module are executed, to ensure as much pertinent information is captured as possible. For information on doing this, please see the documentation for that module at https://forge.puppet.com/puppetlabs/puppet_metrics_collector/readme.

In cases where installing the module(s) through the normal methods is problematic due to change control or time constraints, it is possible to install them in an alternate location which will not require editing a Puppetfile or installing into the normal live code directory. In order to install to this alternative location, please run the following command:
> puppet module install --modulepath=/opt/puppetlabs/puppet/modules spynappels-healthcheck_lite

This will install the modules into the system module path, making the Tasks and classes available without interfering with the normal code directory. Installing here is unlikely to survive a PE upgrade, but the same installation method can be used after an upgrade if required. If the puppetlabs/puppet_metrics_collector module is already installed and classified in the standard code directory, it will be re-installed in this alternate location, but this will not cause any issues.

### Beginning with healthcheck_lite

By far the easiest way to capture and package the data required for the HealthCheck Lite service is to run the two wrapper tasks, healthcheck_lite::hcl1 and healthcheck_lite::hcl2, on the MoM node.
The first takes 2 input parameters, which are the username and password for a user account which has RBAC permissions to run Tasks on the infrastructure nodes. These are used to create a short lived Authentication Token which will be used to run all the wrapped tasks in hcl1 and hcl2. After creating the token and writing it to a file, it then runs the PE Support Script on all infrastructure nodes (MoM/CMs, PuppetDB and Console nodes if present). After this task completes, the resultant Support Script tarballs from all infrastructure nodes need to be copied to the /var/tmp/hcl_data directory on the MoM.
The second task will capture some additional data on the MoM, and then package all this data, including the Support Script tarballs copied to the MoM, up for forwarding to Puppet. It takes a single parameter which is an identifier (allowed characters are all alphanumeric characters plus underscore) which is to be agreed with Puppet.  This task also cleans up after itself by deleting the working directory and the temporary Authentication Token.

## Usage

To be updated with instructions on running each Task individually.

## Development

This module is developed and maintained by the Puppet Support and Technical Sales teams.
