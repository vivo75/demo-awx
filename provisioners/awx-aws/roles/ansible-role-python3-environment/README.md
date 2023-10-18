Role Name
=========

A role that installs python3, and python packages from pip eventually

Role Variables
--------------

The most important variables are listed below:

``` yaml
py3_env_install: False
py3_env_major_version: 3
py3_env_minor_version: 6
py3_env_version: '{{ py3_env_major_version }}.{{py3_env_minor_version }}'
py3_env_pkgs_state: present
py3_pip_pkgs_state: present
py3_env_site: False

py3_env_wheel_pip_pkgs: []
py3_env_pip_pkgs: []
py3_env_versioned_pip_pkgs: []
```

Dependencies
------------

None

License
-------

EUPL-1.2

Author Information
------------------

Andrea Dell'Amico, <andrea.dellamico@isti.cnr.it>
