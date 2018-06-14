/etc/apt/sources.list:
  file.managed:
    - source: salt://files/sources.list
    - user: root
    - group: root
    - mode: 644

refresh_packages_db:
  cmd.run:
    - name: apt-get update -y
    - onchanges:
      - file: /etc/apt/sources.list

install_obs_packages:
  pkg.installed:
    - pkgs:
      - obs-server
      - obs-api
      - obs-worker
      - osc

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

/tmp/test_proj.xml:
  file.managed:
    - source: salt://files/test_proj.xml
    - user: root
    - group: root
    - mode: 644

set_obs_instance_configurations:
  cmd.run:
    - name: osc -A https://localhost:443 api /configuration -T /tmp/obs_instance_configuration.xml

create_debian_8_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:8 -F /tmp/debian_8.xml

configure_debian_8_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prjconf Debian:8 -F /tmp/debian_8.conf

create_debian_unstable_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj Debian:Unstable -F /tmp/debian_unstable.xml

configure_debian_unstable_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prjconf Debian:Unstable -F /tmp/debian_unstable.conf

create_debian_clang_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj debclang -F /tmp/debian_clang.xml

create_test_project:
  cmd.run:
    - name: osc -A https://localhost:443 meta prj test -F /tmp/test_proj.xml

