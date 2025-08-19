# Docker Management TUI Helper (DMTH) - System Architecture

## System Components

```mermaid
graph TB
    User((User)) -- Interacts --> TUI[TUI Interface<br>whiptail]
    TUI -- Executes --> ScriptCore[Core Script<br>Bash/sh]
    
    subgraph "Host Management"
        ScriptCore -- Connection --> LocalHost[Local Host]
    end
    
    subgraph "Configuration Management"
        ScriptCore -- Reads/Writes --> EnvFiles[Master .env]
        ScriptCore -- Generates --> TempEnv[Temporary .env files]
    end
    
    subgraph "Docker Operations"
        ScriptCore -- Commands --> DockerCLI[Docker CLI]
        ScriptCore -- Commands --> ComposeCLI[Docker Compose CLI]
        DockerCLI -- Manages --> Containers[Containers]
        ComposeCLI -- Manages --> Stacks[Compose Stacks]
    end

    subgraph "Installation"
        Makefile[Makefile] -- Creates --> Symlink[Symlink in PATH]
        Symlink -- Executes --> EntryScript[dockermenu Script]
        EntryScript -- Loads --> ScriptCore
    end
```

## Data Flow

```mermaid
sequenceDiagram
    participant User
    participant TUI as TUI (whiptail)
    participant Script as Script Core
    participant Config as Configuration Files
    participant Docker as Docker/Compose CLI
    participant Host as Local Host
    
    User->>TUI: Start Application
    TUI->>Script: Get Local Hostname
    Script->>Host: Get Hostname
    Host-->>Script: Return Hostname
    Script->>Host: Create Host Directory if Needed
    Script->>Host: Create Basic Compose File if Needed
    Script-->>TUI: Display Main Menu
    User->>TUI: Select Stack
    TUI->>Script: Request Stack List
    Script->>Host: List Compose Files in Host Directory
    Host-->>Script: Stack List
    Script-->>TUI: Display Stack Options
    User->>TUI: Select Operation
    TUI->>Script: Execute Operation
    Script->>Config: Read/Generate .env
    Script->>Docker: Execute Docker Command
    Docker->>Host: Perform Operation
    Host-->>Docker: Operation Result
    Docker-->>Script: Command Output
    Script-->>TUI: Display Result
    TUI-->>User: Show Operation Status
```

## Directory Structure

```mermaid
graph TD
    User[User Home] --> ConfigDir[~/.dmth/]
    ConfigDir --> MasterEnv[master.env]
    
    Projects[Project Root] --> HostDir[hostname/]
    HostDir --> Stack1[stack1/]
    HostDir --> Stack2[stack2/]
    HostDir --> RootCompose[docker-compose.yml]
    
    Stack1 --> Compose1[docker-compose.yml]
    Stack2 --> Compose2[docker-compose.yml]

    Bin[/usr/local/bin/] --> Symlink[dockermenu]
    Symlink -- "symlink to" --> EntryScript[PROJECT_ROOT/dockermenu]
```

## TUI Navigation Flow

```mermaid
stateDiagram-v2
    [*] --> MainMenu
    
    MainMenu --> ProjectSelection
    MainMenu --> GlobalSettings
    MainMenu --> Exit
    
    ProjectSelection --> ProjectSpecificMenu
    
    ProjectSpecificMenu --> ManageStacks
    ProjectSpecificMenu --> ViewContainers
    ProjectSpecificMenu --> PruneSystem
    ProjectSpecificMenu --> BackToMain
    
    ManageStacks --> StackList
    StackList --> StackActions
    
    StackActions --> ViewStatus
    StackActions --> StartStack
    StackActions --> StopStack
    StackActions --> RestartStack
    StackActions --> PullImages
    StackActions --> UpdateRecreate
    StackActions --> ViewLogs
    StackActions --> DownStack
    StackActions --> BackToStacks
    
    BackToMain --> MainMenu
    BackToStacks --> StackList
    
    ViewStatus --> StackActions
    StartStack --> StackActions
    StopStack --> StackActions
    RestartStack --> StackActions
    PullImages --> StackActions
    UpdateRecreate --> StackActions
    ViewLogs --> StackActions
    DownStack --> StackActions
    
    Exit --> [*]
``` 

## Installation System

```mermaid
graph TD
    Start[User: make install] --> CreateDir[Create ~/.dmth directory]
    CreateDir --> CopyConfig[Copy default config files]
    CopyConfig --> CreateSymlink[Create symlink to dockermenu]
    CreateSymlink --> SetPermissions[Set execute permissions]
    SetPermissions --> InstallComplete[Installation Complete]
    
    Uninstall[User: make uninstall] --> RemoveSymlink[Remove symlink]
    RemoveSymlink --> UninstallComplete[Uninstallation Complete]
```

## Docker Compose Standardization

```mermaid
graph TD
    StandardizationTool[Docker Compose Standardization Tool] --> VersionCheck[Check Compose Version]
    VersionCheck --> ServiceCheck[Validate Service Layout]
    ServiceCheck --> VolumeCheck[Configure External Data Volumes]
    VolumeCheck --> LoggingCheck[Ensure Proper Logging]
    LoggingCheck --> StandardizationComplete[Standardization Complete]
``` 
