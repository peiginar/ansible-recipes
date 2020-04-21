#!/bin/bash
# Usage:
#   $ (proxy_enable)
#   $ sudo -E ./install-docker.sh
set -xe
dns_server=
dns_domain=
inet_lookup() {
  wget -q -O/dev/null --connect-timeout=5 https://github.com/
}
do_remove_old_docker() {
  apt remove -y docker docker-engine docker.io containerd runc
}
do_install_docker() {
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  apt-key fingerprint 0EBFCD88
  local distr="stable"
  local codename="$(lsb_release -cs)"
  #test "$codename" = "focal" && distr="${distr} edge"
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $codename ${distr}"
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io

  if [ -n "$http_proxy" ]; then
    mkdir -p /etc/systemd/system/docker.service.d/
    tee /etc/systemd/system/docker.service.d/docker-options.conf <<-_
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0 -H unix:///var/run/docker.sock --dns ${dns_server} --dns-search ${dns_domain}
Environment="http_proxy=${http_proxy}" "https_proxy=${http_proxy}" "no_proxy=localhost,127.0.0.1,.local,.${dns_domain}"
_
    systemctl daemon-reload
    systemctl show docker --property Environment --property  ExecStart| cat
    systemctl restart docker
  fi
  docker search ubuntu > /dev/null

  local uid="$(id -un)"
  [ -n "$SUDO_USER" ] && uid="$SUDO_USER"
  [ "$uid" != "root" ] && usermod -aG docker $uid
  return 0
}
do_install_compose() {
  local cmd=$(curl -sSL https://github.com/docker/compose/releases| grep curl| head -n1| sed 's/.*>//')
  eval $cmd
  chmod +x /usr/local/bin/docker-compose
  docker-compose -v
  return 0
}
inet_lookup
do_remove_old_docker
do_install_docker
do_install_compose
echo done...

# vim: set ts=2 sw=2 et:
