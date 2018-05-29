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

enable_obs_workers:
  file.replace:
    - name: /etc/default/obsworker
    - pattern: '^ENABLED=0'
    - repl: 'ENABLED=1'
    - count: 1

{% if salt['grains.get']('api_setup') != 'done' %}
setup_obs_api:
  cmd.run:
    - name: /usr/share/obs/api/script/rake-tasks.sh setup
    - cwd: /usr/share/obs/api
  grains.present:
    - name: api_setup
    - value: done
{% endif %}

restart_apache:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - setup_obs_api
