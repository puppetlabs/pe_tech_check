
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


### Setup Requirements

While the HealthCheck Lite module does not have any hard dependencies, it is recommended that the puppetlabs/puppet_metrics_collector module is installed and enabled at least 24 hours before the Tasks in this module are executed, to ensure as much pertinent information is captured as possible

### Beginning with healthcheck_lite

To use this module, please simply run the Tasks it provides on the relevant nodes, and provide the resultant tarball to Puppet for analysis as part of a defined HealthCheck Lite engagement.

## Usage

Please run the datacapture Task to capture additional information not included in the Support Script.
This Task should be run on the Master/Master of Masters in either a monolithic or split configuration, whether Compile Masters are present or not.

## Development

This module is developed and maintained by the Puppet Support and Technical Sales teams.
