install_common_packages:
  pkg.installed:
    - pkgs:
      - vim
      - osc

/usr/lib/python2.7/dist-packages/osc/util/debquery.py:
  file.managed:
    - source: salt://files/debquery.py
    - user: root
    - group: root
    - mode: 644
