#!/bin/bash
set -euxo pipefail

apt_proxy_url="${1:-http://10.10.10.3:3142}"; shift || true

#
# configure APT to use our cache APT proxy.
# see http://10.10.10.3:3142
# NB we cannot use APT::Update::Pre-Invoke because that is invoked after sources.list is
#    loaded, so we had to override the apt-get command with our own version.

echo "Acquire::http::Proxy \"$apt_proxy_url\";" >/etc/apt/apt.conf.d/00aptproxy
cat >/usr/local/bin/apt-get <<EOF
#!/bin/bash
if [ "\$1" == 'update' ]; then
    for p in \$(find /etc/apt/sources.list /etc/apt/sources.list.d -type f); do
        sed -i -E 's,(deb(-src)? .*)https://,\1$apt_proxy_url/,g' \$p
    done
fi
exec /usr/bin/apt-get "\$@"
EOF
chmod +x /usr/local/bin/apt-get
hash -r


#
# use APT to see it using our APT proxy. 

echo 'Defaults env_keep += "DEBIAN_FRONTEND"' >/etc/sudoers.d/env_keep_apt
chmod 440 /etc/sudoers.d/env_keep_apt
export DEBIAN_FRONTEND=noninteractive
apt-get update


#
# provision other packages to further see the APT cache proxy working.

apt-get install -y vim


#
# install docker to see whether an https repository can be used (and our
# /usr/local/bin/apt-get is working correctly).
# see https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository
# NB execute apt-cache madison docker-ce to known the available versions.
docker_version='20.10.13'
apt-get install -y apt-transport-https software-properties-common
wget -qO- https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-cache madison docker-ce
docker_package_version="$(apt-cache madison docker-ce | awk "/$docker_version~/{print \$3}")"
apt-get install -y "docker-ce=$docker_package_version" "docker-ce-cli=$docker_package_version" containerd.io
# let the vagrant user manage docker.
usermod -aG docker vagrant
