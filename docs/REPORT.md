# Healthcheck Lite Report for $customer <!-- omit in toc -->
Date: dd Month yyyy

- [Introduction](#introduction)
- [Environment overview](#environment-overview)
- [Architecture](#architecture)
- [Performance](#performance)
- [Configuration notes](#configuration-notes)
- [Thundering herd query results](#thundering-herd-query-results)
- [Code practices](#code-practices)
- [Code warnings](#code-warnings)
- [Conclusions and Recommendations](#conclusions-and-recommendations)
- [Ticket history](#ticket-history)

# Introduction

Healthcheck Lite is a Puppet assessment offered to \$customer. The goals of Healthcheck Lite are:

- Create a snapshot \$customer's Puppet Infrastructure architecture
- Review configuration of the Primary Master, PuppetDB, Compile Masters, code
- Gather performance metrics
- Suggest improvements to the Puppet infrastructure that ensure problem-free operation

The report is produced using the following tools / practices:

1. Supplying \$customer with the 'healthcheck_lite' analysis tool to be executed on the Primary Master and analysing its output
2. A conversation about the network architecture and other relevant topics

# Environment overview

| Report date / time  | dd Month yyyy          |
| ------------------- | ---------------------- |
| Number of nodes     | \$nodes_count          |
| Licenced nodes      | \$licenced_nodes_count |
| License valid until | dd Month yyyy          |

# Architecture

| Report date / time              | dd Month yyyy hh:mm:ss ZZZ                     | color |
| ------------------------------- | ---------------------------------------------- | ----- |
| Type of installation            | \$installation_type                            |       |
| High Availability configuration | Yes/No                                         |       |
| Master node                     | $master_hostname                               |       |
| PuppetDB node                   | $puppetdb_hostname                             |       |
| Console node                    | $console_hostname                              |       |
| Compilers                       | $compiler_hostname1, \$compiler_hostname2, ... |       |

# Performance

| Report date / time | dd Month yyyy hh:mm:ss ZZZ | color |
| ------------------ | -------------------------- | ----- |
| Master certname    | $master_certname           |       |
| CPU summary        | $cpu_summary               |       |
| RAM summary        | $ram_summary               |       |
| Storage summary    | $performance_summary       |       |
| Database summary   | $database_summary          |       |
| Java VM summary    | $jvm_summary               |       |

# Configuration notes

# Thundering herd query results

A thundering herd is a simultaneous rush of nodes attempting to check in with the master simultaneously for a new catalog. This can result in reduced performance and potentially result in failures if the master is underprovisioned.

A [thundering herd query](https://support.puppet.com/hc/en-us/articles/215729277) requests the number of agent check-ins per minute from PuppetDB to determine whether check-ins are being evenly distributed.

| Month  | Day  | Hour  | Minute  | Count  |
| ------ | ---- | ----- | ------- | ------ |
| $month | $day | $hour | $minute | $count |
| $month | $day | $hour | $minute | $count |

# Code practices

| Report date / time                          | dd Month yyyy hh:mm:ss ZZZ | color |
| ------------------------------------------- | -------------------------- | ----- |
| Number of environments                      | $environment_count         |       |
| Number of modules in production environment | $production_modules_count  |       |

# Code warnings

# Conclusions and Recommendations

# Ticket history

- Support tickets in the last 12 months: $tickets_count_last_year
- Named support contacts with cases: $support_contacts
