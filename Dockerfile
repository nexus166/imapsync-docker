FROM	debian:buster-slim
SHELL	["/bin/bash", "-xeo", "pipefail", "-c"]

ARG	IMAPSYNC_VCS="https://github.com/imapsync/imapsync.git"
ARG	IMAPSYNC_VERSION

RUN	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update; \
	apt-get dist-upgrade -y; \
	apt install -y --no-install-recommends \
		automake build-essential ca-certificates cpanminus git libssl-dev make makepasswd procps rcs zlib1g-dev; \
	apt install -y --no-install-recommends libio-socket-inet6-perl libperl-dev perl perl-doc; \
	cpanm \
		File::Tail Authen::NTLM CGI Crypt::OpenSSL::RSA Data::Uniqid Digest::HMAC Digest::HMAC_MD5 \
		Dist::CheckConflicts File::Copy::Recursive IO::Socket::SSL IO::Tee \
		JSON JSON::WebToken JSON::WebToken::Crypt::RSA HTML::Entities LWP::UserAgent \
		Mail::IMAPClient Module::Implementation Module::Runtime Module::ScanDeps Net::SSLeay \
		Package::Stash Package::Stash::XS PAR::Packer Parse::RecDescent Readonly Regexp::Common \
		Sys::MemInfo Term::ReadKey Test::Fatal Test::Mock::Guard Test::MockObject Test::Pod \
		Test::Requires Test::Deep Try::Tiny Unicode::String URI::Escape; \
	git clone "${IMAPSYNC_VCS}" /usr/src/imapsync; \
	cd /usr/src/imapsync; \
	[[ ! -z "${IMAPSYNC_VERSION}" ]] && git checkout "tags/${IMAPSYNC_VERSION}"; \
	make install -j"${nproc}"; \
	apt-get remove --purge --autoremove -y \
		automake build-essential cpanminus git make zlib1g-dev perl-doc; \
	apt-get clean; \
	apt-get autoclean; \
	rm -fr /usr/src/imapsync ~/.cpan /tmp/*

ARG     user=imapsync
RUN     export GRPID="$(shuf -i 2000-3000 -n1)"; \
        addgroup --gid "${GRPID}" --system "${user}" ; \
        export USRID="$(shuf -i 3000-4000 -n1)"; \
        useradd --home /var/tmp --no-create-home --system --shell /sbin/nologin --gid "${GRPID}" --uid "${USRID}" "${user}"

RUN	{ \
		printf '#!/usr/bin/env bash\n'; \
		printf 'set -eo pipefail\n'; \
		printf '/usr/bin/imapsync --host1 ${MAIL_ORIGIN} --user1 ${ORIGIN_USER} --password1 ${ORIGIN_USER_PASSWORD} --host2 ${MAIL_DESTINATION} --user2 ${DEST_USER:-${ORIGIN_USER}} --password2 ${DEST_USER_PASSWORD:-${ORIGIN_USER_PASSWORD}} ${@}\n'; \
	} | tee /usr/local/bin/entrypoint.sh; \
	chmod -v +x /usr/local/bin/entrypoint.sh

SHELL	["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

USER	"${user}"
