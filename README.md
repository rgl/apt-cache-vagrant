This is a [Vagrant](https://www.vagrantup.com/) Environment for a APT Caching Proxy server using the [Apt-Cacher NG](https://www.unix-ag.uni-kl.de/~bloch/acng/) daemon.

# Usage

Install the [Ubuntu 20.04 box](https://github.com/rgl/ubuntu-vagrant).

Run `vagrant up --no-destroy-on-error cache` to launch the APT Caching Proxy server.

Run `vagrant up --no-destroy-on-error ubuntu` to launch an Ubuntu client configured to use the `cache` server.

Visit http://10.10.10.3:3142/acng-report.html and click the "Count Data"
button to see the cache statistics. You'll notice a lot of cache misses.
The next client runs will have an improved cache efficiency and will be
a lot faster. To see that happening, re-create the `ubuntu` client (and
also re-check the cache statistics page):

```bash
vagrant destroy -f ubuntu
vagrant up --no-destroy-on-error ubuntu
```
