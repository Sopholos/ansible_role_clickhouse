ansible-clickhouse 
=========
![Build Status](https://github.com/alexeysetevoi/ansible-clickhouse/actions/workflows/ci.yml/badge.svg?branch=master)
[![Build Status](https://travis-ci.org/AlexeySetevoi/ansible-clickhouse.svg?branch=master)](https://travis-ci.org/github/AlexeySetevoi/ansible-clickhouse)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/alexeysetevoi/ansible-clickhouse)](https://galaxy.ansible.com/alexeysetevoi/clickhouse)
[![Ansible Galaxy](https://img.shields.io/badge/role-alexeysetevoi.clickhouse-blue.svg)](https://galaxy.ansible.com/alexeysetevoi/clickhouse/)

Simple clickhouse-server deploy and management role.
Any issues and pr are welcome.

Role Variables
--------------
F: You can specify a particular version (or `*` for the latest). Please note that downgrade isn't supported.
```yaml
clickhouse_version: "19.11.3.11"
```

F: You can manage listen ports
```yaml
clickhouse_http_port: 8123
clickhouse_tcp_port: 9000
clickhouse_interserver_http: 9009
clickhouse_keeper_port: 9181
```
F: You can add listen ips on top of defaults:
```yaml
clickhouse_listen_host_custom:
  - "192.168.0.1"
```

F: you can manage ttl query_log:
```yaml
clickhouse_query_log_ttl: 'event_date + INTERVAL 7 DAY DELETE'
```
F: you can manage ttl query_thread_log:
```yaml
clickhouse_query_thread_log_ttl: 'event_date + INTERVAL 7 DAY DELETE'
```

F: Or you can specify ips directly e.g. to listen on all ipv4 and ipv6 addresses:
```yaml
clickhouse_listen_host:
  - "::"
```

F: You can create custom profiles
```yaml
clickhouse_profiles_custom:
 my_custom_profile:
   max_memory_usage: 10000000000
   use_uncompressed_cache: 0
   load_balancing: random
   my_super_param: 9000
```

Allow any plain k-v. Transform to xml
```xml
<profiles>
    <!-- Profiles of settings. -->
    <!-- Default profiles. -->
        <default>
            <max_memory_usage>10000000000</max_memory_usage>
            <load_balancing>random</load_balancing>
            <use_uncompressed_cache>0</use_uncompressed_cache>
        </default>
        <readonly>
            <readonly>1</readonly>
        </readonly>
        <!-- Default profiles end. -->
        <!-- Custom profiles. -->
        <my_custom_profile>
            <max_memory_usage>10000000000</max_memory_usage>
            <load_balancing>random</load_balancing>
            <use_uncompressed_cache>0</use_uncompressed_cache>
            <my_super_param>9000</my_super_param>
        </my_custom_profile>
        <!-- Custom profiles end. -->
</profiles>
```

F: You can create custom users:
```yaml
clickhouse_users_custom:
      - { name: "testuser",
          password_sha256_hex: "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2",
          networks: "{{ clickhouse_networks_default }}",
          profile: "default",
          quota: "default",
          dbs: [ testu1 ] ,
          comment: "classic user with plain password"}
      - { name: "testuser2",
          password: "testplpassword",
          networks: "{{ clickhouse_networks_default }}",
          profile: "default",
          quota: "default",
          dbs: [ testu2 ] ,
          comment: "classic user with hex password"}
      - { name: "testuser3",
          password: "testplpassword",
          networks: { 192.168.0.0/24, 10.0.0.0/8 },
          profile: "default",
          quota: "default",
          dbs: [ testu1,testu2,testu3 ] ,
          comment: "classic user with multi dbs and multi-custom network allow password"}
      - { name: "testuser4",
          ldap_server: "example_ldap_server",
          networks: { 192.168.0.0/24, 10.0.0.0/8 },
          profile: "default",
          quota: "default",
          dbs: [ testu1,testu2,testu3 ] ,
          comment: "external authentication using ldap_server definition"}
```

F: You can manage own quotas:
```yaml
clickhouse_quotas_custom:
 - { name: "my_custom_quota", intervals: "{{ clickhouse_quotas_intervals_default }}",comment: "Default quota - count only" }
```
Quote object is simple dict:
```yaml
 - { duration: 3600, queries: 0, errors: 0,result_rows: 0,read_rows: 0,execution_time: 0 }
```

F: You can create any databases:
default db state - present
```yaml
clickhouse_dbs_custom:
      - { name: testu1 }
      - { name: testu2 }
      - { name: testu3 }
      - { name: testu4, state: absent }
      - { name: testu5, state: present }
      - { name: testu6, state: absent, cluster: testu6 }
      - { name: testu7, state: present, cluster: testu7 }
      - { name: testu8, state: absent, cluster: testu8, engine: Lazy(3600) }
      - { name: testu9, state: present, cluster: testu9, engine: Lazy(3600) }

```

F: You can create dictionary via `odbc`:
```yaml
clickhouse_dicts:
  test1:
    name: test_dict
    odbc_source:
      connection_string: "DSN=testdb"
      source_table: "dict_source"
    lifetime:
      min: 300
      max: 360
    layout: hashed
    structure:
      key: "testIntKey"
      attributes:
        - { name: testAttrName, type: UInt32, null_value: 0 }
  test2:
    name: test_dict
    odbc_source:
      connection_string: "DSN=testdb"
      source_table: "dict_source"
    lifetime:
      min: 300
      max: 360
    layout: complex_key_hashed
    structure:
      key:
        attributes:
          - { name: testAttrComplexName, type: String }
      attributes:
        - { name: testAttrName, type: String, null_value: "" }
```

Or `file`:
```yaml
clickhouse_dicts:
  geoip_asn_blocks_ipv4:
    name: geoip_asn_blocks_ipv4
    source:
      type: file
      file:
        path: "{{ clickhouse_path_configdir }}/GeoLite2-ASN-Blocks-IPv4.csv"
        format: "CSVWithNames"
    lifetime:
      min: "300"
      max: "600"
    layout: ip_trie
    structure:
      key:
        attributes:
          - { name: "prefix", type: "String" }
      attributes:
        - { name: "autonomous_system_number", type: "UInt32", null_value: "0" }
        - { name: "autonomous_system_organization", type: "String", null_value: "?" }
```

F: Flag for remove clickhouse from host(disabled by default)
```yaml
clickhouse_remove: no
```

F: You can manage [Kafka configuration](https://clickhouse.com/docs/en/engines/table-engines/integrations/kafka/#configuration)
```yaml
# global configuration
clickhouse_kafka_config:
  auto_offset_reset: smallest
  debug: cgrp
# topic-level configuration
clickhouse_kafka_topics_config:
  topic1:
    retry_backoff_ms: 250
    fetch_min_bytes: 100000
  topic2:
    retry_backoff_ms: 300
    fetch_min_bytes: 120000
```

F: You can manage [LDAP Server configuration](https://clickhouse.com/docs/en/operations/external-authenticators/ldap/#ldap-server-definition)
```yaml
clickhouse_ldap_servers:
  # Debug with ldapwhoami -H '<host>' -D '<bind_dn>' -w <password>
  example_ldap_server:
    host: "ldaps.example.com"
    port: "636"
    bind_dn: "EXAMPLENET\\{user_name}"
    verification_cooldown: "300"
    enable_tls: "yes"
    tls_require_cert: "demand"
```

F: You can manage [LDAP External User Directory](https://clickhouse.com/docs/en/operations/external-authenticators/ldap/#ldap-external-user-directory)
```yaml
# Helpful guide on https://altinity.com/blog/integrating-clickhouse-with-ldap-part-two
clickhouse_ldap_user_directories:
  - server: "example_ldap_server"
    roles:
      - "ldap_user"
    role_mapping:
      base_dn: "ou=groups,dc=example,dc=com"
      attribute: "CN"
      scope: "subtree"
      search_filter: "(&amp;(objectClass=group)(member={user_dn}))"
      prefix: "clickhouse_
```

F: You can manage Merge Tree config. For the list of available parameters, see [MergeTree tables settings](https://clickhouse.com/docs/en/operations/settings/merge-tree-settings/).
```yaml
clickhouse_merge_tree_config:
  max_suspicious_broken_parts: 5
  parts_to_throw_insert: 600
```

F: You can configure ClickHouse Keeper, as an alternative to Zookeeper. For a list of available parameters, see [Configuring ClickHouse Keeper](https://clickhouse.com/docs/en/guides/sre/keeper/clickhouse-keeper). The items in the following variable will end up in the `raft_configuration`. Mutually exclusive with `clickhouse_zookeeper_nodes`.
```yaml
clickhouse_keeper_id: 1 # This machine's ID
clickhousekeeper_nodes:
  - id: 1
    hostname: "host1"
    port: 9234 # use Raft Port here
  - id: 2
    hostname: "host2"
    port: 9234
```

The following vars for ClickHouse Keeper have sane defaults, but are adjustable:
```yaml
clickhouse_keeper_port: 9181
clickhouse_path_chk: /var/lib/clickhouse/coordination
clickhouse_path_chk_log: /var/lib/clickhouse/coordination/log
clickhouse_path_chk_snap: /var/lib/clickhouse/coordination/snapshots
```

F: You can manage [Query Cache](https://clickhouse.com/docs/en/operations/query-cache)
```yaml
clickhouse_query_cache:
  max_size_in_bytes: 1073741824
  max_entries: 1024
  max_entry_size_in_bytes: 1048576
  max_entry_size_in_rows: 30000000
```

F: You can integrate [S3](https://clickhouse.com/docs/en/integrations/s3#s3-backed-mergetree)
```yaml
clickhouse_storage:
  disks:
    s3_disk:
      type: s3
      endpoint: 'https://YOUR_S3_URL/'
      access_key_id: 'YOUR_ACCESS_KEY'
      secret_access_key: 'YOUR_SECRET_KEY'
      cache_path: '/var/lib/clickhouse/disks/s3_disk/cache/'
      metadata_path: '/var/lib/clickhouse/disks/s3_disk/'
      cache_enabled: 'true'
      data_cache_enabled: 'true'
  policies:
    s3_policy:
      volumes:
        main:
          disk: 's3_disk'
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:
```yaml
  - hosts: clickhouse_cluster
    remote_user: root
    vars:
      clickhouse_users_custom:
          - { name: "testuser",
              password_sha256_hex: "f2ca1bb6c7e907d06dafe4687e579fce76b37e4e93b7605022da52e6ccc26fd2",
              networks: "{{ clickhouse_networks_default }}",
              profile: "default",
              quota: "default",
              dbs: [ testu1 ] ,
              comment: "classic user with plain password"}
          - { name: "testuser2",
              password: "testplpassword",
              networks: "{{ clickhouse_networks_default }}",
              profile: "default",
              quota: "default",
              dbs: [ testu2 ] ,
              comment: "classic user with hex password"}
          - { name: "testuser3",
              password: "testplpassword",
              networks: { 192.168.0.0/24, 10.0.0.0/8 },
              profile: "default",
              quota: "default",
              dbs: [ testu1,testu2,testu3 ] ,
              comment: "classic user with multi dbs and multi-custom network allow password"}
      clickhouse_query_log_ttl: 'event_date + INTERVAL 7  DELETE'
      clickhouse_query_thread_log_ttl: 'event_date + INTERVAL 7  DELETE'
      clickhouse_dicts:
          test1:
            name: test_dict
            odbc_source:
              connection_string: "DSN=testdb"
              source_table: "dict_source"
            lifetime:
              min: 300
              max: 360
            layout: hashed
            structure:
              key: "testIntKey"
              attributes:
                - { name: testAttrName, type: UInt32, null_value: 0 }
          test2:
            name: test_dict
            odbc_source:
              connection_string: "DSN=testdb"
              source_table: "dict_source"
            lifetime:
              min: 300
              max: 360
            layout: complex_key_hashed
            structure:
              key:
                attributes:
                  - { name: testAttrComplexName, type: String }
              attributes:
                - { name: testAttrName, type: String, null_value: "" }
      clickhouse_dbs_custom:
         - { name: testu1 }
         - { name: testu2, state:present }
         - { name: testu3, state:absent }
      clickhouse_clusters:
        your_cluster_name:
          shard_1:
              - { host: "db_host_1", port: 9000 }
              - { host: "db_host_2", port: 9000 }
          shard_2:
              - { host: "db_host_3", port: 9000 }
              - { host: "db_host_4", port: 9000 }       
      clickhouse_zookeeper_nodes:
        - { host: "zoo_host_1", port: 2181 }
        - { host: "zoo_host_2", port: 2181 }
        - { host: "zoo_host_3", port: 2181 }
    roles:
      - ansible-clickhouse
```

To generate macros: in file host_vars\db_host_1.yml
```yaml
clickhouse_macros:
  layer: 01
  shard: "your_shard_name"
  replica: "db_host_1"
```

To automate detection of `shard` macro value based on `clickhouse_clusters` dict
(given that `ansible_hostname` resolves to `db-host-?`):
```yaml
- hosts: clickhouse_cluster
  remote_user: root
  vars:
    clickhouse_clusters:
      your_cluster_name:
        shard_1:
          settings:
            weight: "1"
          hosts:
          - { host: "db-host-1", port: 9000 }
          - { host: "db-host-2", port: 9000 }
        shard_2:
          settings:
            weight: "2"
          hosts:
          - { host: "db-host-3", port: 9000 }
          - { host: "db-host-4", port: 9000 }       
    clickhouse_macros:
      shard: "{{ this_shard }}"
      replica: "{{ ansible_hostname }}"
  tasks:
    - name: get shard of host
      set_fact:
        this_shard: "{{ item.0.key }}"
      loop: "{{ clickhouse_clusters.your_cluster_name | dict2items | subelements('value') }}"
      when: item.1.host == ansible_hostname
```

Security harden the cluster. You can configure the cluster with extra settings
which enables
- HTTPS port
- TLS Encrypted TCP port
- HTTPS for data replication
- Credentials for data replication
- Secret validation for distributed queries
- ZooKeeper ACL
```yaml
- hosts: clickhouse_cluster
  become: true
  roles:
    - ansible-clickhouse
  vars:
    # HTTPS instead of normal HTTP
    clickhouse_https_port: 8443
    # TLS encryption for the native TCP protocol (needs `clickhouse-client --secure`)
    clickhouse_tcp_secure_port: 9440
    # TLS encryption between nodes in cluster
    clickhouse_interserver_https: 9010
    # Credentials used to authenticate nodes during data replication
    clickhouse_interserver_http_credentials:
      user: "internal"
      password: "supersecretstring"
    # Secret used to validate nodes in cluster for distributed queries
    clickhouse_distributed_secret: "supersecretstring2"
    # Password protect zookeeper paths used by ClickHouse
    clickhouse_zookeeper_identity:
      user: "zoo_user"
      password: "secretzoostring"
    # OpenSSL settings
    clickhouse_ssl_server:
      certificate_file: "/etc/clickhouse-server/server.crt"
      private_key_file: "/etc/clickhouse-server/server.key"
      dh_params_file: "/etc/clickhouse-server/dhparam.pem"
      verification_mode: "none"
      load_default_ca_file: "true"
      cache_sessions: "true"
      disable_protocols: "sslv2,sslv3"
      prefer_server_ciphers: "true"
    clickhouse_clusters:
      your_cluster_name:
        shard_1:
          - host: "db_host_1"
            port: 9440
            secure: true
          - host: "db_host_2"
            port: 9440
            secure: true
        shard_2:
          - host: "db_host_3"
            port: 9440
            secure: true
          - host: "db_host_4"
            port: 9440
            secure: true
    clickhouse_zookeeper_nodes:
      - host: "zoo_host_1"
        port: 2181
      - host: "zoo_host_2"
        port: 2181
      - host: "zoo_host_3"
        port: 2181
```

F: You can call separately stages(from playbook, external role etc.):

Tag | Action
------------ | -------------
install | Only installation of packages
config_sys | Only configuration system configs(users.xml and config.xml)
config_db | Only add&remove databases
config_sys | Only regenerate dicts
config | config_sys+config_db

License
-------

BSD

Author Information
------------------

[ClickHouse](https://clickhouse.com/docs/en/index.html) by [ClickHouse, Inc.](https://clickhouse.com/company/).

Role by [AlexeySetevoi](https://github.com/AlexeySetevoi).

Dear contributors, thank you.
