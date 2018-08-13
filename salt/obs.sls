/etc/apt/sources.list:
  file.managed:
    - source: salt://files/sources.list
    - user: root
    - group: root
    - mode: 644

/etc/hosts:
  file.managed:
    - source: salt://files/etc-hosts
    - user: root
    - group: root
    - mode: 644

refresh_packages_db:
  cmd.run:
    - name: apt-get update -y
    - onchanges:
      - file: /etc/apt/sources.list

install_apache:
  pkg.installed:
    - pkgs:
      - apache2

install_obs_packages:
  pkg.installed:
    - pkgs:
      - obs-server
      - obs-api
      - obs-worker
      - osc

install_obs_build_from_backports:
  pkg.latest:
    - pkgs:
      - obs-build
    - fromrepo: stretch-backports

install_libsolv_from_testing:
  pkg.latest:
    - pkgs:
      - libsolv0
      - libsolv-perl
      - libsolvext0
    - fromrepo: buster

/usr/share/obs/api/Gemfile:
  file.managed:
    - source: salt://files/Gemfile
    - user: root
    - group: root
    - mode: 644

/etc/default/obsworker:
  file.managed:
    - source: salt://files/obsworker
    - user: root
    - group: root
    - mode: 644

{% if salt['grains.get']('api_setup') != 'done' %}
setup_obs_api:
  cmd.run:
    - name: /usr/share/obs/api/script/rake-tasks.sh setup
    - cwd: /usr/share/obs/api
  grains.present:
    - name: api_setup
    - value: done

restart_apache:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - setup_obs_api
{% endif %}

start_obsservice:
  service.running:
    - name: obsservice
    - enable: True

/root/.oscrc:
  file.managed:
    - source: salt://files/oscrc
    - user: root
    - group: root
    - mode: 600

/tmp/obs_instance_configuration.xml:
  file.managed:
    - source: salt://files/obs_instance_configuration.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_unstable.xml:
  file.managed:
    - source: salt://files/debian_unstable.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_unstable.conf:
  file.managed:
    - source: salt://files/debian_unstable.conf
    - user: root
    - group: root
    - mode: 644

/tmp/debian_clang.xml:
  file.managed:
    - source: salt://files/debian_clang.xml
    - user: root
    - group: root
    - mode: 644

trust_self_cert:
  cmd.run:
    - name: c_rehash /etc/ssl/certs/

restart_obssrcserver:
  service.running:
    - name: obssrcserver
    - enable: True
    - watch:
      - trust_self_cert

set_obs_instance_configurations:
  cmd.run:
    - name: osc -A https://localhost:443 api /configuration -T /tmp/obs_instance_configuration.xml

create_debian_unstable_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:Unstable -F /tmp/debian_unstable.xml

configure_debian_unstable_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prjconf Debian:Unstable -F /tmp/debian_unstable.conf

create_debian_clang_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:Unstable:Clang -F /tmp/debian_clang.xml

/usr/local/bin/trigger_clang_build:
  file.managed:
    - source: salt://files/trigger_clang_build
    - user: root
    - group: root
    - mode: 755

build_obs_clang_build_package:
  cmd.run:
    - name: trigger_clang_build obs-service-clang-build

/usr/local/bin/check_new_uploads:
  file.managed:
    - source: salt://files/check_new_uploads
    - user: root
    - group: root
    - mode: 755
  cron.present:
    - user: root
    - minute: 15

/tmp/obs_service_clang_build_meta.xml:
  file.managed:
    - source: salt://files/obs_service_clang_build_meta.xml
    - user: root
    - group: root
    - mode: 644

allow_obs_service_clang_build_usage:
  cmd.run:
    - name: osc -A https://localhost:443 meta pkg Debian:Unstable:Clang obs-service-clang-build -F /tmp/obs_service_clang_build_meta.xml
