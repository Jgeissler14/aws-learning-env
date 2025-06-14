# Ansible Examples

This folder contains a minimal playbook and role used in the tutorial. The `common.yml` playbook installs basic packages on hosts listed in `inventory`.

Run the playbook from the repository root with:

```
ansible-playbook ansible/common.yml
```

For advanced tasks, explore the `roles/common` directory. This role installs the Datadog agent only if it is missing and shows how to use variables and conditionals.
