Role Name
=========

A role that installs and configures the nginx web server and proxy

Role Variables
--------------

There are a lot of variables. See the **defaults/main.yml** file for a complete list. Here an example of how to setup a virtualhost:

``` yaml
nginx_virthosts:
  - virthost_name: '{{ ansible_fqdn }}'
    listen: '{{ http_port }}'
    server_name: '{{ ansible_fqdn }}'
    server_aliases: ''
    index: index.html
    error_page: /path_to_error_page.html
    ssl_enabled: False
    ssl_only: False
    ssl_letsencrypt_certs: '{{ nginx_letsencrypt_managed }}'
    root: {{ nginx_webroot }}
    server_tokens: 'off'
    proxy_standard_setup: True
    proxy_additional_options:
      - 'proxy_cache_path /tmp/nginx_cache levels=1:2 keys_zone=cache:30m max_size=250m;'
    locations:
      - location: /
        target: http://localhost:{{ local_http_port }}
```

Dependencies
------------

If basic ldap authentication is required: <git+https@gitea-s2i2s.isti.cnr.it:ISTI-ansible-roles/ansible-role-ldap-client-config.git>

License
-------

EUPL-1.2

Author Information
------------------

Andrea Dell'Amico, <andrea.dellamico@isti.cnr.it>
