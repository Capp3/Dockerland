# Docker Management TUI Helper (DMTH) - Active Context

## Project Overview
The DMTH project aims to create a Text User Interface (TUI) tool for managing Docker containers and Docker Compose stacks across multiple hosts (local and remote). The tool will simplify common Docker operations through an intuitive whiptail-based interface.

## Current Directory Structure
```
.
├── docs/
│   ├── projectbrief.md        # Project requirements and specifications
│   └── tasks.md               # Implementation plan and tracking
├── castle0/                   # Docker Compose stack
│   └── docker-compose.yml
├── knight0/                   # Docker Compose stack
│   ├── docker-compose.yml
│   └── docker-compose-combined.yml
├── knight1/                   # Docker Compose stack
│   └── docker-compose.yml
├── scout1/                    # Docker Compose stack
│   └── docker-compose.yml
└── .env.sample                # Environment variable template
```

## Existing Infrastructure
- Multiple Docker Compose stacks organized in separate directories
- Environment variables template for container configuration

## Current Phase
Planning phase - Detailed implementation plan created for a Level 3 complexity project. Next step is technology validation.

## Technical Requirements
- Primary Language: Bash/sh
- Alternative Language: Python (for complex operations)
- TUI Library: whiptail
- Dependencies: docker, docker-compose, ssh, scp, whiptail, hostname
- Configuration storage in ~/.dmth/ directory

## Key Components to Implement
1. Project Structure & Core Infrastructure
2. Host Management & Context Switching
3. Docker Compose Project Structure 
4. Environment Variable Management
5. Docker & Docker Compose Operations
6. TUI Navigation System
7. Integration & Testing

## Creative Components
Components requiring design decisions:
- TUI Navigation Flow
- Remote Host Communication Architecture
- Environment Variable Management System
