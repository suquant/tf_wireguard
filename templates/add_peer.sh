#!/bin/bash

set -e

(wg show ${interface} peers | grep "${public_key}") || (
    wg set ${interface} peer ${public_key} endpoint ${ip}:${port} allowed-ips ${allowed_cidr}
)