# Ansible Playbook Tutorial

This guide walks you through creating a basic Ansible playbook. It is written for beginners who might not have a programming background.

## 1. What is Ansible?
Ansible is a tool that lets you automate tasks on other computers. You describe the tasks in a **playbook**, which is a text file written in YAML format.

## 2. Prerequisites
- A Linux machine (or WSL on Windows) with Python installed.
- Ansible installed (`pip install ansible` or `sudo apt install ansible`).
- Access to another machine or virtual machine that you can connect to with SSH.

## 3. Directory Structure
Create a folder named `ansible` inside this repository if it does not already exist.

```
aws-learning-env/
└── ansible/
    ├── ansible.cfg
    ├── inventory
    └── common.yml
```

## 4. The Inventory File
The **inventory** lists the computers Ansible will manage. Create a file called `inventory` in the `ansible/` directory:

```
[common_nodes]
your_server_ip
```

Replace `your_server_ip` with the IP address of the machine you want to manage.

## 5. The Configuration File
Create `ansible/ansible.cfg` so Ansible knows where the inventory file is:

```
[defaults]
inventory = inventory
```

## 6. Writing the Playbook
Create a file called `common.yml` in the `ansible/` directory. YAML is sensitive to **spaces** and **indentation**. Use two spaces for each level.

```
# code: language=ansible
---
- name: Common
  hosts: common_nodes
  gather_facts: true
  tasks:
    - name: Install common packages
      ansible.builtin.apt:
        update_cache: true
        pkg:
          - policycoreutils
        state: present
```

### YAML basics
- Lines starting with `-` define a list. Ensure the hyphen is followed by a space.
- Indentation matters. Use spaces, **not** tabs.
- Key and value are separated by `:`, with a space after the colon.
- Curly braces (`{{ }}`) are used for variables. We do not use any variables in this simple example.

## 7. Running the Playbook
From the repository root, run:

```
ansible-playbook ansible/common.yml
```

Ansible will connect to the host listed in `inventory` and install the package defined in the playbook.

## 8. Next Steps
- Add more tasks under the `tasks:` section using the same indentation style.
- Explore roles to organize tasks when your playbook grows larger.

## 9. Working with Variables
Variables let you reuse values and keep your playbooks tidy.

```yaml
- name: Install custom message of the day
  ansible.builtin.copy:
    content: "{{ motd_text }}"
    dest: /etc/motd
```

Set the `motd_text` variable in the playbook or load it from a file with `vars_files`.

## 10. Loops
Use a `loop` to repeat a task for multiple items.

```yaml
- name: Install extra packages
  ansible.builtin.apt:
    name: "{{ item }}"
    state: present
  loop:
    - git
    - htop
```

## 11. Conditionals
Tasks can run only when a condition is true.

```yaml
- name: Restart web service on Ubuntu
  ansible.builtin.service:
    name: apache2
    state: restarted
  when: ansible_facts['os_family'] == 'Debian'
```

## 12. Roles
As playbooks grow, organize tasks using **roles**. This repository includes a basic role at `ansible/roles/common`.
You include a role in a playbook like this:

```yaml
- hosts: common_nodes
  roles:
    - common
```

The `common` role checks whether the Datadog agent is installed, imports variables, and restarts the service if necessary.

## 13. Continue Learning
- Explore the [Ansible documentation](https://docs.ansible.com/) for more modules and examples.
- Experiment with additional roles to automate your own environment.
