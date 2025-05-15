# Project Title: Docker Management TUI Helper (DMTH)

1. Introduction & Vision

To develop a lightweight, TUI-based (Text User Interface) command-line tool using whiptail for simplifying daily Docker container and Docker Compose management tasks. The tool will operate primarily via Bash/sh scripts, with Python as an acceptable alternative for more complex logic. The paramount design goals are simplicity, ease of use, and efficient workflow for managing Docker environments across multiple local and remote hosts.

2. Core User Needs & Goals

Unified Interface: Provide a single, intuitive interface to manage Docker resources without needing to remember or type out lengthy Docker commands.
Multi-Host Management: Seamlessly switch between managing Docker instances on the local machine and pre-configured remote hosts via SSH.
Streamlined Stack Operations: Easily start, stop, update, and view the status of Docker Compose stacks.
Centralized & Secure Configuration: Manage environment variables for Docker Compose projects from a master file with host-specific overrides, ensuring sensitive data is handled appropriately.
Quick Status Checks: Quickly get an overview of running containers and stack health.

3. Key Features & Functionality

3.1. Host Management & Context Switching
* Local Host Detection: Automatically identify the current hostname (e.g., using hostname).
* Remote Host Configuration:
* Maintain a configuration file (e.g., ~/.dmth/hosts.conf or a section in a main config) listing remote hosts.
* Each remote host entry to include:
* Alias/Name (for TUI display)
* SSH User
* SSH Hostname/IP
* SSH Port (optional, defaults to 22)
* Path to SSH Identity File (optional, for key-based authentication)
* Base directory for Docker Compose projects on the remote host.
* TUI Host Selection: The main interface will allow users to select the target host (local or a configured remote host) for subsequent operations.

3.2. Docker Compose Project Structure
* Compose files are expected to be organized in directories named after their respective hostnames (e.g., [PROJECT_ROOT]/compose-files/[HOSTNAME]/docker-compose.yml).
* The tool should allow selection from multiple Docker Compose projects/stacks if found within a host's designated directory.

3.3. Docker & Docker Compose Operations (per selected host/stack)
* Stack Management:
* List Stacks: Display available Docker Compose projects for the selected host.
* Start Stack: Execute docker-compose up -d.
* Stop Stack: Execute docker-compose stop.
* Restart Stack: (Typically docker-compose stop then docker-compose up -d, or docker-compose restart).
* Down Stack: Execute docker-compose down (optionally with -v for volumes).
* Container & Stack Updates:
* Pull Images: For a selected stack, pull the latest images for all services (docker-compose pull).
* Update & Recreate Stack: Pull latest images and then recreate services (docker-compose up -d --remove-orphans --force-recreate).
* Status & Information:
* Stack Status: Display output of docker-compose ps for the selected stack.
* Container Status (Host-wide): Display output of docker ps -a (formatted for readability in TUI).
* View Logs: Stream logs for a selected stack or specific service within a stack (docker-compose logs -f --tail=N [service_name]).
* System Maintenance (Host-wide):
* Prune System: Offer options for docker system prune -af (with clear warnings).

3.4. Environment Variable Management (.env files)
* Master .env File:
* A single, master .env file (e.g., ~/.dmth/master.env) will store all common environment variables.
* Host-Specific Overrides:
* Variables in the master file can be made host-specific by prefixing them with the uppercase hostname and an underscore (e.g., MYHOST_DB_PASSWORD=secret would override a general DB_PASSWORD for host myhost).
* Secure Storage/Handling:
* The master.env file should have its permissions restricted (e.g., chmod 600).
* Option A (Simpler): Rely on file permissions.
* Option B (More Secure, more complex): Consider encrypting master.env with GPG, prompting for a passphrase at script startup. Initial preference for Option A due to simplicity, unless strong need for B is identified.
* Dynamic .env Generation:
* Before executing docker-compose commands for a specific stack on a specific host, the tool will:
1.  Read the master.env file.
2.  Identify and apply any relevant host-specific overrides for the target host.
3.  Generate a temporary .env file in the target stack's directory. This file will be used by Docker Compose.
4.  This generated .env file should be cleaned up after the operation if it contains sensitive data and is not meant to persist.

3.5. TUI (Text User Interface) - Whiptail
* Main Menu:
* Select Host (Local / Remote Host 1 / ...)
* Global Settings (if any)
* Exit
* Host-Specific Menu (after host selection):
* Manage Docker Compose Stacks
* View All Container Status (on this host)
* Docker System Prune (on this host)
* Back to Main Menu
* Stack Management Menu (after selecting "Manage ... Stacks"):
* List available stacks (from [PROJECT_ROOT]/compose-files/[HOSTNAME]/[STACK_NAME]/docker-compose.yml)
* Select a stack to perform actions on.
* Stack Action Menu (after selecting a stack):
* View Status
* Start
* Stop
* Restart
* Pull Images
* Update & Recreate
* View Logs
* Down Stack
* Back
* Use appropriate whiptail dialogs (menus, checklists, input boxes, message boxes, yes/no) for intuitive interaction.
* Provide clear feedback and progress indicators for operations.

4. Non-Vital / Optional Features (Future Enhancements)

SSH Key Management:
Basic functionality to generate new SSH key pairs (ssh-keygen).
Utility to copy a public key to a configured remote host (ssh-copy-id equivalent).
To be deferred if it significantly increases complexity for the initial version. Prioritize using existing SSH agent setups.
Git Integration for Compose Files: Option to perform a git pull within a stack's directory before updating, if the stack is managed under version control.
Advanced Configuration Validation: More robust checking of configuration files.
5. Technical Requirements & Constraints

Primary Language: Bash/sh.
Alternative Language: Python (for specific modules if Bash becomes too cumbersome, e.g., complex parsing or if a Python TUI library offers significant advantages over direct whiptail scripting for certain views).
TUI Library: whiptail.
Dependencies: docker, docker-compose, ssh, scp (for remote ops), whiptail, hostname. The script should perform a dependency check on startup.
Configuration Storage:
Main script location: User-defined.
Configuration directory: ~/.dmth/ (e.g., for hosts.conf, master.env).
Compose file base directory: User-configurable, e.g., ~/docker-projects/ containing compose-files/[HOSTNAME]/.
Error Handling: Implement comprehensive error checking for all external commands. Provide clear, user-friendly error messages.
Security: Prioritize secure handling of credentials and sensitive data. Leverage SSH agent forwarding where possible. Minimize storage of plain-text secrets.
6. Guiding Principles

Simplicity over Features: If a feature adds significant complexity for marginal benefit, it should be reconsidered or deferred.
Daily Usability: The tool must be fast, responsive, and intuitive for frequent use.
Non-Intrusive: The tool should work with existing Docker and Docker Compose setups without requiring major changes to them.
Idempotency (where applicable): Operations should be safe to run multiple times.
7. Open Questions & Areas for Clarification

Granularity of "Stack" Definition:
Is a "stack" always a single docker-compose.yml directly within compose-files/[HOSTNAME]/?
Or can compose-files/[HOSTNAME]/ contain multiple subdirectories, each representing a stack (e.g., compose-files/[HOSTNAME]/web-app/docker-compose.yml, compose-files/[HOSTNAME]/database/docker-compose.yml)? The latter is more flexible. The brief has been updated assuming the latter for more flexibility.
Remote .env Handling: When operating on a remote host, how is the final .env file placed in the remote stack's directory?
Option 1: Generate locally, then scp to remote, execute docker-compose, then ssh to remove remote .env.
Option 2: scp the master.env (or relevant parts) and a lightweight generation script to the remote host, execute generation remotely.
Option 3: Pass environment variables directly via ssh user@host "VAR=val docker-compose ...". (Can become unwieldy for many variables).
Initial thought: Option 1 seems like a good balance for shell scripting.
Python Usage Threshold: At what point of complexity should a feature be implemented in Python instead of Bash? (e.g., complex JSON parsing, state management beyond simple variables).

Target systems include Linux (ubuntu) and Macos and should accomidate this. 

Services should be standardized as far as layout and base services (sockey proxy, garbage collection). existing services should be kept. External data drives should be maintaind to allow remote backup. 

Docker Compose V3.8 should be the standard used. 

logging shuold be kept and accesable. Docker installation should be accomidated. 