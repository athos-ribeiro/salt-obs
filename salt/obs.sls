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

/tmp/debian_8.xml:
  file.managed:
    - source: salt://files/debian_8.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_8.conf:
  file.managed:
    - source: salt://files/debian_8.conf
    - user: root
    - group: root
    - mode: 644

/tmp/debian_9.xml:
  file.managed:
    - source: salt://files/debian_9.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_9.conf:
  file.managed:
    - source: salt://files/debian_9.conf
    - user: root
    - group: root
    - mode: 644

/tmp/debian_testing.xml:
  file.managed:
    - source: salt://files/debian_testing.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_testing.conf:
  file.managed:
    - source: salt://files/debian_testing.conf
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

/tmp/debian_8_test.xml:
  file.managed:
    - source: salt://files/debian_8_test.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_9_test.xml:
  file.managed:
    - source: salt://files/debian_9_test.xml
    - user: root
    - group: root
    - mode: 644

/tmp/debian_testing_test.xml:
  file.managed:
    - source: salt://files/debian_testing_test.xml
    - user: root
    - group: root
    - mode: 644

/usr/lib/obs/service/clang_build.service:
  file.managed:
    - source: salt://files/clang_build.service
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

/usr/lib/obs/service/clang_build:
  file.managed:
    - source: salt://files/clang_build
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

set_obs_instance_configurations:
  cmd.run:
    - name: osc -A https://localhost:443 api /configuration -T /tmp/obs_instance_configuration.xml

create_debian_8_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:8 -F /tmp/debian_8.xml

configure_debian_8_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prjconf Debian:8 -F /tmp/debian_8.conf

create_debian_9_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:9 -F /tmp/debian_9.xml

configure_debian_9_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prjconf Debian:9 -F /tmp/debian_9.conf

create_debian_testing_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:Testing -F /tmp/debian_testing.xml

configure_debian_testing_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prjconf Debian:Testing -F /tmp/debian_testing.conf

create_debian_unstable_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:Unstable -F /tmp/debian_unstable.xml

configure_debian_unstable_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prjconf Debian:Unstable -F /tmp/debian_unstable.conf

create_debian_clang_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:Unstable:Clang -F /tmp/debian_clang.xml

create_debian_8_test_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:8:test -F /tmp/debian_8_test.xml

create_debian_9_test_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:9:test -F /tmp/debian_9_test.xml

create_debian_testing_test_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:Testing:test -F /tmp/debian_testing_test.xml

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
    - hour: '*/4'
