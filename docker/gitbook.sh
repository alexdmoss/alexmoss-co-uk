#!/bin/sh -eux
#
#------------------------------------------------------------------------------
# [Alex Moss, 2017-07-21]
#------------------------------------------------------------------------------
# Builds a docker image to allow running of Gitbook build commands.
# Heavily based on https://github.com/humangeo/gitbook-docker/
#------------------------------------------------------------------------------

#GITBOOK_CLI_VERSION="2.3.0"
GITBOOK_CLI_VERSION="2.3.2"
apt-get update
apt-get install -y --no-install-recommends git calibre
npm install -g gitbook-cli@$GITBOOK_CLI_VERSION
#npm install gitbook-plugin-bring-yer-favicon
#npm install gitbook-plugin-ga
#npm install gitbook-plugin-image-class
gitbook fetch latest

# add gitbook wrapper script
cat <<EOF > /usr/local/bin/gitbookw
#!/bin/sh -eu
# gitbookw --- Wrapper for gitbook that autoinstalls plugins.
gitbook install
gitbook \$@
EOF
chmod +x /usr/local/bin/gitbookw

apt-get clean
apt-get autoclean
apt-get autoremove

rm -rf /var/lib/apt/lists/* /var/cache/apt/* /root/.npm /tmp/npm*

# Directory to load into
mkdir -p /docs
