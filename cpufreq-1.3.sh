#!/bin/bash
sudo cpufreq-set -f 1.30GHz -c0
sudo cpufreq-set -f 1.30GHz -c1
cpufreq-info | grep "current CPU"
exit 0
