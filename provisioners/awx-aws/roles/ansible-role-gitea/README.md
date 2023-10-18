Role Name
=========

A role that installs the gitea git repository server, <https://gitea.io>

Role Variables
--------------

The most important variables are listed below:

``` yaml
gitea_version: 1.14.3
gitea_local_postgresql: True
gitea_local_mysql: False
gitea_local_mariadb: False
gitea_nginx_frontend: True
gitea_local_redis: True
gitea_local_memcache: True
gitea_app_configurations:
  - { section: 'mailer', option: 'ENABLED', value: 'true', state: 'present' }
  - { section: 'mailer', option: 'FROM', value: '{{ gitea_mail_from }}', state: 'present' }
  - { section: 'mailer', option: 'MAILER_TYPE', value: '{{ gitea_mailer_type }}', state: 'present' }
  - { section: 'mailer', option: 'SENDMAIL_PATH', value: '{{ gitea_sendmail_path }}', state: 'present' }
  - { section: 'metrics', option: 'ENABLED', value: 'true', state: 'present' }
  - { section: 'metrics', option: 'TOKEN', value: '{{ gitea_prometheus_bearer_token }}', state: 'present' }
gitea_install_viewer_addons: True
gitea_addons_deb_packages:
  - jupyter
  - asciidoctor
  - pandoc

gitea_markup_asciidoc_enabled: True
gitea_markup_jupyter_enabled: True
gitea_markup_restructuredtext_enabled: True
gitea_markup_sanitizer_tex_enabled: True
gitea_markup_markdown_enabled: True
gitea_prometheus_metrics: False
gitea_prometheus_bearer_token: 'Use a vault'
gitea_log_level: Info
```

Dependencies
------------

* nginx
* mysql, when a local mysql installation is required
* postgresql, when a local postgresql installation is required

License
-------

EUPL-1.2

Author Information
------------------

Andrea Dell'Amico, <andrea.dellamico@isti.cnr.it>
