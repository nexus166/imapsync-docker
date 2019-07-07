#!/usr/bin/env bash

set -xeuo pipefail

docker build \
	--squash \
	--rm --file Dockerfile \
	--tag nexus166/imapsync \
	.
