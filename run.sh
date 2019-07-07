#!/usr/bin/env bash

docker run \
	--rm \
	--env MAIL_ORIGIN \
	--env ORIGIN_USER \
	--env ORIGIN_USER_PASSWORD \
	--env MAIL_DESTINATION \
	--env DEST_USER \
	--env DEST_USER_PASSWORD \
	nexus166/imapsync
