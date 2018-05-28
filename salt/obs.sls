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

patch1_obs_api_gemfile_lock:
  cmd.run:
    - name: sed -i 's/sass (3.4.22)/sass (3.4.23)/' /usr/share/obs/api/Gemfile.lock

patch2_obs_api_gemfile:
  cmd.run:
    - name: sed -i 's/^group :assets do$//' /usr/share/obs/api/Gemfile

patch3_obs_api_gemfile:
  cmd.run:
    - name: sed -i '93s/^end$//' /usr/share/obs/api/Gemfile

enable_apache_ssl_module:
  cmd.run:
    - name: a2enmod ssl

enable_apache_headers_module:
  cmd.run:
    - name: a2enmod headers

enable_apache_expires_module:
  cmd.run:
    - name: a2enmod expires

disable_default_apache2_site:
  cmd.run:
    - name: a2dissite 000-default.conf

enable_obs_site:
  cmd.run:
    - name: a2ensite obs

# set files on log and api dir to www-data
/usr/share/obs/api:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

/var/log/obs:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group

{% if salt['grains.get']('db_setup') != 'done' %}
setup_database:
  cmd.run:
    - name: "RAILS_ENV=production bundle exec rake db:setup"
    - cwd: /usr/share/obs/api
  grains.present:
    - name: db_setup
    - value: done
{% endif %}

compile_assets:
  cmd.run:
    - name: "RAILS_ENV=production bundle exec rake assets:precompile"
    - cwd: /usr/share/obs/api

restart_apache:
  service.running:
    - name: apache2
    - enable: True
    - watch_any:
      - enable_obs_site
      - disable_default_apache2_site
      - file: /var/log/obs
      - file: /usr/share/obs/api
      - compile_assets
