# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains Docker image builders for creating comprehensive PHP development and production environments, particularly optimized for Laravel applications. The images support multiple PHP versions (8.3, 8.4) and include extensive tooling and configurations.

## Build Commands

### Building Docker Images

```bash
# Build PHP 8.3 image
./docker_build/buildDocker2404Php83.sh

# Build PHP 8.4 image  
./docker_build/buildDocker2404Php84.sh
```

Build configuration is controlled via `docker_build/buildDockerBase.settings.env`.

### Key Build Options
- `TARGETARCH`: Build for specific architecture (amd64, arm64)
- `NO_CACHE`: Set to "true" to disable Docker build cache
- `PUSH_IMAGE`: Set to "true" to push to registry after build
- `COMPRESS`: Enable compression (requires zstd)

## Architecture

### Multi-Stage Dockerfile
The `docker_build/ubuntuPhp.Dockerfile` uses multi-stage builds:
1. **Base stage**: Ubuntu 24.04 with system dependencies
2. **PHP stage**: Installs PHP and extensions
3. **Development tools stage**: Adds development utilities
4. **Final stage**: Optimized runtime image

### Key Components

#### Process Management
- **Supervisor**: Manages all services (PHP-FPM, Nginx, queue workers, etc.)
- Configuration: `files/supervisord_base.conf`
- Modified at runtime based on environment variables

#### Entry Point
- **start.sh**: Main entry script that:
  - Creates required directories
  - Configures PHP and Nginx based on environment variables
  - Sets up supervisor configuration
  - Manages Laravel-specific services

#### PHP Configuration
- **configure_php_nginx.sh**: Centralizes PHP and Nginx configuration
- Supports extensive PHP tuning via environment variables
- Configures OPcache, memory limits, timeouts, etc.

## Laravel Services

### Laravel Reverb (WebSocket Server)
- **Port**: 8080 (default, configurable via `REVERB_PORT`)
- **Enable**: Set `ENABLE_REVERB=TRUE`
- **Command**: `php artisan reverb:start --host=0.0.0.0 --port=8080`
- **Nginx proxy**: Routes `/app/` to Reverb server

### Laravel Horizon (Queue Management)
- **Enable**: Set `ENABLE_HORIZON=TRUE`
- **Note**: Disables simple queue workers when enabled

### Laravel Pulse (Application Monitoring)
- **Check**: Set `ENABLE_PULSE_CHECK=TRUE`
- **Work**: Set `ENABLE_PULSE_WORK=TRUE`

### Queue Workers
- **Simple Workers**: Set `ENABLE_SIMPLE_QUEUE=TRUE` and `SIMPLE_WORKER_NUM=5`
- **Note**: Disabled when Horizon is enabled

### Scheduled Tasks
- **Enable**: Set `ENABLE_CRONTAB=TRUE`
- Runs Laravel scheduler every minute

## Key Environment Variables

### Service Control
- `ENABLE_WEB`: Enable/disable web server (default: TRUE)
- `ENABLE_REVERB`: Enable Laravel Reverb WebSocket server (default: FALSE)
- `ENABLE_HORIZON`: Enable Laravel Horizon (default: FALSE)
- `ENABLE_SIMPLE_QUEUE`: Enable simple queue workers (default: FALSE)
- `ENABLE_CRONTAB`: Enable Laravel scheduler (default: FALSE)
- `ENABLE_SSH`: Enable SSH server (default: FALSE)

### PHP Configuration
- `PHP_VERSION`: PHP version to use (e.g., 8.3, 8.4)
- `PHP_MEMORY_LIMIT`: Memory limit (default: 3G)
- `PHP_UPLOAD_MAX_FILESIZE`: Upload size limit (default: 256M)
- `PHP_POST_MAX_SIZE`: POST size limit (default: 256M)
- `PHP_MAX_EXECUTION_TIME`: Max execution time (default: 600)
- `PHP_OPCACHE_MEMORY_CONSUMPTION`: OPcache memory (default: 512)

### PHP-FPM Configuration
- `FPM_MAX_CHILDREN`: Max child processes (default: 32)
- `FPM_START_SERVERS`: Initial servers (default: 4)
- `FPM_MIN_SPARE_SERVERS`: Min spare servers (default: 4)
- `FPM_MAX_SPARE_SERVERS`: Max spare servers (default: 8)

### Laravel Reverb Configuration
- `REVERB_PORT`: WebSocket server port (default: 8080)
- `REVERB_SCALING_ENABLED`: Enable Reverb scaling (default: FALSE)

### Development/Debug
- `ENABLE_DEBUG`: Enable Xdebug and pcov (default: FALSE)
- `LV_DO_CACHING`: Run Laravel caching commands (default: FALSE)

## Directory Structure

```
/site/
├── web/              # Laravel application root
│   ├── public/       # Web root
│   ├── .env          # Laravel environment file
│   └── .envDocker    # Docker-specific env vars
├── logs/
│   ├── php/          # PHP logs
│   └── nginx/        # Nginx logs
└── nginx/
    └── config/       # Nginx configuration
```

## Development Workflow

### Adding New Services
1. Add program definition to `supervisord_base.conf`
2. Add enable flag logic to `start.sh`
3. Update nginx proxy configuration if needed

### Modifying PHP Settings
1. Add environment variable to `start.sh`
2. Add sed replacement to `configure_php_nginx.sh`
3. Document in this file

### Testing Changes
```bash
# Build image locally
./docker_build/buildDocker2404Php83.sh

# Run with custom settings
docker run -e ENABLE_REVERB=TRUE -e REVERB_PORT=8080 [image-name]
```

## Important Notes

- The image includes extensive PHP extensions for Laravel compatibility
- Supports both development (with Xdebug) and production modes
- Includes modern shell (zsh with starship prompt) for development
- Automatically manages file permissions for the web user
- Health check endpoint available at port 8080 `/nginx_status`